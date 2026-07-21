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
              'webinar_participants_watching'.trParams(<String, String>{
                'value': controller.participantsTotal.value.toString(),
              }),
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
            Positioned.fill(
              child: _RemoteAgoraVideoGrid(controller: controller),
            ),
            Positioned(
              left: 24.w,
              top: 20.h,
              child: _HostChip(webinar: webinar),
            ),
            Positioned(
              left: 26.w,
              bottom: 28.h,
              child: _VideoControlIcon(controller: controller),
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
        return _VideoPlaceholder(text: 'waiting_for_host_video'.tr);
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
        'webinar_host_value'.trParams(<String, String>{
          'host': webinar.hostTeacherName,
        }),
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
        child: Icon(
          Icons.fullscreen_rounded,
          color: AppColors.white,
          size: 28.w,
        ),
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

class _WebinarVideoFullScreenViewState
    extends State<WebinarVideoFullScreenView> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
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
    this.showTitle = true,
  });

  final WebinarController controller;
  final bool compact;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int itemCount = compact
          ? math.min(controller.liveMessages.length, 3)
          : controller.liveMessages.length;

      final Widget list = ListView.separated(
        controller: compact ? null : controller.chatScrollController,
        shrinkWrap: compact,
        physics: compact
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: compact ? 12.h : 16.h),
        itemBuilder: (_, int index) {
          final int messageIndex = controller.liveMessages.length - 1 - index;

          final WebinarLiveChatModel message =
              controller.liveMessages[messageIndex];

          return WebinarAnimatedChatBubble(
            key: ValueKey<String>(
              '${message.createdAt?.microsecondsSinceEpoch}_'
              '${message.senderName}_'
              '${message.message}',
            ),
            message: message,
            compact: compact,
          );
        },
      );

      if (compact || !showTitle) {
        return list;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'live_chat'.tr,
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

    final Color avatarTextColor = message.colorIndex == 1
        ? AppColors.white
        : AppColors.primaryGreen;

    final Color bubbleColor = compact
        ? AppColors.black.withValues(alpha: 0.72)
        : AppColors.webinarChatBubble;

    final Color senderTextColor = compact
        ? AppColors.limeTextColor
        : AppColors.primaryGreen;

    final Color timeTextColor = compact
        ? AppColors.white.withValues(alpha: 0.75)
        : AppColors.bodyText;

    final Color messageTextColor = compact
        ? AppColors.white
        : AppColors.bodyText;

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
                : compact
                ? Border.all(color: AppColors.white.withValues(alpha: 0.35))
                : null,
          ),
          child: ClipOval(
            child:
                message.senderProfilePhoto != null &&
                    message.senderProfilePhoto!.trim().isNotEmpty
                ? Image.network(
                    message.senderProfilePhoto!,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildInitialAvatar(avatarTextColor);
                        },
                  )
                : _buildInitialAvatar(avatarTextColor),
          ),
        ),

        SizedBox(width: compact ? 10.w : 16.w),

        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12.w : 14.w,
              vertical: compact ? 10.h : 14.h,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(compact ? 18.r : kRadius28.r),
              border: message.isHost
                  ? Border.all(color: AppColors.webinarHeroBorder, width: 2.w)
                  : compact
                  ? Border.all(color: AppColors.white.withValues(alpha: 0.20))
                  : null,
              boxShadow: compact
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.35),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
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
                          'host'.tr,
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
                          color: senderTextColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Text(
                      _formatChatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: timeTextColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Text(
                  message.message,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: compact ? FontWeight.w500 : FontWeight.w400,
                    color: messageTextColor,
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

  Widget _buildInitialAvatar(Color textColor) {
    return Center(
      child: Text(
        message.initials,
        style: TextStyle(
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  String _formatChatTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final int hour = value.hour;
    final int minute = value.minute;

    final String suffix = hour >= 12 ? 'pm'.tr : 'am'.tr;

    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:'
        '${minute.toString().padLeft(2, '0')} '
        '$suffix';
  }
}

class WebinarChatInput extends StatefulWidget {
  const WebinarChatInput({super.key, required this.controller});

  final WebinarController controller;

  @override
  State<WebinarChatInput> createState() => _WebinarChatInputState();
}

class _WebinarChatInputState extends State<WebinarChatInput> {
  bool _isSending = false;

  Future<void> _handleSend() async {
    final String message = widget.controller.chatTextController.text.trim();

    if (message.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.controller.sendMessage();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

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
              controller: widget.controller.chatTextController,
              enabled: !_isSending,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'gen_write_a_message'.tr,
                hintStyle: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: _isSending ? null : _handleSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: _isSending
                    ? AppColors.primaryGreen.withValues(alpha: 0.65)
                    : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: _isSending
                      ? SizedBox(
                          key: const ValueKey<String>('loading'),
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.limeTextColor,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          key: const ValueKey<String>('send'),
                          color: AppColors.limeTextColor,
                          size: 26.w,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebinarAnimatedChatBubble extends StatefulWidget {
  const WebinarAnimatedChatBubble({
    super.key,
    required this.message,
    required this.compact,
  });

  final WebinarLiveChatModel message;
  final bool compact;

  @override
  State<WebinarAnimatedChatBubble> createState() =>
      _WebinarAnimatedChatBubbleState();
}

class _WebinarAnimatedChatBubbleState extends State<WebinarAnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.centerLeft,
          child: WebinarChatBubble(
            message: widget.message,
            compact: widget.compact,
          ),
        ),
      ),
    );
  }
}

class _RemoteAgoraVideoGrid extends StatelessWidget {
  const _RemoteAgoraVideoGrid({required this.controller});

  final WebinarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RtcEngine? engine = controller.agoraService.engine;
      final String? channelName = controller.agoraService.activeChannelName;

      final List<int> remoteUids = controller.agoraService.remoteVideoUids
          .toList();

      if (engine == null || channelName == null || remoteUids.isEmpty) {
        return _VideoPlaceholder(text: 'waiting_for_host_video'.tr);
      }

      Widget buildRemoteVideo(int uid) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(
              uid: uid,
              renderMode: RenderModeType.renderModeHidden,
            ),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      }

      if (remoteUids.length == 1) {
        return buildRemoteVideo(remoteUids.first);
      }

      return Row(
        children: <Widget>[
          Expanded(child: buildRemoteVideo(remoteUids[0])),
          SizedBox(width: 2.w),
          Expanded(child: buildRemoteVideo(remoteUids[1])),
        ],
      );
    });
  }
}
