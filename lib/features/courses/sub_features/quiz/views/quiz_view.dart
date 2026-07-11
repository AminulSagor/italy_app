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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _showQuitDialog();
      },
      child: LearningActivityPageScope(
        activityKind: LearningActivityKind.quiz,
        sourceId: 'quiz_view',
        child: Material(
        color: AppColors.coursesDetailBg,
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            final QuizQuestionModel? question = controller.currentQuestion;
            final bool showWrongResult =
                !controller.isExamMode && controller.showWrongResult;
            final double keyboardHeight =
                MediaQuery.viewInsetsOf(context).bottom;

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
                    16.h,
                    kQuizHorizontalPadding.w,
                    (showWrongResult ? 270.h : 150.h) + keyboardHeight,
                  ),
                  child: Column(
                    children: <Widget>[
                      QuizTopBar(
                        current: controller.currentIndex.value + 1,
                        total: controller.totalQuestions,
                        onCloseTap: _showQuitDialog,
                      ),
                      SizedBox(height: 16.h),
                      QuizQuestionPanel(
                        key: ValueKey<String>(question.id),
                        question: question,
                        selectedIndex:
                        controller.selectedOptionIndex.value,
                        hasCheckedAnswer:
                        controller.isExamMode ? false : controller.hasCheckedAnswer.value,
                        isAnswerCorrect:
                        controller.isExamMode ? false : controller.isAnswerCorrect.value,
                        sentenceSelectedWords:
                        controller.sentenceSelectedWords.toList(),
                        listeningSelectedWords:
                        controller.listeningSelectedWords.toList(),
                        matchingRightOrder:
                        controller.matchingRightOrder.toList(),
                        matchingRightKeys:
                        controller.matchingRightPairIdOrder.toList(),
                        writingAnswerController:
                        controller.writingAnswerController,
                        onOptionTap: controller.selectOption,
                        onSentenceWordTap:
                        controller.addSentenceWord,
                        onSentenceSelectedWordTap:
                        controller.removeSentenceWord,
                        onListeningWordTap:
                        controller.addListeningWord,
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
                  child: SafeArea(
                    top: false,
                    child: QuizBottomAction(
                      isExamMode: controller.isExamMode,
                      showWrongResult: showWrongResult,
                      isLoading:
                      controller.isSubmittingAnswer.value ||
                          controller.isCompleting.value,
                      feedback: controller.isExamMode
                          ? null
                          : QuizWrongAnswerFeedback(
                        correctAnswer: controller.currentCorrectAnswer,
                      ),
                      onCheckTap: _handleCheckAnswer,
                      onNextTap: _goNext,
                      onSkipTap: _skipQuestion,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      ),
    );
  }

  Future<void> _handleCheckAnswer() async {
    if (controller.isSubmittingAnswer.value ||
        controller.isCompleting.value) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (controller.isExamMode) {
      if (!controller.hasCurrentAnswer) {
        Get.snackbar(
          'quiz'.tr,
          'please_select_an_answer'.tr,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16.w),
          duration: const Duration(seconds: 2),
        );
        return;
      }

      await controller.checkAnswer();

      if (!controller.hasCheckedAnswer.value) {
        return;
      }

      await _goNext();
      return;
    }

    final bool isCorrect = await controller.checkAnswer();

    if (!isCorrect) {
      return;
    }

    Get.bottomSheet<void>(
      QuizCorrectAnswerSheet(
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
  Future<void> _skipQuestion() async {
    if (!controller.isExamMode ||
        controller.isSubmittingAnswer.value ||
        controller.isCompleting.value) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    // Skipping does not submit an answer.
    await _goNext();
  }

  Future<void> _goNext() async {
    if (controller.isCompleting.value) {
      return;
    }

    final bool isFinished = controller.goNext();

    if (!isFinished) {
      return;
    }

    if (controller.isExamMode) {
      Get.back<bool>(result: true);
      return;
    }

    await controller.loadLessonComplete();

    // Do not open the completion page until the API result exists.
    if (controller.lessonComplete.value == null) {
      return;
    }

    final Object? routeResult = await Get.toNamed(
      AppRoutes.quizCompletion,
      arguments: ControllerTagRouteArguments(
        controllerTag: controllerTag,
      ),
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
