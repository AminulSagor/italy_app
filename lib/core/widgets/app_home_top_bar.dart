import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../themes/app_colors.dart';
import '../themes/app_font.dart';
import '../themes/app_constants.dart';

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
        color: AppColors.homeBackground, // padding: const EdgeInsets.all(8.0),
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
                      style: TextStyle(fontSize: AppFont.font11.sp, fontWeight: FontWeight.w600, color: AppColors.homeSecondaryText),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: AppFont.font18.sp, fontWeight: FontWeight.w800, height: 1, color: AppColors.primaryGreen),
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
      width: (kHomeAvatarSize + 10).w,
      height: (kHomeAvatarSize + 8).w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: kHomeAvatarSize.w,
            height: kHomeAvatarSize.w,
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: kHomeTopIconSize.w,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: kHomeTinyBadgeSize.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.homeLime,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Text(streakLabel, style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
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
      borderRadius: BorderRadius.circular(kHomePillRadius.r),
      onTap: onTap,
      child: SizedBox(
        width: kHomeIconCircleSize.w,
        height: kHomeIconCircleSize.w,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            Icon(
              icon,
              size: kHomeTopIconSize.w,
              color: AppColors.primaryGreen,
            ),
            if (badgeCount > 0)
              Positioned(
                right: 7.w,
                top: 8.h,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: AppColors.homeNotificationRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.6.w),
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
                    color: AppColors.homeNotificationRed,
                    borderRadius: BorderRadius.circular(
                      kHomePillRadius.r,
                    ),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(fontSize: AppFont.font9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.homePaleGreen),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
