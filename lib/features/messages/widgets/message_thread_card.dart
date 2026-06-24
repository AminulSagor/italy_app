import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message_models.dart';
import 'message_avatar.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class MessageThreadCard extends StatelessWidget {
  final MessageThreadModel thread;
  final VoidCallback? onTap;

  const MessageThreadCard({super.key, required this.thread, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: (thread.isHighlighted || thread.unreadCount > 0)
              ? AppColors.messageTileActiveBg
              : AppColors.messageTileInactiveBg,
          borderRadius: BorderRadius.circular(kMessageTileRadius.r),
        ),
        child: Row(
          children: <Widget>[
            MessageAvatar(
              imageUrl: thread.avatarUrl,
              showStatus: true,
              isOnline: thread.isOnline,
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          thread.learnerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font20.sp,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: thread.unreadCount > 0
                                ? AppColors.homePrimaryText
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        thread.timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: thread.unreadCount > 0
                              ? FontWeight.w800
                              : FontWeight.w500,
                          letterSpacing: 0.7,
                          color: thread.unreadCount > 0
                              ? AppColors.homePrimaryText
                              : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                            height: 1.25,
                            color: thread.unreadCount > 0
                                ? AppColors.homePrimaryText
                                : AppColors.bodyText,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _TrailingStatus(thread: thread),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailingStatus extends StatelessWidget {
  final MessageThreadModel thread;

  const _TrailingStatus({required this.thread});

  @override
  Widget build(BuildContext context) {
    if (thread.unreadCount > 0 || thread.isHighlighted) {
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
      );
    }

    return Icon(
      thread.isDelivered ? Icons.done_all_rounded : Icons.check_rounded,
      size: 18.w,
      color: thread.isDelivered
          ? AppColors.primaryGreen
          : AppColors.messageCheckGrey,
    );
  }
}
