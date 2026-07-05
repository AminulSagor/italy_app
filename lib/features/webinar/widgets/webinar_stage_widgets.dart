import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';

class WebinarStageArea extends StatelessWidget {
  const WebinarStageArea({super.key, required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isTalking = controller.isTalking.value;
      return Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 22.h),
        decoration: BoxDecoration(
          color: AppColors.webinarStagePanelBg,
          borderRadius: BorderRadius.circular(kWebinarStageRadius.r),
          border: Border.all(
            color: isTalking
                ? AppColors.webinarHeroBorder
                : AppColors.webinarStageBorderIdle,
            width: isTalking ? 5.w : 2.w,
          ),
          boxShadow: isTalking
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.webinarStageShadow,
                    blurRadius: 30.r,
                    spreadRadius: 8.r,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((kWebinarStageRadius - 8).r),
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _LocalStageVideo(controller: controller)),
              Positioned.fill(child: _StageMessagePreview(controller: controller)),
            ],
          ),
        ),
      );
    });
  }
}

class _LocalStageVideo extends StatelessWidget {
  const _LocalStageVideo({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RtcEngine? engine = controller.agoraService.engine;
      final bool canShowVideo = controller.agoraService.isBroadcaster.value &&
          controller.agoraService.isCameraEnabled.value &&
          engine != null;

      if (canShowVideo) {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: engine,
            canvas: const VideoCanvas(
              uid: 0,
              renderMode: RenderModeType.renderModeFit,
            ),
          ),
        );
      }

      return _StagePlaceholder(controller: controller);
    });
  }
}

class _StagePlaceholder extends StatelessWidget {
  const _StagePlaceholder({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(color: AppColors.legacyColorFFECEFF0),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Icon(
              Icons.bar_chart_rounded,
              color: AppColors.webinarHeroBorder,
              size: 26.w,
            ),
          ),
        ),
        Center(
          child: Text(
            'your_video_will_appear_here_when_camera_is_on'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}

class _StageMessagePreview extends StatelessWidget {
  const _StageMessagePreview({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<WebinarLiveChatModel> messages = controller.latestStageMessages;
      if (messages.isEmpty) return const SizedBox.shrink();

      return Stack(
        children: List<Widget>.generate(messages.length, (int index) {
          final WebinarLiveChatModel message = messages[index];
          final int visualIndex = messages.length - 1 - index;
          final double opacity = switch (visualIndex) {
            0 => 0.92,
            1 => 0.56,
            _ => 0.24,
          };
          return Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 16.h + (visualIndex * 42.h),
            child: Opacity(
              opacity: opacity,
              child: _StageMessageChip(message: message),
            ),
          );
        }),
      );
    });
  }
}

class _StageMessageChip extends StatelessWidget {
  const _StageMessageChip({required this.message});

  final WebinarLiveChatModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: _avatarColor(message),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              'message_sendername_message_message'.trParams(<String, String>{'sendername': message.senderName.toString(), 'message': message.message.toString()}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(WebinarLiveChatModel message) {
    return switch (message.colorIndex) {
      1 => AppColors.primaryGreen,
      2 => AppColors.webinarAccentOrange,
      _ => AppColors.webinarAccentBlue,
    };
  }
}

class WebinarStageControls extends StatelessWidget {
  const WebinarStageControls({super.key, required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onLongPressStart: (_) => controller.startTalking(),
            onLongPressEnd: (_) => controller.stopTalking(),
            onTap: controller.toggleMic,
            child: _RoundControl(
              icon: controller.agoraService.isMicEnabled.value
                  ? Icons.mic_rounded
                  : Icons.mic_off_rounded,
              isActive: controller.agoraService.isMicEnabled.value,
            ),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: controller.toggleCamera,
            child: _RoundControl(
              icon: controller.agoraService.isCameraEnabled.value
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              isActive: controller.agoraService.isCameraEnabled.value,
            ),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: controller.switchCamera,
            child: const _RoundControl(icon: Icons.flip_camera_ios_rounded),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: controller.openChatMode,
            child: const _RoundControl(icon: Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, this.isActive = false});

  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kWebinarControlSize.w,
      height: kWebinarControlSize.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : AppColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isActive ? AppColors.white : AppColors.black,
        size: 28.w,
      ),
    );
  }
}
