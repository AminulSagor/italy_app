import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/messages/sub-feature/call/service/call_socket_service.dart';
import 'callkit_pending_action_store.dart';
import 'token_service.dart';

@pragma('vm:entry-point')
Future<void> callkitBackgroundActionHandler(CallEvent event) async {
  debugPrint('[CallKitBackground] Received ${event.runtimeType}');

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
  final String callId =
      extraCallId.isNotEmpty ? extraCallId : callKitParams.id.trim();

  if (callId.isEmpty) {
    debugPrint('[CallKitBackground] Action ignored: callId missing');
    return;
  }

  await _runBackgroundAction((CallSocketService callService) async {
    if (event is CallEventActionCallAccept) {
      debugPrint('[CallKitBackground] Answering over HTTP callId=$callId');

      final Map<String, dynamic> answerResponse =
          await callService.answerCallOverHttp(callId: callId);

      await CallkitPendingActionStore.saveAcceptedCall(
        callId: callId,
        callData: extra,
        answerResponse: answerResponse,
      );

      debugPrint(
        '[CallKitBackground] Answer saved for foreground restoration',
      );
      return;
    }

    if (event is CallEventActionCallDecline) {
      debugPrint('[CallKitBackground] Rejecting over HTTP callId=$callId');
      await callService.rejectCallOverHttp(callId: callId);
      await CallkitPendingActionStore.clear();
      return;
    }

    final Map<String, dynamic> current =
        await callService.fetchCall(callId: callId);
    final Map<String, dynamic> call = _extractExtra(current['call']);
    final String status = call['status']?.toString() ?? '';

    // Remote termination also closes native CallKit. Only send a local end
    // request when the authoritative server state is still active.
    if (status == 'active') {
      await callService.endCallOverHttp(callId: callId);
    }
  });
}

Future<void> _runBackgroundAction(
  Future<void> Function(CallSocketService callService) action,
) async {
  try {
    await dotenv.load(fileName: '.env');
    final CallSocketService callService = CallSocketService(
      tokenService: TokenService(),
    );
    await action(callService);
  } catch (error, stackTrace) {
    debugPrint('[CallKitBackground] Action failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

CallKitParams? _callKitParamsFromEvent(CallEvent event) {
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
