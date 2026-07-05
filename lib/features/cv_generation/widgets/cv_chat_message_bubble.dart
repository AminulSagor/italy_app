import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_assistant_models.dart';

class CvChatMessageBubble extends StatelessWidget {
  const CvChatMessageBubble({
    required this.message,
    this.onRetry,
    super.key,
  });

  final CvAssistantMessageModel message;
  final VoidCallback? onRetry;

  bool get _isPending {
    return message.metadata['localState'] == 'sending';
  }

  bool get _isFailed {
    return message.metadata['localState'] == 'failed';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: AnimatedOpacity(
        duration: const Duration(
          milliseconds: 180,
        ),
        opacity: _isPending ? 0.68 : 1,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 0.82.sw,
          ),
          margin: EdgeInsets.only(
            bottom: 12.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 17.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primaryGreen
                : Colors.white,
            border: Border.all(
              color: _isFailed
                  ? Colors.redAccent
                  : Colors.transparent,
              width: _isFailed ? 1.2 : 0,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(
                isUser ? 20.r : 5.r,
              ),
              bottomRight: Radius.circular(
                isUser ? 5.r : 20.r,
              ),
            ),
            boxShadow: isUser
                ? null
                : <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.45,
                  color: isUser
                      ? Colors.white
                      : AppColors.homePrimaryText,
                ),
              ),

              SizedBox(height: 7.h),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: isUser
                          ? Colors.white70
                          : AppColors
                          .homeSecondaryText,
                    ),
                  ),

                  if (_isPending) ...<Widget>[
                    SizedBox(width: 7.w),
                    SizedBox(
                      width: 11.w,
                      height: 11.w,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: isUser
                            ? Colors.white70
                            : AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'cv_chat_message_sending'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isUser
                            ? Colors.white70
                            : AppColors
                            .homeSecondaryText,
                      ),
                    ),
                  ],

                  if (_isFailed) ...<Widget>[
                    SizedBox(width: 7.w),
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14.w,
                      color: isUser
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'cv_chat_message_failed'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: isUser
                            ? Colors.white
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ],
              ),

              if (_isFailed &&
                  onRetry != null) ...<Widget>[
                SizedBox(height: 7.h),
                InkWell(
                  onTap: onRetry,
                  borderRadius:
                  BorderRadius.circular(10.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.refresh_rounded,
                          size: 16.w,
                          color: isUser
                              ? Colors.white
                              : AppColors
                              .primaryGreen,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'cv_chat_message_retry'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight:
                            FontWeight.w800,
                            color: isUser
                                ? Colors.white
                                : AppColors
                                .primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(
      DateTime? dateTime,
      ) {
    if (dateTime == null) {
      return '';
    }

    final DateTime local = dateTime.toLocal();

    final int hour =
    local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;

    final String minute =
    local.minute.toString().padLeft(2, '0');

    final String period =
    local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}