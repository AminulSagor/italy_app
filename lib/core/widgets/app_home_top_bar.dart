import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../themes/app_colors.dart';
import '../themes/app_constants.dart';
import '../themes/app_font.dart';
import 'package:get/get.dart';

class AppHomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHomeTopBar({
    super.key,
    required this.greeting,
    required this.userName,
    required this.streakLabel,
    required this.showNotificationDot,
    required this.messageCount,
    this.avatarUrl,
    this.onNotificationTap,
    this.onMessageTap,
    this.onProfileTap,
  });

  final String greeting;
  final String userName;
  final String streakLabel;
  final String? avatarUrl;
  final bool showNotificationDot;
  final int messageCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.homeBackground,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: onProfileTap,
              child: _AvatarBadge(
                streakLabel: streakLabel,
                avatarUrl: avatarUrl,
              ),
            ),
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
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.homeSecondaryText,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Hi, '+ userName.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            _TopActionIcon(
              icon: Icons.notifications_none_rounded,
              showDot: showNotificationDot,
              badgeCount: 0,
              showCount: false,
              onTap: onNotificationTap,
              // onTap: () => Get.snackbar("In Progress", "Feature comming soon"),
            ),
            SizedBox(width: 16.w),
            _TopActionIcon(
              icon: Icons.chat_bubble_outline_rounded,
              showDot: messageCount > 0,
              badgeCount: messageCount,
              showCount: true,
              onTap: onMessageTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.streakLabel, this.avatarUrl});

  final String streakLabel;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String normalizedAvatarUrl = avatarUrl?.trim() ?? '';
    final Uri? avatarUri = Uri.tryParse(normalizedAvatarUrl);
    final bool canLoadAvatar =
        avatarUri != null &&
        (avatarUri.scheme == 'https' || avatarUri.scheme == 'http');

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
            child: ClipOval(
              child: ColoredBox(
                color: AppColors.white,
                child: !canLoadAvatar
                    ? const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryGreen,
                      )
                    : Image.network(
                        normalizedAvatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryGreen,
                        ),
                      ),
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
              child: Text(
                streakLabel,
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({
    required this.icon,
    required this.showDot,
    required this.badgeCount,
    required this.showCount,
    this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final int badgeCount;
  final bool showCount;
  final VoidCallback? onTap;

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
            Icon(icon, size: kHomeTopIconSize.w, color: AppColors.primaryGreen),
            if (showDot && (!showCount || badgeCount <= 1))
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
            if (showCount && badgeCount > 1)
              Positioned(
                right: 1.w,
                top: 3.h,
                child: Container(
                  height: 18.h,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.homeNotificationRed,
                    borderRadius: BorderRadius.circular(kHomePillRadius.r),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(
                      fontSize: AppFont.font9.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
