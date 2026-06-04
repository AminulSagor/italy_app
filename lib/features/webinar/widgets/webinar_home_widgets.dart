import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/webinar_models.dart';
import 'webinar_common_widgets.dart';

class WebinarLiveHeroCard extends StatelessWidget {
  const WebinarLiveHeroCard({
    super.key,
    required this.webinar,
    required this.onJoinTap,
    required this.isJoining,
  });

  final WebinarItemModel webinar;
  final VoidCallback onJoinTap;
  final bool isJoining;

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
            Positioned.fill(child: WebinarThumbnail(url: webinar.thumbnailImageUrl)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.transparent,
                      AppColors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.02,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Host: ${webinar.hostTeacherName}',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.limeTextColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: isJoining ? null : onJoinTap,
                      child: Container(
                        height: 46.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: AppColors.legacyColorFFD5D5D5,
                          borderRadius: BorderRadius.circular(kHomePillRadius.r),
                        ),
                        child: Center(
                          child: isJoining
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGreen,
                                  ),
                                )
                              : Row(
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

class WebinarThumbnail extends StatelessWidget {
  const WebinarThumbnail({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = url?.trim() ?? '';
    if (imageUrl.isEmpty) return const _ThumbnailFallback();

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
      loadingBuilder: (_, Widget child, ImageChunkEvent? progress) {
        if (progress == null) return child;
        return const _ThumbnailFallback();
      },
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.legacyColorFFECEFF0,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.bodyText,
          size: 42.w,
        ),
      ),
    );
  }
}

class WebinarSectionHeader extends StatelessWidget {
  const WebinarSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Upcoming Sessions',
      style: TextStyle(
        fontSize: AppFont.font20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.homePrimaryText,
      ),
    );
  }
}

class WebinarSessionCard extends StatelessWidget {
  const WebinarSessionCard({super.key, required this.webinar});

  final WebinarItemModel webinar;

  @override
  Widget build(BuildContext context) {
    final DateTime? dateTime = webinar.dateTime;
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
                  _monthLabel(dateTime),
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  dateTime?.day.toString().padLeft(2, '0') ?? '--',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  webinar.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Starts at ${_timeLabel(dateTime)}\nHost: ${webinar.hostTeacherName}',
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
        ],
      ),
    );
  }

  String _monthLabel(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    const List<String> months = <String>[
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return months[dateTime.month - 1];
  }

  String _timeLabel(DateTime? dateTime) {
    if (dateTime == null) return 'Not available';
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String suffix = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

class WebinarEmptyState extends StatelessWidget {
  const WebinarEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 34.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius28.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppFont.font15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.bodyText,
        ),
      ),
    );
  }
}
