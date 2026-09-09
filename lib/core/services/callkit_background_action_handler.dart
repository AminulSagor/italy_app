import 'dart:io';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/messages/sub-feature/call/service/call_socket_service.dart';
import 'callkit_pending_action_store.dart';
import 'token_service.dart';

@pragma('vm:entry-point')
Future<void> callkitBackgroundActionHandler(CallEvent event) async {
  DartPluginRegistrant.ensureInitialized();

  if (event is CallEventActionCallTimeout) {
    final String callId = event.id.trim();
    if (callId.isEmpty) {
      return;
    }

    await _runBackgroundAction((CallSocketService callService) async {
      await callService.timeoutCallOverHttp(callId: callId);
      await CallkitPendingActionStore.clear();
    });
    return;
  }

  final CallKitParams? callKitParams = _callKitParamsFromEvent(event);
  if (callKitParams == null) {
    return;
  }

  final Map<String, dynamic> extra = _extractExtra(callKitParams.extra);
  final String extraCallId = extra['callId']?.toString().trim() ?? '';
  final String callId = extraCallId.isNotEmpty
      ? extraCallId
      : callKitParams.id.trim();

  if (callId.isEmpty) {
    return;
  }

  if (event is CallEventActionCallAccept) {
    // Persist first so the main isolate can restore the media session even if
    // iOS launches this callback while the app is terminated.
    await CallkitPendingActionStore.saveAcceptedCall(
      callId: callId,
      callData: extra,
    );

    await _runBackgroundAction((CallSocketService callService) async {
      final Map<String, dynamic> answerResponse = await callService
          .answerCallOverHttp(callId: callId);
      await CallkitPendingActionStore.saveAcceptedCall(
        callId: callId,
        callData: extra,
        answerResponse: answerResponse,
      );
    });
    return;
  }

  if (event is CallEventActionCallIncoming && Platform.isIOS) {
    // PushKit, unlike the FCM background handler, reaches this callback when
    // iOS wakes a terminated app. ACK as soon as CallKit is visible so the
    // caller transitions from "calling" to "ringing".
    await _runBackgroundAction((CallSocketService callService) async {
      await callService.acknowledgeIncomingCallOverHttp(callId: callId);
    });
    return;
  }

  if (event is CallEventActionCallDecline) {
    // Keep a durable retry before starting network I/O. iOS may suspend a
    // terminated/background process before the request reaches the server.
    await CallkitPendingActionStore.saveDeclinedCall(
      callId: callId,
      callData: extra,
    );
  }

  if (event is CallEventActionCallEnded) {
    // The local CallKit end has won over any in-flight accepted restoration.
    // Clear it before network reconciliation so a later app resume cannot
    // join Agora for a call that the user already hung up.
    await CallkitPendingActionStore.clearAcceptedCall();
    await CallkitPendingActionStore.saveEndedCall(
      callId: callId,
      callData: extra,
    );
  }

  await _runBackgroundAction((CallSocketService callService) async {
    if (event is CallEventActionCallDecline) {
      try {
        await callService.rejectCallOverHttp(callId: callId);
      } on CallSocketException catch (error) {
        if (error.code != 'CALL_NOT_FOUND') {
          rethrow;
        }
        // The server has already removed this stale call. Treat that as a
        // completed decline and clear the persisted retry action.
      }
      await CallkitPendingActionStore.clearDeclinedCall();
      return;
    }

    if (event is CallEventActionCallEnded) {
      // The endpoint is idempotent. Avoid a preliminary GET: iOS may suspend
      // the lock-screen execution window between the GET and the actual end.
      try {
        await callService.endCallOverHttp(callId: callId);
      } on CallSocketException catch (error) {
        if (error.code != 'CALL_NOT_FOUND' &&
            error.code != 'CALL_CANNOT_BE_ENDED') {
          rethrow;
        }
      }
      await CallkitPendingActionStore.clearEndedCall();
    }
  });
}

Future<bool> _runBackgroundAction(
  Future<void> Function(CallSocketService callService) action,
) async {
  try {
    developer.log('background action begin', name: 'CallLifecycle.CallKit');
    await Firebase.initializeApp();
    await dotenv.load(fileName: '.env');
    final CallSocketService callService = CallSocketService(
      tokenService: TokenService(),
    );
    await action(callService);
    developer.log('background action complete', name: 'CallLifecycle.CallKit');
    return true;
  } catch (error, stackTrace) {
    developer.log(
      'background action failed',
      name: 'CallLifecycle.CallKit',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

CallKitParams? _callKitParamsFromEvent(CallEvent event) {
  if (event is CallEventActionCallIncoming) {
    return event.callKitParams;
  }

  if (event is CallEventActionCallAccept) {
    return event.callKitParams;
  }

  if (event is CallEventActionCallDecline) {
    return event.callKitParams;
  }

  if (event is CallEventActionCallEnded) {
    return event.callKitParams;
  }

  return null;
}

Map<String, dynamic> _extractExtra(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}
