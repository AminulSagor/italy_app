import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../models/quiz_models.dart';
import 'package:get/get.dart';

class LessonTrophyHero extends StatelessWidget {
  final double size;
  final bool compact;

  const LessonTrophyHero({super.key, required this.size, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.lessonMilestoneGlow.withValues(alpha: 0.12),
            blurRadius: 50,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(child: Image.asset('assets/decor_png/lesson_complete.png')),
    );
  }
}

class LessonXpPill extends StatelessWidget {
  final QuizLessonCompleteModel complete;

  const LessonXpPill({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.lessonXpBg,
        borderRadius: BorderRadius.circular(kRadius48.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            offset: Offset(0, 4.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.homeOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 28.w,
              color: AppColors.lessonXpText,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  complete.hasXpBoost
                      ? complete.xpBoostLabel
                      : 'points_earned'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'score_xp_value'.trParams(<String, String>{
                    'xp': complete.xpEarned.toString(),
                  }),
                  style: TextStyle(
                    fontSize: AppFont.font30.sp,
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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kRadius48.r),
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
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: 24.w),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font30.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(9999.r),
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
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28.w),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.bodyText,
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: subtitle == null
                        ? AppFont.font12.sp
                        : AppFont.font28.sp,
                    fontWeight: FontWeight.w800,
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
              size: 24.w,
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(9999.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.lessonMilestoneGlow.withValues(alpha: 0.3),
            blurRadius: 30.r,
            offset: Offset(0, 0.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.homeLime,
              borderRadius: BorderRadius.circular(kRadius22.r),
            ),
            child: Text(
              '2×',
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'boost_active_remaining'.trParams(<String, String>{
                'remaining': complete.boostRemaining,
              }),
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w700,
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
              padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 42.h),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onCloseTap,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 22.w,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'milestone_reached'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                  SizedBox(height: 22.h),
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
                          complete.appName,
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        LessonTrophyHero(size: 210, compact: true),
                        Text(
                          complete.headline,
                          style: TextStyle(
                            fontSize: AppFont.font44.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'you_completed_chapter'.trParams(<String, String>{
                            'chapter': complete.chapterTitle,
                          }),
                          style: TextStyle(
                            fontSize: AppFont.font18.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14.w,
                          runSpacing: 12.h,
                          children: <Widget>[
                            _MilestoneChip(
                              label: 'xp_earned_value'.trParams(
                                <String, String>{'xp': '${complete.xpEarned}'},
                              ),
                            ),
                            _MilestoneChip(
                              label: 'day_streak_value'.trParams(
                                <String, String>{
                                  'days': '${complete.streakDays}',
                                },
                              ),
                              color: AppColors.lessonStreakBg,
                              textColor: AppColors.blockDangerRed,
                            ),
                            _MilestoneChip(
                              label: 'accuracy_percent_value'.trParams(
                                <String, String>{
                                  'accuracy': '${complete.accuracyPercent}',
                                },
                              ),
                              color: AppColors.lessonAccuracyBg,
                              textColor: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                        SizedBox(height: 28.h),
                        SizedBox(
                          width: 296.w,
                          child: CustomButton(
                            onPressed: onCloseTap,
                            text: 'join_the_italian_journey'.tr,
                            height: 44,
                            width: double.infinity,
                            showShadow: false,
                            fontSize: AppFont.font14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32.w, 24.h, 32.w, 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'share_your_victory'.tr,
                          style: TextStyle(
                            fontSize: AppFont.font11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bodyText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 14.h),
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
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w700,
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
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 3.w),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 28.w),
    );
  }
}
