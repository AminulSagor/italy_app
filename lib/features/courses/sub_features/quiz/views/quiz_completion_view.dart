import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_completion_widgets.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';

class QuizCompletionView extends GetView<QuizController> {
  final String controllerTag;

  const QuizCompletionView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      body: SafeArea(
        child: Obx(() {
          final QuizLessonCompleteModel? complete =
              controller.lessonComplete.value;

          if (controller.isCompleting.value && complete == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (complete == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              kLessonCompleteHorizontalPadding.w,
              20.h,
              kLessonCompleteHorizontalPadding.w,
              20.h,
            ),
            child: Column(
              children: <Widget>[
                _CompletionTopBar(
                  title: complete.title,
                  onCloseTap: () => Get.back<bool>(result: true),
                ),
                SizedBox(height: 26.h),
                LessonTrophyHero(size: kLessonCompleteHeroSize),
                SizedBox(height: 12.h),
                Text(
                  complete.headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font42.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    height: 1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You completed ${complete.chapterTitle}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 30.h),
                LessonXpPill(complete: complete),
                SizedBox(height: 20.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: LessonMetricCard(
                        icon: Icons.track_changes_rounded,
                        value: '${complete.accuracyPercent}%',
                        label: 'ACCURACY',
                        backgroundColor: AppColors.lessonAccuracyBg,
                        iconBackgroundColor: AppColors.homeLime,
                        valueColor: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: LessonMetricCard(
                        icon: Icons.local_fire_department_rounded,
                        value: complete.timeTaken,
                        label: 'TIME TAKEN',
                        backgroundColor: AppColors.lessonTimeBg,
                        iconBackgroundColor: AppColors.reportReviewIconBg,
                        valueColor: AppColors.lessonTimeText,
                      ),
                    ),
                  ],
                ),
                if (complete.hasXpBoost) ...<Widget>[
                  SizedBox(height: 20.h),
                  LessonBoostPill(complete: complete),
                ],
                SizedBox(height: 20.h),
                LessonSimplePill(
                  icon: Icons.shield_outlined,
                  title: complete.leagueMessage,
                  iconColor: AppColors.lessonTimeText,
                ),
                SizedBox(height: 24.h),
                LessonSimplePill(
                  icon: Icons.local_fire_department_rounded,
                  subtitle: 'DAILY STREAK',
                  title: '${complete.streakDays} Days',
                  iconColor: AppColors.blockDangerRed,
                  backgroundColor: AppColors.lessonStreakBg,
                ),
                SizedBox(height: 50.h),
                GestureDetector(
                  onTap: _openReviewAnswers,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.search_rounded,
                        size: 20.w,
                        color: AppColors.lessonTimeText,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Review Answers',
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lessonTimeText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                CustomButton.primary(
                  onPressed: () => _showMilestoneDialog(complete),
                  text: 'CONTINUE',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _openReviewAnswers() async {
    await Get.toNamed(
      AppRoutes.quizReviewAnswers,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> _showMilestoneDialog(QuizLessonCompleteModel complete) async {
    await Get.dialog<void>(
      LessonMilestoneDialog(
        complete: complete,
        onCloseTap: () {
          Get.back<void>();
          Get.back<bool>(result: true);
        },
      ),
      barrierDismissible: false,
      barrierColor: AppColors.transparent,
    );
  }
}

class _CompletionTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onCloseTap;

  const _CompletionTopBar({required this.title, required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          child: Icon(
            Icons.close_rounded,
            size: 22.w,
            color: AppColors.bodyText,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Icon(Icons.share_rounded, size: 20.w, color: AppColors.bodyText),
      ],
    );
  }
}
