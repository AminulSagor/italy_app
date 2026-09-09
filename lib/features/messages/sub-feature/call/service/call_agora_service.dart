import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/services/callkit_incoming_service.dart';
import '../models/message_call_models.dart';
import 'package:flutter/widgets.dart';

typedef CallAgoraTokenProvider = Future<MessageCallMediaModel> Function();

enum CallRemoteVideoStatus {
  waiting,
  starting,
  playing,
  reconnecting,
  paused,
  failed,
}

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
  Future<void>? _tokenRenewalFuture;
  Timer? _tokenRenewalTimer;
  CallAgoraTokenProvider? _tokenProvider;
  String? _initializedAppId;
  int _lastRemoteVideoStatsLogMs = 0;

  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool isMicrophoneEnabled = true.obs;
  final RxBool isCameraEnabled = false.obs;
  final RxBool isSpeakerEnabled = true.obs;
  final RxnInt remoteUid = RxnInt();
  final RxBool isRemoteCameraEnabled = false.obs;
  final Rx<CallRemoteVideoStatus> remoteVideoStatus =
      CallRemoteVideoStatus.waiting.obs;

  bool _supportsVideo = false;
  bool _videoPublishDesired = false;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'CallLifecycle.Agora',
      error: error,
      stackTrace: stackTrace,
    );
  }

  RtcEngine? get engine => _engine;

  String? get channelName => _activeMedia?.channelName;

  int? get localUid => _activeMedia?.uid;

  bool get supportsVideo => _supportsVideo;

  bool get videoPublishDesired => _videoPublishDesired;

  /// Creates the RTC engine before CallKit fulfills an incoming answer. This
  /// ensures Agora is listening when iOS activates the CallKit audio session.
  Future<void> prepareCallKitEngine({
    required String appId,
    required bool isVideoCall,
  }) async {
    if (!Platform.isIOS) {
      return;
    }

    final String normalizedAppId = appId.trim();
    if (normalizedAppId.isEmpty) {
      throw const CallAgoraException('Invalid Agora app ID.');
    }

    if (_engine != null &&
        isInitialized.value &&
        _initializedAppId == normalizedAppId) {
      _supportsVideo = isVideoCall;
      _videoPublishDesired = isVideoCall;
      return;
    }

    await leaveCall();

    final RtcEngine engine = createAgoraRtcEngine();
    _engine = engine;
    _initializedAppId = normalizedAppId;
    _supportsVideo = isVideoCall;
    _videoPublishDesired = isVideoCall;

    try {
      _log('prepare engine begin video=$isVideoCall');
      await engine.initialize(RtcEngineContext(appId: normalizedAppId));
      await engine.setAudioSessionOperationRestriction(
        AudioSessionOperationRestriction.audioSessionOperationRestrictionAll,
      );
      isInitialized.value = true;
      _log('prepare engine complete; CallKit owns AVAudioSession');
    } catch (error) {
      _log('prepare engine failed', error: error);
      if (identical(_engine, engine)) {
        await leaveCall();
      }
      throw CallAgoraException('Unable to prepare call audio: $error');
    }
  }

  Future<bool> prepareLocalVideoPreview({required String appId}) async {
    final String normalizedAppId = appId.trim();

    if (normalizedAppId.isEmpty) {
      throw const CallAgoraException('Invalid Agora app ID.');
    }

    await leaveCall();

    final bool cameraWasRequested = await _ensureCameraPermission();

    if (cameraWasRequested) {
      await _waitUntilAppResumed();
    }

    _supportsVideo = true;
    _videoPublishDesired = true;
    _initializedAppId = normalizedAppId;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
    remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
    isJoined.value = false;
    isCameraEnabled.value = false;

    final RtcEngine engine = createAgoraRtcEngine();
    _engine = engine;

    try {
      await engine.initialize(RtcEngineContext(appId: normalizedAppId));

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

      throw CallAgoraException('Unable to start camera preview: $error');
    }
  }

  Future<void> joinCall({
    required MessageCallMediaModel media,
    required bool isVideoCall,
    bool isCallKitAudioSessionManaged = false,
    CallAgoraTokenProvider? tokenProvider,
  }) async {
    if (media.appId.trim().isEmpty ||
        media.channelName.trim().isEmpty ||
        media.token.trim().isEmpty ||
        media.uid <= 0) {
      throw const CallAgoraException('Invalid Agora call credentials.');
    }

    await ensurePermissionsForCall(isVideoCall: isVideoCall);

    final String normalizedAppId = media.appId.trim();

    final RtcEngine? preparedEngine = _engine;

    final bool reusePreparedEngine =
        preparedEngine != null &&
        isInitialized.value &&
        _initializedAppId == normalizedAppId &&
        (isCallKitAudioSessionManaged || isVideoCall);

    if (!reusePreparedEngine) {
      await leaveCall();
    }

    _activeMedia = media;
    _tokenProvider = tokenProvider;
    _supportsVideo = isVideoCall;
    _videoPublishDesired = isVideoCall;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
    remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
    isJoined.value = false;

    late final RtcEngine engine;

    if (reusePreparedEngine) {
      engine = preparedEngine;
    } else {
      isCameraEnabled.value = false;

      engine = createAgoraRtcEngine();
      _engine = engine;
    }

    final Completer<void> joinCompleter = Completer<void>();
    CallAgoraException? joinError;
    _joinCompleter = joinCompleter;

    try {
      _log(
        'join begin callKitManaged=$isCallKitAudioSessionManaged '
        'video=$isVideoCall uid=${media.uid}',
      );
      if (!reusePreparedEngine) {
        await engine.initialize(RtcEngineContext(appId: normalizedAppId));

        if (Platform.isIOS && isCallKitAudioSessionManaged) {
          // CallKit configured and activated AVAudioSession. Agora may capture,
          // render, and change routes, but must not replace that configuration.
          await engine.setAudioSessionOperationRestriction(
            AudioSessionOperationRestriction
                .audioSessionOperationRestrictionAll,
          );
        }

        isInitialized.value = true;
        _initializedAppId = normalizedAppId;
      }

      _ensureJoinStillActive(engine);

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            isJoined.value = true;
            _log(
              'join success elapsedMs=$elapsed localUid=${connection.localUid}',
            );

            if (!joinCompleter.isCompleted) {
              joinCompleter.complete();
            }
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            remoteUid.value = uid;
            isRemoteCameraEnabled.value = false;
            remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
            _log('remote user joined uid=$uid elapsedMs=$elapsed');
          },
          onConnectionStateChanged:
              (
                RtcConnection connection,
                ConnectionStateType state,
                ConnectionChangedReasonType reason,
              ) {
                _log('connection state=$state reason=$reason');
                if (state == ConnectionStateType.connectionStateReconnecting) {
                  remoteVideoStatus.value = CallRemoteVideoStatus.reconnecting;
                } else if (state == ConnectionStateType.connectionStateFailed) {
                  remoteVideoStatus.value = CallRemoteVideoStatus.failed;
                } else if (state ==
                        ConnectionStateType.connectionStateConnected &&
                    remoteUid.value != null &&
                    isRemoteCameraEnabled.value &&
                    remoteVideoStatus.value ==
                        CallRemoteVideoStatus.reconnecting) {
                  remoteVideoStatus.value = CallRemoteVideoStatus.starting;
                }
              },
          onLocalAudioStateChanged:
              (
                RtcConnection connection,
                LocalAudioStreamState state,
                LocalAudioStreamReason reason,
              ) {
                _log('local audio state=$state reason=$reason');
              },
          onRemoteAudioStateChanged:
              (
                RtcConnection connection,
                int uid,
                RemoteAudioState state,
                RemoteAudioStateReason reason,
                int elapsed,
              ) {
                _log(
                  'remote audio uid=$uid state=$state reason=$reason '
                  'elapsedMs=$elapsed',
                );
              },
          onAudioVolumeIndication:
              (
                RtcConnection connection,
                List<AudioVolumeInfo> speakers,
                int speakerNumber,
                int totalVolume,
              ) {
                final String levels = speakers
                    .map(
                      (AudioVolumeInfo info) =>
                          '${info.uid ?? -1}:${info.volume ?? -1}:vad=${info.vad ?? -1}',
                    )
                    .join(',');
                _log(
                  'audio levels speakers=$speakerNumber total=$totalVolume '
                  'uid:volume:vad=[$levels]',
                );
              },

          onRemoteVideoStateChanged:
              (
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

                _log(
                  'remote video uid=$uid state=$state reason=$reason '
                  'elapsedMs=$elapsed',
                );

                switch (state) {
                  case RemoteVideoState.remoteVideoStateStarting:
                    isRemoteCameraEnabled.value = true;
                    remoteVideoStatus.value = CallRemoteVideoStatus.starting;
                    break;

                  case RemoteVideoState.remoteVideoStateDecoding:
                    isRemoteCameraEnabled.value = true;
                    remoteVideoStatus.value = CallRemoteVideoStatus.playing;
                    break;

                  case RemoteVideoState.remoteVideoStateFrozen:
                    isRemoteCameraEnabled.value = true;
                    remoteVideoStatus.value =
                        CallRemoteVideoStatus.reconnecting;
                    break;

                  case RemoteVideoState.remoteVideoStateStopped:
                    isRemoteCameraEnabled.value = false;
                    remoteVideoStatus.value =
                        reason ==
                            RemoteVideoStateReason
                                .remoteVideoStateReasonAudioFallback
                        ? CallRemoteVideoStatus.reconnecting
                        : CallRemoteVideoStatus.paused;
                    break;

                  case RemoteVideoState.remoteVideoStateFailed:
                    isRemoteCameraEnabled.value = false;
                    remoteVideoStatus.value = CallRemoteVideoStatus.failed;
                    break;
                }
              },

          onFirstRemoteVideoDecoded:
              (
                RtcConnection connection,
                int uid,
                int width,
                int height,
                int elapsed,
              ) {
                if (remoteUid.value == uid) {
                  isRemoteCameraEnabled.value = true;
                  remoteVideoStatus.value = CallRemoteVideoStatus.playing;
                }
                _log(
                  'first remote video decoded uid=$uid size=${width}x$height '
                  'elapsedMs=$elapsed',
                );
              },

          onFirstRemoteVideoFrame:
              (
                RtcConnection connection,
                int uid,
                int width,
                int height,
                int elapsed,
              ) {
                if (remoteUid.value == uid) {
                  isRemoteCameraEnabled.value = true;
                  remoteVideoStatus.value = CallRemoteVideoStatus.playing;
                }
                _log(
                  'first remote video rendered uid=$uid size=${width}x$height '
                  'elapsedMs=$elapsed',
                );
              },

          onRemoteSubscribeFallbackToAudioOnly: (int uid, bool fallback) {
            if (remoteUid.value == uid) {
              remoteVideoStatus.value = fallback
                  ? CallRemoteVideoStatus.reconnecting
                  : CallRemoteVideoStatus.starting;
            }
            _log('remote video fallback uid=$uid audioOnly=$fallback');
          },

          onRemoteVideoStats:
              (RtcConnection connection, RemoteVideoStats stats) {
                final int nowMs = DateTime.now().millisecondsSinceEpoch;
                if (nowMs - _lastRemoteVideoStatsLogMs < 10000) {
                  return;
                }
                _lastRemoteVideoStatsLogMs = nowMs;
                _log(
                  'remote video stats uid=${stats.uid} '
                  'size=${stats.width}x${stats.height} '
                  'bitrateKbps=${stats.receivedBitrate} '
                  'decoderFps=${stats.decoderOutputFrameRate} '
                  'rendererFps=${stats.rendererOutputFrameRate} '
                  'packetLoss=${stats.packetLossRate}% '
                  'frozenRate=${stats.frozenRate}% '
                  'e2eDelayMs=${stats.e2eDelay} stream=${stats.rxStreamType}',
                );
              },

          onNetworkQuality:
              (
                RtcConnection connection,
                int uid,
                QualityType txQuality,
                QualityType rxQuality,
              ) {
                if (uid == 0 || uid == remoteUid.value) {
                  _log('network quality uid=$uid tx=$txQuality rx=$rxQuality');
                }
              },

          onLocalVideoStateChanged:
              (
                VideoSourceType source,
                LocalVideoStreamState state,
                LocalVideoStreamReason reason,
              ) {
                _log('local video state=$state reason=$reason source=$source');
                if (_videoPublishDesired &&
                    (state ==
                            LocalVideoStreamState
                                .localVideoStreamStateCapturing ||
                        state ==
                            LocalVideoStreamState
                                .localVideoStreamStateEncoding)) {
                  isCameraEnabled.value = true;
                } else if (state ==
                        LocalVideoStreamState.localVideoStreamStateStopped ||
                    state ==
                        LocalVideoStreamState.localVideoStreamStateFailed) {
                  isCameraEnabled.value = false;
                }
              },

          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _renewTokenInBackground(engine, 'privilege-will-expire');
          },

          onRequestToken: (RtcConnection connection) {
            _renewTokenInBackground(engine, 'request-token');
          },

          onUserOffline:
              (
                RtcConnection connection,
                int uid,
                UserOfflineReasonType reason,
              ) {
                if (remoteUid.value == uid) {
                  remoteUid.value = null;
                  isRemoteCameraEnabled.value = false;
                  remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
                }
                _log('remote user offline uid=$uid reason=$reason');
              },

          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            isJoined.value = false;
            remoteUid.value = null;
            isRemoteCameraEnabled.value = false;
            remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
            _log('leave channel callback duration=${stats.duration}');
          },
          onError: (ErrorCodeType errorCode, String message) {
            _log('Agora error code=$errorCode message=$message');
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
      await engine.enableAudioVolumeIndication(
        interval: 3000,
        smooth: 3,
        reportVad: true,
      );

      isMicrophoneEnabled.value = true;

      if (isVideoCall) {
        await engine.enableVideo();
        await engine.setRemoteSubscribeFallbackOption(
          StreamFallbackOptions.streamFallbackOptionAudioOnly,
        );

        // Preserve an outgoing foreground preview, but keep a CallKit-prepared
        // engine audio-only until the receiver unlocks the device.
        if (!isCameraEnabled.value) {
          await engine.enableLocalVideo(false);
          await engine.muteLocalVideoStream(true);
        }
      } else {
        await engine.disableVideo();
      }

      await _setSpeakerphone(enabled: isVideoCall);

      _ensureJoinStillActive(engine);

      await engine.joinChannel(
        token: media.token,
        channelId: media.channelName,
        uid: media.uid,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
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

      _scheduleTokenRenewal(engine, media);

      if (Platform.isIOS && isCallKitAudioSessionManaged) {
        // Do not call Agora's resumeAudio() here. It is an internal, @nodoc
        // API and returns ERR_NOT_SUPPORTED (-4) on the iOS 6.5.x SDK, which
        // would tear down an otherwise successfully joined call.
        await engine.enableLocalAudio(true);
        await engine.muteLocalAudioStream(false);
        await engine.updateChannelMediaOptions(
          ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileCommunication,
            autoSubscribeAudio: true,
            autoSubscribeVideo: isVideoCall,
            publishMicrophoneTrack: true,
            publishCameraTrack: false,
          ),
        );
        final bool resumed = await CallkitIncomingService.resumeIosCallAudio();
        _log('CallKit activation replay after join resumed=$resumed');
      }
    } catch (error) {
      _log('join failed', error: error);
      await leaveCall();

      if (error is CallAgoraException) {
        rethrow;
      }

      throw CallAgoraException('Unable to join the call: $error');
    } finally {
      if (identical(_joinCompleter, joinCompleter)) {
        _joinCompleter = null;
      }
    }
  }

  Future<void> ensurePermissionsForCall({required bool isVideoCall}) async {
    if (Platform.isIOS &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      final PermissionStatus microphoneStatus =
          await Permission.microphone.status;

      if (!microphoneStatus.isGranted) {
        // CallKit may deliver the answer while Flutter is still transitioning
        // from inactive to resumed. Give that transition time to complete so
        // iOS can present its native microphone permission dialog immediately.
        final bool appBecameActive = await _waitUntilAppResumed();
        if (!appBecameActive) {
          throw const CallAgoraException(
            'Open the app once and allow microphone access before answering '
            'calls from the lock screen.',
          );
        }
      } else {
        // A video call can begin as audio-only while the device is locked.
        // Camera access is requested after iOS brings the app to the foreground.
        return;
      }
    }

    final bool microphoneWasRequested = await _ensureMicrophonePermission();

    final bool cameraWasRequested = isVideoCall
        ? await _ensureCameraPermission()
        : false;

    /*
   * Android permission dialogs temporarily make the
   * Flutter activity inactive. Do not start Agora or
   * socket actions until the activity is resumed.
   */
    if (microphoneWasRequested || cameraWasRequested) {
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

    _videoPublishDesired = true;

    // iOS does not permit an app to start camera capture while it remains
    // lock-screened/backgrounded. Keep the accepted call on audio and retry
    // when MessageCallController observes the foreground transition.
    if (Platform.isIOS &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return false;
    }

    if (!isJoined.value) {
      for (int attempt = 0; attempt < 50 && !isJoined.value; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
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
        channelProfile: ChannelProfileType.channelProfileCommunication,
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

    await activeEngine.muteLocalAudioStream(!nextValue);

    isMicrophoneEnabled.value = nextValue;

    return nextValue;
  }

  Future<bool> toggleSpeaker() async {
    if (!isJoined.value) {
      return isSpeakerEnabled.value;
    }
    final bool nextValue = !isSpeakerEnabled.value;

    await _setSpeakerphone(enabled: nextValue);

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
      _videoPublishDesired = true;
      return activateVideo();
    }

    _videoPublishDesired = false;

    await activeEngine.muteLocalVideoStream(true);
    await activeEngine.stopPreview();
    await activeEngine.enableLocalVideo(false);

    await activeEngine.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
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
    if (!_supportsVideo || !isCameraEnabled.value || _engine == null) {
      return;
    }

    await _engine!.switchCamera();
  }

  Future<void> leaveCall() async {
    final RtcEngine? activeEngine = _engine;

    _tokenRenewalTimer?.cancel();
    _tokenRenewalTimer = null;
    _tokenRenewalFuture = null;
    _engine = null;
    _activeMedia = null;
    _tokenProvider = null;
    _supportsVideo = false;
    _videoPublishDesired = false;
    _initializedAppId = null;
    _lastRemoteVideoStatsLogMs = 0;

    remoteUid.value = null;
    isRemoteCameraEnabled.value = false;
    remoteVideoStatus.value = CallRemoteVideoStatus.waiting;
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

    _log('leave begin');

    try {
      await activeEngine.stopPreview();
    } catch (_) {}

    try {
      await activeEngine.leaveChannel();
    } catch (_) {}

    try {
      await activeEngine.release();
    } catch (_) {}
    _log('leave complete');
  }

  void _scheduleTokenRenewal(
    RtcEngine activeEngine,
    MessageCallMediaModel media,
  ) {
    _tokenRenewalTimer?.cancel();
    _tokenRenewalTimer = null;

    if (_tokenProvider == null || media.expiresAt <= 0) {
      return;
    }

    final DateTime renewAt = DateTime.fromMillisecondsSinceEpoch(
      media.expiresAt * 1000,
    ).subtract(const Duration(minutes: 1));
    final Duration untilRenewal = renewAt.difference(DateTime.now());
    final Duration delay = untilRenewal.isNegative
        ? const Duration(seconds: 1)
        : untilRenewal;

    _tokenRenewalTimer = Timer(
      delay,
      () => _renewTokenInBackground(activeEngine, 'scheduled'),
    );
  }

  void _renewTokenInBackground(RtcEngine activeEngine, String trigger) {
    final Future<void>? existing = _tokenRenewalFuture;
    if (existing != null) {
      _log('token renewal coalesced trigger=$trigger');
      return;
    }

    final Future<void> renewal = _renewToken(activeEngine, trigger);
    _tokenRenewalFuture = renewal;
    unawaited(
      renewal.whenComplete(() {
        if (identical(_tokenRenewalFuture, renewal)) {
          _tokenRenewalFuture = null;
        }
      }),
    );
  }

  Future<void> _renewToken(RtcEngine activeEngine, String trigger) async {
    final CallAgoraTokenProvider? provider = _tokenProvider;
    final MessageCallMediaModel? currentMedia = _activeMedia;

    if (provider == null || currentMedia == null) {
      _log('token renewal unavailable trigger=$trigger');
      return;
    }

    try {
      _log('token renewal begin trigger=$trigger');
      final MessageCallMediaModel renewedMedia = await provider().timeout(
        const Duration(seconds: 12),
      );

      if (!identical(_engine, activeEngine) || !isJoined.value) {
        _log('token renewal ignored because call already ended');
        return;
      }

      if (renewedMedia.appId != currentMedia.appId ||
          renewedMedia.channelName != currentMedia.channelName ||
          renewedMedia.uid != currentMedia.uid ||
          renewedMedia.token.trim().isEmpty) {
        throw const CallAgoraException(
          'The server returned mismatched Agora renewal credentials.',
        );
      }

      await activeEngine.renewToken(renewedMedia.token);
      _activeMedia = renewedMedia;
      _scheduleTokenRenewal(activeEngine, renewedMedia);
      _log(
        'token renewal complete trigger=$trigger '
        'expiresAt=${renewedMedia.expiresAt}',
      );
    } catch (error, stackTrace) {
      // Agora can request the token again while the transport reconnects.
      // Do not end a working call because a single renewal request timed out.
      _log(
        'token renewal failed trigger=$trigger',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _ensureJoinStillActive(RtcEngine engine) {
    if (!identical(_engine, engine)) {
      throw const CallAgoraException('The call was closed before joining.');
    }
  }

  Future<void> _setSpeakerphone({required bool enabled}) async {
    final RtcEngine? activeEngine = _engine;

    if (activeEngine == null) {
      isSpeakerEnabled.value = enabled;
      return;
    }

    try {
      await activeEngine.setEnableSpeakerphone(enabled);
    } on AgoraRtcException {
      // Some devices report an Agora route error even though
      // the audio route is changed successfully.
    }

    isSpeakerEnabled.value = enabled;
  }

  Future<bool> _ensureMicrophonePermission() async {
    final PermissionStatus currentStatus = await Permission.microphone.status;

    if (currentStatus.isGranted) {
      return false;
    }

    final PermissionStatus status = await Permission.microphone.request();

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
    final PermissionStatus currentStatus = await Permission.camera.status;

    if (currentStatus.isGranted) {
      return false;
    }

    final PermissionStatus status = await Permission.camera.request();

    if (!status.isGranted) {
      throw CallAgoraException(
        status.isPermanentlyDenied
            ? 'Allow camera access from the app settings to use video calls.'
            : 'Camera permission is required for video calling.',
      );
    }

    return true;
  }

  Future<bool> _waitUntilAppResumed() async {
    final WidgetsBinding binding = WidgetsBinding.instance;

    if (binding.lifecycleState != AppLifecycleState.resumed) {
      final Completer<void> completer = Completer<void>();

      late final AppLifecycleListener listener;

      listener = AppLifecycleListener(
        onResume: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      if (binding.lifecycleState == AppLifecycleState.resumed &&
          !completer.isCompleted) {
        completer.complete();
      }

      try {
        await completer.future.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        // A locked/backgrounded iOS app cannot present a permission prompt.
      } finally {
        listener.dispose();
      }
    }

    final bool isResumed = binding.lifecycleState == AppLifecycleState.resumed;
    if (isResumed) {
      // Allow the foreground transition or Android permission UI to settle.
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    return isResumed;
  }

  @override
  void onClose() {
    unawaited(leaveCall());
    super.onClose();
  }
}
