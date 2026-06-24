import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';

class AiTutorLevelTestSpeakingRecorder extends StatelessWidget {
  const AiTutorLevelTestSpeakingRecorder({
    super.key,
    required this.recorderController,
    required this.isPreparing,
    required this.isRecording,
    required this.isTranscribing,
    required this.recordedSeconds,
    required this.transcript,
    required this.onRecordStart,
    required this.onRecordEnd,
  });

  final RecorderController recorderController;
  final bool isPreparing;
  final bool isRecording;
  final bool isTranscribing;
  final int recordedSeconds;
  final String transcript;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E7E3)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            isPreparing
                ? 'Preparing microphone...'
                : isRecording
                    ? 'Listening... ${_formatDuration(recordedSeconds)}'
                    : isTranscribing
                        ? 'Turning your voice into text...'
                        : 'Hold the microphone and speak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF35413D),
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            height: 76.h,
            child: isRecording
                ? LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return AudioWaveforms(
                        size: Size(constraints.maxWidth, 76.h),
                        recorderController: recorderController,
                        enableGesture: false,
                        waveStyle: WaveStyle(
                          waveColor: AppColors.primaryGreen,
                          extendWaveform: true,
                          showMiddleLine: false,
                          spacing: 6.w,
                          waveThickness: 4.w,
                        ),
                      );
                    },
                  )
                : _IdleWaveform(isLoading: isTranscribing),
          ),
          SizedBox(height: 18.h),
          IgnorePointer(
            ignoring: isTranscribing,
            child: GestureDetector(
              onLongPressStart: (_) => onRecordStart(),
              onLongPressEnd: (_) => onRecordEnd(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 82.r,
                height: 82.r,
                decoration: BoxDecoration(
                  color: isRecording
                      ? const Color(0xFFD84F4F)
                      : AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (isRecording
                              ? const Color(0xFFD84F4F)
                              : AppColors.primaryGreen)
                          .withValues(alpha: .24),
                      blurRadius: 18.r,
                      spreadRadius: isRecording ? 8.r : 3.r,
                    ),
                  ],
                ),
                child: isPreparing || isTranscribing
                    ? Padding(
                        padding: EdgeInsets.all(25.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        isRecording
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_rounded,
                        color: AppColors.white,
                        size: 38.r,
                      ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isPreparing
                ? 'Keep holding the microphone'
                : isRecording
                    ? 'Release to use this answer'
                    : 'চেপে ধরে কথা বলুন',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF737C78),
            ),
          ),
          if (transcript.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F8EF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'YOUR SPOKEN ANSWER',
                    style: TextStyle(
                      fontSize: 9.sp,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    transcript.trim(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF35413D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _IdleWaveform extends StatelessWidget {
  const _IdleWaveform({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 28.r,
          height: 28.r,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    const List<double> bars = <double>[18, 32, 50, 28, 58, 38, 22, 46, 30];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: bars.map((double height) {
        return Container(
          width: 6.w,
          height: height.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }).toList(growable: false),
    );
  }
}
