import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

class DailyOverviewSection extends StatelessWidget {
  final HomeOverviewModel overview;

  const DailyOverviewSection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(overview.title, style: AppTheme.homeSectionTitleStyle),
                  SizedBox(height: 4.h),
                  Text(
                    overview.subtitle,
                    style: AppTheme.homeSectionSubtitleStyle,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  overview.totalTime,
                  style: AppTheme.homeOverviewValueStyle,
                ),
                SizedBox(height: 2.h),
                Text(
                  overview.totalTimeLabel,
                  style: AppTheme.homeOverviewUnitStyle,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: (AppTheme.homeChartHeight + 24).h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: overview.activities.map((HomeActivityModel activity) {
              return Expanded(child: _DailyActivityBar(activity: activity));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DailyActivityBar extends StatelessWidget {
  final HomeActivityModel activity;

  const _DailyActivityBar({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: AppTheme.homeChartHeight.h - 1,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 42.w,
              height: activity.trackHeight.h,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    width: 42.w,
                    height: activity.trackHeight.h,
                    decoration: BoxDecoration(
                      color: AppTheme.homeBarTrack,
                      borderRadius: BorderRadius.circular(
                        AppTheme.homePillRadius.r,
                      ),
                    ),
                  ),
                  Container(
                    width: 42.w,
                    height: activity.valueHeight.h,
                    decoration: BoxDecoration(
                      color: _barColor(activity.tone),
                      borderRadius: BorderRadius.circular(
                        AppTheme.homePillRadius.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          activity.dayLabel,
          style: AppTheme.homeChartAxisStyle.copyWith(
            color: activity.isSelected
                ? AppTheme.primaryGreen
                : AppTheme.homeSecondaryText,
          ),
        ),
      ],
    );
  }

  Color _barColor(HomeActivityTone tone) {
    switch (tone) {
      case HomeActivityTone.primary:
        return AppTheme.primaryGreen;
      case HomeActivityTone.lime:
        return AppTheme.homeBarPale;
      case HomeActivityTone.muted:
        return AppTheme.homeSoftGreen;
      case HomeActivityTone.soft:
        return AppTheme.homeBarLight;
    }
  }
}
