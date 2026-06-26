import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';

import '../../features/messages/sub-feature/call/service/call_socket_service.dart';
import 'token_service.dart';

@pragma('vm:entry-point')
Future<void> callkitBackgroundActionHandler(
    CallEvent event,
    ) async {
  debugPrint(
    '[CallKitBackground] Received ${event.runtimeType}',
  );

  if (event is! CallEventActionCallDecline) {
    return;
  }

  final Map<String, dynamic> extra = _extractExtra(
    event.callKitParams.extra,
  );

  final String callId =
      extra['callId']?.toString() ??
          event.callKitParams.id?.toString() ??
          '';

  if (callId.trim().isEmpty) {
    debugPrint(
      '[CallKitBackground] Decline ignored: callId missing',
    );
    return;
  }

  try {
    /*
     * The CallKit background callback runs in a separate Dart
     * isolate, so dotenv and dependencies must be initialized here.
     */
    await dotenv.load(fileName: '.env');

    final TokenService tokenService = TokenService();

    final CallSocketService socketService =
    CallSocketService(
      tokenService: tokenService,
    );

    try {
      debugPrint(
        '[CallKitBackground] Sending call:reject '
            'callId=$callId',
      );

      final Map<String, dynamic> response =
      await socketService.rejectCall(
        callId: callId,
      );

      debugPrint(
        '[CallKitBackground] Reject completed: $response',
      );
    } finally {
      await socketService.disconnect();
    }
  } catch (error, stackTrace) {
    debugPrint(
      '[CallKitBackground] Reject failed: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }
}

Map<String, dynamic> _extractExtra(
    dynamic value,
    ) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}