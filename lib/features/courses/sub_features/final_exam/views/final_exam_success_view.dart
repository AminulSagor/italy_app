import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/final_exam_controller.dart';

class FinalExamSuccessView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamSuccessView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(28.w, 18.h, 28.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 22.r,
              offset: Offset(0, -8.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: CustomButton.primary(
            onPressed: () => Get.offAllNamed(AppRoutes.wrapper),
            text: 'Back To Practice HUB',
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 80.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.wrapper),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryGreen,
                        size: 28.w,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Exam Success',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 28.w),
                  ],
                ),
                SizedBox(height: 30.h),
                Image.asset('assets/decor_png/achievement_2.png'),
                SizedBox(height: 36.h),
                Text(
                  'Exam Submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font34.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBtnShadow,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Bravissimo! You've done the hard work. Now, it's our turn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 38.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 14.h,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.reportReviewBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '#',
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.reportReviewText,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Reference ID: ${controller.referenceId.value}',
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.reportReviewText,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.copy_rounded,
                        color: AppColors.reportReviewText,
                        size: 18.w,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                _TimelineCard(
                  teacherDone: controller.teacherReviewComplete.value,
                  resultDone: controller.resultComplete.value,
                  onViewResultTap: controller.openResult,
                ),
                SizedBox(height: 34.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(kRadius32.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.homeNeutralShadow,
                        blurRadius: 18.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: AppColors.coursesCreamLightBg,
                          borderRadius: BorderRadius.circular(kRadius16.r),
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.vocabularyOrangeShadow,
                          size: 28.w,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Text(
                          'While you wait, why not try a Daily Challenge or start Level A2 for free?',
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: AppColors.homePrimaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final bool teacherDone;
  final bool resultDone;
  final VoidCallback onViewResultTap;

  const _TimelineCard({
    required this.teacherDone,
    required this.resultDone,
    required this.onViewResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius48.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'EVALUATION TIMELINE',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 28.h),
          _TimelineStep(
            isDone: true,
            isActive: true,
            title: 'Exam Received',
            subtitle: 'Successfully uploaded to server',
            icon: Icons.check_rounded,
          ),
          _TimelineStep(
            isDone: teacherDone,
            isActive: teacherDone,
            title: 'Teacher Review',
            subtitle: teacherDone
                ? 'Manual review completed'
                : 'Reviewing Speaking & Writing...',
            icon: teacherDone ? Icons.check_rounded : Icons.circle,
          ),
          _TimelineStep(
            isDone: resultDone,
            isActive: resultDone,
            title: 'Result & Certificate',
            subtitle: resultDone
                ? 'Result is ready'
                : 'Unlock your achievement',
            icon: resultDone ? Icons.check_rounded : Icons.lock_outline_rounded,
            showConnector: false,
          ),
          SizedBox(height: 16.h),
          if (resultDone)
            GestureDetector(
              onTap: onViewResultTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.homeSoftGreen,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  'View Result',
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFF1F2F2,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time_rounded,
                    color: AppColors.primaryGreen,
                    size: 22.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Estimated Result: 24 - 48 Hours',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final bool isDone;
  final bool isActive;
  final bool showConnector;
  final String title;
  final String subtitle;
  final IconData icon;

  const _TimelineStep({
    required this.isDone,
    required this.isActive,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.showConnector = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? AppColors.primaryGreen
        : AppColors.quizAnswerShadow;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.white, size: 20.w),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 4.w,
                    color: isDone
                        ? AppColors.primaryGreen
                        : AppColors.quizProgressTrack,
                  ),
                ),
            ],
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 34.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.homePrimaryText
                          : AppColors.quizAnswerShadow,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                      color: isActive
                          ? AppColors.bodyText
                          : AppColors.quizAnswerShadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
