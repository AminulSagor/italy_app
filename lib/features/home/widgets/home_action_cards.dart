import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

class SupportCommunityCard extends StatelessWidget {
  final HomeSupportModel support;
  final VoidCallback? onTap;

  const SupportCommunityCard({
    super.key,
    required this.support,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
      onTap: onTap,
      child: Container(
        height: AppTheme.homeSupportCardHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.homePaleGreen,
          borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: AppTheme.homeIconCircleSize.w,
              height: AppTheme.homeIconCircleSize.w,
              decoration: const BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_rounded,
                color: AppTheme.primaryGreen,
                size: AppTheme.homeTopIconSize.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(support.title, style: AppTheme.homeSupportTitleStyle),
                  SizedBox(height: 3.h),
                  Text(support.subtitle, style: AppTheme.homeSupportSubtitleStyle),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.primaryGreen,
              size: (AppTheme.homeTopIconSize + 6).w,
            ),
          ],
        ),
      ),
    );
  }
}

class WebinarCard extends StatelessWidget {
  final HomeWebinarModel webinar;
  final VoidCallback? onJoinTap;

  const WebinarCard({super.key, required this.webinar, this.onJoinTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.homeWebinarCardHeight.h,
      padding: EdgeInsets.fromLTRB(30.w, 26.h, 26.w, 24.h),
      decoration: BoxDecoration(
        color: AppTheme.homeDeepGreen,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.homeBarLight,
              borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
            ),
            child: Text(webinar.badgeLabel, style: AppTheme.homeWebinarBadgeStyle),
          ),
          const Spacer(),
          Text(webinar.title, style: AppTheme.homeWebinarTitleStyle),
          const Spacer(),
          Row(
            children: <Widget>[
              Container(
                width: AppTheme.homeIconCircleSize.w,
                height: AppTheme.homeIconCircleSize.w,
                decoration: BoxDecoration(
                  color: AppTheme.homePrimaryText,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 2.w),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.white,
                  size: AppTheme.homeTopIconSize.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(webinar.hostName, style: AppTheme.homeWebinarNameStyle),
                    SizedBox(height: 2.h),
                    Text(webinar.timeLabel, style: AppTheme.homeWebinarTimeStyle),
                  ],
                ),
              ),
              SizedBox(
                height: 38.h,
                width: 76.w,
                child: ElevatedButton(
                  onPressed: onJoinTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
                    ),
                  ),
                  child: Text(webinar.buttonLabel, style: AppTheme.homeJoinButtonStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
