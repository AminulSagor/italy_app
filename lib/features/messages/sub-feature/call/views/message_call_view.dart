import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/message_call_controller.dart';
import '../models/message_call_models.dart';
import '../service/call_agora_service.dart';
import '../widgets/message_call_controls.dart';
import '../widgets/message_call_participant_card.dart';
import '../widgets/message_video_placeholder.dart';

class MessageCallView extends GetView<MessageCallController> {
  const MessageCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final MessageCallType callType = controller.callType;

      final bool showVideoStage = callType.isVideo;
      final bool isCallConnected = controller.isActive.value;

      return Scaffold(
        backgroundColor: showVideoStage
            ? AppColors.black
            : AppColors.homeBackground,
        body: Stack(
          children: <Widget>[
            if (showVideoStage)
              Positioned.fill(
                child: isCallConnected
                    ? _buildRemoteVideo()
                    : _buildLocalVideoBackground(),
              ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  _MessageCallTopBar(
                    callType: callType,
                    status: controller.durationLabel.value,
                    useLightText: showVideoStage,
                  ),
                  if (controller.isLoading.value)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primaryGreen,
                    ),
                  Expanded(
                    child: Center(
                      child: _buildParticipantArea(
                        showVideoStage: showVideoStage,
                      ),
                    ),
                  ),
                  MessageCallControls(
                    callType: callType,
                    isMuted: controller.isMuted.value,
                    isSpeakerOn: controller.isSpeakerOn.value,
                    isCameraOff: controller.isCameraOff.value,
                    isEnding: controller.isEnding.value,
                    onMuteTap: controller.toggleMute,
                    onSpeakerTap: controller.toggleSpeaker,
                    onCameraTap: controller.toggleCamera,
                    onSwitchCameraTap: controller.switchCamera,
                    onEndTap: controller.endCall,
                  ),
                ],
              ),
            ),
            if (showVideoStage && isCallConnected) _buildLocalVideoPreview(),
          ],
        ),
      );
    });
  }

  Widget _buildRemoteVideo() {
    final RtcEngine? engine = controller.agoraEngine;
    final int? remoteUid = controller.agora.remoteUid.value;
    final bool remoteCameraEnabled =
        controller.agora.isRemoteCameraEnabled.value;
    final String? channelName = controller.agoraChannelName;
    final CallRemoteVideoStatus status =
        controller.agora.remoteVideoStatus.value;
    final bool canRender =
        engine != null &&
        remoteUid != null &&
        remoteCameraEnabled &&
        channelName != null &&
        channelName.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (canRender)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(
                uid: remoteUid,
                renderMode: RenderModeType.renderModeHidden,
              ),
              connection: RtcConnection(channelId: channelName),
            ),
          )
        else
          const MessageVideoPlaceholder(),
        if (status != CallRemoteVideoStatus.waiting &&
            status != CallRemoteVideoStatus.playing)
          _RemoteVideoStatusOverlay(status: status),
      ],
    );
  }

  Widget _buildParticipantArea({required bool showVideoStage}) {
    final CallRemoteVideoStatus remoteVideoStatus =
        controller.agora.remoteVideoStatus.value;
    final bool remoteVideoStateVisible =
        remoteVideoStatus != CallRemoteVideoStatus.waiting;
    final bool hasRemoteVideo =
        showVideoStage &&
        controller.agora.remoteUid.value != null &&
        (controller.agora.isRemoteCameraEnabled.value ||
            remoteVideoStateVisible);

    if (hasRemoteVideo) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: MessageCallParticipantCard(
        participant: controller.participant,
        durationLabel: controller.durationLabel.value,
        isVideoCall: showVideoStage,
      ),
    );
  }

  Widget _buildLocalVideoBackground() {
    final RtcEngine? engine = controller.agoraEngine;

    if (engine == null ||
        !controller.agora.isInitialized.value ||
        controller.isCameraOff.value) {
      return const MessageVideoPlaceholder();
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine,
        canvas: const VideoCanvas(
          uid: 0,
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  }

  Widget _buildLocalVideoPreview() {
    final RtcEngine? engine = controller.agoraEngine;

    if (engine == null ||
        !controller.agora.isJoined.value ||
        controller.isCameraOff.value) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 110.h,
      right: 18.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 110.w,
          height: 155.h,
          color: AppColors.black,
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(
                uid: 0,
                renderMode: RenderModeType.renderModeHidden,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoteVideoStatusOverlay extends StatelessWidget {
  const _RemoteVideoStatusOverlay({required this.status});

  final CallRemoteVideoStatus status;

  @override
  Widget build(BuildContext context) {
    final bool showProgress =
        status == CallRemoteVideoStatus.starting ||
        status == CallRemoteVideoStatus.reconnecting;
    final String label = switch (status) {
      CallRemoteVideoStatus.starting => 'call_video_connecting'.tr,
      CallRemoteVideoStatus.reconnecting => 'call_video_reconnecting'.tr,
      CallRemoteVideoStatus.paused => 'call_video_remote_paused'.tr,
      CallRemoteVideoStatus.failed => 'call_video_unavailable'.tr,
      CallRemoteVideoStatus.waiting || CallRemoteVideoStatus.playing => '',
    };

    return ColoredBox(
      color: AppColors.black.withValues(alpha: 0.28),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showProgress)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              else
                Icon(
                  status == CallRemoteVideoStatus.paused
                      ? Icons.videocam_off_rounded
                      : Icons.signal_wifi_statusbar_connected_no_internet_4,
                  size: 20.w,
                  color: AppColors.white,
                ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCallTopBar extends StatelessWidget {
  const _MessageCallTopBar({
    required this.callType,
    required this.status,
    required this.useLightText,
  });

  final MessageCallType callType;
  final String status;
  final bool useLightText;

  @override
  Widget build(BuildContext context) {
    final Color textColor = useLightText
        ? AppColors.white
        : AppColors.homePrimaryText;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 8.h),
      child: Row(
        children: <Widget>[
          Icon(
            callType.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
            size: 24.w,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  callType.title,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
