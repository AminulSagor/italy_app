import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';

class CourseFinalExamCard extends StatelessWidget {
  final CourseFinalExamModel finalExam;

  const CourseFinalExamCard({super.key, required this.finalExam});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 38.h),
      decoration: BoxDecoration(
        color: AppColors.coursesFinalLockedBg,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        border: Border.all(color: AppColors.white, width: 2.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            finalExam.title,
            style: TextStyle(
              fontSize: AppFont.font24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            finalExam.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.bodyText,
              height: 1.42,
            ),
          ),
          SizedBox(height: 36.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.modalBorderGrey,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.verified_outlined,
                  color: AppColors.bodyText,
                  size: 18.w,
                ),
                SizedBox(width: 10.w),
                Text(
                  finalExam.actionLabel,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryGreen,
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  finalExam.helperLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
