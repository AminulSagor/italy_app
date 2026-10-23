// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:video_player/video_player.dart';

enum HlsPlaybackRecoveryReason {
  accessExpiring,
  bufferingStalled,
  playerError,
  appResumed,
  manual,
}

typedef HlsPlaybackRecoveryCallback =
    Future<bool> Function({
      required HlsPlaybackRecoveryReason reason,
      required bool refreshAccess,
    });

/// Coordinates all automatic HLS recovery triggers for a single player.
///
/// Controller creation remains with the owning widget, while this class owns
/// expiry, buffering, retry, and mutual-exclusion state. This keeps access
/// refreshes and controller swaps from racing each other.
class HlsPlaybackRecoveryCoordinator {
  HlsPlaybackRecoveryCoordinator({
    required HlsPlaybackRecoveryCallback onRecover,
    required void Function(HlsPlaybackRecoveryReason reason)
    onRecoveryExhausted,
    Duration expiryLeadTime = const Duration(minutes: 1),
    Duration stallTimeout = const Duration(seconds: 10),
    Duration retryBaseDelay = const Duration(seconds: 3),
    Duration automaticAttemptWindow = const Duration(minutes: 1),
    Duration healthyPlaybackResetAfter = const Duration(seconds: 30),
    int maximumAutomaticAttempts = 2,
    DateTime Function()? now,
  }) : _onRecover = onRecover,
       _onRecoveryExhausted = onRecoveryExhausted,
       _expiryLeadTime = expiryLeadTime,
       _stallTimeout = stallTimeout,
       _retryBaseDelay = retryBaseDelay,
       _automaticAttemptWindow = automaticAttemptWindow,
       _healthyPlaybackResetAfter = healthyPlaybackResetAfter,
       _maximumAutomaticAttempts = maximumAutomaticAttempts,
       _now = now ?? DateTime.now;

  final HlsPlaybackRecoveryCallback _onRecover;
  final void Function(HlsPlaybackRecoveryReason reason) _onRecoveryExhausted;
  final Duration _expiryLeadTime;
  final Duration _stallTimeout;
  final Duration _retryBaseDelay;
  final Duration _automaticAttemptWindow;
  final Duration _healthyPlaybackResetAfter;
  final int _maximumAutomaticAttempts;
  final DateTime Function() _now;

  Timer? _accessRefreshTimer;
  Timer? _stallTimer;
  Timer? _retryTimer;
  DateTime? _accessExpiresAt;
  DateTime? _healthyPlaybackStartedAt;
  Duration _lastHealthyPosition = Duration.zero;
  final List<DateTime> _automaticAttempts = <DateTime>[];
  bool _requiresSignedAccess = false;
  bool _operationInProgress = false;
  bool _automaticRecoveryBlocked = false;
  bool _disposed = false;
  int _generation = 0;

  bool get isBusy => _operationInProgress;

  bool get isAccessExpiredOrNearExpiry {
    if (!_requiresSignedAccess) {
      return false;
    }

    final DateTime? expiresAt = _accessExpiresAt;
    if (expiresAt == null) {
      return true;
    }

    return !_now().isBefore(expiresAt.subtract(_expiryLeadTime));
  }

