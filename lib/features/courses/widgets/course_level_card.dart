import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';
import 'package:get/get.dart';

class CourseLevelCard extends StatelessWidget {
  final CourseCardModel course;
  final VoidCallback onTap;

  const CourseLevelCard({super.key, required this.course, required this.onTap});

  bool get _isActive => course.state == CourseCardState.active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kCourseCardWidth.w,
        height: kCourseCardHeight,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: _isActive ? AppColors.primaryGreen : AppColors.coursesCardInactiveBg,
          borderRadius: BorderRadius.circular(kCourseCardRadius.r),
          border: Border.all(
            color: _isActive ? AppColors.primaryGreen : AppColors.coursesCardInactiveBorder,
            width: 2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Opacity(
          opacity: _isActive ? 1 : 0.52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: _isActive
                          ? AppColors.white.withValues(alpha: 0.22)
                          : AppColors.coursesCardDisabledIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 36.w,
                      color: _isActive ? AppColors.white : AppColors.coursesCardDisabledText,
                    ),
                  ),
                  if (_isActive)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.homeLime,
                        borderRadius: BorderRadius.circular(kHomePillRadius.r),
                      ),
                      child: Text(
                        course.statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font26.sp,
                  fontWeight: FontWeight.w900,
                  color: _isActive ? AppColors.white : AppColors.coursesCardDisabledText,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                course.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w500,
                  color: _isActive
                      ? AppColors.white.withValues(alpha: 0.9)
                      : AppColors.coursesCardDisabledText,
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'progress'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: _isActive
                          ? AppColors.white.withValues(alpha: 0.86)
                          : AppColors.coursesCardDisabledText,
                    ),
                  ),
                  Text(
                    course.progressLabel,
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w900,
                      color: _isActive ? AppColors.white : AppColors.coursesCardDisabledText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 12.h,
                  color: AppColors.homeLime,
                  backgroundColor: _isActive
                      ? AppColors.white.withValues(alpha: 0.24)
                      : AppColors.homeProgressTrack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
