import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/message_call_models.dart';

class CallAgoraException implements Exception {
  const CallAgoraException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CallAgoraService extends GetxService {
  RtcEngine? _engine;
  MessageCallMediaModel? _activeMedia;
  Completer<void>? _joinCompleter;

  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool isMicrophoneEnabled = true.obs;
  final RxBool isCameraEnabled = false.obs;
  final RxBool isSpeakerEnabled = true.obs;
  final RxnInt remoteUid = RxnInt();

  bool _supportsVideo = false;

  RtcEngine? get engine => _engine;

  String? get channelName => _activeMedia?.channelName;

  int? get localUid => _activeMedia?.uid;

  bool get supportsVideo => _supportsVideo;

  /// Joins the call with audio enabled.
  ///
  /// For video calls, remote-video subscription is enabled,
  /// but the local camera is not published until activateVideo().
  Future<void> joinCall({
    required MessageCallMediaModel media,
    required bool isVideoCall,
  }) async {
    if (media.appId.trim().isEmpty ||
        media.channelName.trim().isEmpty ||
        media.token.trim().isEmpty ||
        media.uid <= 0) {
      throw const CallAgoraException(
        'Invalid Agora call credentials.',
      );
    }

    await leaveCall();
    await _ensureMicrophonePermission();

    _activeMedia = media;
    _supportsVideo = isVideoCall;

    remoteUid.value = null;
    isCameraEnabled.value = false;

    final RtcEngine engine = createAgoraRtcEngine();
    _engine = engine;

    final Completer<void> joinCompleter = Completer<void>();
    CallAgoraException? joinError;
    _joinCompleter = joinCompleter;

    try {
      await engine.initialize(
        RtcEngineContext(
          appId: media.appId,
        ),
      );

      isInitialized.value = true;
      _ensureJoinStillActive(engine);

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (
              RtcConnection connection,
              int elapsed,
              ) {
            isJoined.value = true;

            if (!joinCompleter.isCompleted) {
              joinCompleter.complete();
            }
          },
          onUserJoined: (
              RtcConnection connection,
              int uid,
              int elapsed,
              ) {
            remoteUid.value = uid;
          },
          onUserOffline: (
              RtcConnection connection,
              int uid,
              UserOfflineReasonType reason,
              ) {
            if (remoteUid.value == uid) {
              remoteUid.value = null;
            }
          },
          onLeaveChannel: (
              RtcConnection connection,
              RtcStats stats,
              ) {
            isJoined.value = false;
            remoteUid.value = null;
          },
          onError: (
            ErrorCodeType errorCode,
            String message,
          ) {
            joinError = CallAgoraException(
              message.trim().isEmpty
                  ? 'Agora error: $errorCode'
                  : 'Agora error: $message',
            );

            if (!joinCompleter.isCompleted) {
              joinCompleter.complete();
            }
          },
        ),
      );

      await engine.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      await engine.enableAudio();
      await engine.enableLocalAudio(true);
      await engine.muteLocalAudioStream(false);

      isMicrophoneEnabled.value = true;

      if (isVideoCall) {
        // Enable the video module for receiving remote video,
        // but do not publish the local camera while ringing.
        await engine.enableVideo();
        await engine.enableLocalVideo(false);
        await engine.muteLocalVideoStream(true);
      } else {
        await engine.disableVideo();
      }

      await _setSpeakerphone(
        enabled: true,
      );

      _ensureJoinStillActive(engine);

      await engine.joinChannel(
        token: media.token,
        channelId: media.channelName,
        uid: media.uid,
        options: ChannelMediaOptions(
          channelProfile:
          ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideoCall,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
        ),
      );

      await joinCompleter.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw const CallAgoraException(
            'Joining the Agora channel timed out.',
          );
        },
      );

      final CallAgoraException? error = joinError;
      if (error != null) {
        throw error;
      }

      _ensureJoinStillActive(engine);
    } catch (error) {
      await leaveCall();

      if (error is CallAgoraException) {
        rethrow;
      }

      throw CallAgoraException(
        'Unable to join the call: $error',
      );
    } finally {
      if (identical(_joinCompleter, joinCompleter)) {
        _joinCompleter = null;
      }
    }
  }

  /// Requests camera permission and begins publishing local video.
  ///
  /// Call this only after the receiver answers.
  Future<bool> activateVideo() async {
    if (!_supportsVideo) {
      return false;
    }

    final RtcEngine? activeEngine = _engine;

    if (activeEngine == null || !isJoined.value) {
      return false;
    }

    await _ensureCameraPermission();

    await activeEngine.enableVideo();
    await activeEngine.enableLocalVideo(true);
    await activeEngine.muteLocalVideoStream(false);
    await activeEngine.startPreview();

    await activeEngine.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile:
        ChannelProfileType.channelProfileCommunication,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishMicrophoneTrack: true,
        publishCameraTrack: true,
      ),
    );

    isCameraEnabled.value = true;

    return true;
  }

  Future<bool> toggleMicrophone() async {
    final RtcEngine? activeEngine = _engine;

    if (activeEngine == null) {
      return isMicrophoneEnabled.value;
    }

    final bool nextValue = !isMicrophoneEnabled.value;

    if (nextValue) {
      await activeEngine.enableLocalAudio(true);
    }

    await activeEngine.muteLocalAudioStream(
      !nextValue,
    );

    isMicrophoneEnabled.value = nextValue;

    return nextValue;
  }

  Future<bool> toggleSpeaker() async {
    final bool nextValue = !isSpeakerEnabled.value;

    await _setSpeakerphone(
      enabled: nextValue,
    );

    return isSpeakerEnabled.value;
  }

  Future<bool> toggleCamera() async {
    if (!_supportsVideo) {
      return false;
    }

    final RtcEngine? activeEngine = _engine;

    if (activeEngine == null) {
      return isCameraEnabled.value;
    }

    if (!isCameraEnabled.value) {
      return activateVideo();
    }

    await activeEngine.muteLocalVideoStream(true);
    await activeEngine.stopPreview();
    await activeEngine.enableLocalVideo(false);

    await activeEngine.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile:
        ChannelProfileType.channelProfileCommunication,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishMicrophoneTrack: true,
        publishCameraTrack: false,
      ),
    );

    isCameraEnabled.value = false;

    return false;
  }

  Future<void> switchCamera() async {
    if (!_supportsVideo ||
        !isCameraEnabled.value ||
        _engine == null) {
      return;
    }

    await _engine!.switchCamera();
  }

  Future<void> leaveCall() async {
    final RtcEngine? activeEngine = _engine;

    _engine = null;
    _activeMedia = null;
    _supportsVideo = false;

    remoteUid.value = null;
    isJoined.value = false;
    isInitialized.value = false;
    isMicrophoneEnabled.value = true;
    isCameraEnabled.value = false;
    isSpeakerEnabled.value = true;

    final Completer<void>? joinCompleter = _joinCompleter;
    _joinCompleter = null;

    if (joinCompleter != null && !joinCompleter.isCompleted) {
      // Complete normally to unblock joinCall without creating an unhandled
      // asynchronous error when a call is rejected during Agora setup.
      joinCompleter.complete();
    }

    if (activeEngine == null) {
      return;
    }

    try {
      await activeEngine.stopPreview();
    } catch (_) {}

    try {
      await activeEngine.leaveChannel();
    } catch (_) {}

    try {
      await activeEngine.release();
    } catch (_) {}
  }

  void _ensureJoinStillActive(RtcEngine engine) {
    if (!identical(_engine, engine)) {
      throw const CallAgoraException(
        'The call was closed before joining.',
      );
    }
  }

  Future<void> _setSpeakerphone({
    required bool enabled,
  }) async {
    final RtcEngine? activeEngine = _engine;

    if (activeEngine == null) {
      isSpeakerEnabled.value = enabled;
      return;
    }

    try {
      await activeEngine.setEnableSpeakerphone(
        enabled,
      );
    } on AgoraRtcException {
      // Some devices report an Agora route error even though
      // the audio route is changed successfully.
    }

    isSpeakerEnabled.value = enabled;
  }

  Future<void> _ensureMicrophonePermission() async {
    final PermissionStatus status =
    await Permission.microphone.request();

    if (!status.isGranted) {
      throw const CallAgoraException(
        'Microphone permission is required for calling.',
      );
    }
  }

  Future<void> _ensureCameraPermission() async {
    final PermissionStatus status =
    await Permission.camera.request();

    if (!status.isGranted) {
      throw const CallAgoraException(
        'Camera permission is required for video calling.',
      );
    }
  }

  @override
  void onClose() {
    unawaited(leaveCall());
    super.onClose();
  }
}