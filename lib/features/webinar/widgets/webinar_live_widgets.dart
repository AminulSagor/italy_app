import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/webinar_controller.dart';
import '../models/webinar_models.dart';
import 'webinar_common_widgets.dart';

class WebinarLiveHeader extends StatelessWidget {
  final WebinarModel webinar;
  final VoidCallback onBackTap;

  const WebinarLiveHeader({
    super.key,
    required this.webinar,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          child: Icon(Icons.arrow_back_rounded, color: AppColors.homePrimaryText, size: 34.w),
        ),
        SizedBox(width: 36.w),
        Expanded(
          child: Text(
            webinar.liveTitle,
            style: TextStyle(
              fontSize: AppFont.font34.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.webinarViewerBadge,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            '${webinar.watchingCount} Watching',
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class WebinarVideoCard extends StatelessWidget {
  final WebinarModel webinar;
  final bool alt;
  final bool showTopHostChip;

  const WebinarVideoCard({
    super.key,
    required this.webinar,
    this.alt = false,
    this.showTopHostChip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kWebinarLiveVideoHeight.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kWebinarLiveVideoRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kWebinarLiveVideoRadius.r),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: WebinarTeacherImage(
                alt: alt,
                borderRadius: kWebinarLiveVideoRadius,
              ),
            ),
            Positioned(
              left: showTopHostChip ? 24.w : 46.w,
              bottom: showTopHostChip ? null : 34.h,
              top: showTopHostChip ? 20.h : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: showTopHostChip
                      ? AppColors.webinarHostChipBg
                      : AppColors.legacyColorFFD5D5D5,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (showTopHostChip) ...<Widget>[
                      Container(
                        width: 11.w,
                        height: 11.w,
                        decoration: const BoxDecoration(
                          color: AppColors.webinarViewerBadge,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 9.w),
                    ],
                    Text(
                      showTopHostChip
                          ? 'Host: ${webinar.hostName}'
                          : 'Host: ${webinar.hostName}',
                      style: TextStyle(
                        fontSize: showTopHostChip ? AppFont.font20.sp : AppFont.font22.sp,
                        fontWeight: showTopHostChip ? FontWeight.w500 : FontWeight.w900,
                        color: showTopHostChip ? AppColors.white : AppColors.black,
                      ),
                    ),
                    if (!showTopHostChip) ...<Widget>[
                      SizedBox(width: 10.w),
                      Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 24.w),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 26.w,
              bottom: 28.h,
              child: _VideoControlIcon(icon: Icons.fullscreen_rounded),
            ),
            Positioned(
              right: 26.w,
              bottom: 28.h,
              child: const WebinarLiveBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoControlIcon extends StatelessWidget {
  final IconData icon;

  const _VideoControlIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, color: AppColors.white, size: 28.w),
    );
  }
}

class WebinarRequestButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const WebinarRequestButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton.primary(
      onPressed: onTap,
      text: text,
      icon: icon,
      textSize: AppFont.font24,
    );
  }
}

class WebinarLiveChatSection extends StatelessWidget {
  final WebinarController controller;
  final bool compact;

  const WebinarLiveChatSection({
    super.key,
    required this.controller,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!compact) ...<Widget>[
            Text(
              'Live Chat',
              style: TextStyle(
                fontSize: AppFont.font30.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 22.h),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: compact
                ? math.min(controller.liveMessages.length, 4)
                : math.min(controller.liveMessages.length, 8),
            separatorBuilder: (_, __) => SizedBox(height: compact ? 12.h : 20.h),
            itemBuilder: (_, int index) {
              final int start = compact
                  ? math.max(0, controller.liveMessages.length - 4)
                  : math.max(0, controller.liveMessages.length - 8);
              return WebinarChatBubble(message: controller.liveMessages[start + index], compact: compact);
            },
          ),
        ],
      ),
    );
  }
}

class WebinarChatBubble extends StatelessWidget {
  final WebinarLiveChatModel message;
  final bool compact;

