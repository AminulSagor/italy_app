import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_review_widgets.dart';

class QuizReviewAnswersView extends GetView<QuizController> {
  final String controllerTag;

  const QuizReviewAnswersView({super.key, required this.controllerTag});

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
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
                child: _ReviewTopBar(
                  score:
                      '${controller.correctAnswerCount}/${controller.totalQuestions}',
                  onCloseTap: () => Get.back<void>(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 24.h),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 12.h),
                      Text(
                        'great_effort'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font24.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.homePrimaryText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Let's look at how you did in your Italian\nbasics.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: AppColors.bodyText,
                        ),
                      ),
                      SizedBox(height: 26.h),
                      ...controller.questions.map((QuizQuestionModel question) {
                        final QuizAnswerReviewModel? review = _findReview(
                          question.id,
                        );
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: ReviewAnswerCard(
                            question: question,
                            review: review,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(kRadius16.r),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 18.r,
                      offset: Offset(0, -8.h),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: CustomButton.primary(
                    onPressed: () => Get.back<void>(),
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
    for (final QuizAnswerReviewModel review in controller.answerReviews) {
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

  const _ReviewTopBar({required this.score, required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          child: Container(
            width: 34.w,
            height: 34.w,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFFF1F2F2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20.w,
              color: AppColors.bodyText,
            ),
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: Text(
            'review_answers'.tr,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.homeLime,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            score,
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
