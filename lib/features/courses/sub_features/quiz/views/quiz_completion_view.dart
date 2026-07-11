import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/models/learning_activity_models.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/learning_activity_page_scope.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_completion_widgets.dart';

class QuizCompletionView extends GetView<QuizController> {
  final String controllerTag;

  const QuizCompletionView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.quiz,
      sourceId: 'quiz_completion_view',
      child: Scaffold(
        backgroundColor: AppColors.coursesDetailBg,
        body: SafeArea(
          child: Obx(() {
            final QuizLessonCompleteModel? complete =
                controller.lessonComplete.value;

            if (controller.isCompleting.value &&
                complete == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (complete == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    'quiz_result_not_available'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                kLessonCompleteHorizontalPadding.w,
                12.h,
                kLessonCompleteHorizontalPadding.w,
                24.h,
              ),
              child: Column(
                children: <Widget>[
                  _CompletionTopBar(
                    title: complete.title,
                    onCloseTap: () {
                      Get.back<bool>(result: true);
                    },
                  ),
                  SizedBox(height: 14.h),

                  LessonTrophyHero(
                    size: 108,
                  ),
                  SizedBox(height: 10.h),

                  Text(
                    complete.headline,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _CompactXpCard(
                    xpEarned: complete.xpEarned,
                  ),
                  SizedBox(height: 14.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _CompactMetricCard(
                          icon: Icons.track_changes_rounded,
                          value: '${complete.accuracyPercent}%',
                          label: 'gen_accuracy'.tr,
                          backgroundColor:
                          AppColors.lessonAccuracyBg,
                          iconBackgroundColor:
                          AppColors.homeLime,
                          valueColor:
                          AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _CompactMetricCard(
                          icon: Icons.timer_outlined,
                          value: complete.timeTaken,
                          label: 'gen_time_taken'.tr,
                          backgroundColor:
                          AppColors.lessonTimeBg,
                          iconBackgroundColor:
                          AppColors.reportReviewIconBg,
                          valueColor:
                          AppColors.lessonTimeText,
                        ),
                      ),
                    ],
                  ),

                  if (complete.hasXpBoost) ...<Widget>[
                    SizedBox(height: 14.h),
                    LessonBoostPill(complete: complete),
                  ],

                  SizedBox(height: 14.h),
                  LessonSimplePill(
                    icon: Icons.shield_outlined,
                    title: complete.leagueMessage,
                    iconColor: AppColors.lessonTimeText,
                  ),

                  SizedBox(height: 14.h),
                  LessonSimplePill(
                    icon: Icons.local_fire_department_rounded,
                    subtitle: 'gen_daily_streak'.tr,
                    title: 'days_value'.trParams(
                      <String, String>{
                        'days': complete.streakDays.toString(),
                      },
                    ),
                    iconColor: AppColors.blockDangerRed,
                    backgroundColor: AppColors.lessonStreakBg,
                  ),

                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: _openReviewAnswers,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.search_rounded,
                            size: 19.sp,
                            color: AppColors.lessonTimeText,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'review_answers'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppFont.font14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lessonTimeText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _openReviewAnswers() async {
    await Get.toNamed(
      AppRoutes.quizReviewAnswers,
      arguments: ControllerTagRouteArguments(
        controllerTag: controllerTag,
      ),
    );
  }


}

class _CompletionTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onCloseTap;

  const _CompletionTopBar({
    required this.title,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 38.w,
            height: 38.w,
            child: Icon(
              Icons.close_rounded,
              size: 20.sp,
              color: AppColors.bodyText,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 38.w,
          height: 38.w,
        ),
      ],
    );
  }
}

class _CompactXpCard extends StatelessWidget {
  final int xpEarned;

  const _CompactXpCard({
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.lessonAccuracyBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.homeOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 25.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '+$xpEarned XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'xp_earned'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
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

class _CompactMetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color valueColor;

  const _CompactMetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 118.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 21.sp,
              color: valueColor,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font17.sp,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}