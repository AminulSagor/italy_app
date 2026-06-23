import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../service/call_socket_service.dart';
import '../views/message_call_view.dart';
import 'message_call_controller.dart';

class MessageIncomingCallController
    extends GetxController {
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

  final RxString statusLabel =
      'Incoming call'.obs;

  final RxBool isProcessing = false.obs;

  Timer? _ringTimer;
  bool _routeClosed = false;

  late final CallSocketListener
  _cancelledCallListener;

  late final CallSocketListener
  _endedCallListener;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> call =
    _toMap(payload['call']);

    final Map<String, dynamic> callerData =
    _toMap(payload['caller']);

    callId = call['id']?.toString() ?? '';

    conversationId =
        call['directConversationId']
            ?.toString() ??
            '';

    callType = MessageCallType.fromValue(
      call['callType']?.toString(),
    );

    caller =
        MessageCallParticipantModel.fromJson(
          callerData,
        );

    statusLabel.value = callType.isVideo
        ? 'Incoming video call'
        : 'Incoming voice call';

    _cancelledCallListener =
        _handleRemoteCallClosed;

    _endedCallListener =
        _handleRemoteCallClosed;

    _callSocketService.addCancelledCallListener(
      _cancelledCallListener,
    );

    _callSocketService.addEndedCallListener(
      _endedCallListener,
    );

    _startRinging();
  }

  void _startRinging() {
    _playRingAlert();

    _ringTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) {
        _playRingAlert();
      },
    );
  }

  void _playRingAlert() {
    unawaited(
      SystemSound.play(
        SystemSoundType.alert,
      ),
    );

    unawaited(
      HapticFeedback.vibrate(),
    );
  }

  void _stopRinging() {
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  Future<void> answerCall() async {
    if (isProcessing.value ||
        callId.isEmpty) {
      return;
    }

    isProcessing.value = true;
    statusLabel.value = 'Connecting...';

    try {
      final Map<String, dynamic> response =
      await _callSocketService.answerCall(
        callId: callId,
      );

      final MessageCallSessionModel session =
      MessageCallSessionModel
          .fromInitiateResponse(
        response: response,
        participant: caller,
      );

      if (session.id.isEmpty ||
          session.media.token.isEmpty ||
          session.media.channelName.isEmpty) {
        throw const CallSocketException(
          code: 'INVALID_ANSWER_RESPONSE',
          message:
          'The server returned invalid call credentials.',
        );
      }

      _stopRinging();
      _routeClosed = true;
      isProcessing.value = false;

      Get.off<void>(
            () => const MessageCallView(),
        binding: BindingsBuilder(
              () {
            Get.put<MessageCallController>(
              MessageCallController(
                conversationId:
                session.conversationId,
                callType: session.type,
                participant: caller,
                callSocketService:
                _callSocketService,
                callAgoraService:
                CallAgoraService(),
                initialSession: session,
              ),
            );
          },
        ),
        transition: Transition.fadeIn,
      );
    } on CallSocketException catch (error) {
      statusLabel.value = callType.isVideo
          ? 'Incoming video call'
          : 'Incoming voice call';

      isProcessing.value = false;

      Get.snackbar(
        'Unable to answer',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      statusLabel.value = callType.isVideo
          ? 'Incoming video call'
          : 'Incoming voice call';

      isProcessing.value = false;

      Get.snackbar(
        'Unable to answer',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectCall() async {
    if (isProcessing.value ||
        callId.isEmpty) {
      return;
    }

    isProcessing.value = true;
    statusLabel.value = 'Declining...';

    try {
      await _callSocketService.rejectCall(
        callId: callId,
      );

      _stopRinging();
      _closeRoute();
    } on CallSocketException catch (error) {
      Get.snackbar(
        'Unable to decline',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Unable to decline',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _handleRemoteCallClosed(
      Map<String, dynamic> data,
      ) {
    final Map<String, dynamic> call =
    _toMap(data['call']);

    final String eventCallId =
        call['id']?.toString() ??
            data['callId']?.toString() ??
            '';

    if (eventCallId != callId) {
      return;
    }

    _stopRinging();
    _closeRoute();
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

  static Map<String, dynamic> _toMap(
      dynamic value,
      ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  @override
  void onClose() {
    _stopRinging();

    _callSocketService
        .removeCancelledCallListener(
      _cancelledCallListener,
    );

    _callSocketService
        .removeEndedCallListener(
      _endedCallListener,
    );

    super.onClose();
  }
}