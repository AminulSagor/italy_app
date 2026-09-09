import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/home_models.dart';
import 'package:get/get.dart';

class DailyOverviewSection extends StatelessWidget {
  const DailyOverviewSection({super.key, required this.overview});

  final HomeOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final int maxSeconds = overview.days.fold<int>(
      0,
      (int current, HomeActivityModel item) =>
          item.durationSeconds > current ? item.durationSeconds : current,
    );

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'gen_daily_overview'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.homePrimaryText,
                    ),
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    'gen_your_learning_activity_this_we'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.homeSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  overview.totalTimeLabel,
                  style: TextStyle(
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'this_week'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font9.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.homeSecondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        RepaintBoundary(
          child: SizedBox(
            // Keep a dedicated footer for the gap and day label. The previous
            // height was smaller than the scaled children by a fraction of a
            // pixel, which produced one RenderFlex exception for every bar.
            height: (kHomeChartHeight + 42).h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: overview.days
                  .map(
                    (HomeActivityModel activity) => Expanded(
                      child: _DailyActivityBar(
                        activity: activity,
                        maxSeconds: maxSeconds,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyActivityBar extends StatelessWidget {
  const _DailyActivityBar({
    required this.activity,
    required this.maxSeconds,
  });

  final HomeActivityModel activity;
  final int maxSeconds;

  @override
  Widget build(BuildContext context) {
    final double rawFraction = maxSeconds <= 0
        ? 0
        : (activity.durationSeconds / maxSeconds)
              .clamp(0.0, 1.0)
              .toDouble();
    final double fraction = activity.durationSeconds > 0
        ? rawFraction.clamp(0.08, 1.0).toDouble()
        : 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.h,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                activity.durationLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w700,
                  color: activity.durationSeconds > 0
                      ? AppColors.homePrimaryText
                      : AppColors.homeSecondaryText,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.homeBarTrack,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: fraction,
                  widthFactor: 1,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: activity.isToday
                          ? AppColors.primaryGreen
                          : AppColors.homeBarLight,
                      borderRadius: BorderRadius.circular(kHomePillRadius.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 18.h,
            child: Center(
              child: Text(
                activity.dayLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: activity.isToday
                      ? AppColors.primaryGreen
                      : AppColors.homeSecondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
