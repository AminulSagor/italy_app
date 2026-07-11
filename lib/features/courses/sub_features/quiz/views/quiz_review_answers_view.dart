import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/models/learning_activity_models.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/learning_activity_page_scope.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_review_widgets.dart';

class QuizReviewAnswersView extends GetView<QuizController> {
  final String controllerTag;

  const QuizReviewAnswersView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.quiz,
      sourceId: 'quiz_review_answers_view',
      child: Material(
        color: AppColors.coursesDetailBg,
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    14.h,
                    20.w,
                    12.h,
                  ),
                  child: _ReviewTopBar(
                    score:
                    '${controller.correctAnswerCount}/${controller.totalQuestions}',
                    onCloseTap: () {
                      Get.back<void>();
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      0,
                      20.w,
                      22.h,
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10.h),
                        Text(
                          'great_effort'.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font22.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.homePrimaryText,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'review_quiz_subtitle'.tr,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        ...controller.questions.map(
                              (QuizQuestionModel question) {
                            final QuizAnswerReviewModel? review =
                            _findReview(question.id);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 18.h),
                              child: ReviewAnswerCard(
                                question: question,
                                review: review,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    14.h,
                    20.w,
                    18.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(kRadius16.r),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.homeNeutralShadow,
                        blurRadius: 16.r,
                        offset: Offset(0, -6.h),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: CustomButton.primary(
                      onPressed: () {
                        Get.back<void>();
                      },
                      text: 'done'.tr,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  QuizAnswerReviewModel? _findReview(String questionId) {
    for (final QuizAnswerReviewModel review
    in controller.answerReviews) {
      if (review.id == questionId) {
        return review;
      }
    }

    return null;
  }
}

class _ReviewTopBar extends StatelessWidget {
  final String score;
  final VoidCallback onCloseTap;

  const _ReviewTopBar({
    required this.score,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFFF1F2F2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20.sp,
              color: AppColors.bodyText,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'review_answers'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          constraints: BoxConstraints(
            minWidth: 52.w,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 7.h,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.homeLime,
            borderRadius: BorderRadius.circular(
              kHomePillRadius.r,
            ),
          ),
          child: Text(
            score,
            maxLines: 1,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}