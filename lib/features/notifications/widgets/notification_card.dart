import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/notification_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItemModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final _NotificationCardStyle cardStyle = _styleForTone(notification.tone);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardStyle.backgroundColor,
        borderRadius: BorderRadius.circular(kNotificationCardRadius.r),
        border: Border.all(color: cardStyle.borderColor, width: 1.2.w),
        boxShadow: cardStyle.hasShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.homePaleGreen.withValues(alpha: 0.45),
                  blurRadius: 28.r,
                  offset: Offset(0, 12.h),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _NotificationIcon(notification: notification),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: AppColors.homePrimaryText,
                        ).copyWith(color: cardStyle.titleColor),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    _TimeLabel(notification: notification),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  notification.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.42,
                    color: AppColors.bodyText,
                  ).copyWith(color: cardStyle.bodyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotificationCardStyle _styleForTone(NotificationTone tone) {
    switch (tone) {
      case NotificationTone.lesson:
        return const _NotificationCardStyle(
          backgroundColor: AppColors.white,
          borderColor: AppColors.notificationLearningBorder,
          titleColor: AppColors.homePrimaryText,
          bodyColor: AppColors.bodyText,
          hasShadow: true,
        );
      case NotificationTone.webinar:
        return const _NotificationCardStyle(
          backgroundColor: AppColors.notificationWarningBg,
          borderColor: AppColors.notificationWarningBorder,
          titleColor: AppColors.homePrimaryText,
          bodyColor: AppColors.bodyText,
        );
      case NotificationTone.message:
        return const _NotificationCardStyle(
          backgroundColor: AppColors.white,
          borderColor: AppColors.white,
          titleColor: AppColors.homePrimaryText,
          bodyColor: AppColors.bodyText,
        );
      case NotificationTone.streak:
        return const _NotificationCardStyle(
          backgroundColor: AppColors.notificationStreakBg,
          borderColor: AppColors.notificationStreakBorder,
          titleColor: AppColors.notificationBrown,
          bodyColor: AppColors.notificationBrown,
        );
    }
  }
}

class _TimeLabel extends StatelessWidget {
  final NotificationItemModel notification;

  const _TimeLabel({required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.tone == NotificationTone.lesson) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.homePaleGreen,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
        ),
        child: Text(
          notification.timeLabel,
          style: TextStyle(
            fontSize: AppFont.font10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: 20.w, top: 2.w),
      child: Text(
        notification.timeLabel,
        textAlign: TextAlign.center,
        style:
            TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.bodyText,
            ).copyWith(
              color: notification.tone == NotificationTone.streak
                  ? AppColors.notificationBrown.withValues(alpha: 0.72)
                  : AppColors.bodyText,
            ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final NotificationItemModel notification;

  const _NotificationIcon({required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.tone == NotificationTone.message) {
      return _AvatarIcon(avatarUrl: notification.avatarUrl);
    }

    final _NotificationIconStyle iconStyle = _iconStyleForTone(
      notification.tone,
    );

    return Container(
      width: kNotificationIconSize.w,
      height: kNotificationIconSize.w,
      decoration: BoxDecoration(
        color: iconStyle.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconStyle.icon, color: iconStyle.iconColor, size: 26.w),
    );
  }

  _NotificationIconStyle _iconStyleForTone(NotificationTone tone) {
    switch (tone) {
      case NotificationTone.lesson:
        return const _NotificationIconStyle(
          icon: Icons.book_outlined,
          backgroundColor: AppColors.homeLime,
          iconColor: AppColors.primaryGreen,
        );
      case NotificationTone.webinar:
        return const _NotificationIconStyle(
          icon: Icons.videocam_outlined,
          backgroundColor: AppColors.notificationRed,
          iconColor: AppColors.white,
        );
      case NotificationTone.streak:
        return const _NotificationIconStyle(
          icon: Icons.local_fire_department_outlined,
          backgroundColor: AppColors.notificationOrange,
          iconColor: AppColors.notificationBrown,
        );
      case NotificationTone.message:
        return const _NotificationIconStyle(
          icon: Icons.person_rounded,
          backgroundColor: AppColors.white,
          iconColor: AppColors.primaryGreen,
        );
    }
  }
}

class _AvatarIcon extends StatelessWidget {
  final String avatarUrl;

  const _AvatarIcon({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kNotificationIconSize.w,
      height: kNotificationIconSize.w,
      padding: EdgeInsets.all(2.w),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? const Icon(Icons.person_rounded, color: AppColors.primaryGreen)
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
      ),
    );
  }
}

class _NotificationCardStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final bool hasShadow;

  const _NotificationCardStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    this.hasShadow = false,
  });
}

class _NotificationIconStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _NotificationIconStyle({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
