import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../ widgets/message_call_controls.dart';
import '../ widgets/message_call_participant_card.dart';
import '../ widgets/message_video_placeholder.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/message_call_controller.dart';
import '../models/ message_call_models.dart';


class MessageCallView extends GetView<MessageCallController> {
  const MessageCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageCallType callType = controller.callType;

    return Scaffold(
      backgroundColor: callType.isVideo
          ? AppColors.black
          : AppColors.homeBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        return Stack(
          children: <Widget>[
            if (callType.isVideo)
              Positioned.fill(
                child: MessageVideoPlaceholder(
                  isCameraOff: controller.isCameraOff.value,
                  isFrontCamera: controller.isFrontCamera.value,
                ),
              ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  _MessageCallTopBar(callType: callType),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: MessageCallParticipantCard(
                          participant: controller.participant,
                          durationLabel: controller.durationLabel.value,
                          isVideoCall: callType.isVideo,
                        ),
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
          ],
        );
      }),
    );
  }
}

class _MessageCallTopBar extends StatelessWidget {
  final MessageCallType callType;

  const _MessageCallTopBar({required this.callType});

  @override
  Widget build(BuildContext context) {
    final Color textColor =
    callType.isVideo ? AppColors.white : AppColors.homePrimaryText;

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
          Text(
            callType.title,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}