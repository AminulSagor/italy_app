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
          color: AppColors.white,
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
            padding: EdgeInsets.fromLTRB(30.w, 36.h, 30.w, 132.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.wrapper),
                      child: Icon(Icons.close_rounded, color: AppColors.primaryGreen, size: 28.w),
                    ),
                    Expanded(
                      child: Text(
                        'Exam Success',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 28.w),
                  ],
                ),
                SizedBox(height: 58.h),
                Icon(Icons.workspace_premium_rounded, color: AppColors.primaryGreen, size: 190.w),
                SizedBox(height: 42.h),
                Text(
                  'Exam Submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font38.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homeDarkGreen,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  "Bravissimo! You've done the hard work.\nNow, it's our turn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 42.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.reportReviewBg,
                    borderRadius: BorderRadius.circular(kHomePillRadius.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '#',
                        style: TextStyle(
                          fontSize: AppFont.font26.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.reportReviewText,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Reference ID: ${controller.referenceId.value}',
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.reportReviewText,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.copy_rounded, color: AppColors.reportReviewText, size: 22.w),
                    ],
                  ),
                ),
                SizedBox(height: 46.h),
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
                    borderRadius: BorderRadius.circular(kRadius28.r),
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
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          color: AppColors.coursesCreamLightBg,
                          borderRadius: BorderRadius.circular(kRadius16.r),
                        ),
                        child: Icon(Icons.lightbulb_rounded, color: AppColors.vocabularyOrangeShadow, size: 32.w),
                      ),
                      SizedBox(width: 22.w),
                      Expanded(
                        child: Text(
                          'While you wait, why not try a Daily Challenge or start Level A2 for free?',
                          style: TextStyle(
                            fontSize: AppFont.font18.sp,
                            height: 1.35,
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
      padding: EdgeInsets.fromLTRB(34.w, 32.h, 34.w, 34.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius34.r),
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
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
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
            subtitle: teacherDone ? 'Manual review completed' : 'Reviewing Speaking & Writing...',
            icon: Icons.circle,
          ),
          _TimelineStep(
            isDone: resultDone,
            isActive: resultDone,
            title: 'Result & Certificate',
            subtitle: resultDone ? 'Result is ready' : 'Unlock your achievement',
            icon: resultDone ? Icons.check_rounded : Icons.lock_outline_rounded,
            showConnector: false,
          ),
          SizedBox(height: 22.h),
          if (resultDone)
            GestureDetector(
              onTap: onViewResultTap,
              child: Container(
                width: double.infinity,
                height: 58.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.homeSoftGreen,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  'View Result',
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w900,
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
                  Icon(Icons.access_time_rounded, color: AppColors.primaryGreen, size: 22.w),
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
    final Color color = isActive ? AppColors.primaryGreen : AppColors.quizAnswerShadow;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.white, size: 24.w),
              ),
              if (showConnector)
                Expanded(
                  child: Container(width: 4.w, color: isDone ? AppColors.primaryGreen : AppColors.quizProgressTrack),
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
                      fontSize: AppFont.font20.sp,
                      fontWeight: FontWeight.w900,
                      color: isActive ? AppColors.homePrimaryText : AppColors.quizAnswerShadow,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: isActive ? AppColors.bodyText : AppColors.quizAnswerShadow,
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
