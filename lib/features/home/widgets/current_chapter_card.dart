import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/home_models.dart';

class CurrentChapterCard extends StatelessWidget {
  const CurrentChapterCard({
    super.key,
    required this.chapter,
    this.onContinueTap,
  });

  final HomeChapterModel chapter;
  final VoidCallback? onContinueTap;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            chapter.courseTitle.isEmpty
                ? 'CURRENT CHAPTER'
                : chapter.courseTitle.toUpperCase(),
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: AppColors.homeBarLight,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            chapter.lessonTitle,
            style: TextStyle(
              fontSize: AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              height: 1.12,
              color: AppColors.homePaleGreen,
            ),
          ),
          if (chapter.chapterTitle.isNotEmpty) ...<Widget>[
            SizedBox(height: 5.h),
            Text(
              chapter.chapterTitle,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                color: AppColors.homeBarLight,
              ),
            ),
          ],
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Chapter progress',
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePaleGreen,
                ),
              ),
              Text(
                chapter.progressLabel,
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePaleGreen,
                ),
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
          CustomButton(
            onPressed: onContinueTap ?? () {},
            text: 'Continue Learning',
            width: double.infinity,
            height: 56.h,
            icon: Icons.play_arrow_rounded,
            textColor: AppColors.primaryGreen,
            btnColor: AppColors.white,
            borderRadius: kHomePillRadius.r,
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}
