part of 'message_call_controller.dart';

extension MessageCallControllerMedia on MessageCallController {


  Future<void> _prepareOutgoingVideoPreview(
      MessageCallSessionModel session,
      ) async {
    if (!callType.isVideo ||
        _routeClosed ||
        _remoteTerminal ||
        _endRequested) {
      return;
    }

    try {
      final bool enabled =
      await _callAgoraService
          .prepareLocalVideoPreview(
        appId: session.media.appId,
      );

      if (_routeClosed ||
          _remoteTerminal ||
          _endRequested) {
        return;
      }

      isCameraOff.value = !enabled;
    } catch (_) {
      // A preview failure should not cancel the call.
      // Agora will initialize normally after acceptance.
      isCameraOff.value = true;
    }
  }
  Future<void> _activateVideoIfNeeded() async {
    if (!callType.isVideo || isEnding.value) {
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

  Future<void> _syncProximityLock() async {
    final bool shouldEnable =
        !callType.isVideo &&
            isActive.value &&
            !isSpeakerOn.value &&
            !isEnding.value;

    await _proximityService.setEnabled(shouldEnable);
  }

  Future<void> toggleSpeaker() async {
    try {
      isSpeakerOn.value =
      await _callAgoraService.toggleSpeaker();

      await _syncProximityLock();
    } catch (error) {
      Get.snackbar(
        'Speaker error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleCamera() async {
    if (!callType.isVideo) {
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
