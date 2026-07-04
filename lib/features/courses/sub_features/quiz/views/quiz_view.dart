import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_common_widgets.dart';
import '../widgets/quiz_panels.dart';
import '../widgets/quiz_result_widgets.dart';

class QuizView extends GetView<QuizController> {
  final String controllerTag;

  const QuizView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.quiz,
      sourceId: 'quiz_view',
      child: Material(
      color: AppColors.coursesDetailBg,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final QuizQuestionModel? question = controller.currentQuestion;
          final bool showWrongResult = controller.showWrongResult;

          if (controller.isLoading.value && question == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (question == null) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: <Widget>[
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  kQuizHorizontalPadding.w,
                  15.h,
                  kQuizHorizontalPadding.w,
                  showWrongResult ? 270.h : 150.h,
                ),
                child: Column(
                  children: <Widget>[
                    QuizTopBar(
                      current: controller.currentIndex.value + 1,
                      total: controller.totalQuestions,
                      onCloseTap: _showQuitDialog,
                    ),
                    SizedBox(height: 15.h),
                    QuizQuestionPanel(
                      key: ValueKey<String>(question.id),
                      question: question,
                      selectedIndex: controller.selectedOptionIndex.value,
                      hasCheckedAnswer: controller.hasCheckedAnswer.value,
                      isAnswerCorrect: controller.isAnswerCorrect.value,
                      sentenceSelectedWords: controller.sentenceSelectedWords
                          .toList(),
                      listeningSelectedWords: controller.listeningSelectedWords
                          .toList(),
                      matchingRightOrder:
                          controller.matchingRightOrder.toList(),
                      matchingRightKeys:
                          controller.matchingRightPairIdOrder.toList(),
                      writingAnswerController:
                          controller.writingAnswerController,
                      onOptionTap: controller.selectOption,
                      onSentenceWordTap: controller.addSentenceWord,
                      onSentenceSelectedWordTap: controller.removeSentenceWord,
                      onListeningWordTap: controller.addListeningWord,
                      onListeningSelectedWordTap:
                          controller.removeListeningWord,
                      onMatchingRightReorder:
                          controller.reorderMatchingRight,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: QuizBottomAction(
                  showWrongResult: showWrongResult,
                  isLoading: controller.isSubmittingAnswer.value,
                  feedback: QuizWrongAnswerFeedback(
                    correctAnswer: controller.currentCorrectAnswer,
                  ),
                  onCheckTap: _handleCheckAnswer,
                  onNextTap: _goNext,
                ),
              ),
            ],
          );
        }),
      ),
    ),
    );
  }

  Future<void> _handleCheckAnswer() async {
    final bool isCorrect = await controller.checkAnswer();
    if (!isCorrect) {
      return;
    }

    Get.bottomSheet<void>(
      QuizCorrectAnswerSheet(
        meaning: controller.currentCorrectMeaning,
        onContinueTap: () {
          Get.back<void>();
          _goNext();
        },
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.transparent,
    );
  }

  Future<void> _goNext() async {
    final bool isFinished = controller.goNext();
    if (!isFinished) {
      return;
    }

    if (controller.isExamMode) {
      Get.back<bool>(result: true);
      return;
    }

    await controller.loadLessonComplete();

    final Object? routeResult = await Get.toNamed(
      AppRoutes.quizCompletion,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );

    if (routeResult == true) {
      Get.back<bool>(result: true);
    }
  }

  Future<void> _showQuitDialog() async {
    await Get.dialog<void>(
      QuizExitConfirmationDialog(
        onKeepGoingTap: () => Get.back<void>(),
        onQuitTap: () {
          Get.back<void>();
          Get.back<bool>(result: false);
        },
      ),
      barrierDismissible: false,
      barrierColor: AppColors.quizExitDialogOverlay,
    );
  }
}
