import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/message_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageChatItemModel message;

  const ChatMessageBubble({super.key, required this.message});

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
            child: GestureDetector(
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
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(
            left: message.isMine ? 0 : 22.w,
            right: message.isMine ? 0 : 0,
          ),
          child: Row(
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
        ),
      ],
    );
  }
}
