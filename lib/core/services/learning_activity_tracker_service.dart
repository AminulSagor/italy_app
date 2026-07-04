import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/learning_activity_models.dart';
import 'api_error_handler.dart';
import 'learning_activity_api_service.dart';
import 'storage_service.dart';

class LearningActivityTrackerService extends GetxService
    with WidgetsBindingObserver {
  LearningActivityTrackerService({
    required LearningActivityApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  static const String _pendingStorageKey = 'pendingLearningActivityTime';
  static const Duration _heartbeatDuration = Duration(seconds: 10);
  static const int _minimumRecordSeconds = 1;

  final LearningActivityApiService _apiService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  final List<_LearningPageScope> _visibleScopes = <_LearningPageScope>[];

  Timer? _heartbeat;
  Future<void> _operationQueue = Future<void>.value();
  LearningActivityKind? _currentKind;
  String? _currentSourceId;
  String? _currentScopeToken;
  DateTime? _startedAt;
  bool _isForeground = true;
  bool _isClosed = false;

  Future<LearningActivityTrackerService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _heartbeat = Timer.periodic(
      _heartbeatDuration,
      (_) => unawaited(flushAndSync()),
    );
    return this;
  }

  Future<void> startSession() {
    return _enqueue(() async {
      await _syncPendingInternal();
      await _activateVisibleScopeInternal();
    });
  }

  Future<void> endSession() {
    return _enqueue(() async {
      await _flushCurrentInternal(clearActivity: true);
      await _syncPendingInternal();
      _visibleScopes.clear();
      await _writePending(<LearningActivityTimeEntryModel>[]);
    });
  }

  Future<void> discardSession() {
    return _enqueue(() async {
      _currentKind = null;
      _currentSourceId = null;
      _currentScopeToken = null;
      _startedAt = null;
      _visibleScopes.clear();
      await _writePending(<LearningActivityTimeEntryModel>[]);
    });
  }

  Future<void> flushAndSync() {
    return _enqueue(() async {
      await _flushCurrentInternal(clearActivity: false);
      await _syncPendingInternal();
    });
  }

  Future<void> syncPending() => _enqueue(_syncPendingInternal);

  void setPageScope({
    required String token,
    required LearningActivityKind activityKind,
    required String sourceId,
    required bool isVisible,
  }) {
    unawaited(
      _enqueue(() async {
        _visibleScopes.removeWhere(
          (_LearningPageScope scope) => scope.token == token,
        );
        if (isVisible) {
          _visibleScopes.add(
            _LearningPageScope(
              token: token,
              activityKind: activityKind,
              sourceId: sourceId,
            ),
          );
        }
        await _activateVisibleScopeInternal();
      }),
    );
  }

  void removePageScope(String token) {
    unawaited(
      _enqueue(() async {
        _visibleScopes.removeWhere(
          (_LearningPageScope scope) => scope.token == token,
        );
        await _activateVisibleScopeInternal();
      }),
    );
  }

  // Learning time is controlled exclusively by LearningActivityPageScope.
  // These methods remain for existing navigation callers but do not infer
  // activity from shell tabs or broad route prefixes.
  void setShellTab(int _) {}

  void handleRoute(String? _) {}

  Future<void> _activateVisibleScopeInternal() async {
    final _LearningPageScope? scope = _isForeground && _visibleScopes.isNotEmpty
        ? _visibleScopes.last
        : null;

    if (scope?.token == _currentScopeToken &&
        scope?.activityKind == _currentKind &&
        scope?.sourceId == _currentSourceId) {
      if (scope != null && _startedAt == null) {
        _startedAt = DateTime.now();
      }
      return;
    }

    await _flushCurrentInternal(clearActivity: true);
    _currentScopeToken = scope?.token;
    _currentKind = scope?.activityKind;
    _currentSourceId = scope?.sourceId;
    _startedAt = scope == null ? null : DateTime.now();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _isForeground = false;
      unawaited(
        _enqueue(() async {
          await _flushCurrentInternal(clearActivity: true);
          await _syncPendingInternal();
        }),
      );
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      unawaited(
        _enqueue(() async {
          await _activateVisibleScopeInternal();
          await _syncPendingInternal();
        }),
      );
    }
  }

  Future<void> _flushCurrentInternal({required bool clearActivity}) async {
    final LearningActivityKind? kind = _currentKind;
    final DateTime? startedAt = _startedAt;
    final String? sourceId = _currentSourceId;
    final DateTime endedAt = DateTime.now();

    if (clearActivity) {
      _currentKind = null;
      _currentSourceId = null;
      _currentScopeToken = null;
      _startedAt = null;
    } else {
      _startedAt = kind != null && _isForeground ? endedAt : null;
    }

    if (kind == null || startedAt == null) return;

    final int durationSeconds = endedAt.difference(startedAt).inSeconds;
    if (durationSeconds < _minimumRecordSeconds) return;

    await _appendPending(
      LearningActivityTimeEntryModel(
        eventId: _uuid.v4(),
        activityKind: kind,
        sourceId: sourceId,
        durationSeconds: durationSeconds.clamp(1, 3600).toInt(),
        startedAt: startedAt,
        endedAt: endedAt,
        clientActivityDate: _dateOnly(startedAt.toLocal()),
      ),
    );
  }

  Future<void> _syncPendingInternal() async {
    final List<LearningActivityTimeEntryModel> pending = _readPending();
    if (pending.isEmpty) return;

    final List<LearningActivityTimeEntryModel> remaining =
        <LearningActivityTimeEntryModel>[];

    for (final LearningActivityTimeEntryModel entry in pending) {
      final ApiResult<bool> result = await ApiErrorHandler.call<bool>(
        () => _apiService.recordTime(entry),
        showError: false,
      );
      if (!result.isSuccess) {
        remaining.add(entry);
        dev.log(
          'Unable to upload learning activity: ${result.error}',
          name: 'LearningActivityTracker',
        );
      }
    }

    await _writePending(remaining);
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final Completer<void> completer = Completer<void>();
    _operationQueue = _operationQueue.then((_) async {
      if (_isClosed) {
        completer.complete();
        return;
      }
      try {
        await operation();
      } catch (error, stackTrace) {
        dev.log(
          'Learning activity operation failed',
          error: error,
          stackTrace: stackTrace,
          name: 'LearningActivityTracker',
        );
      } finally {
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }

  List<LearningActivityTimeEntryModel> _readPending() {
    final String? raw = _storageService.readString(_pendingStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <LearningActivityTimeEntryModel>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return <LearningActivityTimeEntryModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (Map item) => LearningActivityTimeEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: true);
    } catch (_) {
      return <LearningActivityTimeEntryModel>[];
    }
  }

  Future<void> _appendPending(LearningActivityTimeEntryModel entry) async {
    final List<LearningActivityTimeEntryModel> pending = _readPending();
    pending.add(entry);
    await _writePending(pending);
  }

  Future<void> _writePending(
    List<LearningActivityTimeEntryModel> entries,
  ) async {
    await _storageService.writeString(
      _pendingStorageKey,
      jsonEncode(
        entries
            .map((LearningActivityTimeEntryModel item) => item.toJson())
            .toList(growable: false),
      ),
    );
  }

  String _dateOnly(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  void onClose() {
    _heartbeat?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(
      flushAndSync().whenComplete(() {
        _isClosed = true;
      }),
    );
    super.onClose();
  }
}

class _LearningPageScope {
  const _LearningPageScope({
    required this.token,
    required this.activityKind,
    required this.sourceId,
  });

  final String token;
  final LearningActivityKind activityKind;
  final String sourceId;
}
