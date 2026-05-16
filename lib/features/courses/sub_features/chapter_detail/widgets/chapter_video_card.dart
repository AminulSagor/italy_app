import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/chapter_detail_models.dart';

class ChapterVideoCard extends StatelessWidget {
  final ChapterDetailModel detail;

  const ChapterVideoCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kChapterVideoCardHeight.h,
      padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 26.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.chapterVideoDark,
            AppColors.chapterVideoDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(kCourseDetailCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 24.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 74.w,
            height: 74.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.white,
              size: 44.w,
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  detail.videoProgressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${detail.watchedTimeLabel} / ${detail.totalTimeLabel}',
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homeLime,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            child: LinearProgressIndicator(
              value: detail.videoProgress,
              borderRadius: BorderRadius.circular(999.r),
              minHeight: 15.h,
              color: AppColors.homeLime,
              backgroundColor: AppColors.chapterProgressTrack,
            ),
          ),
        ],
      ),
    );
  }
}
