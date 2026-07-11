import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

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
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.coursesDetailBannerBg,
        borderRadius: BorderRadius.circular(
          kCourseDetailCardRadius.r,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46.w,
            height: 46.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: AppColors.coursesCreamText,
              size: 21.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'unlock_coursename'.trParams(
                    <String, String>{
                      'coursename': courseName,
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'lessoncount_lessons_included'.trParams(
                    <String, String>{
                      'lessoncount': lessonCount.toString(),
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.coursesCreamText,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: isLoading ? null : onGetProTap,
            child: Container(
              width: 72.w,
              height: 52.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.modalBorderGrey,
                  width: 1.5.w,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.modalBorderGrey,
                    blurRadius: 0,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              )
                  : Text(
                'get_pro'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coursesCreamText,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}