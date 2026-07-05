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
      bottomNavigationBar: Obx(
        () => FinalExamBottomButton(
          label: 'gen_submit_answer'.tr,
          onTap: controller.submitWritingAnswer,
          isLoading: controller.isSubmitting.value,
        ),
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
            padding: EdgeInsets.fromLTRB(28.w, 10.h, 28.w, 60.h),
            child: Column(
              children: <Widget>[
                FinalExamTopBar(
                  title: task.title,
                  closeIcon: true,
                  timerText: 'gen_35_10'.tr,
                  onBackTap: () => Get.back<void>(),
                ),
                SizedBox(height: 32.h),
                _WritingTaskCard(task: task),
                SizedBox(height: 38.h),
                _WritingAnswerCard(controller: controller.writingController),
                SizedBox(height: 28.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 26.w,
                    vertical: 22.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(9999.r),
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
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primaryGreen,
                        size: 20.w,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'ai_is_monitoring_for_copy_paste_actions'.tr,
                          style: TextStyle(
                            fontSize: AppFont.font12.sp,
                            fontWeight: FontWeight.w700,
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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(kRadius34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.draw_rounded,
                  color: AppColors.vocabularyOrangeShadow,
                  size: 34.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  task.taskTitle,
                  style: TextStyle(
                    fontSize: AppFont.font22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            task.instruction,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            task.banglaInstruction,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w400,
              height: 1.65,
              color: AppColors.bodyText,
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
      height: 420.h,
      padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius34.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
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
                hintText: 'gen_inizia_a_scrivere_qui_la_tua_s'.tr,
                hintStyle: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: AppColors.modalBorderGrey,
                ),
              ),
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                height: 1.45,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          Divider(color: AppColors.modalBorderGrey, height: 1.h),
          SizedBox(height: 22.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <String>['à', 'è', 'é', 'ì', 'ò', 'ù']
                .map(
                  (String item) => GestureDetector(
                    onTap: () => controller.text = '${controller.text}$item',
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.legacyColorFFF1F2F2,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
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
