import 'dart:math' as math;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            Positioned(
              left: 26.w,
              bottom: 28.h,
              child: _VideoControlIcon(controller: controller),
            ),
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
      final int? remoteUid = controller.agoraService.activeRemoteVideoUid;
      final String? channelName = controller.agoraService.activeChannelName;
      if (engine == null || remoteUid == null || channelName == null) {
        return const _VideoPlaceholder(text: 'Waiting for host video');
      }

      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(
            uid: remoteUid,
            renderMode: RenderModeType.renderModeFit,
          ),
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
  const _VideoControlIcon({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to<void>(
        () => WebinarVideoFullScreenView(controller: controller),
        transition: Transition.fadeIn,
      ),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(Icons.fullscreen_rounded, color: AppColors.white, size: 28.w),
      ),
    );
  }
}

class WebinarVideoFullScreenView extends StatefulWidget {
  const WebinarVideoFullScreenView({super.key, required this.controller});

  final WebinarController controller;

  @override
  State<WebinarVideoFullScreenView> createState() =>
      _WebinarVideoFullScreenViewState();
}

class _WebinarVideoFullScreenViewState extends State<WebinarVideoFullScreenView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: _RemoteAgoraVideo(controller: widget.controller),
            ),
            Positioned(
              top: 16.h,
              left: 16.w,
              child: GestureDetector(
                onTap: () => Get.back<void>(),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_fullscreen_rounded,
                    color: AppColors.white,
                    size: 24.w,
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
    return Obx(() {
      final int itemCount = compact
          ? math.min(controller.liveMessages.length, 3)
          : controller.liveMessages.length;
      final int start = compact
          ? math.max(0, controller.liveMessages.length - 3)
          : 0;

      final Widget list = ListView.separated(
        controller: compact ? null : controller.chatScrollController,
        shrinkWrap: compact,
        physics: compact
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: compact ? 12.h : 16.h),
        itemBuilder: (_, int index) => WebinarChatBubble(
          message: controller.liveMessages[start + index],
          compact: compact,
        ),
      );

      if (compact) return list;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Live Chat',
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 14.h),
          Expanded(child: list),
        ],
      );
    });
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
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.webinarChatBubble.withValues(
                alpha: compact ? 0.58 : 1,
              ),
              borderRadius: BorderRadius.circular(kRadius28.r),
              border: message.isHost
                  ? Border.all(color: AppColors.webinarHeroBorder, width: 2.w)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (message.isHost) ...<Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'HOST',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Flexible(
                      child: Text(
                        message.senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatChatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  message.message,
                  maxLines: compact ? 1 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    color: AppColors.bodyText,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatChatTime(DateTime? value) {
    if (value == null) return '';
    final int hour = value.hour;
    final int minute = value.minute;
    final String suffix = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
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
            onTap: () => controller.sendMessage(),
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
