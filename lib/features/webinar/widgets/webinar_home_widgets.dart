import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
    required this.onRestrictionTap,
    required this.isJoining,
  });

  final WebinarItemModel webinar;
  final VoidCallback onJoinTap;
  final VoidCallback onRestrictionTap;
  final bool isJoining;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = !webinar.isEligible;

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
            Positioned.fill(
              child: WebinarThumbnail(url: webinar.thumbnailImageUrl),
            ),
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
            if (isLocked)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: _WebinarLockIcon(
                    backgroundColor: AppColors.black.withValues(alpha: 0.55),
                    iconColor: AppColors.white,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  30.w,
                  65.h,
                  isLocked ? 64.w : 30.w,
                  0,
                ),
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
                      'webinar_host_value'.trParams(<String, String>{
                        'host': webinar.hostTeacherName,
                      }),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.limeTextColor,
                      ),
                    ),
                    if (isLocked) ...<Widget>[
                      SizedBox(height: 6.h),
                      _RestrictedAudienceLink(
                        onTap: onRestrictionTap,
                        textColor: AppColors.white,
                      ),
                    ],
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: isJoining || isLocked ? null : onJoinTap,
                      child: Container(
                        height: 46.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: AppColors.legacyColorFFD5D5D5,
                          borderRadius: BorderRadius.circular(
                            kHomePillRadius.r,
                          ),
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
                                      isLocked ? 'locked'.tr : 'join_now'.tr,
                                      style: TextStyle(
                                        fontSize: AppFont.font14.sp,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      isLocked
                                          ? Icons.lock_outline_rounded
                                          : Icons.play_arrow_rounded,
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
      errorBuilder: (_, _, _) => const _ThumbnailFallback(),
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
      'upcoming_sessions'.tr,
      style: TextStyle(
        fontSize: AppFont.font20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.homePrimaryText,
      ),
    );
  }
}

class WebinarSessionCard extends StatelessWidget {
  const WebinarSessionCard({
    super.key,
    required this.webinar,
    required this.onRestrictionTap,
  });

  final WebinarItemModel webinar;
  final VoidCallback onRestrictionTap;

  @override
  Widget build(BuildContext context) {
    final DateTime? dateTime = webinar.dateTime;
    final bool isLocked = !webinar.isEligible;

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
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: isLocked ? 42.w : 0),
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
                        'webinar_starts_at'.trParams(<String, String>{
                          'time': _timeLabel(dateTime),
                        }),
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.bodyText,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'webinar_host_value'.trParams(<String, String>{
                          'host': webinar.hostTeacherName,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.bodyText,
                          height: 1.2,
                        ),
                      ),
                      if (isLocked) ...<Widget>[
                        SizedBox(height: 5.h),
                        _RestrictedAudienceLink(
                          onTap: onRestrictionTap,
                          textColor: AppColors.primaryGreen,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            const _WebinarLockIcon(
              backgroundColor: AppColors.webinarDateBg,
              iconColor: AppColors.primaryGreen,
            ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime? dateTime) {
    if (dateTime == null) return 'n_a'.tr;
    final List<String> months = <String>[
      'month_jan'.tr,
      'month_feb'.tr,
      'month_mar'.tr,
      'month_apr'.tr,
      'month_may'.tr,
      'month_jun'.tr,
      'month_jul'.tr,
      'month_aug'.tr,
      'month_sep'.tr,
      'month_oct'.tr,
      'month_nov'.tr,
      'month_dec'.tr,
    ];
    return months[dateTime.month - 1];
  }

  String _timeLabel(DateTime? dateTime) {
    if (dateTime == null) return 'not_available'.tr;
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String suffix = hour >= 12 ? 'pm'.tr : 'am'.tr;
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

class WebinarCourseAccessDialog extends StatelessWidget {
  const WebinarCourseAccessDialog({super.key, required this.courseNames});

  final List<String> courseNames;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.homeBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      title: Text(
        'course_details'.tr,
        style: TextStyle(
          fontSize: AppFont.font18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
          height: 1.32,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('webinar_course_access_description'.tr),
          SizedBox(height: 14.h),
          if (courseNames.isEmpty)
            Text('not_available'.tr)
          else
            ...courseNames.map(
              (String courseName) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 7.h),
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(child: Text(courseName)),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('done'.tr),
        ),
      ],
    );
  }
}

class _RestrictedAudienceLink extends StatelessWidget {
  const _RestrictedAudienceLink({required this.onTap, required this.textColor});

  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        'webinar_selected_course_only'.tr,
        style: TextStyle(
          fontSize: AppFont.font12.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
          decoration: TextDecoration.underline,
          decorationColor: textColor,
        ),
      ),
    );
  }
}

class _WebinarLockIcon extends StatelessWidget {
  const _WebinarLockIcon({
    required this.backgroundColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(Icons.lock_outline_rounded, color: iconColor, size: 21.w),
    );
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
