import 'dart:math' as math;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
  const WebinarLiveHeader({
    super.key,
    required this.webinar,
    required this.controller,
  });

  final WebinarItemModel webinar;
  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            final bool shouldPop = await controller.onWillPopLive();
            if (shouldPop) Get.back<void>();
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.homePrimaryText,
            size: 24.w,
          ),
        ),
        SizedBox(width: 22.w),
        Expanded(
          child: Text(
            webinar.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.webinarViewerBadge,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
            ),
            child: Text(
              '${controller.participantsTotal.value} Watching',
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WebinarVideoCard extends StatelessWidget {
  const WebinarVideoCard({
    super.key,
    required this.webinar,
    required this.controller,
  });

  final WebinarItemModel webinar;
  final WebinarController controller;

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
            Positioned.fill(child: _RemoteAgoraVideo(controller: controller)),
            Positioned(left: 24.w, top: 20.h, child: _HostChip(webinar: webinar)),
            Positioned(left: 26.w, bottom: 28.h, child: _VideoControlIcon()),
            Positioned(right: 26.w, bottom: 28.h, child: const WebinarLiveBadge()),
          ],
        ),
      ),
    );
  }
}

class _RemoteAgoraVideo extends StatelessWidget {
  const _RemoteAgoraVideo({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RtcEngine? engine = controller.agoraService.engine;
      final int? remoteUid = controller.agoraService.remoteHostUid.value;
      final String? channelName = controller.agoraService.activeChannelName;
      if (engine == null || remoteUid == null || channelName == null) {
        return const _VideoPlaceholder(text: 'Waiting for host video');
      }

      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    });
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.legacyColorFFECEFF0,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}

class _HostChip extends StatelessWidget {
  const _HostChip({required this.webinar});

  final WebinarItemModel webinar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.webinarHostChipBg,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Text(
        'Host: ${webinar.hostTeacherName}',
        style: TextStyle(
          fontSize: AppFont.font12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _VideoControlIcon extends StatelessWidget {
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
      child: Icon(Icons.fullscreen_rounded, color: AppColors.white, size: 28.w),
    );
  }
}

class WebinarRequestButton extends StatelessWidget {
  const WebinarRequestButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.isDisabled = false,
  });

  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return CustomButton.primary(
      onPressed: isDisabled ? () {} : onTap,
      text: text,
      icon: icon,
      fontSize: AppFont.font16,
      btnColor: isDisabled
          ? AppColors.legacyColorFFD5D5D5
          : AppColors.primaryBtnColor,
      borderColor: isDisabled
          ? AppColors.legacyColorFFD5D5D5
          : AppColors.primaryBtnColor,
      textColor: isDisabled ? AppColors.bodyText : AppColors.limeTextColor,
    );
  }
}

class WebinarLiveChatSection extends StatelessWidget {
  const WebinarLiveChatSection({
    super.key,
    required this.controller,
    this.compact = false,
  });

  final WebinarController controller;
  final bool compact;

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
            separatorBuilder: (_, __) => SizedBox(height: compact ? 12.h : 20.h),
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
  const WebinarChatBubble({
    super.key,
    required this.message,
    this.compact = false,
  });

  final WebinarLiveChatModel message;
  final bool compact;

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
          width: 40.w,
          height: 40.w,
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
              borderRadius: BorderRadius.circular(kRadius28.r),
              border: message.isHost
                  ? Border.all(color: AppColors.webinarHeroBorder, width: 2.w)
                  : null,
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                color: AppColors.bodyText,
                height: 1.28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WebinarChatInput extends StatelessWidget {
  const WebinarChatInput({super.key, required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68.h,
      padding: EdgeInsets.only(left: 24.w, right: 10.w),
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
                hintText: 'Write a message...',
                hintStyle: TextStyle(color: AppColors.bodyText, fontSize: 14.sp),
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
                size: 26.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
