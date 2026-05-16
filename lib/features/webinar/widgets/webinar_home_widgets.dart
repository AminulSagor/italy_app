import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/webinar_models.dart';
import 'webinar_common_widgets.dart';

class WebinarLiveHeroCard extends StatelessWidget {
  final WebinarModel webinar;
  final VoidCallback onJoinTap;

  const WebinarLiveHeroCard({
    super.key,
    required this.webinar,
    required this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kWebinarHeroHeight.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kWebinarHeroRadius.r),
        border: Border.all(color: AppColors.webinarHeroBorder, width: 3.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((kWebinarHeroRadius - 2).r),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: WebinarTeacherImage(
                alt: true,
                borderRadius: kWebinarHeroRadius,
              ),
            ),
            Positioned(right: 18.w, top: 16.h, child: const WebinarLiveBadge()),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30.w, 75.h, 30.w, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      webinar.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.02,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Host: ${webinar.hostName}',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.limeTextColor,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.group_outlined,
                          size: 14.w,
                          color: AppColors.limeTextColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${webinar.learnersJoined} Learners Joined',
                          style: TextStyle(
                            fontSize: AppFont.font16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.limeTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: onJoinTap,
                      child: Container(
                        height: 46.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: AppColors.legacyColorFFD5D5D5,
                          borderRadius: BorderRadius.circular(
                            kHomePillRadius.r,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Join Now',
                              style: TextStyle(
                                fontSize: AppFont.font14.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primaryGreen,
                              size: 22.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebinarSectionHeader extends StatelessWidget {
  const WebinarSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Upcoming Sessions',
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.homePrimaryText,
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.homePaleGreen,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
          ),
          child: Text(
            'Free',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class WebinarSessionCard extends StatelessWidget {
  final WebinarSessionModel session;

  const WebinarSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.webinarSessionBg,
        borderRadius: BorderRadius.circular(kRadius32.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.webinarDateBg,
              borderRadius: BorderRadius.circular(kRadius24.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  session.month,
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  session.day,
                  style: TextStyle(
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  session.title,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${session.timeLabel}\n• ${session.levelLabel}',
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.bodyText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(
              color: AppColors.webinarControlBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.bodyText,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
