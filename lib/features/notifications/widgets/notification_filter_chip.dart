import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/notification_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class NotificationFilterChip extends StatelessWidget {
  final NotificationFilterModel filter;
  final bool isSelected;
  final ValueChanged<NotificationCategory> onTap;

  const NotificationFilterChip({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(filter.category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: kNotificationChipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.homeLime
              : AppColors.notificationInactiveChipBg,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
        ),
        child: Text(
          filter.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isSelected
              ? TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                )
              : TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
        ),
      ),
    );
  }
}
