import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/final_exam_controller.dart';
import '../models/final_exam_models.dart';
import '../widgets/final_exam_common_widgets.dart';

double _boundedWidth(double value, double min, double max) {
  return value.w.clamp(min, max).toDouble();
}

double _boundedHeight(double value, double min, double max) {
  return value.h.clamp(min, max).toDouble();
}

double _boundedFont(double value, double min, double max) {
  return value.sp.clamp(min, max).toDouble();
}

String _translatedDynamicText(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  // If the API returns a translation key, GetX translates it.
  // If it returns normal text, GetX safely returns the original value.
  return value.tr;
}

String _localizedInstruction(FinalExamSpeakingModel task) {
  final String languageCode = Get.locale?.languageCode ?? 'en';

  if (languageCode == 'bn' && task.banglaInstruction.trim().isNotEmpty) {
    return task.banglaInstruction;
  }

  return _translatedDynamicText(task.instruction);
}

class FinalExamSpeakingView extends GetView<FinalExamController> {
  final String controllerTag;

  const FinalExamSpeakingView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.exam,
      sourceId: 'final_exam_speaking_view',
      child: Scaffold(
        backgroundColor: AppColors.coursesDetailBg,
        bottomNavigationBar: Obx(
              () => FinalExamBottomButton(
            label: 'final_exam_submit_answer'.tr,
            onTap: controller.submitSpeakingAnswer,
            isLoading: controller.isSubmitting.value,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Obx(() {
            final FinalExamSpeakingModel? task =
                controller.speakingTask.value;

            if (controller.isLoading.value && task == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (task == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'final_exam_no_speaking_task'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _boundedFont(AppFont.font14, 13, 15),
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                _boundedWidth(20, 16, 22),
                _boundedHeight(10, 8, 12),
                _boundedWidth(20, 16, 22),
                _boundedHeight(24, 20, 28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SpeakingHeader(
                    taskTitle: _translatedDynamicText(task.title),
                  ),
                  SizedBox(height: _boundedHeight(18, 16, 20)),
                  _SpeakingTaskCard(task: task),
                  SizedBox(height: _boundedHeight(18, 16, 20)),
                  _RecordingCard(
                    isRecording: controller.isRecording.value,
                    hasRecording: controller.hasRecording.value,
                    isPlaying: controller.isRecordedAudioPlaying.value,
                    recordedSeconds: controller.recordedSeconds.value,
                    recorderController:
                    controller.speakingRecorderController,
                    playerController: controller.recordedWaveController,
                    onRecordStart: controller.startRecording,
                    onRecordEnd: controller.stopRecording,
                    onResetTap: controller.resetRecording,
                    onPlayTap: controller.toggleRecordedAudio,
                  ),
                  SizedBox(height: _boundedHeight(18, 16, 20)),
                  _SpeakingTip(
                    text: _translatedDynamicText(task.tip),
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

class _SpeakingHeader extends StatelessWidget {
  final String taskTitle;

  const _SpeakingHeader({required this.taskTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => Get.back<void>(),
              tooltip: 'common_back'.tr,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            SizedBox(width: _boundedWidth(8, 6, 10)),
            Expanded(
              child: Text(
                taskTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _boundedFont(AppFont.font16, 15, 17),
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            SizedBox(width: _boundedWidth(8, 6, 10)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.modalBorderGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '28:05',
                style: TextStyle(
                  fontSize: _boundedFont(AppFont.font12, 12, 14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _boundedHeight(16, 14, 18)),
        Row(
          children: <Widget>[
            Text(
              '1/4',
              style: TextStyle(
                fontSize: _boundedFont(AppFont.font14, 12, 14),
                color: AppColors.bodyText,
              ),
            ),
            const Spacer(),
            Text(
              '80%',
              style: TextStyle(
                fontSize: _boundedFont(AppFont.font14, 12, 14),
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        SizedBox(height: _boundedHeight(8, 7, 10)),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(
            value: 0.8,
            minHeight: 8,
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
    final String instruction = _localizedInstruction(task);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_boundedWidth(16, 14, 18)),
      decoration: BoxDecoration(
        color: AppColors.homeSoftGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ),
          SizedBox(width: _boundedWidth(10, 8, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _translatedDynamicText(task.taskTitle),
                  style: TextStyle(
                    fontSize: _boundedFont(AppFont.font16, 15, 17),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: _boundedHeight(6, 5, 8)),
                Text(
                  instruction,
                  style: TextStyle(
                    fontSize: _boundedFont(AppFont.font14, 13, 15),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
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

  String get _statusText {
    if (isRecording) {
      return 'final_exam_recording'.tr;
    }

    if (hasRecording) {
      return 'final_exam_recorded'.tr;
    }

    return 'final_exam_ready'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final int safeSeconds = recordedSeconds.clamp(0, 3599).toInt();
    final String minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final String seconds = (safeSeconds % 60).toString().padLeft(2, '0');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double timerSize =
        (constraints.maxWidth * 0.46).clamp(132.0, 156.0).toDouble();
        final double recordButtonSize =
        (constraints.maxWidth * 0.24).clamp(72.0, 86.0).toDouble();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(_boundedWidth(20, 16, 22)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: timerSize,
                height: timerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 6,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$minutes:$seconds',
                        style: TextStyle(
                          fontSize: _boundedFont(
                            AppFont.font32,
                            26,
                            30,
                          ),
                          fontWeight: FontWeight.w900,
                          color: AppColors.homePrimaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        isRecording ? '● $_statusText' : _statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _boundedFont(AppFont.font12, 10, 12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: isRecording
                              ? AppColors.blockDangerRed
                              : AppColors.bodyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _boundedHeight(22, 18, 24)),
              SizedBox(
                height: 64,
                child: Center(
                  child: isRecording
                      ? FinalExamRecorderWaveform(
                    recorderController: recorderController,
                    height: 64,
                  )
                      : hasRecording
                      ? FinalExamPlayerWaveform(
                    playerController: playerController,
                    height: 64,
                  )
                      : const _IdleWaveform(),
                ),
              ),
              SizedBox(height: _boundedHeight(22, 18, 24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _RoundControl(
                    icon: Icons.refresh_rounded,
                    tooltip: 'final_exam_reset_recording'.tr,
                    onTap: hasRecording || isRecording ? onResetTap : null,
                  ),
                  Tooltip(
                    message: 'final_exam_hold_to_record'.tr,
                    child: Semantics(
                      button: true,
                      label: 'final_exam_hold_to_record'.tr,
                      child: GestureDetector(
                        onLongPressStart: (_) => onRecordStart(),
                        onLongPressEnd: (_) => onRecordEnd(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: recordButtonSize,
                          height: recordButtonSize,
                          decoration: BoxDecoration(
                            color: isRecording
                                ? AppColors.blockDangerRed
                                : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: AppColors.white,
                            size: recordButtonSize * 0.46,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _RoundControl(
                    icon: isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    tooltip: isPlaying
                        ? 'final_exam_pause_recording'.tr
                        : 'final_exam_play_recording'.tr,
                    onTap: hasRecording ? onPlayTap : null,
                  ),
                ],
              ),
              SizedBox(height: _boundedHeight(16, 14, 18)),
              Text(
                'final_exam_hold_to_record'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _boundedFont(AppFont.font12, 11, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'final_exam_release_to_stop'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _boundedFont(AppFont.font10, 10, 11),
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IdleWaveform extends StatelessWidget {
  const _IdleWaveform();

  @override
  Widget build(BuildContext context) {
    const List<double> heights = <double>[16, 28, 40, 54, 44, 26, 38, 18];

    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: heights.map((double item) {
          return Container(
            width: 8,
            height: item,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(
                alpha: item >= 44 ? 1 : 0.42,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.legacyColorFFF1F2F2,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.homeNeutralShadow,
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? AppColors.bodyText
                  : AppColors.bodyText.withValues(alpha: 0.35),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeakingTip extends StatelessWidget {
  final String text;

  const _SpeakingTip({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppColors.vocabularyOrangeShadow,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _boundedFont(AppFont.font12, 11, 13),
                fontWeight: FontWeight.w400,
                color: AppColors.bodyText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
