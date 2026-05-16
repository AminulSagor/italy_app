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
          child: Container(
            width: kCourseDetailBackButtonSize.w,
            height: kCourseDetailBackButtonSize.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.homeNeutralShadow,
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: 24.w,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
              letterSpacing: -0.6,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: progressLabel == '100%'
                ? AppColors.homeGreenChip
                : AppColors.coursesProgressBadgeBg,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            progressLabel,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.coursesCreamText,
            ),
          ),
        ),
      ],
    );
  }
}
