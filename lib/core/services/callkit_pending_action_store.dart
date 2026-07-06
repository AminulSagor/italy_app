import 'dart:convert';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

class PendingAcceptedCall {
  const PendingAcceptedCall({
    required this.callId,
    required this.callData,
    required this.answerResponse,
    required this.createdAt,
  });

  final String callId;
  final Map<String, dynamic> callData;
  final Map<String, dynamic> answerResponse;
  final DateTime createdAt;
}

class CallkitPendingActionStore {
  CallkitPendingActionStore._();

  static const String _acceptedCallKey =
      'callkit_pending_accepted_call_v1';
  static const Duration _acceptedCallLifetime = Duration(minutes: 2);

  static Future<void> saveAcceptedCall({
    required String callId,
    required Map<String, dynamic> callData,
    Map<String, dynamic> answerResponse = const <String, dynamic>{},
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _acceptedCallKey,
      jsonEncode(<String, dynamic>{
        'callId': normalizedCallId,
        'callData': callData,
        'answerResponse': answerResponse,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  static Future<PendingAcceptedCall?> takeAcceptedCall() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    // The value can be written by the CallKit background isolate.
    await preferences.reload();

    final String? encoded = preferences.getString(_acceptedCallKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }

    await preferences.remove(_acceptedCallKey);

    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        return null;
      }

      final Map<String, dynamic> payload =
          Map<String, dynamic>.from(decoded);
      final String callId = payload['callId']?.toString().trim() ?? '';
      final DateTime? createdAt = DateTime.tryParse(
        payload['createdAt']?.toString() ?? '',
      );

      if (callId.isEmpty || createdAt == null) {
        return null;
      }

      if (DateTime.now().toUtc().difference(createdAt.toUtc()) >
          _acceptedCallLifetime) {
        return null;
      }

      return PendingAcceptedCall(
        callId: callId,
        callData: _toMap(payload['callData']),
        answerResponse: _toMap(payload['answerResponse']),
        createdAt: createdAt,
      );
    } catch (error, stackTrace) {
      dev.log(
        'Unable to decode pending accepted call',
        name: 'CallKitPending',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<void> clear() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.remove(_acceptedCallKey);
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}
