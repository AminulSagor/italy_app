import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class QuizTopBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onCloseTap;

  const QuizTopBar({
    super.key,
    required this.current,
    required this.total,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : current / total;

    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onCloseTap,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.bodyText,
            size: 20.w,
          ),
        ),
        SizedBox(width: 28.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: kQuizTopProgressHeight.h,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.quizProgressTrack,
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            '$current/$total',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}

class QuizBottomAction extends StatelessWidget {
  final bool showWrongResult;
  final Widget? feedback;
  final VoidCallback onCheckTap;
  final VoidCallback onNextTap;

  const QuizBottomAction({
    super.key,
    required this.showWrongResult,
    required this.onCheckTap,
    required this.onNextTap,
    this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        kQuizHorizontalPadding.w,
        showWrongResult ? 28.h : 20.h,
        kQuizHorizontalPadding.w,
        24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius16.r)),
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
        child: showWrongResult
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ?feedback,
                  SizedBox(height: 18.h),
                  CustomButton.primary(
                    text: 'Next Question',
                    onPressed: onNextTap,
                  ),
                ],
              )
            : CustomButton.primary(text: 'Check Answer', onPressed: onCheckTap),
      ),
    );
  }
}

class CustomQuizButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isWrong;
  final double height;
  final double radius;

  const CustomQuizButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isWrong = false,
    this.height = kQuizOptionHeight,
    this.radius = kRadius48,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isWrong
        ? AppColors.quizWrongBg
        : isSelected
        ? AppColors.homeLime
        : AppColors.white;
    final Color border = isWrong
        ? AppColors.quizWrongBorder
        : isSelected
        ? AppColors.chapterSelectedGreenBorder
        : AppColors.quizAnswerShadow;
    final Color shadow = isWrong
        ? AppColors.quizWrongShadow
        : isSelected
        ? AppColors.primaryBtnShadow
        : AppColors.quizAnswerShadow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(color: border, width: 2.w),
          boxShadow: <BoxShadow>[
            BoxShadow(color: shadow, blurRadius: 0, offset: Offset(0, 8.h)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w900,
            color: isWrong
                ? AppColors.quizWrongShadow
                : AppColors.homePrimaryText,
          ),
        ),
      ),
    );
  }
}

class AudioPromptCard extends StatelessWidget {
  final bool compact;

  const AudioPromptCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 0,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: const BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volume_up_rounded,
              color: AppColors.primaryGreen,
              size: 50.w,
            ),
          ),
          SizedBox(height: 46.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _RoundAudioButton(label: '1X'),
              SizedBox(width: 48.w),
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(width: 48.w),
              _RoundAudioButton(icon: Icons.replay_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAudioButton extends StatelessWidget {
  final String? label;
  final IconData? icon;

  const _RoundAudioButton({this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        shape: BoxShape.circle,
      ),
      child: icon == null
          ? Text(
              label!,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.bodyText,
              ),
            )
          : Icon(icon, color: AppColors.bodyText, size: 20.w),
    );
  }
}
