import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';

class AppHomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(60.h);
  final String greeting;
  final String userName;
  final String streakLabel;
  final int notificationCount;
  final int messageCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const AppHomeTopBar({
    super.key,
    required this.greeting,
    required this.userName,
    required this.streakLabel,
    required this.notificationCount,
    required this.messageCount,
    this.onNotificationTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppTheme.homeBackground, // padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),

          child: Row(
            children: <Widget>[
              _AvatarBadge(streakLabel: streakLabel),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.homeWelcomeLabelStyle,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.homeWelcomeNameStyle,
                    ),
                  ],
                ),
              ),
              _TopActionIcon(
                icon: Icons.notifications_none_rounded,
                badgeCount: notificationCount,
                onTap: onNotificationTap,
              ),
              SizedBox(width: 16.w),
              _TopActionIcon(
                icon: Icons.chat_bubble_outline_rounded,
                badgeCount: messageCount,
                onTap: onMessageTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String streakLabel;

  const _AvatarBadge({required this.streakLabel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (AppTheme.homeAvatarSize + 10).w,
      height: (AppTheme.homeAvatarSize + 8).w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: AppTheme.homeAvatarSize.w,
            height: AppTheme.homeAvatarSize.w,
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: AppTheme.homeLime,
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: AppTheme.homeTopIconSize.w,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: AppTheme.homeTinyBadgeSize.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.homeLime,
                borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
              ),
              child: Text(streakLabel, style: AppTheme.homeActionChipStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  const _TopActionIcon({
    required this.icon,
    required this.badgeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
      onTap: onTap,
      child: SizedBox(
        width: AppTheme.homeIconCircleSize.w,
        height: AppTheme.homeIconCircleSize.w,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            Icon(
              icon,
              size: AppTheme.homeTopIconSize.w,
              color: AppTheme.primaryGreen,
            ),
            if (badgeCount > 0)
              Positioned(
                right: 7.w,
                top: 8.h,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: AppTheme.homeNotificationRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.white, width: 1.6.w),
                  ),
                ),
              ),
            if (badgeCount > 1)
              Positioned(
                right: 1.w,
                top: 3.h,
                child: Container(
                  height: 18.h,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.homeNotificationRed,
                    borderRadius: BorderRadius.circular(
                      AppTheme.homePillRadius.r,
                    ),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: AppTheme.homeWebinarBadgeStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
