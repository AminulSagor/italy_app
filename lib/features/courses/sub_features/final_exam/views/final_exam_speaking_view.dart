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
          label: 'Submit Answer',
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
            padding: EdgeInsets.fromLTRB(28.w, 34.h, 28.w, 132.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SpeakingHeader(taskTitle: task.title),
                SizedBox(height: 32.h),
                _SpeakingTaskCard(task: task),
                SizedBox(height: 34.h),
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
                SizedBox(height: 28.h),
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
              child: Icon(Icons.arrow_back_rounded, color: AppColors.primaryGreen, size: 28.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                taskTitle,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.modalBorderGrey,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Text(
                '⏱ 28:05',
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
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
              '1/5',
              style: TextStyle(fontSize: AppFont.font18.sp, color: AppColors.bodyText),
            ),
            const Spacer(),
            Text(
              '80%',
              style: TextStyle(
                fontSize: AppFont.font18.sp,
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
            minHeight: 14.h,
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
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(kRadius34.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Icon(Icons.mic_rounded, color: AppColors.primaryGreen, size: 36.w),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.taskTitle,
                  style: TextStyle(
                    fontSize: AppFont.font26.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  task.instruction,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  task.banglaInstruction,
                  style: TextStyle(
                    fontSize: AppFont.font17.sp,
                    fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.fromLTRB(24.w, 44.h, 24.w, 34.h),
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
              border: Border.all(color: AppColors.primaryGreen, width: 6.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '00:$seconds',
                  style: TextStyle(
                    fontSize: AppFont.font36.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isRecording ? '● RECORDING...' : hasRecording ? 'RECORDED' : 'READY',
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: isRecording ? AppColors.blockDangerRed : AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 34.h),
          if (isRecording)
            FinalExamRecorderWaveform(recorderController: recorderController, height: 92)
          else if (hasRecording)
            FinalExamPlayerWaveform(playerController: playerController, height: 92)
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
                  width: 126.w,
                  height: 126.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic_rounded, color: AppColors.white, size: 58.w),
                ),
              ),
              _RoundControl(
                icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: onPlayTap,
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            'HOLD TO RECORD',
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
          Text(
            'চেপে ধরে কথা বলুন',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
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
    final List<double> heights = <double>[18, 34, 52, 78, 64, 30, 58, 22, 44, 72];
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
              color: AppColors.primaryGreen.withValues(alpha: item > 60 ? 1 : 0.42),
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
        width: 62.w,
        height: 62.w,
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
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius28.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lightbulb_rounded, color: AppColors.vocabularyOrangeShadow, size: 26.w),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w500,
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
