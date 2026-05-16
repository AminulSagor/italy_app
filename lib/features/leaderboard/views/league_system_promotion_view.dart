import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/leaderboard_controller.dart';

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
                          'The League\nSystem',
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
                    'Climb the tiers and become\nan Italian Master.',
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
                    child: const _LeagueTrackCard(),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: _ZoneCard(
                          bgColor: Color(0xFFE4F8D8),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: Color(0xFF35C51E),
                          title: 'Promotion',
                          subtitle: 'Earn More\nXP to\nmove up.',
                          titleColor: Color(0xFF244D3A),
                          subtitleColor: Color(0xFF477159),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      const Expanded(
                        child: _ZoneCard(
                          bgColor: Color(0xFFFCE4E8),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: Color(0xFFFF4A47),
                          title: 'Demotion',
                          subtitle: 'Finish in the\nBottom 5 to\ndrop back.',
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
  const _LeagueTrackCard();

  @override
  Widget build(BuildContext context) {
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
              value: 0.40,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE4E8EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2BCB1A),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: const <Widget>[
              Expanded(
                child: _LeagueTrackItem(
                  title: 'BRONZE',
                  icon: Icons.military_tech_rounded,
                  color: Color(0xFF9A4E05),
                  borderColor: Color(0xFF9A4E05),
                ),
              ),
              Expanded(
                child: _LeagueTrackItem(
                  title: 'SILVER',
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.white,
                  bgColor: Color(0xFFA9D1FF),
                  textColor: Color(0xFF1765A5),
                  isActive: true,
                ),
              ),
              Expanded(
                child: _LeagueTrackItem(
                  title: 'GOLD',
                  icon: Icons.star_rounded,
                  color: Color(0xFFFFA400),
                  borderColor: Color(0xFFFFC100),
                ),
              ),
              Expanded(
                child: _LeagueTrackItem(
                  title: 'DIAMOND',
                  icon: Icons.diamond_rounded,
                  color: Color(0xFF00A5B8),
                  borderColor: Color(0xFF73DCE5),
                ),
              ),
            ],
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
                  'HOW TO EARN XP',
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
          const _EarnXpRow(text: 'Complete Video\nLessons'),
          SizedBox(height: 16.h),
          const _EarnXpRow(text: 'Pass Chapter Quizzes'),
          SizedBox(height: 16.h),
          const _EarnXpRow(text: 'Maintain Answer\nStreaks'),
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
