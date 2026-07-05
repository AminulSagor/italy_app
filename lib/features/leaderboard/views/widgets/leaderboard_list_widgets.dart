import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class LeaderboardMilestoneCard extends StatelessWidget {
  final Map<String, dynamic>? milestone;

  const LeaderboardMilestoneCard({this.milestone});

  String _formatWithCommas(int n) {
    final String s = n.toString();
    final StringBuffer sb = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      sb.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        sb.write(',');
        count = 0;
      }
    }
    return sb.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? ms = milestone;
    final String nextLeagueName = ms?['nextLeague'] is Map
        ? (ms!['nextLeague']['name']?.toString() ?? '')
        : '';
    final String message = ms?['message']?.toString() ?? '';

    final int currentXp = ms?['currentXp'] is int
        ? ms!['currentXp'] as int
        : int.tryParse(ms?['currentXp']?.toString() ?? '0') ?? 0;
    final int targetXp = ms?['targetXp'] is int
        ? ms!['targetXp'] as int
        : int.tryParse(ms?['targetXp']?.toString() ?? '0') ?? 0;

    double progress = 0.0;
    if (ms?['progressPercentage'] is num) {
      progress = (ms!['progressPercentage'] as num).toDouble() / 100.0;
    } else if (targetXp > 0) {
      progress = currentXp / targetXp;
    } else {
      progress = 0.0;
    }

    return Container(
      height: 190.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            nextLeagueName.isNotEmpty
                ? '${'leaderboard_milestone_title'.tr}: $nextLeagueName'
                : 'leaderboard_milestone_title'.tr,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message.isNotEmpty ? message : 'leaderboard_milestone_message'.tr,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.homeSecondaryText,
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(29, 0, 0, 0),
                ),
                child: Icon(Icons.emoji_events_outlined),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 16.h,
                    backgroundColor: AppColors.legacyColorFFDFDFDF,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF52CE12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              const _MilestoneIcon(
                icon: Icons.star_rounded,
                iconColor: AppColors.white,
                backgroundColor: Color.fromARGB(54, 255, 162, 0),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: <Widget>[
              Text(
                _formatWithCommas(currentXp),
                style: TextStyle(
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homeSecondaryText,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.bolt_rounded,
                size: 13.r,
                color: AppColors.primaryGreen,
              ),
              const Spacer(),
              Text(
                _formatWithCommas(targetXp),
                style: TextStyle(
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homeSecondaryText,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.bolt_rounded,
                size: 13.r,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _MilestoneIcon({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.r,
      height: 42.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Container(
        width: 37.r,
        height: 27.r,
        decoration: BoxDecoration(
          color: AppColors.homeOrange,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22.r, color: iconColor),
      ),
    );
  }
}

class LeaderboardSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const LeaderboardSearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: AppColors.homeSecondaryText.withValues(alpha: 0.45),
          width: 1.w,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.primaryGreen,
        style: TextStyle(
          fontSize: AppFont.font15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.homePrimaryText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'gen_search_users'.tr.tr,
          hintStyle: TextStyle(
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.homeSecondaryText.withValues(alpha: 0.65),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 18.w, right: 8.w),
            child: Icon(
              Icons.search_rounded,
              size: 24.r,
              color: AppColors.homeSecondaryText,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 52.w),
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
        ),
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final ValueChanged<Map<String, dynamic>> onMessageTap;

  const LeaderboardList({required this.users, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => SizedBox(height: 14.h),
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> user = users[index];

        return _LeaderboardUserTile(
          user: user,
          onMessageTap: () => onMessageTap(user),
        );
      },
    );
  }
}

class _LeaderboardUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onMessageTap;

  const _LeaderboardUserTile({required this.user, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    final int rank = user['rank'] as int;
    final String name = user['name'] as String;
    final String xp = user['xp'] as String;
    final String league = user['league'] as String;
    final bool isCurrentUser = (user['isCurrentUser'] as bool?) ?? false;
    final String avatarUrl = user['avatarUrl']?.toString().trim() ?? '';

    return GestureDetector(
      onTap: isCurrentUser ? null : onMessageTap,
      child: Container(
        height: 82.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFFF1FAEA) : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCurrentUser
                ? AppColors.primaryGreen.withValues(alpha: 0.22)
                : AppColors.transparent,
            width: 1.2.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 38.w,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: AppFont.font17.sp,
                  fontWeight: FontWeight.w900,
                  color: isCurrentUser
                      ? AppColors.primaryGreen
                      : AppColors.homeSecondaryText,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            _SmallAvatar(
              isCurrentUser: isCurrentUser,
              rank: rank,
              avatarUrl: avatarUrl,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font15.sp,
                      height: 1.14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 12.r,
                        color: isCurrentUser
                            ? AppColors.primaryGreen
                            : AppColors.homeSecondaryText,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        league,
                        style: TextStyle(
                          fontSize: AppFont.font10.sp,
                          fontWeight: FontWeight.w900,
                          color: isCurrentUser
                              ? AppColors.primaryGreen
                              : AppColors.homeSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  xp,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.bolt_rounded,
                  size: 18.r,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
            if (!isCurrentUser) ...<Widget>[
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onMessageTap,
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.legacyColorFFF1F2F2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18.r,
                    color: AppColors.homeSecondaryText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final bool isCurrentUser;
  final int rank;
  final String avatarUrl;

  const _SmallAvatar({
    required this.isCurrentUser,
    required this.rank,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.r,
      height: 52.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rank > 16 ? AppColors.legacyColorFFDFDFDF : AppColors.black,
        border: Border.all(color: AppColors.white, width: 2.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? _SmallAvatarFallback(
                isCurrentUser: isCurrentUser,
                rank: rank,
              )
            : Image.network(
                avatarUrl,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _SmallAvatarFallback(
                  isCurrentUser: isCurrentUser,
                  rank: rank,
                ),
              ),
      ),
    );
  }
}

class _SmallAvatarFallback extends StatelessWidget {
  const _SmallAvatarFallback({
    required this.isCurrentUser,
    required this.rank,
  });

  final bool isCurrentUser;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: rank > 16 ? AppColors.legacyColorFFDFDFDF : AppColors.black,
      child: Center(
        child: Icon(
          isCurrentUser ? Icons.person_rounded : Icons.person,
          size: 30.r,
          color: rank > 16
              ? AppColors.white
              : AppColors.legacyColorFFDFDFDF,
        ),
      ),
    );
  }
}

class EmptyLeaderboard extends StatelessWidget {
  const EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      alignment: Alignment.center,
      child: Text(
        'No users found',
        style: TextStyle(
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.homeSecondaryText,
        ),
      ),
    );
  }
}
