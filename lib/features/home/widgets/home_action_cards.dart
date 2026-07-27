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

  const WebinarCard({
    super.key,
    required this.webinar,
    this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onJoinTap != null,
      label: '${'upcoming_webinar'.tr}: ${webinar.title}',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.homeDeepGreen,
            borderRadius: BorderRadius.circular(kHomeCardRadius.r),
          ),
          child: InkWell(
            onTap: onJoinTap,
            borderRadius: BorderRadius.circular(kHomeCardRadius.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22.w,
                vertical: 22.h,
              ),
              child: LayoutBuilder(
                builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                    ) {
                  final bool useCompactLayout =
                      constraints.maxWidth < 330;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildWebinarBadge(),

                      SizedBox(height: 18.h),

                      Text(
                        webinar.title.trim().isEmpty
                            ? 'upcoming_webinar'.tr
                            : webinar.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font22.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: AppColors.white,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      if (useCompactLayout) ...<Widget>[
                        _buildHostInformation(),

                        SizedBox(height: 18.h),

                        SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: _buildViewButton(),
                        ),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: _buildHostInformation(),
                            ),

                            SizedBox(width: 14.w),

                            SizedBox(
                              height: 42.h,
                              child: _buildViewButton(),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebinarBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Text(
        'upcoming_webinar'.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: AppFont.font10.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildHostInformation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            color: AppColors.homePrimaryText,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            color: AppColors.white,
            size: 23.r,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                webinar.hostName.trim().isEmpty
                    ? 'upcoming_webinar'.tr
                    : webinar.hostName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.white,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                webinar.timeLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.homePaleGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton() {
    return ElevatedButton(
      onPressed: onJoinTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryGreen,
        disabledBackgroundColor:
        AppColors.white.withValues(alpha: 0.55),
        disabledForegroundColor:
        AppColors.primaryGreen.withValues(alpha: 0.55),
        elevation: 0,
        minimumSize: Size(88.w, 42.h),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
        ),
      ),
      child: Text(
        'view'.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: AppFont.font13.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
