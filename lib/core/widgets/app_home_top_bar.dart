import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../themes/app_colors.dart';
import '../themes/app_constants.dart';
import '../themes/app_font.dart';

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

  /// Used by both this widget and its parent PreferredSize.
  static const double toolbarHeight = 72;

  static double get preferredHeight => toolbarHeight.h;

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
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  Widget build(BuildContext context) {
    final String normalizedName = userName.trim();
    final String displayedName = normalizedName.isEmpty ? '—' : normalizedName;

    final int normalizedMessageCount = messageCount < 0 ? 0 : messageCount;

    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredHeight,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.homeBackground,
            border: Border(
              bottom: BorderSide(
                color: AppColors.primaryGreen.withAlpha(18),
                width: 1,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool useCompactSpacing = constraints.maxWidth < 360;

              return Row(
                children: <Widget>[
                  _ProfileButton(
                    streakLabel: streakLabel,
                    avatarUrl: avatarUrl,
                    onTap: onProfileTap,
                  ),
                  SizedBox(width: useCompactSpacing ? 8.w : 11.w),
                  Expanded(
                    child: _UserInformation(
                      greeting: greeting,
                      userName: displayedName,
                    ),
                  ),
                  SizedBox(width: useCompactSpacing ? 2.w : 6.w),
                  _TopActionIcon(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'notifications'.tr,
                    semanticsLabel: 'notifications'.tr,
                    showDot: showNotificationDot,
                    badgeCount: 0,
                    showCount: false,
                    onTap: onNotificationTap,
                  ),
                  SizedBox(width: useCompactSpacing ? 1.w : 4.w),
                  _TopActionIcon(
                    icon: Icons.chat_bubble_outline_rounded,
                    tooltip: 'messages'.tr,
                    semanticsLabel: 'messages'.tr,
                    showDot: normalizedMessageCount > 0,
                    badgeCount: normalizedMessageCount,
                    showCount: true,
                    onTap: onMessageTap,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UserInformation extends StatelessWidget {
  const _UserInformation({required this.greeting, required this.userName});

  final String greeting;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: userName,
      waitDuration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            greeting.trim(),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w600,
              height: 1.15,
              color: AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'home_greeting'.trParams(<String, String>{'name': userName}),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.25,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.streakLabel,
    required this.avatarUrl,
    required this.onTap,
  });

  final String streakLabel;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'profile'.tr,
      child: Semantics(
        button: true,
        label: 'profile'.tr,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: _AvatarBadge(
                streakLabel: streakLabel,
                avatarUrl: avatarUrl,
              ),
            ),
          ),
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
    final String normalizedStreakLabel = streakLabel.trim();

    final Uri? avatarUri = Uri.tryParse(normalizedAvatarUrl);

    final bool canLoadAvatar =
        avatarUri != null &&
        (avatarUri.scheme == 'https' || avatarUri.scheme == 'http');

    return SizedBox(
      width: (kHomeAvatarSize + 12).w,
      height: (kHomeAvatarSize + 10).w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: kHomeAvatarSize.w,
            height: kHomeAvatarSize.w,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.homeLime,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primaryGreen.withAlpha(24),
                  blurRadius: 8.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: ClipOval(
              child: ColoredBox(
                color: AppColors.white,
                child: canLoadAvatar
                    ? Image.network(
                        normalizedAvatarUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        frameBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              int? frame,
                              bool wasSynchronouslyLoaded,
                            ) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }

                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              );
                            },
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return const _AvatarFallback();
                            },
                      )
                    : const _AvatarFallback(),
              ),
            ),
          ),
          if (normalizedStreakLabel.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 29.w,
                  minHeight: kHomeTinyBadgeSize.h,
                ),
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.homeLime,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                  border: Border.all(
                    color: AppColors.homeBackground,
                    width: 2.w,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  normalizedStreakLabel,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
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

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person_rounded,
      size: 27.w,
      color: AppColors.primaryGreen,
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({
    required this.icon,
    required this.tooltip,
    required this.semanticsLabel,
    required this.showDot,
    required this.badgeCount,
    required this.showCount,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String semanticsLabel;
  final bool showDot;
  final int badgeCount;
  final bool showCount;
  final VoidCallback? onTap;

  String get _formattedBadgeCount {
    if (badgeCount > 99) {
      return '99+';
    }

    return badgeCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowCount = showCount && badgeCount > 0;

    final bool shouldShowDot = !shouldShowCount && showDot;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        value: shouldShowCount ? _formattedBadgeCount : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            onTap: onTap,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 38.w,
                    height: 38.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: kHomeTopIconSize.w,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  if (shouldShowDot)
                    Positioned(
                      right: 7.w,
                      top: 7.h,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.homeNotificationRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.homeBackground,
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  if (shouldShowCount)
                    Positioned(
                      right: 0,
                      top: 1.h,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 19.w,
                          minHeight: 18.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.homeNotificationRed,
                          borderRadius: BorderRadius.circular(
                            kHomePillRadius.r,
                          ),
                          border: Border.all(
                            color: AppColors.homeBackground,
                            width: 1.5.w,
                          ),
                        ),
                        child: Text(
                          _formattedBadgeCount,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: AppFont.font9.sp,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
