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
    return Material(
      color: AppColors.coursesDetailBg,
      child: SafeArea(
        bottom: false,
        child: Obx(
          () {
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
                38.h,
                kLessonCompleteHorizontalPadding.w,
                42.h,
              ),
              child: Column(
                children: <Widget>[
                  _CompletionTopBar(
                    title: complete.title,
                    onCloseTap: () => Get.back<bool>(result: true),
                  ),
                  SizedBox(height: 46.h),
                  LessonTrophyHero(size: kLessonCompleteHeroSize),
                  SizedBox(height: 18.h),
                  Text(
                    complete.headline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font56.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'You completed ${complete.chapterTitle}!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                    ),
                  ),
                  SizedBox(height: 44.h),
                  LessonXpPill(complete: complete),
                  SizedBox(height: 26.h),
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
                      SizedBox(width: 22.w),
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
                    SizedBox(height: 28.h),
                    LessonBoostPill(complete: complete),
                  ],
                  SizedBox(height: 34.h),
                  LessonSimplePill(
                    icon: Icons.shield_outlined,
                    title: complete.leagueMessage,
                    iconColor: AppColors.lessonTimeText,
                  ),
                  SizedBox(height: 30.h),
                  LessonSimplePill(
                    icon: Icons.local_fire_department_rounded,
                    subtitle: 'DAILY STREAK',
                    title: '${complete.streakDays} Days',
                    iconColor: AppColors.blockDangerRed,
                    backgroundColor: AppColors.lessonStreakBg,
                  ),
                  SizedBox(height: 42.h),
                  GestureDetector(
                    onTap: _openReviewAnswers,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search_rounded, size: 22.w, color: AppColors.lessonTimeText),
                        SizedBox(width: 10.w),
                        Text(
                          'Review Answers',
                          style: TextStyle(
                            fontSize: AppFont.font18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.lessonTimeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 34.h),
                  CustomButton.primary(
                    onPressed: () => _showMilestoneDialog(complete),
                    text: 'CONTINUE',
                  ),
                ],
              ),
            );
          },
        ),
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
          child: Icon(Icons.close_rounded, size: 32.w, color: AppColors.bodyText),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Icon(Icons.share_rounded, size: 30.w, color: AppColors.bodyText),
      ],
    );
  }
}
