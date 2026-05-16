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
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.homePrimaryText,
            size: 24.w,
          ),
        ),
        SizedBox(width: 22.w),
        Expanded(
          child: Text(
            webinar.liveTitle,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.webinarViewerBadge,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            '${webinar.watchingCount} Watching',
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w600,
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
                        width: 8.w,
                        height: 8.w,
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
                        fontSize: AppFont.font12.sp,
                        fontWeight: showTopHostChip
                            ? FontWeight.w500
                            : FontWeight.w900,
                        color: showTopHostChip
                            ? AppColors.white
                            : AppColors.black,
                      ),
                    ),
                    if (!showTopHostChip) ...<Widget>[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryGreen,
                        size: 18.w,
                      ),
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
      width: 40.w,
      height: 40.w,
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
      fontSize: AppFont.font16,
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
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 22.h),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: compact
                ? math.min(controller.liveMessages.length, 3)
                : math.min(controller.liveMessages.length, 8),
            separatorBuilder: (_, __) =>
                SizedBox(height: compact ? 12.h : 20.h),
            itemBuilder: (_, int index) {
              final int start = compact
                  ? math.max(0, controller.liveMessages.length - 3)
                  : math.max(0, controller.liveMessages.length - 8);
              return WebinarChatBubble(
                message: controller.liveMessages[start + index],
                compact: compact,
              );
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
    final Color textColor = message.colorIndex == 1
        ? AppColors.white
        : AppColors.primaryGreen;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: compact ? 40.w : 40.w,
          height: compact ? 40.w : 40.w,
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
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.webinarChatBubble.withValues(
                alpha: compact ? 0.58 : 1,
              ),
              borderRadius: BorderRadius.circular(
                compact ? kRadius22.r : kRadius28.r,
              ),
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
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w900,
                          color: message.isHost
                              ? AppColors.primaryGreen
                              : AppColors.bodyText,
                        ),
                      ),
                    ),
                    if (message.isHost) ...<Widget>[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryGreen,
                        size: 18.w,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.homePrimaryText.withValues(
                      alpha: compact ? 0.68 : 1,
                    ),
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
      padding: EdgeInsets.only(left: 24.w, right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
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
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.proHintText,
                ),
              ),
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppColors.limeTextColor,
                size: 28.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
