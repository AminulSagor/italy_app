import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/home_models.dart';

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
                    'Daily Overview',
                    style: TextStyle(
                      fontSize: AppFont.font20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your learning activity this week',
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
                  'THIS WEEK',
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
        SizedBox(
          height: (kHomeChartHeight + 24).h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
    final double fraction = maxSeconds <= 0
        ? 0
        : (activity.durationSeconds / maxSeconds).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: kHomeChartHeight.h,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              child: Container(
                width: 42.w,
                height: kHomeChartHeight.h,
                color: AppColors.homeBarTrack,
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
                      borderRadius: BorderRadius.circular(
                        kHomePillRadius.r,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          activity.dayLabel,
          style: TextStyle(
            fontSize: AppFont.font10.sp,
            fontWeight: FontWeight.w900,
            color: activity.isToday
                ? AppColors.primaryGreen
                : AppColors.homeSecondaryText,
          ),
        ),
      ],
    );
  }
}
