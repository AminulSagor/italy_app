import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/webinar_models.dart';

class WebinarAgoraService {
  RtcEngine? _engine;
  AgoraTokenModel? _activeToken;

  final RxnInt remoteHostUid = RxnInt();
  final RxBool isJoined = false.obs;
  final RxBool isBroadcaster = false.obs;
  final RxBool isMicEnabled = false.obs;
  final RxBool isCameraEnabled = false.obs;

  RtcEngine? get engine => _engine;
  String? get activeChannelName => _activeToken?.channelName;

  Future<void> joinAsAudience(AgoraTokenModel token) async {
    await _ensurePermissions();
    await _initializeEngine(token.appId);
    _activeToken = token;
    remoteHostUid.value = null;

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
    await _engine?.muteLocalAudioStream(!nextValue);
    isMicEnabled.value = nextValue;
  }

  Future<void> toggleCamera() async {
    if (!isBroadcaster.value) return;
    final bool nextValue = !isCameraEnabled.value;
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
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) => isJoined.value = true,
        onUserJoined: (_, int remoteUid, __) {
          remoteHostUid.value = remoteUid;
        },
        onUserOffline: (_, int remoteUid, __) {
          if (remoteHostUid.value == remoteUid) remoteHostUid.value = null;
        },
        onLeaveChannel: (_, __) {
          isJoined.value = false;
          remoteHostUid.value = null;
        },
      ),
    );
    _engine = engine;
  }

  Future<void> _ensurePermissions() async {
    await <Permission>[Permission.microphone, Permission.camera].request();
  }
}
