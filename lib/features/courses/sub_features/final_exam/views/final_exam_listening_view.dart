import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';
import '../widgets/final_exam_common_widgets.dart';

class FinalExamListeningView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamListeningView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.exam,
      sourceId: 'final_exam_listening_view',
      child: Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: Obx(
        () => FinalExamBottomButton(
          label: 'gen_submit_answer'.tr,
          onTap: controller.submitListeningAnswer,
          isLoading: controller.isSubmitting.value,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final FinalExamListeningModel? task = controller.listeningTask.value;

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
            padding: EdgeInsets.fromLTRB(28.w, 10.h, 28.w, 132.h),
            child: Column(
              children: <Widget>[
                _ExamProgressHeader(onCloseTap: () => Get.back<void>()),
                SizedBox(height: 25.h),
                _AudioClipCard(
                  task: task,
                  isPlaying: controller.isAudioPlaying.value,
                  playerController: controller.listeningWaveController,
                  onPlayTap: controller.toggleListeningAudio,
                ),
                SizedBox(height: 26.h),
                ExamInfoTip(
                  text: 'strict_exam_mode'.tr,
                  subText:
                      'gen_once_the_audio_finishes_you_ca'.tr,
                  bg: AppColors.coursesCreamLightBg,
                  borderColor: AppColors.vocabularyOrangeShadow,
                  color: AppColors.profileOrangeText,
                  icon: Icons.warning_rounded,
                ),
                SizedBox(height: 36.h),
                _QuestionCard(task: task),
                SizedBox(height: 24.h),
                ...List<Widget>.generate(task.options.length, (int index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: _ListeningOption(
                      label: task.options[index],
                      index: index,
                      isSelected:
                          controller.selectedListeningOption.value == index,
                      onTap: () => controller.selectListeningOption(index),
                    ),
                  );
                }),
                SizedBox(height: 12.h),
                ExamInfoTip(
                  subText: task.tip,
                  bg: AppColors.reportReviewBg,
                  borderColor: AppColors.transparent,
                  color: AppColors.reportReviewText,
                  icon: Icons.info_outline_rounded,
                ),
              ],
            ),
          );
        }),
      ),
    ),
    );
  }
}

class _ExamProgressHeader extends StatelessWidget {
  final VoidCallback onCloseTap;

  const _ExamProgressHeader({required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: onCloseTap,
              child: Icon(
                Icons.close_rounded,
                color: AppColors.bodyText,
                size: 22.w,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.modalBorderGrey,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '00:15:00',
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '2_of_4'.tr,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          child: LinearProgressIndicator(
            value: 0.4,
            minHeight: 12.h,
            borderRadius: BorderRadius.circular(999.r),
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.quizProgressTrack,
          ),
        ),
      ],
    );
  }
}

class _AudioClipCard extends StatelessWidget {
  final FinalExamListeningModel task;
  final bool isPlaying;
  final PlayerController playerController;
  final VoidCallback onPlayTap;

  const _AudioClipCard({
    required this.task,
    required this.isPlaying,
    required this.playerController,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 42.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(color: AppColors.homeSoftGreen, width: 2.w),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'press_play_to_start_the_clip'.tr,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            task.clipTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: onPlayTap,
            child: Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeNeutralShadow,
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 40.w,
              ),
            ),
          ),
          SizedBox(height: 26.h),
          FinalExamPlayerWaveform(
            playerController: playerController,
            height: 64,
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final FinalExamListeningModel task;

  const _QuestionCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kRadius34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.reportReviewIconBg,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              task.questionTag,
              style: TextStyle(
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.reportReviewText,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            task.question,
            style: TextStyle(
              fontSize: AppFont.font28.sp,
              fontWeight: FontWeight.w700,
              height: 1.16,
              color: AppColors.homePrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningOption extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ListeningOption({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kRadius32.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.white,
            width: 2.w,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30.w,
              height: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.modalBorderGrey,
                shape: BoxShape.circle,
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.white : AppColors.bodyText,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}
