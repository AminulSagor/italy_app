import 'dart:async';

import 'package:get/get.dart';

import '../models/message_call_models.dart';
import '../service/message_call_mock_service.dart';

class MessageCallController extends GetxController {
  final String conversationId;
  final MessageCallType callType;
  final MessageCallParticipantModel participant;
  final MessageCallMockService _messageCallService;

  MessageCallController({
    required this.conversationId,
    required this.callType,
    required this.participant,
    required MessageCallMockService messageCallService,
  }) : _messageCallService = messageCallService;

  final RxBool isLoading = false.obs;
  final RxBool isEnding = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isCameraOff = false.obs;
  final RxBool isFrontCamera = true.obs;
  final RxString durationLabel = '00:00'.obs;
  final Rxn<MessageCallSessionModel> callSession =
      Rxn<MessageCallSessionModel>();

  Timer? _durationTimer;
  DateTime? _startedAt;

  @override
  void onInit() {
    super.onInit();
    startCall();
  }

  Future<void> startCall() async {
    isLoading.value = true;

    try {
      final MessageCallSessionModel session = await _messageCallService
          .startCall(
            conversationId: conversationId,
            callType: callType,
            participant: participant,
          );

      callSession.value = session;
      _startedAt = session.startedAt;
      _startDurationTimer();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMute() {
    isMuted.toggle();
  }

  void toggleSpeaker() {
    isSpeakerOn.toggle();
  }

  void toggleCamera() {
    if (!callType.isVideo) return;
    isCameraOff.toggle();
  }

  void switchCamera() {
    if (!callType.isVideo || isCameraOff.value) return;
    isFrontCamera.toggle();
  }

  Future<void> endCall() async {
    if (isEnding.value) return;

    isEnding.value = true;

    try {
      final MessageCallSessionModel? session = callSession.value;

      if (session != null) {
        await _messageCallService.endCall(callId: session.id);
      }

      Get.back<void>();
    } finally {
      isEnding.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _updateDurationLabel();

    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDurationLabel(),
    );
  }

  void _updateDurationLabel() {
    final DateTime? startedAt = _startedAt;

    if (startedAt == null) return;

    final int totalSeconds = DateTime.now().difference(startedAt).inSeconds;
    final String minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final String seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    durationLabel.value = '$minutes:$seconds';
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }
}
