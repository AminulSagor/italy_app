import 'dart:convert';

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

class PendingDeclinedCall {
  const PendingDeclinedCall({
    required this.callId,
    required this.callData,
    required this.createdAt,
  });

  final String callId;
  final Map<String, dynamic> callData;
  final DateTime createdAt;
}

class PendingEndedCall {
  const PendingEndedCall({
    required this.callId,
    required this.callData,
    required this.createdAt,
  });

  final String callId;
  final Map<String, dynamic> callData;
  final DateTime createdAt;
}

class CallkitPendingActionStore {
  CallkitPendingActionStore._();

  static const String _acceptedCallKey = 'callkit_pending_accepted_call_v1';
  static const String _declinedCallKey = 'callkit_pending_declined_call_v1';
  static const String _endedCallKey = 'callkit_pending_ended_call_v1';
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

    final SharedPreferences preferences = await SharedPreferences.getInstance();

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

  static Future<void> saveDeclinedCall({
    required String callId,
    required Map<String, dynamic> callData,
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _declinedCallKey,
      jsonEncode(<String, dynamic>{
        'callId': normalizedCallId,
        'callData': callData,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  static Future<void> saveEndedCall({
    required String callId,
    required Map<String, dynamic> callData,
  }) async {
    final String normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _endedCallKey,
      jsonEncode(<String, dynamic>{
        'callId': normalizedCallId,
        'callData': callData,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  static Future<PendingAcceptedCall?> takeAcceptedCall({
    bool requireAnswerResponse = false,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    // The value can be written by the CallKit background isolate.
    await preferences.reload();

    final String? encoded = preferences.getString(_acceptedCallKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        await preferences.remove(_acceptedCallKey);
        return null;
      }

      final Map<String, dynamic> payload = Map<String, dynamic>.from(decoded);
      final String callId = payload['callId']?.toString().trim() ?? '';
      final DateTime? createdAt = DateTime.tryParse(
        payload['createdAt']?.toString() ?? '',
      );

      if (callId.isEmpty || createdAt == null) {
        await preferences.remove(_acceptedCallKey);
        return null;
      }

      if (DateTime.now().toUtc().difference(createdAt.toUtc()) >
          _acceptedCallLifetime) {
        await preferences.remove(_acceptedCallKey);
        return null;
      }

      final Map<String, dynamic> answerResponse = _toMap(
        payload['answerResponse'],
      );
      if (requireAnswerResponse && answerResponse.isEmpty) {
        return null;
      }

      await preferences.remove(_acceptedCallKey);

      return PendingAcceptedCall(
        callId: callId,
        callData: _toMap(payload['callData']),
        answerResponse: answerResponse,
        createdAt: createdAt,
      );
    } catch (_) {
      await preferences.remove(_acceptedCallKey);
      return null;
    }
  }

  static Future<PendingDeclinedCall?> takeDeclinedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();

    final String? encoded = preferences.getString(_declinedCallKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }

    await preferences.remove(_declinedCallKey);

    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        return null;
      }

      final Map<String, dynamic> payload = Map<String, dynamic>.from(decoded);
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

      return PendingDeclinedCall(
        callId: callId,
        callData: _toMap(payload['callData']),
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<PendingEndedCall?> takeEndedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();

    final String? encoded = preferences.getString(_endedCallKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }

    await preferences.remove(_endedCallKey);

    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        return null;
      }

      final Map<String, dynamic> payload = Map<String, dynamic>.from(decoded);
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

      return PendingEndedCall(
        callId: callId,
        callData: _toMap(payload['callData']),
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_acceptedCallKey);
    await preferences.remove(_declinedCallKey);
    await preferences.remove(_endedCallKey);
  }

  static Future<void> clearAcceptedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_acceptedCallKey);
  }

  static Future<bool> hasAcceptedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences.getString(_acceptedCallKey)?.trim().isNotEmpty == true;
  }

  static Future<void> clearDeclinedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_declinedCallKey);
  }

  static Future<void> clearEndedCall() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_endedCallKey);
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
