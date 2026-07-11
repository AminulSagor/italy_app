import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';

class CourseFinalExamCard extends StatelessWidget {
  final CourseFinalExamModel finalExam;
  final VoidCallback? onTap;

  const CourseFinalExamCard({
    super.key,
    required this.finalExam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 24.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.coursesFinalLockedBg,
          borderRadius: BorderRadius.circular(
            kCourseDetailCardRadius.r,
          ),
          border: Border.all(
            color: AppColors.white,
            width: 2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              finalExam.title.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              finalExam.description.tr,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.bodyText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 22.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 9.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.modalBorderGrey,
                borderRadius: BorderRadius.circular(
                  kHomePillRadius.r,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.verified_outlined,
                    color: AppColors.bodyText,
                    size: 17.sp,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      finalExam.actionLabel.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryGreen,
                  size: 16.sp,
                ),
                SizedBox(width: 7.w),
                Flexible(
                  child: Text(
                    finalExam.helperLabel.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}