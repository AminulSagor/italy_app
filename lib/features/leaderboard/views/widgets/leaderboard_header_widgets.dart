import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class LeaderboardHeader extends StatelessWidget {
  final bool showPageAppBar;
  final VoidCallback onHelpTap;

  const LeaderboardHeader({
    required this.showPageAppBar,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    if (showPageAppBar) {
      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back<void>,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 28.r,
              color: AppColors.primaryGreen,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'leaderboard'.tr,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          _HelpButton(onTap: onHelpTap),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'leaderboard'.tr,
            style: TextStyle(
              fontSize: AppFont.font28.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
              letterSpacing: -0.8,
            ),
          ),
        ),
        _HelpButton(onTap: onHelpTap),
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HelpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.help_outline_rounded,
        size: 24.r,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class LeaderboardTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LeaderboardTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 326.w,
        height: 58.h,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: AppColors.legacyColorFFDFDFDF,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: <Widget>[
            _TabItem(
              title: 'gen_my_league'.tr.tr,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            SizedBox(width: 8.w),
            _TabItem(
              title: 'gen_global'.tr.tr,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(40.r),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.10),
                      blurRadius: 10.r,
                      offset: Offset(0, 5.h),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? AppColors.homePrimaryText
                  : AppColors.homeSecondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class LeaderboardPodiumSection extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool isGlobal;

  const LeaderboardPodiumSection({required this.users, required this.isGlobal});

  Map<String, dynamic> _userByRank(int rank) {
    return users.firstWhere(
      (Map<String, dynamic> user) => user['rank'] == rank,
      orElse: () => <String, dynamic>{
        'rank': rank,
        'name': '—',
        'xp': '0',
        'league': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> first = _userByRank(1);
    final Map<String, dynamic> second = _userByRank(2);
    final Map<String, dynamic> third = _userByRank(3);

    return SizedBox(
      height: 260.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: _PodiumUserCard(
              user: second,
              isGlobal: isGlobal,
              avatarSize: 64,
              cardHeight: 112,
              accentColor: isGlobal
                  ? const Color(0xFFE92886)
                  : AppColors.homeSecondaryText,
              gradientColor: isGlobal
                  ? const Color(0xFFFFD0E5)
                  : const Color(0xFFEDEEEF),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _PodiumUserCard(
              user: first,
              isGlobal: isGlobal,
              avatarSize: 82,
              cardHeight: 140,
              accentColor: AppColors.primaryGreen,
              gradientColor: const Color(0xFF87FF49),
              isCenter: true,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _PodiumUserCard(
              user: third,
              isGlobal: isGlobal,
              avatarSize: 64,
              cardHeight: 112,
              accentColor: const Color(0xFFD97A00),
              gradientColor: const Color(0xFFFFDFAE),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isGlobal;
  final double avatarSize;
  final double cardHeight;
  final Color accentColor;
  final Color gradientColor;
  final bool isCenter;

  const _PodiumUserCard({
    required this.user,
    required this.isGlobal,
    required this.avatarSize,
    required this.cardHeight,
    required this.accentColor,
    required this.gradientColor,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final int rank = user['rank'] as int;
    final String name = user['name'] as String;
    final String xp = user['xp'] as String;
    final String league = user['league'] as String;

    final bool showChip = isGlobal || isCenter;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _PodiumAvatar(
          rank: rank,
          size: avatarSize,
          accentColor: accentColor,
          isCenter: isCenter,
        ),
        SizedBox(height: 6.h),
        if (showChip)
          Container(
            height: 28.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCenter
                  ? const Color(0xFF77F53E)
                  : rank == 2
                  ? const Color(0xFFE92886)
                  : const Color(0xFFE98B00),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              isCenter && !isGlobal ? 'SILVER' : league,
              style: TextStyle(
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w900,
                color: isCenter ? AppColors.primaryGreen : AppColors.white,
              ),
            ),
          )
        else
          SizedBox(height: 28.h),
        Container(
          height: cardHeight.h,
          width: double.infinity,
          padding: EdgeInsets.only(top: 18.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                gradientColor,
                gradientColor.withValues(alpha: 0.15),
                AppColors.white.withValues(alpha: 0),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          child: Column(
            children: <Widget>[
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$rank${_rankSuffix(rank)}',
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homePrimaryText.withValues(alpha: 0.75),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    xp,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.bolt_rounded, size: 18.r, color: accentColor),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _rankSuffix(int rank) {
    if (rank == 1) return 'st';
    if (rank == 2) return 'nd';
    if (rank == 3) return 'rd';
    return 'th';
  }
}

class _PodiumAvatar extends StatelessWidget {
  final int rank;
  final double size;
  final Color accentColor;
  final bool isCenter;

  const _PodiumAvatar({
    required this.rank,
    required this.size,
    required this.accentColor,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCenter ? AppColors.white : AppColors.legacyColorFFDFDFDF,
        border: Border.all(
          color: isCenter
              ? const Color(0xFF77F53E)
              : AppColors.legacyColorFFABABAB,
          width: isCenter ? 4.w : 3.w,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: isCenter
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 56.sp,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 9.h),
                  child: Text(
                    'st',
                    style: TextStyle(
                      fontSize: AppFont.font9.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                ),
              ],
            )
          : Icon(
              Icons.person_rounded,
              size: 34.r,
              color: AppColors.homeSecondaryText,
            ),
    );
  }
}

