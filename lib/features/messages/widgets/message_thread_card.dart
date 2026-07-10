import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/message_models.dart';
import 'message_avatar.dart';

class MessageThreadCard extends StatelessWidget {
  const MessageThreadCard({
    super.key,
    required this.thread,
    this.onTap,
  });

  final MessageThreadModel thread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasUnread =
        thread.unreadCount > 0 || thread.isHighlighted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.messageTileActiveBg
              : AppColors.messageTileInactiveBg,
          borderRadius: BorderRadius.circular(
            kMessageTileRadius.r,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MessageAvatar(
              imageUrl: thread.avatarUrl,
              size: 48,
              showStatus: true,
              isOnline: thread.isOnline,
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          thread.learnerName,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                            AppFont.font16.sp,
                            fontWeight: thread
                                .unreadCount >
                                0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: thread.unreadCount > 0
                                ? AppColors
                                .homePrimaryText
                                : AppColors
                                .primaryGreen,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        thread.timeLabel,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                          thread.unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: thread.unreadCount > 0
                              ? AppColors
                              .homePrimaryText
                              : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                            AppFont.font14.sp,
                            fontWeight: thread
                                .unreadCount >
                                0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.25,
                            color:
                            _previewColor(thread),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      _TrailingStatus(
                        thread: thread,
                      ),
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

Color _previewColor(MessageThreadModel thread) {
  switch (thread.previewTone) {
    case MessageThreadPreviewTone.missed:
      return AppColors.homeNotificationRed;

    case MessageThreadPreviewTone.ongoing:
      return AppColors.messageOnlineGreen;

    case MessageThreadPreviewTone.normal:
      return thread.unreadCount > 0
          ? AppColors.homePrimaryText
          : AppColors.bodyText;
  }
}

class _TrailingStatus extends StatelessWidget {
  const _TrailingStatus({
    required this.thread,
  });

  final MessageThreadModel thread;

  @override
  Widget build(BuildContext context) {
    if (thread.unreadCount > 0 ||
        thread.isHighlighted) {
      return Container(
        width: 10.w,
        height: 10.w,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
      );
    }

    return Icon(
      thread.isDelivered
          ? Icons.done_all_rounded
          : Icons.check_rounded,
      size: 16.w,
      color: thread.isDelivered
          ? AppColors.primaryGreen
          : AppColors.messageCheckGrey,
    );
  }
}