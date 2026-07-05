import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class CourseProBanner extends StatelessWidget {
  final bool isLoading;
  final String courseName;
  final int lessonCount;
  final VoidCallback onGetProTap;

  const CourseProBanner({
    super.key,
    required this.isLoading,
    required this.courseName,
    required this.lessonCount,
    required this.onGetProTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kCourseDetailBannerHeight.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 22.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.coursesDetailBannerBg,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 13.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: AppColors.coursesCreamText,
              size: 21.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'unlock_coursename'.trParams(<String, String>{'coursename': courseName.toString()}),
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'lessoncount_lessons_included'.trParams(<String, String>{'lessoncount': lessonCount.toString()}),
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.coursesCreamText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : onGetProTap,
            child: Container(
              height: 72.h,
              width: 94.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: AppColors.modalBorderGrey,
                  width: 2.w,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.modalBorderGrey,
                    blurRadius: 0,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Text(
                      'Get\nPro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.coursesCreamText,
                        height: 1.25,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
