import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

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
      height: AppTheme.homeChapterCardHeight.h,
      padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 26.h),
      decoration: BoxDecoration(
        gradient: AppTheme.homeChapterGradient,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.homeCardShadow,
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(chapter.eyebrow, style: AppTheme.homeChapterEyebrowStyle),
          SizedBox(height: 14.h),
          Text(chapter.title, style: AppTheme.homeChapterTitleStyle),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(chapter.progressLabel, style: AppTheme.homeChapterMetaStyle),
              Text(
                '${(chapter.progress * 100).round()}%',
                style: AppTheme.homeChapterMetaStyle,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
            child: LinearProgressIndicator(
              minHeight: AppTheme.homeProgressHeight.h,
              value: chapter.progress,
              backgroundColor: AppTheme.homeProgressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.homeLime),
            ),
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 58.h,
            child: ElevatedButton(
              onPressed: onContinueTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(chapter.buttonLabel, style: AppTheme.homePrimaryButtonStyle),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: AppTheme.primaryGreen,
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
