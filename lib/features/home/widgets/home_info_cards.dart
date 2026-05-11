import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

class CulturalTipCard extends StatelessWidget {
  final HomeInfoCardModel tip;

  const CulturalTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: AppTheme.homeCultureCardMinHeight.h,
      ),
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 24.w, 20.h),
      decoration: BoxDecoration(
        gradient: AppTheme.homeCultureGradient,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.primaryGreen,
                size: AppTheme.homeTopIconSize.w,
              ),
              SizedBox(width: 12.w),
              Text(tip.title, style: AppTheme.homeCultureTitleStyle),
            ],
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 34.w),
            child: Text(tip.body, style: AppTheme.homeCultureBodyStyle),
          ),
        ],
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  final HomeInfoCardModel streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.homeStreakHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      decoration: BoxDecoration(
        gradient: AppTheme.homeStreakGradient,
        borderRadius: BorderRadius.circular(AppTheme.homeSmallCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppTheme.homeIconCircleSize.w,
            height: AppTheme.homeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.homeOrangeDeep,
              size: AppTheme.homeTopIconSize.w,
            ),
          ),
          SizedBox(width: 18.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(streak.title, style: AppTheme.homeStreakTitleStyle),
              SizedBox(height: 4.h),
              Text(streak.body, style: AppTheme.homeStreakSubtitleStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class AiTutorCard extends StatelessWidget {
  final HomeInfoCardModel tutor;
  final VoidCallback? onStartTap;

  const AiTutorCard({super.key, required this.tutor, this.onStartTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: AppTheme.homeTutorCardMinHeight.h),
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
      decoration: BoxDecoration(
        gradient: AppTheme.homeAiTutorGradient,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.homeNeutralShadow,
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.primaryGreen,
                size: AppTheme.homeTopIconSize.w,
              ),
              SizedBox(width: 8.w),
              Text(tutor.eyebrow, style: AppTheme.homeAiEyebrowStyle),
            ],
          ),
          SizedBox(height: 20.h),
          Text(tutor.title, style: AppTheme.homeAiTitleStyle),
          SizedBox(height: 14.h),
          Text(tutor.body, style: AppTheme.homeAiBodyStyle),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            height: 62.h,
            child: ElevatedButton(
              onPressed: onStartTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                elevation: 8,
                shadowColor: AppTheme.homeCardShadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.homePillRadius.r,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(tutor.actionLabel, style: AppTheme.homeChatButtonStyle),
                  SizedBox(width: 18.w),
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppTheme.white,
                    size: AppTheme.homeTopIconSize.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyChallengesCard extends StatelessWidget {
  final HomeDailyChallengesModel challenges;

  const DailyChallengesCard({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: AppTheme.homeChallengeCardHeight.h,
      ),
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 20.h),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.homeSmallCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppTheme.homeIconCircleSize.w,
            height: AppTheme.homeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppTheme.homePaleGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: AppTheme.primaryGreen,
              size: AppTheme.homeTopIconSize.w,
            ),
          ),
          SizedBox(height: 12.h),
          Text(challenges.label, style: AppTheme.homeChallengeLabelStyle),
          SizedBox(height: 3.h),
          Text(challenges.valueLabel, style: AppTheme.homeChallengeValueStyle),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
            child: LinearProgressIndicator(
              minHeight: AppTheme.homeSlimProgressHeight.h,
              value: challenges.progress,
              backgroundColor: AppTheme.homeProgressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.homeChallengeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
