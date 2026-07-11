import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class CourseDetailHeader extends StatelessWidget {
  final String title;
  final String progressLabel;
  final VoidCallback onBackTap;

  const CourseDetailHeader({
    super.key,
    required this.title,
    required this.progressLabel,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.homeNeutralShadow,
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
              letterSpacing: -0.3,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          constraints: BoxConstraints(
            minWidth: 52.w,
            minHeight: 32.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 6.h,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: progressLabel == '100%'
                ? AppColors.homeGreenChip
                : AppColors.coursesProgressBadgeBg,
            borderRadius: BorderRadius.circular(
              kHomePillRadius.r,
            ),
          ),
          child: Text(
            progressLabel,
            maxLines: 1,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.coursesCreamText,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}