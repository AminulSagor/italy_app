import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../models/final_exam_models.dart';

class FinalExamTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;
  final IconData trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool closeIcon;
  final String? timerText;

  const FinalExamTopBar({
    super.key,
    required this.title,
    required this.onBackTap,
    this.trailingIcon = Icons.emoji_events_outlined,
    this.onTrailingTap,
    this.closeIcon = false,
    this.timerText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onBackTap,
          child: Icon(
            closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
            color: closeIcon ? AppColors.bodyText : AppColors.primaryGreen,
            size: 22.w,
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: 18.w),
        if (timerText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.modalBorderGrey,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.timer_outlined,
                  color: AppColors.primaryGreen,
                  size: 14.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  timerText!,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onTrailingTap,
            child: Icon(
              trailingIcon,
              color: AppColors.primaryGreen,
              size: 24.w,
            ),
          ),
      ],
    );
  }
}

class FinalExamBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const FinalExamBottomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(28.w, 18.h, 28.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CustomButton.primary(
          onPressed: onTap,
          text: label,
          isLoading: isLoading,
          icon: Icons.play_arrow_rounded,
        ),
      ),
    );
  }
}

class FinalExamComponentTile extends StatelessWidget {
  final FinalExamComponentModel component;

  const FinalExamComponentTile({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final Color color = _toneColor(component.tone);
    final Color bg = _toneBg(component.tone);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius32.r),
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
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(_icon(component.iconName), color: color, size: 22.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  component.title,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  component.subtitle,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
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

  Color _toneColor(FinalExamComponentTone tone) {
    switch (tone) {
      case FinalExamComponentTone.green:
        return AppColors.primaryGreen;
      case FinalExamComponentTone.blue:
        return AppColors.coursesChapterBlue;
      case FinalExamComponentTone.orange:
        return AppColors.vocabularyOrangeShadow;
      case FinalExamComponentTone.lime:
        return AppColors.homeLime;
    }
  }

  Color _toneBg(FinalExamComponentTone tone) {
    switch (tone) {
      case FinalExamComponentTone.green:
        return AppColors.homeSoftGreen;
      case FinalExamComponentTone.blue:
        return AppColors.coursesChapterBlueBg;
      case FinalExamComponentTone.orange:
        return AppColors.profileOrangeCardBg;
      case FinalExamComponentTone.lime:
        return AppColors.homePaleGreen;
    }
  }

  IconData _icon(String iconName) {
    switch (iconName) {
      case 'headphones':
        return Icons.headphones_rounded;
      case 'write':
        return Icons.edit_note_rounded;
      case 'speak':
        return Icons.record_voice_over_rounded;
      default:
        return Icons.description_outlined;
    }
  }
}

class AnimatedWaveform extends StatelessWidget {
  final int tick;
  final Color color;
  final double height;

  const AnimatedWaveform({
    super.key,
    required this.tick,
    this.color = AppColors.primaryGreen,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(22, (int index) {
          final double factor = ((index + tick) % 5 + 1) / 5;
          final double barHeight = (18 + (height - 18) * factor).h;
          return Container(
            width: 5.w,
            height: barHeight,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35 + factor * 0.55),
              borderRadius: BorderRadius.circular(kRadius10.r),
            ),
          );
        }),
      ),
    );
  }
}

class FinalExamPlayerWaveform extends StatelessWidget {
  final PlayerController playerController;
  final Color color;
  final double height;

  const FinalExamPlayerWaveform({
    super.key,
    required this.playerController,
    this.color = AppColors.primaryGreen,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AudioFileWaveforms(
          size: Size(constraints.maxWidth, height.h),
          playerController: playerController,
          waveformType: WaveformType.long,
          enableSeekGesture: false,
          playerWaveStyle: PlayerWaveStyle(
            fixedWaveColor: AppColors.quizProgressTrack,
            liveWaveColor: color,
            spacing: 6.w,
            waveThickness: 4.w,
            showSeekLine: false,
          ),
        );
      },
    );
  }
}

class FinalExamRecorderWaveform extends StatelessWidget {
  final RecorderController recorderController;
  final Color color;
  final double height;

  const FinalExamRecorderWaveform({
    super.key,
    required this.recorderController,
    this.color = AppColors.primaryGreen,
    this.height = 92,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AudioWaveforms(
          size: Size(constraints.maxWidth, height.h),
          recorderController: recorderController,
          enableGesture: false,
          waveStyle: WaveStyle(
            waveColor: color,
            extendWaveform: true,
            showMiddleLine: false,
            spacing: 7.w,
            waveThickness: 5.w,
          ),
        );
      },
    );
  }
}

class ExamInfoTip extends StatelessWidget {
  final String? text;
  final String? subText;
  final Color bg;
  final Color borderColor;
  final Color color;
  final IconData icon;

  const ExamInfoTip({
    super.key,
    this.text,
    this.subText,
    required this.bg,
    required this.borderColor,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadius32.r),
        border: Border(
          left: BorderSide(color: borderColor, width: 6.w),
        ),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: <Widget>[
          Icon(icon, color: color, size: 30.w),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (text != null)
                  Text(
                    text!,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                if (text != null && subText != null) SizedBox(height: 4.h),
                if (subText != null)
                  Text(
                    subText!,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: color,
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
