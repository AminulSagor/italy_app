import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class CulturalTipCard extends StatelessWidget {
  final HomeInfoCardModel tip;

  const CulturalTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kHomeCultureCardMinHeight.h),
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 24.w, 20.h),
      decoration: BoxDecoration(
        gradient: AppColors.homeCultureGradient,
        borderRadius: BorderRadius.circular(kHomeCardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primaryGreen,
                size: kHomeTopIconSize.w,
              ),
              SizedBox(width: 12.w),
              Text(
                tip.title,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 34.w),
            child: Text(
              tip.body,
              style: TextStyle(
                fontSize: AppFont.font13.sp,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.homeSecondaryText,
              ),
            ),
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
      height: kHomeStreakHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      decoration: BoxDecoration(
        gradient: AppColors.homeStreakGradient,
        borderRadius: BorderRadius.circular(kHomeSmallCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: kHomeIconCircleSize.w,
            height: kHomeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.homeOrangeDeep,
              size: kHomeTopIconSize.w,
            ),
          ),
          SizedBox(width: 18.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                streak.title,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                streak.body,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
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
      constraints: BoxConstraints(minHeight: kHomeTutorCardMinHeight.h),
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
      decoration: BoxDecoration(
        gradient: AppColors.homeAiTutorGradient,
        borderRadius: BorderRadius.circular(kHomeCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
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
                color: AppColors.primaryGreen,
                size: kHomeTopIconSize.w,
              ),
              SizedBox(width: 8.w),
              Text(
                tutor.eyebrow,
                style: TextStyle(
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            tutor.title,
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              height: 1.12,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            tutor.body,
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w600,
              height: 1.55,
              color: AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 22.h),
          CustomButton.primary(
            onPressed: () => onStartTap,
            text: tutor.actionLabel,
            icon: Icons.chat_bubble_outline_rounded,
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
      constraints: BoxConstraints(minHeight: kHomeChallengeCardHeight.h),
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kHomeSmallCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
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
            width: kHomeIconCircleSize.w,
            height: kHomeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppColors.homePaleGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: AppColors.primaryGreen,
              size: kHomeTopIconSize.w,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            challenges.label,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              color: AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            challenges.valueLabel,
            style: TextStyle(
              fontSize: AppFont.font23.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              minHeight: kHomeSlimProgressHeight.h,
              value: challenges.progress,
              backgroundColor: AppColors.homeProgressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.homeChallengeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