  const WebinarChatBubble({
    super.key,
    required this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color avatarColor = switch (message.colorIndex) {
      1 => AppColors.primaryGreen,
      2 => AppColors.webinarAccentOrange,
      _ => AppColors.webinarAccentBlue,
    };
    final Color textColor = message.colorIndex == 1 ? AppColors.white : AppColors.primaryGreen;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: compact ? 42.w : 56.w,
          height: compact ? 42.w : 56.w,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
            border: message.isHost
                ? Border.all(color: AppColors.webinarHeroBorder, width: 3.w)
                : null,
          ),
          child: Center(
            child: Text(
              message.initials,
              style: TextStyle(
                fontSize: compact ? AppFont.font13.sp : AppFont.font18.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 18.h),
            decoration: BoxDecoration(
              color: AppColors.webinarChatBubble.withValues(alpha: compact ? 0.58 : 1),
              borderRadius: BorderRadius.circular(compact ? kRadius22.r : kRadius28.r),
              border: message.isHost && !compact
                  ? Border.all(color: AppColors.webinarHostBorder, width: 2.w)
                  : null,
              boxShadow: compact
                  ? const <BoxShadow>[]
                  : <BoxShadow>[
                      BoxShadow(
                        color: AppColors.homeNeutralShadow,
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        message.senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? AppFont.font14.sp : AppFont.font17.sp,
                          fontWeight: FontWeight.w900,
                          color: message.isHost ? AppColors.primaryGreen : AppColors.bodyText,
                        ),
                      ),
                    ),
                    if (message.isHost) ...<Widget>[
                      SizedBox(width: 10.w),
                      Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 18.w),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: compact ? AppFont.font16.sp : AppFont.font23.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.homePrimaryText.withValues(alpha: compact ? 0.68 : 1),
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WebinarChatInput extends StatelessWidget {
  final WebinarController controller;

  const WebinarChatInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kWebinarChatInputHeight.h,
      padding: EdgeInsets.only(left: 28.w, right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller.chatTextController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: AppFont.font22.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.proHintText,
                ),
              ),
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 58.w,
              height: 58.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: AppColors.limeTextColor, size: 28.w),
            ),
          ),
        ],
      ),
    );
  }
}

class WebinarStageArea extends StatelessWidget {
  final WebinarController controller;

  const WebinarStageArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: kWebinarStagePanelHeight.h,
        padding: EdgeInsets.fromLTRB(30.w, 32.h, 30.w, 28.h),
        decoration: BoxDecoration(
          color: AppColors.webinarStagePanelBg,
          borderRadius: BorderRadius.circular(kWebinarStageRadius.r),
          border: Border.all(
            color: controller.isTalking.value
                ? AppColors.webinarHeroBorder
                : AppColors.webinarStageBorderIdle,
            width: 3.w,
          ),
          boxShadow: controller.isTalking.value
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.webinarStageShadow,
                    blurRadius: 28.r,
                    spreadRadius: 4.r,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.bar_chart_rounded,
                color: AppColors.webinarHeroBorder,
                size: 48.w,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: WebinarLiveChatSection(controller: controller, compact: true),
            ),
            Positioned(
              left: 6.w,
              bottom: 2.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  'Tu (In Diretta)',
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kWebinarStageRadius.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.white.withValues(alpha: 0.05),
                        AppColors.white.withValues(alpha: 0.46),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
              icon: controller.isMicEnabled.value ? Icons.mic_rounded : Icons.mic_off_rounded,
              isActive: controller.isMicEnabled.value,
              isLarge: true,
            ),
          ),
          SizedBox(width: 26.w),
          GestureDetector(
            onTap: controller.toggleCamera,
            child: _RoundControl(
              icon: controller.isCameraEnabled.value ? Icons.videocam_rounded : Icons.videocam_off_rounded,
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
  final bool isLarge;

  const _RoundControl({
    required this.icon,
    this.isActive = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isLarge ? 80 : kWebinarControlSize;
    return Container(
      width: size.w,
      height: size.w,
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
        size: isLarge ? 38.w : 30.w,
      ),
    );
  }
}

class WebinarLeaveStageButton extends StatelessWidget {
  final VoidCallback onTap;

  const WebinarLeaveStageButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          border: Border.all(color: AppColors.profileWarningBorder, width: 2.w),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.exit_to_app_rounded, color: AppColors.webinarLeaveRed, size: 28.w),
            SizedBox(width: 16.w),
            Text(
              'Stop and Leave the Stage',
              style: TextStyle(
                fontSize: AppFont.font26.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.webinarLeaveRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
