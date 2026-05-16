import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class LeaguePromotionScreen extends StatelessWidget {
  final String headerAssetPath;
  final String leagueName;
  final String xpRange;
  final Color accentColor;
  final Color lightAccentColor;
  final IconData leagueIcon;
  final bool hasBenefit;
  final String? boostTitle;
  final String? boostSubtitle;
  final String? boostFooter;
  final VoidCallback? onContinueTap;
  final VoidCallback? onShareTap;

  const LeaguePromotionScreen({
    super.key,
    required this.headerAssetPath,
    required this.leagueName,
    required this.xpRange,
    required this.accentColor,
    required this.lightAccentColor,
    required this.leagueIcon,
    this.hasBenefit = false,
    this.boostTitle,
    this.boostSubtitle,
    this.boostFooter,
    this.onContinueTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              lightAccentColor.withValues(alpha: 0.62),
              const Color(0xFFF8F8F8),
              const Color(0xFFF7F8F7),
              const Color(0xFFEAFCE3),
            ],
            stops: const <double>[0.0, 0.34, 0.62, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 132.h),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 28.h),
                    _TopBar(onShareTap: onShareTap),
                    SizedBox(height: 8.h),

                    /// Replace this asset with your designed header image.
                    /// Recommended: transparent PNG/WebP containing the league object + decorations.
                    SizedBox(
                      height: hasBenefit ? 280.h : 300.h,
                      width: double.infinity,
                      child: Image.asset(headerAssetPath, fit: BoxFit.contain),
                    ),

                    SizedBox(height: hasBenefit ? 12.h : 16.h),
                    _PromotionBadge(accentColor: accentColor),
                    SizedBox(height: 36.h),

                    Text(
                      "You've been promoted to",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF666B70),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$leagueName League!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -1.2,
                      ),
                    ),

                    SizedBox(height: 58.h),
                    _LeagueCard(
                      leagueName: leagueName,
                      xpRange: xpRange,
                      accentColor: accentColor,
                      lightAccentColor: lightAccentColor,
                      leagueIcon: leagueIcon,
                      hasBenefit: hasBenefit,
                      boostTitle: boostTitle,
                      boostSubtitle: boostSubtitle,
                      boostFooter: boostFooter,
                    ),

                    SizedBox(height: 46.h),
                    _TopLearnerCard(accentColor: accentColor),
                    SizedBox(height: hasBenefit ? 170.h : 420.h),
                  ],
                ),
              ),

              Positioned(
                left: 28.w,
                right: 28.w,
                bottom: 28.h,
                child: _ContinueButton(
                  onTap: onContinueTap ?? () => Get.back<void>(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback? onShareTap;

  const _TopBar({required this.onShareTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 26.r,
                color: const Color(0xFF5B6064),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF25292D),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onShareTap,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F2).withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_outlined,
                size: 22.r,
                color: const Color(0xFF555A5F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionBadge extends StatelessWidget {
  final Color accentColor;

  const _PromotionBadge({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F2).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 16.r,
            height: 16.r,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, size: 11.r, color: AppColors.white),
          ),
          SizedBox(width: 8.w),
          Text(
            'LEAGUE PROMOTION',
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: const Color(0xFF666A70),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  final String leagueName;
  final String xpRange;
  final Color accentColor;
  final Color lightAccentColor;
  final IconData leagueIcon;
  final bool hasBenefit;
  final String? boostTitle;
  final String? boostSubtitle;
  final String? boostFooter;

  const _LeagueCard({
    required this.leagueName,
    required this.xpRange,
    required this.accentColor,
    required this.lightAccentColor,
    required this.leagueIcon,
    required this.hasBenefit,
    required this.boostTitle,
    required this.boostSubtitle,
    required this.boostFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(26.w, 26.h, 26.w, hasBenefit ? 26.h : 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(38.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 26.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: lightAccentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(leagueIcon, size: 35.r, color: accentColor),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$leagueName\nLeague',
                      style: TextStyle(
                        fontSize: 25.sp,
                        height: 1.18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF262A2D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      xpRange,
                      style: TextStyle(
                        fontSize: AppFont.font15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6E7378),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF7CFB45),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'NEW LEAGUE',
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          if (hasBenefit) ...<Widget>[
            SizedBox(height: 30.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: const Color(0xFFE1E1E1),
            ),
            SizedBox(height: 30.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'YOUR NEW BENEFITS',
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: const Color(0xFF666A70),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDEAE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on_rounded,
                      size: 27.r,
                      color: const Color(0xFF9A5A08),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    boostTitle ?? '',
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF25292D),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    boostSubtitle ?? '',
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7E8388),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Lasts for ${boostFooter ?? ''}. Practice more!',
                    style: TextStyle(
                      fontSize: AppFont.font10.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9A9EA3),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    height: 22.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4C4),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.r,
                          color: const Color(0xFF9A5A08),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          boostFooter == '3 days' ? '73:59:59' : '47:59:59',
                          style: TextStyle(
                            fontSize: AppFont.font10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9A5A08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopLearnerCard extends StatelessWidget {
  final Color accentColor;

  const _TopLearnerCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 23.r,
              color: accentColor,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "You're in the top 20% of learners!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF25292D),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Keep going to reach Diamond League',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF777C82),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 30.r,
            color: const Color(0xFF565B60),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color(0xFF174B00), offset: Offset(0, 7.h)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.play_arrow_rounded, size: 22.r, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
