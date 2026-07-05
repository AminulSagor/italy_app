import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';
import 'package:get/get.dart';

class SupportCommunityCard extends StatelessWidget {
  final HomeSupportModel support;
  final VoidCallback? onTap;

  const SupportCommunityCard({super.key, required this.support, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kHomeCardRadius.r),
      onTap: onTap,
      child: Container(
        height: kHomeSupportCardHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.homePaleGreen,
          borderRadius: BorderRadius.circular(kHomeCardRadius.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: kHomeIconCircleSize.w,
              height: kHomeIconCircleSize.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primaryGreen,
                size: kHomeTopIconSize.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    support.title,
                    style: TextStyle(
                      fontSize: AppFont.font17.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    support.subtitle,
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryGreen,
              size: (kHomeTopIconSize + 6).w,
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
    return GestureDetector(
      onTap: onJoinTap,
      child: Container(
        height: kHomeWebinarCardHeight.h,
        padding: EdgeInsets.fromLTRB(30.w, 26.h, 26.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.homeDeepGreen,
          borderRadius: BorderRadius.circular(kHomeCardRadius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Text(
                'upcoming_webinar'.tr,
                style: TextStyle(
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppColors.white,
                ),
              ),
            ),
            const Spacer(),
            Text(
              webinar.title,
              style: TextStyle(
                fontSize: AppFont.font22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Container(
                  width: kHomeIconCircleSize.w,
                  height: kHomeIconCircleSize.w,
                  decoration: BoxDecoration(
                    color: AppColors.homePrimaryText,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.w),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.white,
                    size: kHomeTopIconSize.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        webinar.hostName,
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        webinar.timeLabel,
                        style: TextStyle(
                          fontSize: AppFont.font11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.homePaleGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38.h,
                  width: 76.w,
                  child: ElevatedButton(
                    onPressed: onJoinTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kHomePillRadius.r),
                      ),
                    ),
                    child: Text(
                      'view'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
