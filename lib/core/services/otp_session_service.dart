import 'dart:convert';

import 'package:get/get.dart';

import '../utils/app_logger.dart';
import 'storage_service.dart';

enum OtpSessionFlow { accountVerification, passwordReset }

class PendingOtpSession {
  const PendingOtpSession({
    required this.flow,
    required this.identifier,
    required this.maskedIdentifier,
    required this.isEmail,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final OtpSessionFlow flow;
  final String identifier;
  final String maskedIdentifier;
  final bool isEmail;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  bool get isValid =>
      identifier.trim().isNotEmpty && expiresAt.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => <String, dynamic>{
    'flow': flow.name,
    'identifier': identifier,
    'maskedIdentifier': maskedIdentifier,
    'isEmail': isEmail,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'resendAvailableAt': resendAvailableAt.toUtc().toIso8601String(),
  };

  factory PendingOtpSession.fromJson(Map<String, dynamic> json) {
    return PendingOtpSession(
      flow: OtpSessionFlow.values.byName(json['flow']?.toString() ?? ''),
      identifier: json['identifier']?.toString().trim() ?? '',
      maskedIdentifier: json['maskedIdentifier']?.toString().trim() ?? '',
      isEmail: json['isEmail'] == true,
      expiresAt: DateTime.parse(json['expiresAt']?.toString() ?? '').toLocal(),
      resendAvailableAt: DateTime.parse(
        json['resendAvailableAt']?.toString() ?? '',
      ).toLocal(),
    );
  }
}

class OtpSessionService extends GetxService {
  OtpSessionService(this._storageService);

  static const String _storageKey = 'pendingOtpSession';
  static const Duration otpLifetime = Duration(minutes: 10);
  static const Duration resendCooldown = Duration(minutes: 3);

  final StorageService _storageService;
  PendingOtpSession? _current;
  bool _discardedExpiredSession = false;

  bool get discardedExpiredSession => _discardedExpiredSession;

  PendingOtpSession? get currentSession {
    final PendingOtpSession? session = _current;
    return session != null && session.isValid ? session : null;
  }

  Future<PendingOtpSession?> getValidSession() async {
    final PendingOtpSession? session = _current;
    if (session == null) {
      return null;
    }
    if (!session.isValid) {
      _discardedExpiredSession = true;
      await clear();
      return null;
    }
    return session;
  }

  Future<OtpSessionService> init() async {
    final String? encoded = _storageService.readString(_storageKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return this;
    }

    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('OTP session must be a JSON object.');
      }

      final PendingOtpSession session = PendingOtpSession.fromJson(decoded);
      if (!session.isValid) {
        _discardedExpiredSession = true;
        await clear();
        return this;
      }

      _current = session;
    } catch (error, stackTrace) {
      AppLogger.log(
        'Discarding an invalid persisted OTP session',
        error: error,
        stackTrace: stackTrace,
        name: 'OtpSessionService',
      );
      await clear();
    }

    return this;
  }

  Future<PendingOtpSession> save({
    required OtpSessionFlow flow,
    required String identifier,
    required String maskedIdentifier,
    required bool isEmail,
  }) async {
    final DateTime now = DateTime.now();
    final PendingOtpSession session = PendingOtpSession(
      flow: flow,
      identifier: identifier.trim(),
      maskedIdentifier: maskedIdentifier.trim(),
      isEmail: isEmail,
      expiresAt: now.add(otpLifetime),
      resendAvailableAt: now.add(resendCooldown),
    );

    await _storageService.writeString(
      _storageKey,
      jsonEncode(session.toJson()),
    );
    _current = session;
    return session;
  }

  Future<void> clear() async {
    _current = null;
    await _storageService.remove(_storageKey);
  }
}
