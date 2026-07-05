import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/leaderboard_controller.dart';
import '../models/leaderboard_models.dart';

class LeagueSystemPromotionView extends GetView<LeaderboardController> {
  const LeagueSystemPromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    final double maxDialogHeight = MediaQuery.sizeOf(context).height * 0.86;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 30.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(46.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 48.r,
                  offset: Offset(0, 30.h),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'the_league_system'.tr,
                          style: TextStyle(
                            fontSize: 29.sp,
                            height: 1.18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: const Color(0xFF163F2F),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back<void>(),
                        child: Icon(
                          Icons.close_rounded,
                          size: 28.r,
                          color: const Color(0xFF9AA1AA),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'climb_the_tiers_and_become_an_italian_master'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      Get.back<void>();
                      controller.openPopupInsiderPage();
                    },
                    child: _LeagueTrackCard(
                      leagues: controller.leagues.toList(),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _ZoneCard(
                          bgColor: Color(0xFFE4F8D8),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: Color(0xFF35C51E),
                          title: 'gen_promotion'.tr,
                          subtitle: 'gen_earn_more_nxp_to_nmove_up'.tr,
                          titleColor: Color(0xFF244D3A),
                          subtitleColor: Color(0xFF477159),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: _ZoneCard(
                          bgColor: Color(0xFFFCE4E8),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: Color(0xFFFF4A47),
                          title: 'gen_demotion'.tr,
                          subtitle: 'gen_finish_in_the_nbottom_5_to_ndr'.tr,
                          titleColor: Color(0xFF9A2226),
                          subtitleColor: Color(0xFFB75E67),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  const _EarnXpCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeagueTrackCard extends StatelessWidget {
  final List<LeagueModel>? leagues;

  const _LeagueTrackCard({this.leagues});

  IconData _iconForKey(String key) {
    switch (key) {
      case 'bronze':
        return Icons.military_tech_rounded;
      case 'silver':
        return Icons.workspace_premium_rounded;
      case 'gold':
        return Icons.star_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  Color _colorForKey(String key) {
    switch (key) {
      case 'bronze':
        return const Color(0xFF9A4E05);
      case 'silver':
        return const Color(0xFF1765A5);
      case 'gold':
        return const Color(0xFFFFA400);
      case 'diamond':
        return const Color(0xFF00A5B8);
      default:
        return const Color(0xFF9AA1AA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LeagueModel> list = leagues ?? <LeagueModel>[];
    final LeaderboardController ctrl = Get.find<LeaderboardController>();

    // Compute progress from milestone if present, else fallback
    final Map<String, dynamic>? ms = ctrl.milestoneData.value;
    double progress = 0.4;
    if (ms != null) {
      if (ms['progressPercentage'] is num) {
        progress = (ms['progressPercentage'] as num).toDouble() / 100.0;
      } else if (ms['targetXp'] is int &&
          ms['currentXp'] is int &&
          ms['targetXp'] > 0) {
        progress = (ms['currentXp'] as int) / (ms['targetXp'] as int);
      }
    }

    final String currentLeagueKey = ctrl.currentUser.value?.league.key ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE4E8EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2BCB1A),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: List<Widget>.generate(4, (int idx) {
              final LeagueModel? lm = idx < list.length ? list[idx] : null;
              final String title =
                  lm?.name.toUpperCase() ??
                  ['BRONZE', 'SILVER', 'GOLD', 'DIAMOND'][idx];
              final String key =
                  lm?.key ?? ['bronze', 'silver', 'gold', 'diamond'][idx];
              final bool isActive = key == currentLeagueKey;

              Color? bgColor;
              Color? textColor;
              Color? borderColor;

              if (key == 'silver') bgColor = const Color(0xFFA9D1FF);
              if (key == 'gold') borderColor = const Color(0xFFFFC100);
              if (key == 'diamond') borderColor = const Color(0xFF73DCE5);

              return Expanded(
                child: _LeagueTrackItem(
                  title: title,
                  icon: _iconForKey(key),
                  color: key == 'silver' ? AppColors.white : _colorForKey(key),
                  bgColor: bgColor,
                  textColor: key == 'silver' ? const Color(0xFF1765A5) : null,
                  borderColor: borderColor,
                  isActive: isActive,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LeagueTrackItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final Color? borderColor;
  final Color? textColor;
  final bool isActive;

  const _LeagueTrackItem({
    required this.title,
    required this.icon,
    required this.color,
    this.bgColor,
    this.borderColor,
    this.textColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: isActive ? 52.r : 42.r,
          height: isActive ? 52.r : 42.r,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? bgColor ?? color,
              width: 2.w,
            ),
          ),
          child: Icon(icon, size: isActive ? 27.r : 22.r, color: color),
        ),
        SizedBox(height: 8.h),
        FittedBox(
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font9.sp,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w900,
              color: textColor ?? const Color(0xFF9AA1AA),
            ),
          ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const _ZoneCard({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 178.h),
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 14.w, 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 42.r,
            height: 42.r,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25.r, color: iconColor),
          ),
          SizedBox(height: 34.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font17.sp,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnXpCard extends StatelessWidget {
  const _EarnXpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 26.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46.r,
                height: 46.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7118),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  size: 29.r,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  'how_to_earn_xp'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF163F2F),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          _EarnXpRow(text: 'complete_video_nlessons'.tr),
          SizedBox(height: 16.h),
          _EarnXpRow(text: 'pass_chapter_quizzes'.tr),
          SizedBox(height: 16.h),
          _EarnXpRow(text: 'maintain_answer_nstreaks'.tr),
        ],
      ),
    );
  }
}

class _EarnXpRow extends StatelessWidget {
  final String text;

  const _EarnXpRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 20.r,
          height: 20.r,
          decoration: const BoxDecoration(
            color: Color(0xFF37C915),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 15.r, color: AppColors.white),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              height: 1.25,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163F2F),
            ),
          ),
        ),
      ],
    );
  }
}
