import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/message_call_models.dart';
import 'package:flutter/widgets.dart';

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
  String? _initializedAppId;

  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool isMicrophoneEnabled = true.obs;
  final RxBool isCameraEnabled = false.obs;
  final RxBool isSpeakerEnabled = true.obs;
  final RxnInt remoteUid = RxnInt();
  final RxBool isRemoteCameraEnabled = false.obs;

  bool _supportsVideo = false;

  RtcEngine? get engine => _engine;

  String? get channelName => _activeMedia?.channelName;

  int? get localUid => _activeMedia?.uid;

  bool get supportsVideo => _supportsVideo;


  Future<bool> prepareLocalVideoPreview({
    required String appId,
  }) async {
    final String normalizedAppId = appId.trim();

    if (normalizedAppId.isEmpty) {
      throw const CallAgoraException(
        'Invalid Agora app ID.',
      );
    }

    await leaveCall();

    final bool cameraWasRequested =
    await _ensureCameraPermission();

    if (cameraWasRequested) {
      await _waitUntilAppResumed();
    }

    _supportsVideo = true;
    _initializedAppId = normalizedAppId;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
    isJoined.value = false;
    isCameraEnabled.value = false;

    final RtcEngine engine = createAgoraRtcEngine();
    _engine = engine;

    try {
      await engine.initialize(
        RtcEngineContext(
          appId: normalizedAppId,
        ),
      );

      isInitialized.value = true;
      await engine.disableAudio();
      _ensureJoinStillActive(engine);

      // Video only. Do not enable Agora audio here.
      await engine.enableVideo();
      _ensureJoinStillActive(engine);

      await engine.enableLocalVideo(true);
      await engine.startPreview();
      _ensureJoinStillActive(engine);

      isCameraEnabled.value = true;

      return true;
    } catch (error) {
      if (identical(_engine, engine)) {
        await leaveCall();
      }

      if (error is CallAgoraException) {
        rethrow;
      }

      throw CallAgoraException(
        'Unable to start camera preview: $error',
      );
    }
  }


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


    await ensurePermissionsForCall(
      isVideoCall: isVideoCall,
    );

    final String normalizedAppId =
    media.appId.trim();

    final RtcEngine? preparedEngine = _engine;

    final bool reusePreparedEngine =
        isVideoCall &&
            preparedEngine != null &&
            isInitialized.value &&
            _initializedAppId == normalizedAppId;

    if (!reusePreparedEngine) {
      await leaveCall();
    }

    _activeMedia = media;
    _supportsVideo = isVideoCall;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
    isJoined.value = false;

    late final RtcEngine engine;

    if (reusePreparedEngine) {
      engine = preparedEngine!;
    } else {
      isCameraEnabled.value = false;

      engine = createAgoraRtcEngine();
      _engine = engine;
    }

    final Completer<void> joinCompleter = Completer<void>();
    CallAgoraException? joinError;
    _joinCompleter = joinCompleter;

    try {
      if (!reusePreparedEngine) {
        await engine.initialize(
          RtcEngineContext(
            appId: normalizedAppId,
          ),
        );

        isInitialized.value = true;
        _initializedAppId = normalizedAppId;
      }

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
            isRemoteCameraEnabled.value = false;
          },

          onRemoteVideoStateChanged: (
              RtcConnection connection,
              int uid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed,
              ) {
            if (remoteUid.value == null) {
              remoteUid.value = uid;
            }

            if (remoteUid.value != uid) {
              return;
            }

            switch (state) {
              case RemoteVideoState.remoteVideoStateStarting:
              case RemoteVideoState.remoteVideoStateDecoding:
              case RemoteVideoState.remoteVideoStateFrozen:
                isRemoteCameraEnabled.value = true;
                break;

              case RemoteVideoState.remoteVideoStateStopped:
              case RemoteVideoState.remoteVideoStateFailed:
                isRemoteCameraEnabled.value = false;
                break;
            }
          },

          onUserOffline: (
              RtcConnection connection,
              int uid,
              UserOfflineReasonType reason,
              ) {
            if (remoteUid.value == uid) {
              remoteUid.value = null;
              isRemoteCameraEnabled.value = false;
            }
          },

          onLeaveChannel: (
              RtcConnection connection,
              RtcStats stats,
              ) {
            isJoined.value = false;
            remoteUid.value = null;
            isRemoteCameraEnabled.value = false;
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
        await engine.enableVideo();

        // Do not stop the camera when reusing the outgoing preview.
        if (!reusePreparedEngine) {
          await engine.enableLocalVideo(false);
          await engine.muteLocalVideoStream(true);
        }
      } else {
        await engine.disableVideo();
      }

      await _setSpeakerphone(
        enabled: isVideoCall,
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


  Future<void> ensurePermissionsForCall({
    required bool isVideoCall,
  }) async {
    final bool microphoneWasRequested =
    await _ensureMicrophonePermission();

    final bool cameraWasRequested = isVideoCall
        ? await _ensureCameraPermission()
        : false;

    /*
   * Android permission dialogs temporarily make the
   * Flutter activity inactive. Do not start Agora or
   * socket actions until the activity is resumed.
   */
    if (microphoneWasRequested ||
        cameraWasRequested) {
      await _waitUntilAppResumed();
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

    if (activeEngine == null || !isJoined.value) {
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
    if (!isJoined.value) {
      return isSpeakerEnabled.value;
    }
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

    if (activeEngine == null || !isJoined.value) {
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
    _initializedAppId = null;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
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

  Future<bool> _ensureMicrophonePermission() async {
    final PermissionStatus currentStatus =
    await Permission.microphone.status;

    if (currentStatus.isGranted) {
      return false;
    }

    final PermissionStatus status =
    await Permission.microphone.request();

    if (!status.isGranted) {
      throw CallAgoraException(
        status.isPermanentlyDenied
            ? 'Allow microphone access from the app settings to use calls.'
            : 'Microphone permission is required for calling.',
      );
    }

    return true;
  }

  Future<bool> _ensureCameraPermission() async {
    final PermissionStatus currentStatus =
    await Permission.camera.status;

    if (currentStatus.isGranted) {
      return false;
    }

    final PermissionStatus status =
    await Permission.camera.request();

    if (!status.isGranted) {
      throw CallAgoraException(
        status.isPermanentlyDenied
            ? 'Allow camera access from the app settings to use video calls.'
            : 'Camera permission is required for video calling.',
      );
    }

    return true;
  }
  Future<void> _waitUntilAppResumed() async {
    final WidgetsBinding binding =
        WidgetsBinding.instance;

    if (binding.lifecycleState !=
        AppLifecycleState.resumed) {
      final Completer<void> completer =
      Completer<void>();

      late final AppLifecycleListener listener;

      listener = AppLifecycleListener(
        onResume: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      if (binding.lifecycleState ==
          AppLifecycleState.resumed &&
          !completer.isCompleted) {
        completer.complete();
      }

      try {
        await completer.future.timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        // Continue safely after the timeout.
      } finally {
        listener.dispose();
      }
    }

    // Allow Android to finish closing the permission UI.
    await Future<void>.delayed(
      const Duration(milliseconds: 350),
    );
  }



  @override
  void onClose() {
    unawaited(leaveCall());
    super.onClose();
  }
}