import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';

class WebinarStageArea extends StatelessWidget {
  final WebinarController controller;

  const WebinarStageArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isTalking = controller.isTalking.value;

      return Container(
        height: kWebinarStagePanelHeight.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(30.w, 32.h, 30.w, 28.h),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kWebinarStageRadius.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.webinarStagePanelBg.withValues(alpha: 0.10),
                        AppColors.webinarStagePanelBg.withValues(alpha: 0.05),
                        AppColors.white.withValues(alpha: 0.50),
                      ],
                      stops: const <double>[0.0, 0.52, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.bar_chart_rounded,
                color: AppColors.webinarHeroBorder,
                size: 26.w,
              ),
            ),
            Positioned.fill(
              child: _StageMessagePreview(controller: controller),
            ),
          ],
        ),
      );
    });
  }
}

class _StageMessagePreview extends StatelessWidget {
  final WebinarController controller;

  const _StageMessagePreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<WebinarLiveChatModel> messages =
          controller.latestStageMessages;
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
          final double bottom = 22.h + (visualIndex * 52.h);
          final double left = switch (visualIndex) {
            0 => 145.w,
            1 => 130.w,
            _ => 85.w,
          };
          final double right = switch (visualIndex) {
            0 => 0.w,
            1 => 8.w,
            _ => 38.w,
          };

          return Positioned(
            left: left,
            right: right,
            bottom: bottom,
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
  final WebinarLiveChatModel message;

  const _StageMessageChip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
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
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${message.senderName}  ',
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  TextSpan(
                    text: message.message,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
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

class _LiveUserChip extends StatelessWidget {
  const _LiveUserChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Text(
        'Tu (In Diretta)',
        style: TextStyle(
          fontSize: AppFont.font20.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class WebinarStageControls extends StatelessWidget {
  final WebinarController controller;

  const WebinarStageControls({super.key, required this.controller});

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
              icon: controller.isMicEnabled.value
                  ? Icons.mic_rounded
                  : Icons.mic_off_rounded,
              isActive: controller.isMicEnabled.value,
            ),
          ),
          SizedBox(width: 26.w),
          GestureDetector(
            onTap: controller.toggleCamera,
            child: _RoundControl(
              icon: controller.isCameraEnabled.value
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
            ),
          ),
          SizedBox(width: 26.w),
          const _RoundControl(icon: Icons.flip_camera_ios_rounded),
          SizedBox(width: 26.w),
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
  final IconData icon;
  final bool isActive;

  const _RoundControl({required this.icon, this.isActive = false});

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
