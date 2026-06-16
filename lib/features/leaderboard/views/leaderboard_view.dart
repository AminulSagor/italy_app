import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  final bool showPageAppBar;

  const LeaderboardView({super.key, this.showPageAppBar = false});

  @override
  LeaderboardController get controller {
    if (Get.isRegistered<LeaderboardController>()) {
      return Get.find<LeaderboardController>();
    }

    return Get.put<LeaderboardController>(LeaderboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        top: showPageAppBar,
        bottom: false,
        child: Stack(
          children: <Widget>[
            Obx(
              () => CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      kHomeHorizontalPadding.w,
                      showPageAppBar ? 22.h : 20.h,
                      kHomeHorizontalPadding.w,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _LeaderboardHeader(
                            showPageAppBar: showPageAppBar,
                            onHelpTap: controller.onHelpTap,
                          ),
                          SizedBox(height: 24.h),
                          _LeaderboardTabBar(
                            selectedIndex: controller.selectedTabIndex.value,
                            onChanged: controller.onTabChanged,
                          ),
                          SizedBox(height: 48.h),
                          _PodiumSection(
                            users: controller.podiumUsers,
                            isGlobal: controller.isGlobalSelected,
                          ),
                          if (controller.isMyLeagueSelected) ...<Widget>[
                            SizedBox(height: 30.h),
                            const _MilestoneCard(),
                          ],
                          SizedBox(height: 32.h),
                          _SearchField(
                            controller: controller.searchController,
                            onChanged: controller.onSearchChanged,
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      kHomeHorizontalPadding.w,
                      0,
                      kHomeHorizontalPadding.w,
                      245.h,
                    ),
                    sliver: controller.filteredUsers.isEmpty
                        ? const SliverToBoxAdapter(child: _EmptyLeaderboard())
                        : _LeaderboardList(
                            users: controller.filteredUsers,
                            onMessageTap: controller.onMessageTap,
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: showPageAppBar ? 28.h : 90.h,
              child: _MyRankFloatingCard(onInfoTap: controller.onRankInfoTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final bool showPageAppBar;
  final VoidCallback onHelpTap;

  const _LeaderboardHeader({
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
                'Leaderboard',
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
            'Leaderboard',
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

class _LeaderboardTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _LeaderboardTabBar({
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
              title: 'My League',
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            SizedBox(width: 8.w),
            _TabItem(
              title: 'Global',
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

class _PodiumSection extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool isGlobal;

  const _PodiumSection({required this.users, required this.isGlobal});

  Map<String, dynamic> _userByRank(int rank) {
    return users.firstWhere((Map<String, dynamic> user) {
      return user['rank'] == rank;
    });
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

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 172.h,
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
            'Milestone: Silver League',
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Earn 160 more XP to reach Gold!',
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
                // iconColor: Color(0xFFB34E00),
                // backgroundColor: Color(0xFFF0F0F0),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: LinearProgressIndicator(
                    value: 0.82,
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
                '4299',
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
                '5000',
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

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
          hintText: 'Search users...',
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

class _LeaderboardList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final ValueChanged<Map<String, dynamic>> onMessageTap;

  const _LeaderboardList({required this.users, required this.onMessageTap});

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
            _SmallAvatar(isCurrentUser: isCurrentUser, rank: rank),
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

  const _SmallAvatar({required this.isCurrentUser, required this.rank});

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
      child: Icon(
        isCurrentUser ? Icons.person_rounded : Icons.person,
        size: 30.r,
        color: rank > 16 ? AppColors.white : AppColors.legacyColorFFDFDFDF,
      ),
    );
  }
}

class _MyRankFloatingCard extends StatelessWidget {
  final VoidCallback onInfoTap;

  const _MyRankFloatingCard({required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.20),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOUR RANK',
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.limeTextColor.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '#14 | Arif (You)',
                  style: TextStyle(
                    fontSize: AppFont.font17.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF83FF45),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '1,240 XP',
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF83FF45),
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D9416),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'PROMOTION ZONE',
                  style: TextStyle(
                    fontSize: AppFont.font9.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.limeTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          GestureDetector(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline_rounded,
              size: 24.r,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

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
