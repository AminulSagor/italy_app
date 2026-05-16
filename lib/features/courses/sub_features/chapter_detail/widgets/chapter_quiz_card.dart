import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class ChapterQuizCard extends StatelessWidget {
  final ChapterQuizModel quiz;
  final VoidCallback onStartTap;

  const ChapterQuizCard({
    super.key,
    required this.quiz,
    required this.onStartTap,
  });

  bool get _isDisabled => quiz.status == ChapterQuizStatus.disabled;
  bool get _isCompleted => quiz.status == ChapterQuizStatus.completed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDisabled || _isCompleted ? null : onStartTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: kChapterQuizCardHeight.h),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: _isCompleted ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
          border: Border.all(
            color: _isDisabled
                ? AppColors.chapterQuizDisabledBorder
                : AppColors.chapterQuizEnabledBorder,
            width: 1.5.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _QuizIcon(status: quiz.status),
            SizedBox(height: _isCompleted ? 22.h : 20.h),
            if (_isCompleted) ...<Widget>[
              Text(
                'COMPLETED',
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 6.h),
            ],
            Text(
              quiz.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              quiz.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 18.h),
            if (_isCompleted)
              _CompletedStats(quiz: quiz)
            else
              Text(
                quiz.actionLabel,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w900,
                  color: _isDisabled
                      ? AppColors.homeSecondaryText
                      : AppColors.primaryGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizIcon extends StatelessWidget {
  final ChapterQuizStatus status;

  const _QuizIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = status == ChapterQuizStatus.disabled;
    final bool isCompleted = status == ChapterQuizStatus.completed;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.legacyColorFFE9EAEA
                : AppColors.homeLime,
            borderRadius: BorderRadius.circular(9999.r),
          ),
          child: Icon(
            isDisabled
                ? Icons.lock_outline_rounded
                : isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.quiz_outlined,
            color: isDisabled
                ? AppColors.homeSecondaryText
                : AppColors.primaryGreen,
            size: 26.w,
          ),
        ),
        if (isCompleted)
          Positioned(
            right: -1.w,
            bottom: -1.h,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 2.w),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.primaryGreen,
                size: 14.w,
              ),
            ),
          ),
      ],
    );
  }
}

class _CompletedStats extends StatelessWidget {
  final ChapterQuizModel quiz;

  const _CompletedStats({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _StatPill(icon: Icons.star_rounded, label: quiz.scoreLabel),
        SizedBox(height: 14.h),
        _StatPill(
          icon: Icons.workspace_premium_rounded,
          label: quiz.xpLabel,
          isOrange: true,
        ),
        SizedBox(height: 14.h),
        _StatPill(
          icon: Icons.timer_outlined,
          label: quiz.timeLabel,
          isMuted: true,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOrange;
  final bool isMuted;

  const _StatPill({
    required this.icon,
    required this.label,
    this.isOrange = false,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isOrange
            ? AppColors.coursesCreamLightBg
            : isMuted
            ? AppColors.legacyColorFFF0F0F0
            : AppColors.legacyColorFFE8F4DF,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: isOrange
                ? AppColors.coursesCreamText
                : isMuted
                ? AppColors.bodyText
                : AppColors.primaryGreen,
            size: 16.w,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              color: isOrange
                  ? AppColors.coursesCreamText
                  : isMuted
                  ? AppColors.bodyText
                  : AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
