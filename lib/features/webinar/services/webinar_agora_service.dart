import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/webinar_models.dart';

class WebinarAgoraService {
  RtcEngine? _engine;
  AgoraTokenModel? _activeToken;

  final RxnInt remoteHostUid = RxnInt();
  final RxList<int> remoteVideoUids = <int>[].obs;
  final RxBool isJoined = false.obs;
  final RxBool isBroadcaster = false.obs;
  final RxBool isMicEnabled = false.obs;
  final RxBool isCameraEnabled = false.obs;

  RtcEngine? get engine => _engine;
  String? get activeChannelName => _activeToken?.channelName;
  int? get activeRemoteVideoUid =>
      remoteVideoUids.isEmpty ? null : remoteVideoUids.last;

  Future<void> joinAsAudience(AgoraTokenModel token) async {
    await _ensurePermissions();
    await _initializeEngine(token.appId);
    _activeToken = token;
    remoteHostUid.value = null;
    remoteVideoUids.clear();

    await _engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine?.joinChannel(
      token: token.rtcToken,
      channelId: token.channelName,
      uid: token.uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
      ),
    );
    isJoined.value = true;
    isBroadcaster.value = false;
    isMicEnabled.value = false;
    isCameraEnabled.value = false;
  }

  Future<void> promoteToSpeaker(AgoraTokenModel token) async {
    if (_engine == null) return;
    _activeToken = token;

    await _engine?.renewToken(token.rtcToken);
    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine?.enableLocalAudio(true);
    await _engine?.enableLocalVideo(true);
    await _engine?.muteLocalAudioStream(false);
    await _engine?.muteLocalVideoStream(false);
    await _engine?.startPreview();
    await _engine?.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );

    isBroadcaster.value = true;
    isMicEnabled.value = true;
    isCameraEnabled.value = true;
  }

  Future<void> demoteToAudience() async {
    if (_engine == null) return;
    await _engine?.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
      ),
    );
    await _engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine?.enableLocalAudio(false);
    await _engine?.enableLocalVideo(false);
    await _engine?.stopPreview();

    isBroadcaster.value = false;
    isMicEnabled.value = false;
    isCameraEnabled.value = false;
  }

  Future<void> toggleMic() async {
    if (!isBroadcaster.value) return;
    final bool nextValue = !isMicEnabled.value;
    if (nextValue) await _engine?.enableLocalAudio(true);
    await _engine?.muteLocalAudioStream(!nextValue);
    isMicEnabled.value = nextValue;
  }

  Future<void> toggleCamera() async {
    if (!isBroadcaster.value) return;
    final bool nextValue = !isCameraEnabled.value;
    if (nextValue) {
      await _engine?.enableLocalVideo(true);
      await _engine?.startPreview();
    }
    await _engine?.muteLocalVideoStream(!nextValue);
    isCameraEnabled.value = nextValue;
  }

  Future<void> switchCamera() async {
    if (!isBroadcaster.value) return;
    await _engine?.switchCamera();
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    _activeToken = null;
    remoteHostUid.value = null;
    remoteVideoUids.clear();
    isJoined.value = false;
    isBroadcaster.value = false;
    isMicEnabled.value = false;
    isCameraEnabled.value = false;
  }

  Future<void> _initializeEngine(String appId) async {
    if (_engine != null) return;

    final RtcEngine engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));
    await engine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await engine.enableAudio();
    await engine.enableVideo();
    await _setSpeakerphoneSafely(engine);
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (_, _) => isJoined.value = true,
        onUserJoined: (_, int remoteUid, _) {
          _markRemoteVideoActive(remoteUid);
        },
        onUserOffline: (_, int remoteUid, _) {
          _removeRemoteVideo(remoteUid);
        },
        onRemoteVideoStateChanged:
            (_, int remoteUid, RemoteVideoState state, _, _) {
              if (state == RemoteVideoState.remoteVideoStateStarting ||
                  state == RemoteVideoState.remoteVideoStateDecoding) {
                _markRemoteVideoActive(remoteUid);
                return;
              }

              if (state == RemoteVideoState.remoteVideoStateStopped ||
                  state == RemoteVideoState.remoteVideoStateFailed) {
                _removeRemoteVideo(remoteUid);
              }
            },
        onLeaveChannel: (_, _) {
          isJoined.value = false;
          remoteHostUid.value = null;
          remoteVideoUids.clear();
        },
      ),
    );
    _engine = engine;
  }

  void _markRemoteVideoActive(int remoteUid) {
    if (!remoteVideoUids.contains(remoteUid)) {
      remoteVideoUids.add(remoteUid);
    }

    remoteHostUid.value ??= remoteUid;
  }

  void _removeRemoteVideo(int remoteUid) {
    final bool wasOriginalHost = remoteHostUid.value == remoteUid;

    remoteVideoUids.remove(remoteUid);

    if (wasOriginalHost) {
      remoteHostUid.value =
      remoteVideoUids.isEmpty ? null : remoteVideoUids.first;
    }
  }

  Future<void> _setSpeakerphoneSafely(RtcEngine engine) async {
    try {
      await engine.setEnableSpeakerphone(true);
    } on AgoraRtcException {
      // Some Android emulators/devices return -3 for this API even after
      // audio is enabled. Keep the webinar join flow running because Agora
      // audio subscription still works without forcing speakerphone here.
    }
  }

  Future<void> _ensurePermissions() async {
    await <Permission>[Permission.microphone, Permission.camera].request();
  }
}
