import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class CurrentChapterCard extends StatelessWidget {
  final HomeChapterModel chapter;
  final VoidCallback? onContinueTap;

  const CurrentChapterCard({
    super.key,
    required this.chapter,
    this.onContinueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kHomeChapterCardHeight.h),
      padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 26.h),
      decoration: BoxDecoration(
        gradient: AppColors.homeChapterGradient,
        borderRadius: BorderRadius.circular(kHomeCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(chapter.eyebrow, style: TextStyle(fontSize: AppFont.font11.sp, fontWeight: FontWeight.w900, letterSpacing: 0.9, color: AppColors.homeBarLight)),
          SizedBox(height: 14.h),
          Text(chapter.title, style: TextStyle(fontSize: AppFont.font22.sp, fontWeight: FontWeight.w900, height: 1.12, color: AppColors.homePaleGreen)),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(chapter.progressLabel, style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w800, color: AppColors.homePaleGreen)),
              Text(
                '${(chapter.progress * 100).round()}%',
                style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w800, color: AppColors.homePaleGreen),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              minHeight: kHomeProgressHeight.h,
              value: chapter.progress,
              backgroundColor: AppColors.homeProgressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.homeLime,
              ),
            ),
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 58.h,
            child: ElevatedButton(
              onPressed: onContinueTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    kHomePillRadius.r,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    chapter.buttonLabel,
                    style: TextStyle(fontSize: AppFont.font14.sp, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primaryGreen,
                    size: kHomeTopIconSize.w,
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
