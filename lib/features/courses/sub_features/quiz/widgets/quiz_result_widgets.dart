import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import 'quiz_common_widgets.dart';

class QuizCorrectAnswerSheet extends StatelessWidget {
  final String meaning;
  final VoidCallback onContinueTap;

  const QuizCorrectAnswerSheet({
    super.key,
    required this.meaning,
    required this.onContinueTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: Container(
          color: AppColors.black.withOpacity(0.20),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(32.w, 52.h, 32.w, 36.h),
            decoration: BoxDecoration(
              color: AppColors.quizCorrectSheetBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(kRadius48.r),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: const BoxDecoration(
                          color: AppColors.quizCorrectIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 32.w,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Excellent!',
                              style: TextStyle(
                                fontSize: AppFont.font22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              meaning,
                              style: TextStyle(
                                fontSize: AppFont.font16.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  CustomButton.primary(
                    text: 'Continue',
                    onPressed: onContinueTap,
                  ),
                ],
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

  const QuizWrongAnswerFeedback({super.key, required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kQuizFeedbackCardMinHeight.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: AppColors.quizWrongSoftBg,
        borderRadius: BorderRadius.circular(kRadius32.r),
        border: Border.all(color: AppColors.quizWrongBorder, width: 2.w),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.notificationRed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.white,
              size: 36.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Oh no!',
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.quizWrongBorder,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "That's not quite right.",
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.quizWrongBorder,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Correct Answer:',
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  correctAnswer,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      backgroundColor: AppColors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(32.w, 58.h, 32.w, 44.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kQuizExitDialogRadius.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: kQuizExitDialogIconSize.w,
              height: kQuizExitDialogIconSize.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: kQuizExitDialogIconSize.w,
                    height: kQuizExitDialogIconSize.w,
                    decoration: const BoxDecoration(
                      color: AppColors.homeLime,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: AppColors.primaryGreen,
                      size: 66.w,
                    ),
                  ),
                  Positioned(
                    right: -10.w,
                    bottom: 0.h,
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: AppColors.homeOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 4.w),
                      ),
                      child: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        color: AppColors.white,
                        size: 24.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Wait! Are you sure?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font30.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "If you quit now, you'll lose your\nprogress and current score for\nthis chapter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton.primary(
              onPressed: onKeepGoingTap,
              text: 'Keep Going  ▶',
            ),
            SizedBox(height: 16.h),
            CustomButton(
              onPressed: onQuitTap,
              text: 'QUIT QUIZ',
              textColor: AppColors.blockDangerRed,
              btnColor: AppColors.white,
              borderColor: AppColors.blockDangerRed,
              textSize: AppFont.font16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
