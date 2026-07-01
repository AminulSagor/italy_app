import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/widgets.dart';
import '../services/leaderboard_service.dart';

class ScoreSystemInfoView extends StatelessWidget {
  const ScoreSystemInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardService svc = Get.find<LeaderboardService>();
    // fetch scoring guide once (fire-and-forget)
    svc.fetchScoringGuide().then((Map<String, dynamic>? data) {
      if (data == null) return;
      // Optionally cache or pass via Get.arguments in future; for now
      // we could set up a simple reactive binding later. This keeps
      // the current UI unchanged but prepares the service call.
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: SimpleAppbar(
        title: 'gen_scoring_guide'.tr.tr,
        onBackTap: () => Get.back<void>(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 28.h),
        child: Column(
          children: <Widget>[
            // const _ScoringTopBar(),
            SizedBox(
              height: 395.h,
              width: double.infinity,

              child: Image.asset(
                'assets/heroes/Hero Section.png',
                fit: BoxFit.contain,
              ),
            ),
            // SizedBox(height: 18.h),
            // const _ScoreHeroGraphic(),
            // SizedBox(height: 22.h),
            // Text(
            //   'How to climb the\nLeaderboard!',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 31.sp,
            //     height: 1.16,
            //     fontWeight: FontWeight.w900,
            //     letterSpacing: -1.2,
            //     color: AppColors.homePrimaryText,
            //   ),
            // ),
            // SizedBox(height: 12.h),
            // Text(
            //   'Learn the secrets to earning more\npoints.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: AppFont.font19.sp,
            //     height: 1.45,
            //     fontWeight: FontWeight.w500,
            //     color: AppColors.homeSecondaryText,
            //   ),
            // ),
            //SizedBox(height: 86.h),
            const _BasePointsCard(),
            SizedBox(height: 24.h),
            const _StreakBonusCard(),
            SizedBox(height: 40.h),
            const _MasteryCard(),
            SizedBox(height: 24.h),
            const _SpeedBonusCard(),
            SizedBox(height: 32.h),
            const _ProTipCard(),
            SizedBox(height: 32.h),
            _DeepGreenButton(
              text: 'Let’s Learn',
              icon: Icons.play_arrow_rounded,
              onTap: () => Get.back<void>(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoringTopBar extends StatelessWidget {
  const _ScoringTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 28.r,
              color: AppColors.primaryGreen,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Scoring Guide',
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          SizedBox(width: 28.r),
        ],
      ),
    );
  }
}

class _ScoreHeroGraphic extends StatelessWidget {
  const _ScoreHeroGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFFFCB2D), Color(0xFFFFA000)],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.13),
                  blurRadius: 18.r,
                  offset: Offset(0, 12.h),
                ),
              ],
            ),
          ),
          Container(
            width: 58.r,
            height: 58.r,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              size: 45.r,
              color: const Color(0xFFFFA000),
            ),
          ),
          Positioned(
            top: 12.h,
            right: 66.w,
            child: Container(
              width: 32.r,
              height: 32.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  r'$',
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 76.w,
            bottom: 16.h,
            child: Icon(
              Icons.star_rounded,
              size: 30.r,
              color: const Color(0xFFE5A100),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasePointsCard extends StatelessWidget {
  const _BasePointsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD7FDC5),
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SmallCircleIcon(
            icon: Icons.star_rounded,
            bgColor: Color(0xFF13A844),
            iconColor: AppColors.white,
          ),
          const Spacer(),
          Text(
            'Base Points',
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF152331),
            ),
          ),
          SizedBox(height: 26.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Earned for every\ncorrect answer.',
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF40515D),
                  ),
                ),
              ),
              Text(
                '+10 XP',
                style: TextStyle(
                  fontSize: AppFont.font32.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF14863A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBonusCard extends StatelessWidget {
  const _StreakBonusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, 32.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6DFBC),
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.flash_on_rounded,
            size: 30.r,
            color: const Color(0xFF834900),
          ),
          const Spacer(),
          Text(
            'Streak Bonus',
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF152331),
            ),
          ),
          SizedBox(height: 16.h),
          _ScoreStreakRow(label: 'gen_3_streak'.tr.tr, value: '+5 XP'),
          SizedBox(height: 12.h),
          _ScoreStreakRow(label: 'gen_5_streak'.tr.tr, value: '+10 XP'),
        ],
      ),
    );
  }
}

class _ScoreStreakRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreStreakRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFA23A18),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFA23A18),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard();

  @override
  Widget build(BuildContext context) {
    return _BonusCard(
      bgColor: const Color(0xFFF8E8DD),
      icon: Icons.workspace_premium_rounded,
      iconColor: const Color(0xFFD88A00),
      title: 'gen_100_mastery'.tr.tr,
      subtitle: 'gen_perfect_score_on_nfirst_attemp'.tr.tr,
      value: '+20 XP',
      valueColor: const Color(0xFFA56400),
    );
  }
}

class _SpeedBonusCard extends StatelessWidget {
  const _SpeedBonusCard();

  @override
  Widget build(BuildContext context) {
    return _BonusCard(
      bgColor: const Color(0xFFDDE9F7),
      icon: Icons.timer_outlined,
      iconColor: const Color(0xFF2563EB),
      title: 'gen_speed_bonus'.tr.tr,
      subtitle: 'gen_finish_the_quiz_in_nunder_200s'.tr.tr,
      value: '+15 XP',
      valueColor: const Color(0xFF205EEA),
    );
  }
}

class _BonusCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  const _BonusCard({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 30.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 31.r, color: iconColor),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF152331),
            ),
          ),
          SizedBox(height: 26.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5E6976),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppFont.font30.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProTipCard extends StatelessWidget {
  const _ProTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 256.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFF207000),
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_rounded,
                size: 27.r,
                color: const Color(0xFF12C958),
              ),
              SizedBox(width: 12.w),
              Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              children: const <TextSpan>[
                TextSpan(text: 'Accuracy is better than speed. User\n'),
                TextSpan(text: 'B earned '),
                TextSpan(
                  text: '135 XP',
                  style: TextStyle(
                    color: Color(0xFF1CDF65),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text:
                      ' by being careful,\nwhile User A only got 85 XP by\nrushing!',
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 70,
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21D765),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 15,
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 15,
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _SmallCircleIcon({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 20.r, color: iconColor),
    );
  }
}

class _DeepGreenButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const _DeepGreenButton({required this.text, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color(0xFF174B00), offset: Offset(0, 7.h)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
            if (icon != null) ...<Widget>[
              SizedBox(width: 12.w),
              Icon(icon, size: 24.r, color: AppColors.white),
            ],
          ],
        ),
      ),
    );
  }
}
