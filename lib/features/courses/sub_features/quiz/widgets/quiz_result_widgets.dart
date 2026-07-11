import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';

class QuizCorrectAnswerSheet extends StatelessWidget {
  final VoidCallback onContinueTap;

  const QuizCorrectAnswerSheet({
    super.key,
    required this.onContinueTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 9,
          sigmaY: 9,
        ),
        child: Container(
          color: AppColors.black.withValues(alpha: 0.20),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.68,
            ),
            decoration: BoxDecoration(
              color: AppColors.quizCorrectSheetBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  28.h,
                  24.w,
                  24.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 52.w,
                          height: 52.w,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.quizCorrectIconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'excellent'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppFont.font20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'your_answer_is_correct'.tr,
                                style: TextStyle(
                                  fontSize: AppFont.font15.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    CustomButton.primary(
                      text: 'continue'.tr,
                      onPressed: onContinueTap,
                      fontSize: AppFont.font14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizWrongAnswerFeedback extends StatelessWidget {
  final String correctAnswer;

  const QuizWrongAnswerFeedback({
    super.key,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 112.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.quizWrongSoftBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.quizWrongBorder,
          width: 1.5.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.notificationRed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'oh_no'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.quizWrongBorder,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'that_s_not_quite_right'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.quizWrongBorder,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'correct_answer'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  correctAnswer,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.primaryGreen,
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

class QuizExitConfirmationDialog extends StatelessWidget {
  final VoidCallback onKeepGoingTap;
  final VoidCallback onQuitTap;

  const QuizExitConfirmationDialog({
    super.key,
    required this.onKeepGoingTap,
    required this.onQuitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 24.h,
      ),
      backgroundColor: AppColors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 22.w,
            vertical: 28.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              kQuizExitDialogRadius.r,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 92.w,
                height: 92.w,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 92.w,
                      height: 92.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.homeLime,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: AppColors.primaryGreen,
                        size: 46.sp,
                      ),
                    ),
                    Positioned(
                      right: -2.w,
                      bottom: 0,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.homeOrange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 4.w,
                          ),
                        ),
                        child: Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          color: AppColors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'wait_are_you_sure'.tr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'quit_quiz_progress_warning'.tr,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 28.h),
              CustomButton.primary(
                onPressed: onKeepGoingTap,
                text: 'keep_going'.tr,
                icon: Icons.play_arrow_rounded,
                fontSize: AppFont.font14.sp,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                onPressed: onQuitTap,
                text: 'quit_quiz'.tr,
                textColor: AppColors.blockDangerRed,
                btnColor: AppColors.white,
                borderColor: AppColors.blockDangerRed,
                showShadow: false,
                fontSize: AppFont.font14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}