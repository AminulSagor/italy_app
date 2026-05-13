import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';
import '../widgets/final_exam_common_widgets.dart';

class FinalExamWritingView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamWritingView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: FinalExamBottomButton(
        label: 'Submit Answer',
        onTap: controller.submitWritingAnswer,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final FinalExamWritingModel? task = controller.writingTask.value;

          if (controller.isLoading.value && task == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (task == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(28.w, 38.h, 28.w, 132.h),
            child: Column(
              children: <Widget>[
                FinalExamTopBar(
                  title: task.title,
                  closeIcon: true,
                  timerText: '35:10',
                  onBackTap: () => Get.back<void>(),
                ),
                SizedBox(height: 32.h),
                _WritingTaskCard(task: task),
                SizedBox(height: 38.h),
                _WritingAnswerCard(controller: controller.writingController),
                SizedBox(height: 28.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 22.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(kRadius28.r),
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
                      Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen, size: 26.w),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          'AI IS MONITORING FOR COPY PASTE ACTIONS.',
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _WritingTaskCard extends StatelessWidget {
  final FinalExamWritingModel task;

  const _WritingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(kRadius34.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Icon(Icons.draw_rounded, color: AppColors.vocabularyOrangeShadow, size: 34.w),
          ),
          SizedBox(width: 22.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.taskTitle,
                  style: TextStyle(
                    fontSize: AppFont.font30.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  task.instruction,
                  style: TextStyle(
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  task.banglaInstruction,
                  style: TextStyle(
                    fontSize: AppFont.font19.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.65,
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

class _WritingAnswerCard extends StatelessWidget {
  final TextEditingController controller;

  const _WritingAnswerCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 520.h,
      padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius34.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Inizia a scrivere qui la tua\nstoria...',
                hintStyle: TextStyle(
                  fontSize: AppFont.font26.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: AppColors.modalBorderGrey,
                ),
              ),
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1.45,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          Divider(color: AppColors.modalBorderGrey, height: 1.h),
          SizedBox(height: 22.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: <String>['à', 'è', 'é', 'ì', 'ò', 'ù']
                .map(
                  (String item) => GestureDetector(
                    onTap: () => controller.text = '${controller.text}$item',
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.legacyColorFFF1F2F2,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: AppFont.font22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
