import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/message_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onTap,
  });

  final MessageChatItemModel message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool alignRight = message.isMine || message.isSystem;
    final CrossAxisAlignment alignment = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Align(
          alignment: message.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 0.76.sw),
            child: message.isCall
                ? _CallHistoryCard(message: message, onTap: onTap)
                : _TextMessageCard(message: message),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message.timeLabel,
              style: TextStyle(
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.bodyText,
              ),
            ),
            if (message.statusLabel.isNotEmpty) ...<Widget>[
              SizedBox(width: 12.w),
              Text(
                message.statusLabel,
                style: TextStyle(
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w500,
                  color: message.statusLabel == 'Seen'
                      ? AppColors.chatSeenText
                      : AppColors.bodyText,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TextMessageCard extends StatelessWidget {
  const _TextMessageCard({required this.message});

  final MessageChatItemModel message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.text));
        Get.snackbar(
          'Copied',
          'Message copied to clipboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.homeBackground,
          colorText: AppColors.homePrimaryText,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: message.isSystem
              ? AppColors.chatDateChipBg
              : (message.isMine
                    ? AppColors.primaryGreen
                    : AppColors.chatIncomingBubbleBg),
          borderRadius: BorderRadius.circular(kChatBubbleRadius.r),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w400,
            height: 1.42,
            color: message.isSystem
                ? AppColors.homePrimaryText
                : (message.isMine
                      ? AppColors.limeTextColor
                      : AppColors.homePrimaryText),
          ),
        ),
      ),
    );
  }
}

class _CallHistoryCard extends StatelessWidget {
  const _CallHistoryCard({required this.message, this.onTap});

  final MessageChatItemModel message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isVideo = message.callType == MessageChatCallType.video;
    final bool isCompleted =
        message.callStatus == MessageChatCallStatus.completed;
    final bool isMissed = message.callStatus == MessageChatCallStatus.missed;
    final bool isRejected =
        message.callStatus == MessageChatCallStatus.rejected;
    final Color foreground = message.isMine
        ? AppColors.limeTextColor
        : AppColors.homePrimaryText;
    final Color iconColor = isCompleted
        ? foreground
        : AppColors.notificationRed;

    return Material(
      color: message.isMine
          ? AppColors.primaryGreen
          : AppColors.chatIncomingBubbleBg,
      borderRadius: BorderRadius.circular(kChatBubbleRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kChatBubbleRadius.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon(isVideo: isVideo, isCompleted: isCompleted),
                  size: 24.w,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _title(
                        isVideo: isVideo,
                        isMissed: isMissed,
                        isRejected: isRejected,
                        isCompleted: isCompleted,
                      ),
                      style: TextStyle(
                        fontSize: AppFont.font15.sp,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isCompleted
                          ? _durationLabel(message.callDurationSeconds)
                          : 'Tap to call back',
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w500,
                        color: foreground.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon({required bool isVideo, required bool isCompleted}) {
    if (isCompleted) {
      return isVideo ? Icons.videocam_rounded : Icons.call_rounded;
    }
    return isVideo ? Icons.videocam_off_rounded : Icons.phone_missed_rounded;
  }

  String _title({
    required bool isVideo,
    required bool isMissed,
    required bool isRejected,
    required bool isCompleted,
  }) {
    final String type = isVideo ? 'video' : 'voice';
    if (isCompleted) return '${isVideo ? 'Video' : 'Voice'} call';
    if (isMissed) return 'Missed $type call';
    if (isRejected) return '${isVideo ? 'Video' : 'Voice'} call rejected';
    return '${isVideo ? 'Video' : 'Voice'} call failed';
  }

  String _durationLabel(int totalSeconds) {
    final int safeSeconds = totalSeconds.clamp(0, 24 * 60 * 60).toInt();
    final int minutes = safeSeconds ~/ 60;
    final int seconds = safeSeconds % 60;
    if (minutes == 0) return '$seconds sec';
    if (seconds == 0) return '$minutes min';
    return '$minutes min $seconds sec';
  }
}
