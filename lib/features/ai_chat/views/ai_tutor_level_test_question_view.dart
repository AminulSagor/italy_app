import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/ai_tutor_level_test_controller.dart';
import '../models/ai_tutor_level_test_models.dart';
import 'widgets/ai_tutor_level_test_widgets.dart';
import '../../../core/widgets/native_bottom_inset.dart';

class AiTutorLevelTestQuestionView extends GetView<AiTutorLevelTestController> {
  const AiTutorLevelTestQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final AiTutorLevelQuestionModel question = controller.currentQuestion;
          final int number = controller.currentQuestionIndex.value + 1;

          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 0),
                child: AiTutorLevelTestHeader(
                  title: 'question_x_of_y'.trParams(<String, String>{
                    'current': number.toString(),
                    'total': controller.questions.length.toString(),
                  }),
                  onBackTap: controller.handleBack,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24.w, 25.h, 24.w, 145.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: LinearProgressIndicator(
                          minHeight: 8.h,
                          value: controller.progress,
                          backgroundColor: const Color(0xFFE3E8E4),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      AiTutorSkillChip(skill: question.skill),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(22.w, 25.h, 22.w, 25.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 18.r,
                              offset: Offset(0, 8.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              question.prompt,
                              style: TextStyle(
                                fontSize: 20.sp,
                                height: 1.35,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF27332F),
                              ),
                            ),
                            SizedBox(height: 13.h),
                            Text(
                              question.helperText,
                              style: TextStyle(
                                fontSize: 13.sp,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF737C78),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _ChoiceAnswers(
                        options: question.options,
                        selectedOption: controller.selectedOption.value,
                        onSelected: controller.selectOption,
                      ),
                    ],
                  ),
                ),
              ),
              ColoredBox(
                color: AppColors.white,
                child: NativeBottomInset(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 18.r,
                          offset: Offset(0, -7.h),
                        ),
                      ],
                    ),
                    child: AiTutorLevelPrimaryButton(
                      text: controller.isLastQuestion
                          ? 'analyze_my_level'.tr
                          : 'continue_1'.tr,
                      onTap: controller.submitCurrentAnswer,
                      isLoading: controller.isSubmitting.value,
                      isEnabled: controller.canContinue,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChoiceAnswers extends StatelessWidget {
  const _ChoiceAnswers({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((String option) {
            final bool selected = option == selectedOption;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () => onSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE8F8DA) : AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryGreen
                          : const Color(0xFFE2E7E3),
                      width: selected ? 1.6.w : 1.w,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 22.r,
                        height: 22.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryGreen
                                : const Color(0xFFB4BDB8),
                          ),
                        ),
                        child: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 14.r,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: 13.w),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF35413D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
