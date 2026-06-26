import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/message_call_controller.dart';
import '../models/message_call_models.dart';
import '../widgets/message_call_controls.dart';
import '../widgets/message_call_participant_card.dart';
import '../widgets/message_video_placeholder.dart';

class MessageCallView extends GetView<MessageCallController> {
  const MessageCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final MessageCallType callType = controller.callType;

      final bool showVideoStage = callType.isVideo && controller.isActive.value;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }

          await controller.endCall();
        },
        child: Scaffold(
          backgroundColor: showVideoStage
              ? AppColors.black
              : AppColors.homeBackground,
          body: Stack(
            children: <Widget>[
              if (showVideoStage) Positioned.fill(child: _buildRemoteVideo()),

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

              if (showVideoStage) _buildLocalVideoPreview(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRemoteVideo() {
    final RtcEngine? engine = controller.agoraEngine;

    final int? remoteUid = controller.agora.remoteUid.value;

    final String? channelName = controller.agoraChannelName;

    if (engine == null ||
        remoteUid == null ||
        channelName == null ||
        channelName.isEmpty) {
      return MessageVideoPlaceholder(
        isCameraOff: controller.isCameraOff.value,
        isFrontCamera: controller.isFrontCamera.value,
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(
          uid: remoteUid,
          renderMode: RenderModeType.renderModeHidden,
        ),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }

  Widget _buildParticipantArea({required bool showVideoStage}) {
    final bool hasRemoteVideo =
        showVideoStage && controller.agora.remoteUid.value != null;

    if (hasRemoteVideo) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: MessageCallParticipantCard(
        participant: controller.participant,
        durationLabel: controller.durationLabel.value,

        // Before answer, use the normal audio-call colors.
        isVideoCall: showVideoStage,
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
