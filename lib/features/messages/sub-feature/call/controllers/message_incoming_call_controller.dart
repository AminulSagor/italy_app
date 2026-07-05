import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_socket_service.dart';

class MessageIncomingCallController extends GetxController {
  MessageIncomingCallController({
    required this.payload,
    required CallSocketService callSocketService,
    required CallAgoraService callAgoraService,
    required Future<void> Function(Map<String, dynamic>) onAccepted,
    required Future<void> Function() onFinished,
    required void Function(String) onStatusChanged,
  }) : _callSocketService = callSocketService,
       _callAgoraService = callAgoraService,
       _onAccepted = onAccepted,
       _onFinished = onFinished,
       _onStatusChanged = onStatusChanged;

  final Map<String, dynamic> payload;
  final CallSocketService _callSocketService;
  final CallAgoraService _callAgoraService;
  final Future<void> Function(Map<String, dynamic>) _onAccepted;
  final Future<void> Function() _onFinished;
  final void Function(String) _onStatusChanged;

  late final String callId;
  late final String conversationId;
  late final MessageCallType callType;
  late final MessageCallParticipantModel caller;

  final RxString statusLabel = 'incoming_call'.tr.obs;
  final RxBool isProcessing = false.obs;

  Timer? _timeoutTimer;
  bool _routeClosed = false;

  late final CallSocketListener _cancelledCallListener;
  late final CallSocketListener _endedCallListener;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> call = _toMap(payload['call']);
    final Map<String, dynamic> callerData = _toMap(payload['caller']);

    callId = call['id']?.toString() ?? '';
    conversationId = call['directConversationId']?.toString() ?? '';
    callType = MessageCallType.fromValue(call['callType']?.toString());
    caller = MessageCallParticipantModel.fromJson(callerData);

    _setStatus(
      callType.isVideo ? 'incoming_video_call'.tr : 'incoming_voice_call'.tr,
    );

    _cancelledCallListener = _handleRemoteCallClosed;
    _endedCallListener = _handleRemoteCallClosed;

    _callSocketService.addCancelledCallListener(_cancelledCallListener);
    _callSocketService.addEndedCallListener(_endedCallListener);

    _timeoutTimer = Timer(const Duration(minutes: 1), () {
      unawaited(_timeoutCall());
    });
  }

  Future<void> answerCall() async {
    if (isProcessing.value || callId.isEmpty || _routeClosed) {
      return;
    }

    isProcessing.value = true;
    _setStatus('loading'.tr);

    try {
      await _callAgoraService.ensurePermissionsForCall(
        isVideoCall: callType.isVideo,
      );

      _setStatus('Connecting...');
      final Map<String, dynamic> response = await _callSocketService.answerCall(
        callId: callId,
      );

      final MessageCallSessionModel session =
          MessageCallSessionModel.fromInitiateResponse(
            response: response,
            participant: caller,
          );

      if (session.id.isEmpty ||
          session.media.token.isEmpty ||
          session.media.channelName.isEmpty) {
        throw CallSocketException(
          code: 'invalid_answer_response'.tr,
          message: 'the_server_returned_invalid_call_credentials'.tr,
        );
      }

      _stopTimeout();
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      _routeClosed = true;
      isProcessing.value = false;
      await _onAccepted(response);
    } on CallAgoraException catch (error) {
      _resetIncomingStatus();
      Get.snackbar(
        'Permission required',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on CallSocketException catch (error) {
      _resetIncomingStatus();
      Get.snackbar(
        'unable_to_answer'.tr,
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _resetIncomingStatus();
      Get.snackbar(
        'unable_to_answer'.tr,
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectCall() async {
    if (isProcessing.value || callId.isEmpty || _routeClosed) {
      return;
    }

    isProcessing.value = true;
    _setStatus('gen_decline'.tr);

    try {
      await _callSocketService.rejectCall(callId: callId);
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      await _finishCall();
    } on CallSocketException catch (error) {
      Get.snackbar(
        'unable_to_decline'.tr,
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'unable_to_decline'.tr,
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _timeoutCall() async {
    if (_routeClosed || callId.isEmpty) {
      return;
    }

    isProcessing.value = true;
    _setStatus('missed_call'.tr);

    try {
      await _callSocketService.timeoutCall(callId: callId);
    } catch (_) {
      // The backend owns the same timeout, so a race is harmless.
    } finally {
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      await _finishCall();
      isProcessing.value = false;
    }
  }

  void closeFromNativeAction() {
    unawaited(_finishCall());
  }

  void _handleRemoteCallClosed(Map<String, dynamic> data) {
    final Map<String, dynamic> call = _toMap(data['call']);
    final String eventCallId =
        call['id']?.toString() ?? data['callId']?.toString() ?? '';

    if (eventCallId != callId) {
      return;
    }

    unawaited(CallkitIncomingService.endNativeSubsystemOnly(callId));
    unawaited(_finishCall());
  }

  void _resetIncomingStatus() {
    _setStatus(
      callType.isVideo ? 'incoming_video_call'.tr : 'incoming_voice_call'.tr,
    );
    isProcessing.value = false;
  }

  void _setStatus(String status) {
    statusLabel.value = status;
    _onStatusChanged(status);
  }

  void _stopTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  Future<void> _finishCall() async {
    if (_routeClosed) {
      return;
    }

    _routeClosed = true;
    _stopTimeout();
    await _onFinished();
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

  @override
  void onClose() {
    _stopTimeout();
    _callSocketService.removeCancelledCallListener(_cancelledCallListener);
    _callSocketService.removeEndedCallListener(_endedCallListener);
    super.onClose();
  }
}