  void updateAccess({
    required DateTime? expiresAt,
    required bool requiresSignedAccess,
  }) {
    if (_disposed) {
      return;
    }

    _accessExpiresAt = expiresAt;
    _requiresSignedAccess = requiresSignedAccess;
    _accessRefreshTimer?.cancel();
    _accessRefreshTimer = null;

    if (!requiresSignedAccess) {
      return;
    }

    final DateTime? expiry = expiresAt;
    final Duration delay = expiry == null
        ? Duration.zero
        : expiry.subtract(_expiryLeadTime).difference(_now());

    _accessRefreshTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => unawaited(
        _triggerAutomatic(
          reason: HlsPlaybackRecoveryReason.accessExpiring,
          refreshAccess: true,
        ),
      ),
    );
  }

  void updatePlaybackValue(VideoPlayerValue value) {
    if (_disposed) {
      return;
    }

    if (value.hasError) {
      _stallTimer?.cancel();
      _stallTimer = null;
      unawaited(
        _triggerAutomatic(
          reason: HlsPlaybackRecoveryReason.playerError,
          refreshAccess: isAccessExpiredOrNearExpiry,
        ),
      );
      return;
    }

    if (value.isBuffering) {
      _healthyPlaybackStartedAt = null;
      _stallTimer ??= Timer(_stallTimeout, () {
        _stallTimer = null;
        unawaited(
          _triggerAutomatic(
            reason: HlsPlaybackRecoveryReason.bufferingStalled,
            refreshAccess: isAccessExpiredOrNearExpiry,
          ),
        );
      });
      return;
    }

    _stallTimer?.cancel();
    _stallTimer = null;

    if (!value.isPlaying || value.position <= _lastHealthyPosition) {
      _healthyPlaybackStartedAt = null;
      _lastHealthyPosition = value.position;
      return;
    }

    _lastHealthyPosition = value.position;
    _healthyPlaybackStartedAt ??= _now();
    if (_now().difference(_healthyPlaybackStartedAt!) >=
        _healthyPlaybackResetAfter) {
      _automaticAttempts.clear();
      _automaticRecoveryBlocked = false;
      _healthyPlaybackStartedAt = _now();
    }
  }

  void handleAppResumed() {
    if (_disposed || !_requiresSignedAccess) {
      return;
    }

    if (isAccessExpiredOrNearExpiry) {
      unawaited(
        _triggerAutomatic(
          reason: HlsPlaybackRecoveryReason.appResumed,
          refreshAccess: true,
        ),
      );
      return;
    }

    // Recalculate from the server-provided wall-clock expiry after suspension.
    updateAccess(
      expiresAt: _accessExpiresAt,
      requiresSignedAccess: _requiresSignedAccess,
    );
  }

  Future<bool> recoverNow({bool refreshAccess = true}) async {
    if (_disposed) {
      return false;
    }

    _automaticAttempts.clear();
    _automaticRecoveryBlocked = false;
    _retryTimer?.cancel();
    _retryTimer = null;

    return _runExclusive(
      () => _onRecover(
        reason: HlsPlaybackRecoveryReason.manual,
        refreshAccess: refreshAccess,
      ),
    );
  }

  /// Runs user-initiated controller work (such as a quality change) under the
  /// same lock used by automatic recovery.
  Future<bool> runExclusive(Future<bool> Function() operation) {
    return _runExclusive(operation);
  }

  Future<bool> _triggerAutomatic({
    required HlsPlaybackRecoveryReason reason,
    required bool refreshAccess,
  }) async {
    if (_disposed || _retryTimer != null || _automaticRecoveryBlocked) {
      return false;
    }

    if (_operationInProgress) {
      if (reason == HlsPlaybackRecoveryReason.accessExpiring) {
        _accessRefreshTimer?.cancel();
        _accessRefreshTimer = Timer(const Duration(seconds: 1), () {
          unawaited(
            _triggerAutomatic(reason: reason, refreshAccess: refreshAccess),
          );
        });
      }
      return false;
    }

    final DateTime now = _now();
    _automaticAttempts.removeWhere(
      (DateTime attempt) => now.difference(attempt) > _automaticAttemptWindow,
    );

    if (_automaticAttempts.length >= _maximumAutomaticAttempts) {
      _automaticRecoveryBlocked = true;
      _onRecoveryExhausted(reason);
      return false;
    }

    final bool shouldRefreshAccess =
        refreshAccess || _automaticAttempts.isNotEmpty;
    _automaticAttempts.add(now);
    final int generation = _generation;
    final bool succeeded = await _runExclusive(
      () => _onRecover(reason: reason, refreshAccess: shouldRefreshAccess),
    );

    if (_disposed || generation != _generation || succeeded) {
      return succeeded;
    }

    if (_automaticAttempts.length >= _maximumAutomaticAttempts) {
      _automaticRecoveryBlocked = true;
      _onRecoveryExhausted(reason);
      return false;
    }

    final Duration retryDelay = _retryBaseDelay * _automaticAttempts.length;
    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      unawaited(
        _triggerAutomatic(
          reason: reason,
          // A second attempt always asks the API for fresh credentials.
          refreshAccess: true,
        ),
      );
    });
    return false;
  }

  Future<bool> _runExclusive(Future<bool> Function() operation) async {
    if (_disposed || _operationInProgress) {
      return false;
    }

    _operationInProgress = true;
    _stallTimer?.cancel();
    _stallTimer = null;
    try {
      return await operation();
    } catch (_) {
      return false;
    } finally {
      _operationInProgress = false;
    }
  }

  void reset() {
    _generation++;
    _accessRefreshTimer?.cancel();
    _stallTimer?.cancel();
    _retryTimer?.cancel();
    _accessRefreshTimer = null;
    _stallTimer = null;
    _retryTimer = null;
    _accessExpiresAt = null;
    _requiresSignedAccess = false;
    _healthyPlaybackStartedAt = null;
    _lastHealthyPosition = Duration.zero;
    _automaticAttempts.clear();
    _automaticRecoveryBlocked = false;
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    reset();
    _disposed = true;
  }
}
