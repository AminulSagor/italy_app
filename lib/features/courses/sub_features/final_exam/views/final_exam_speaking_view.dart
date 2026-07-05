import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';
import '../widgets/final_exam_common_widgets.dart';

class FinalExamSpeakingView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamSpeakingView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      bottomNavigationBar: Obx(
        () => FinalExamBottomButton(
          label: 'gen_submit_answer'.tr,
          onTap: controller.submitSpeakingAnswer,
          isLoading: controller.isSubmitting.value,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final FinalExamSpeakingModel? task = controller.speakingTask.value;

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
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 80.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SpeakingHeader(taskTitle: task.title),
                SizedBox(height: 24.h),
                _SpeakingTaskCard(task: task),
                SizedBox(height: 24.h),
                _RecordingCard(
                  isRecording: controller.isRecording.value,
                  hasRecording: controller.hasRecording.value,
                  isPlaying: controller.isRecordedAudioPlaying.value,
                  recordedSeconds: controller.recordedSeconds.value,
                  recorderController: controller.speakingRecorderController,
                  playerController: controller.recordedWaveController,
                  onRecordStart: controller.startRecording,
                  onRecordEnd: controller.stopRecording,
                  onResetTap: controller.resetRecording,
                  onPlayTap: controller.toggleRecordedAudio,
                ),
                SizedBox(height: 24.h),
                _SpeakingTip(text: task.tip),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SpeakingHeader extends StatelessWidget {
  final String taskTitle;

  const _SpeakingHeader({required this.taskTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => Get.back<void>(),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: 22.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                taskTitle,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.modalBorderGrey,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Text(
                '28_05'.tr,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 22.h),
        Row(
          children: <Widget>[
            Text(
              '1/4',
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                color: AppColors.bodyText,
              ),
            ),
            const Spacer(),
            Text(
              '80%',
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          child: LinearProgressIndicator(
            value: 0.8,
            minHeight: 12.h,
            borderRadius: BorderRadius.circular(9999.r),
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.quizProgressTrack,
          ),
        ),
      ],
    );
  }
}

class _SpeakingTaskCard extends StatelessWidget {
  final FinalExamSpeakingModel task;

  const _SpeakingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(kRadius34.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_rounded,
              color: AppColors.primaryGreen,
              size: 25.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.taskTitle,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  task.instruction,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  task.banglaInstruction,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w300,
                    height: 1.55,
                    color: AppColors.primaryGreen,
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

class _RecordingCard extends StatelessWidget {
  final bool isRecording;
  final bool hasRecording;
  final bool isPlaying;
  final int recordedSeconds;
  final RecorderController recorderController;
  final PlayerController playerController;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final VoidCallback onResetTap;
  final VoidCallback onPlayTap;

  const _RecordingCard({
    required this.isRecording,
    required this.hasRecording,
    required this.isPlaying,
    required this.recordedSeconds,
    required this.recorderController,
    required this.playerController,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onResetTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final String seconds = recordedSeconds.toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(33.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius34.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 174.w,
            height: 174.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 8.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '00_seconds'.trParams(<String, String>{'seconds': seconds.toString()}),
                  style: TextStyle(
                    fontSize: AppFont.font32.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isRecording
                      ? '● RECORDING...'
                      : hasRecording
                      ? 'recorded'.tr
                      : 'ready'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: isRecording
                        ? AppColors.blockDangerRed
                        : AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 34.h),
          if (isRecording)
            FinalExamRecorderWaveform(
              recorderController: recorderController,
              height: 92,
            )
          else if (hasRecording)
            FinalExamPlayerWaveform(
              playerController: playerController,
              height: 92,
            )
          else
            _IdleWaveform(),
          SizedBox(height: 34.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _RoundControl(icon: Icons.refresh_rounded, onTap: onResetTap),
              GestureDetector(
                onLongPressStart: (_) => onRecordStart(),
                onLongPressEnd: (_) => onRecordEnd(),
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: AppColors.white,
                    size: 50.w,
                  ),
                ),
              ),
              _RoundControl(
                icon: isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onTap: onPlayTap,
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            'hold_to_record'.tr,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
          Text(
            'label_lib_features_courses_sub_features_final_exam_views_final_exam_speaking_view_373'.tr,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleWaveform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<double> heights = <double>[18, 34, 52, 78, 64, 30, 58, 22];
    return SizedBox(
      height: 92.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: heights.map((double item) {
          return Container(
            width: 18.w,
            height: item.h,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(
                alpha: item > 60 ? 1 : 0.42,
              ),
              borderRadius: BorderRadius.circular(kRadius10.r),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: AppColors.legacyColorFFF1F2F2,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 0,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.bodyText, size: 30.w),
      ),
    );
  }
}

class _SpeakingTip extends StatelessWidget {
  final String text;

  const _SpeakingTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 2,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lightbulb_rounded,
            color: AppColors.vocabularyOrangeShadow,
            size: 14.w,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.bodyText,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
