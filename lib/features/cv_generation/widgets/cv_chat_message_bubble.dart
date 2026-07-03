import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_assistant_models.dart';

class CvChatMessageBubble
    extends StatelessWidget {
  const CvChatMessageBubble({
    required this.message,
    super.key,
  });

  final CvAssistantMessageModel message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 0.82.sw,
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(
          horizontal: 17.w,
          vertical: 13.h,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primaryGreen
              : Colors.white,
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
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.45,
            color: isUser
                ? Colors.white
                : AppColors.homePrimaryText,
          ),
        ),
      ),
    );
  }
}