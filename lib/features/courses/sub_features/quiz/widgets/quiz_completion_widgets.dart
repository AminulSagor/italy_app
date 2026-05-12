import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../models/quiz_models.dart';

class LessonTrophyHero extends StatelessWidget {
  final double size;
  final bool compact;

  const LessonTrophyHero({super.key, required this.size, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.lessonMilestoneGlow,
            blurRadius: compact ? 58.r : 90.r,
            spreadRadius: compact ? 16.r : 30.r,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '🏆',
          style: TextStyle(fontSize: compact ? 128.sp : 170.sp),
        ),
      ),
    );
  }
}

class LessonXpPill extends StatelessWidget {
  final QuizLessonCompleteModel complete;

  const LessonXpPill({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kLessonCompletePillHeight.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      decoration: BoxDecoration(
        color: AppColors.lessonXpBg,
        borderRadius: BorderRadius.circular(kXXLargeBorderRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            offset: Offset(0, 6.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: AppColors.homeOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 42.w,
              color: AppColors.lessonXpText,
            ),
          ),
          SizedBox(width: 26.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  complete.hasXpBoost ? complete.xpBoostLabel : 'POINTS EARNED',
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '+${complete.xpEarned} XP',
                  style: TextStyle(
                    fontSize: AppFont.font40.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.lessonXpText,
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

class LessonMetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color valueColor;

  const LessonMetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kLessonCompleteStatCardHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kXXLargeBorderRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            offset: Offset(0, 6.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: 32.w),
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font36.sp,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.7,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonSimplePill extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color? backgroundColor;
  final String? subtitle;

  const LessonSimplePill({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    this.backgroundColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kLessonCompleteSmallPillHeight.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(kXXLargeBorderRadius.r),
        border: backgroundColor == null
            ? Border.all(color: AppColors.modalBorderGrey, width: 2.w)
            : null,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            offset: Offset(0, 5.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30.w),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.bodyText,
                      letterSpacing: 2.2,
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: subtitle == null
                        ? AppFont.font18.sp
                        : AppFont.font34.sp,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          if (subtitle == null)
            Icon(
              Icons.trending_up_rounded,
              color: AppColors.primaryGreen,
              size: 34.w,
            ),
        ],
      ),
    );
  }
}

class LessonBoostPill extends StatelessWidget {
  final QuizLessonCompleteModel complete;

  const LessonBoostPill({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kLessonCompleteBoostHeight.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(kXXLargeBorderRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.lessonMilestoneGlow,
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 66.w,
            height: 66.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.homeLime,
              borderRadius: BorderRadius.circular(kRadius22.r),
            ),
            child: Text(
              '2×',
              style: TextStyle(
                fontSize: AppFont.font28.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 28.w),
          Expanded(
            child: Text(
              'Boost Active:\n${complete.boostRemaining}',
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: AppColors.limeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonMilestoneDialog extends StatelessWidget {
  final QuizLessonCompleteModel complete;
  final VoidCallback onCloseTap;

  const LessonMilestoneDialog({
    super.key,
    required this.complete,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: AppColors.lessonShareOverlay,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22.w, 48.h, 22.w, 42.h),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onCloseTap,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 40.w,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Milestone Reached',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font30.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                  SizedBox(height: 26.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 38.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        kLessonMilestoneDialogRadius.r,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '🇮🇹  ${complete.appName}',
                          style: TextStyle(
                            fontSize: AppFont.font22.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        LessonTrophyHero(size: 210, compact: true),
                        Text(
                          complete.headline,
                          style: TextStyle(
                            fontSize: AppFont.font56.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'You completed ${complete.chapterTitle}!',
                          style: TextStyle(
                            fontSize: AppFont.font26.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14.w,
                          runSpacing: 12.h,
                          children: <Widget>[
                            _MilestoneChip(label: '⚡ +${complete.xpEarned} XP'),
                            _MilestoneChip(
                              label: '🔥 ${complete.streakDays} Day Streak',
                              color: AppColors.lessonStreakBg,
                              textColor: AppColors.blockDangerRed,
                            ),
                            _MilestoneChip(
                              label: '🎯 ${complete.accuracyPercent}% Accuracy',
                              color: AppColors.lessonAccuracyBg,
                              textColor: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: 296.w,
                          child: CustomButton(
                            onPressed: onCloseTap,
                            text: 'Join the Italian journey!',
                            height: 58,
                            width: double.infinity,
                            showShadow: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 46.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(36.w, 34.h, 36.w, 38.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        kLessonMilestoneDialogRadius.r,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'SHARE YOUR VICTORY',
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bodyText,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 34.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            _ShareCircle(icon: Icons.file_download_outlined),
                            _ShareCircle(icon: Icons.share_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MilestoneChip({
    required this.label,
    this.color = AppColors.lessonXpBg,
    this.textColor = AppColors.homeOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}

class _ShareCircle extends StatelessWidget {
  final IconData icon;

  const _ShareCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 4.w),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 34.w),
    );
  }
}
