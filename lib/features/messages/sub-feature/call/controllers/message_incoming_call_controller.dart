import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_socket_service.dart';
import '../views/message_call_view.dart';
import 'message_call_controller.dart';

class MessageIncomingCallController extends GetxController {
  MessageIncomingCallController({
    required this.payload,
    required CallSocketService callSocketService,
  }) : _callSocketService = callSocketService;

  final Map<String, dynamic> payload;
  final CallSocketService _callSocketService;

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

    statusLabel.value =
        callType.isVideo ? 'incoming_video_call'.tr : 'incoming_voice_call'.tr;

    _cancelledCallListener = _handleRemoteCallClosed;
    _endedCallListener = _handleRemoteCallClosed;

    _callSocketService.addCancelledCallListener(_cancelledCallListener);
    _callSocketService.addEndedCallListener(_endedCallListener);

    _timeoutTimer = Timer(const Duration(minutes: 1), () {
      unawaited(_timeoutCall());
    });
  }

  Future<void> answerCall() async {
    if (isProcessing.value || callId.isEmpty) {
      return;
    }

    isProcessing.value = true;
    statusLabel.value = 'loading'.tr;

    try {
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

      Get.off<void>(
        () => const MessageCallView(),
        binding: BindingsBuilder(() {
          Get.put<MessageCallController>(
            MessageCallController(
              conversationId: session.conversationId,
              callType: session.type,
              participant: caller,
              callSocketService: _callSocketService,
              callAgoraService: Get.find<CallAgoraService>(),
              initialSession: session,
            ),
          );
        }),
        transition: Transition.fadeIn,
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
    if (isProcessing.value || callId.isEmpty) {
      return;
    }

    isProcessing.value = true;
    statusLabel.value = 'gen_decline'.tr;

    try {
      await _callSocketService.rejectCall(callId: callId);
      _stopTimeout();
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      _closeRoute();
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
    statusLabel.value = 'missed_call'.tr;

    try {
      await _callSocketService.timeoutCall(callId: callId);
    } catch (_) {
      // The backend also owns a one-minute timer. A race here is harmless.
    } finally {
      await CallkitIncomingService.endNativeSubsystemOnly(callId);
      _closeRoute();
      isProcessing.value = false;
    }
  }

  void closeFromNativeAction() {
    _stopTimeout();
    _closeRoute();
  }

  void _handleRemoteCallClosed(Map<String, dynamic> data) {
    final Map<String, dynamic> call = _toMap(data['call']);
    final String eventCallId =
        call['id']?.toString() ?? data['callId']?.toString() ?? '';

    if (eventCallId != callId) {
      return;
    }

    _stopTimeout();
    unawaited(CallkitIncomingService.endNativeSubsystemOnly(callId));
    _closeRoute();
  }

  void _resetIncomingStatus() {
    statusLabel.value =
        callType.isVideo ? 'incoming_video_call'.tr : 'incoming_voice_call'.tr;
    isProcessing.value = false;
  }

  void _stopTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _closeRoute() {
    if (_routeClosed) {
      return;
    }

    _routeClosed = true;
    if (!isClosed) {
      Get.back<void>();
    }
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
