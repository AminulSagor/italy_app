import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_models.dart';

class SpecializedLearningCard extends StatelessWidget {
  final SpecializedLearningModel item;

  const SpecializedLearningCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kSpecializedCardHeight.h),
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.coursesSpecialBg, AppColors.coursesSpecialBgEnd],
        ),
        borderRadius: BorderRadius.circular(kCourseCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 62.w,
            height: 62.w,
            decoration: const BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_rounded, color: AppColors.primaryGreen, size: 30.w),
          ),
          SizedBox(height: 28.h),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homeLime,
            ),
          ),
          SizedBox(height: 22.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.w,
            runSpacing: 10.h,
            children: <Widget>[
              _FooterPill(icon: Icons.info_outline_rounded, label: item.requirementLabel),
              _FooterPill(icon: Icons.lock_rounded, label: item.lockedLabel, isMuted: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isMuted;

  const _FooterPill({required this.icon, required this.label, this.isMuted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: isMuted ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: isMuted ? AppColors.coursesCardDisabledText : AppColors.homeLime, size: 14.w),
          SizedBox(width: 7.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              color: isMuted ? AppColors.coursesCardDisabledText : AppColors.homeLime,
            ),
          ),
        ],
      ),
    );
  }
}
