part of 'message_call_controller.dart';

extension MessageCallControllerMedia on MessageCallController {
  Future<void> _activateVideoIfNeeded() async {
    if (!callType.isVideo || !isActive.value || isEnding.value) {
      return;
    }

    try {
      final bool enabled = await _callAgoraService.activateVideo();
      isCameraOff.value = !enabled;
    } on CallAgoraException catch (error) {
      isCameraOff.value = true;
      Get.snackbar(
        'Video unavailable',
        '${error.message} The call will continue with audio.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      isCameraOff.value = true;
      Get.snackbar(
        'Video unavailable',
        'The call will continue with audio.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleMute() async {
    try {
      final bool enabled = await _callAgoraService.toggleMicrophone();
      isMuted.value = !enabled;
    } catch (error) {
      Get.snackbar(
        'Microphone error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      isSpeakerOn.value = await _callAgoraService.toggleSpeaker();
    } catch (error) {
      Get.snackbar(
        'Speaker error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleCamera() async {
    if (!callType.isVideo || !isActive.value) {
      return;
    }

    try {
      final bool enabled = await _callAgoraService.toggleCamera();
      isCameraOff.value = !enabled;
    } on CallAgoraException catch (error) {
      Get.snackbar(
        'Camera error',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Camera error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> switchCamera() async {
    if (!callType.isVideo || !isActive.value || isCameraOff.value) {
      return;
    }

    try {
      await _callAgoraService.switchCamera();
      isFrontCamera.toggle();
    } catch (error) {
      Get.snackbar(
        'Camera error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _syncMediaControls() {
    isMuted.value = !_callAgoraService.isMicrophoneEnabled.value;
    isSpeakerOn.value = _callAgoraService.isSpeakerEnabled.value;
    isCameraOff.value = !_callAgoraService.isCameraEnabled.value;
  }
}
