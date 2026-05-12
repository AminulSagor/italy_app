import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class CourseExamSuccessView extends StatelessWidget {
  final String courseTitle;

  const CourseExamSuccessView({super.key, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(26.w, 70.h, 26.w, 38.h),
          child: Column(
            children: <Widget>[
              Container(
                width: kCourseSuccessHeroSize.w,
                height: kCourseSuccessHeroSize.w,
                decoration: BoxDecoration(
                  color: AppColors.coursesSuccessIconBg,
                  borderRadius: BorderRadius.circular(54.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.blockSuccessGlow,
                      blurRadius: 42.r,
                      spreadRadius: 20.r,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 92.w,
                    height: 92.w,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(34.r),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreen,
                      size: 54.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80.h),
              Text(
                'Level A1\nMastered',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font52.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homePrimaryText,
                  height: 1.15,
                  letterSpacing: -2.2,
                ),
              ),
              SizedBox(height: 34.h),
              Text(
                'Congratulations! You finished the final exam and earned your Level A1 certificate.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                  height: 1.55,
                ),
              ),
              SizedBox(height: 52.h),
              Container(
                width: double.infinity,
                height: kCourseSuccessInfoHeight.h,
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                decoration: BoxDecoration(
                  color: AppColors.coursesSuccessInfoBg,
                  borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 68.w,
                      height: 68.w,
                      decoration: const BoxDecoration(
                        color: AppColors.unblockSuccessIconCircle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 34.w),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Certificate Ready',
                            style: TextStyle(
                              fontSize: AppFont.font24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.homePrimaryText,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Your learning milestone is saved.',
                            style: TextStyle(
                              fontSize: AppFont.font18.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton.primary(
                onPressed: () => Get.until((Route<dynamic> route) => route.isFirst),
                text: 'Back To Courses',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
