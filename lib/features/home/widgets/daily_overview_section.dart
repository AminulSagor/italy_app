import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

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
                  Text(overview.title, style: TextStyle(fontSize: AppFont.font20.sp, fontWeight: FontWeight.w800, height: 1.1, color: AppColors.homePrimaryText)),
                  SizedBox(height: 4.h),
                  Text(
                    overview.subtitle,
                    style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w500, height: 1.2, color: AppColors.homeSecondaryText),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  overview.totalTime,
                  style: TextStyle(fontSize: AppFont.font24.sp, fontWeight: FontWeight.w900, height: 1, color: AppColors.primaryGreen),
                ),
                SizedBox(height: 2.h),
                Text(
                  overview.totalTimeLabel,
                  style: TextStyle(fontSize: AppFont.font9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: AppColors.homeSecondaryText),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: (kHomeChartHeight + 24).h,
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
          height: kHomeChartHeight.h - 1,
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
                      color: AppColors.homeBarTrack,
                      borderRadius: BorderRadius.circular(
                        kHomePillRadius.r,
                      ),
                    ),
                  ),
                  Container(
                    width: 42.w,
                    height: activity.valueHeight.h,
                    decoration: BoxDecoration(
                      color: _barColor(activity.tone),
                      borderRadius: BorderRadius.circular(
                        kHomePillRadius.r,
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
          style: TextStyle(fontSize: AppFont.font10.sp, fontWeight: FontWeight.w900, color: AppColors.homeSecondaryText).copyWith(
            color: activity.isSelected
                ? AppColors.primaryGreen
                : AppColors.homeSecondaryText,
          ),
        ),
      ],
    );
  }

  Color _barColor(HomeActivityTone tone) {
    switch (tone) {
      case HomeActivityTone.primary:
        return AppColors.primaryGreen;
      case HomeActivityTone.lime:
        return AppColors.homeBarPale;
      case HomeActivityTone.muted:
        return AppColors.homeSoftGreen;
      case HomeActivityTone.soft:
        return AppColors.homeBarLight;
    }
  }
}
