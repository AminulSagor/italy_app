import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/daily_challenge_models.dart';
import '../../../../core/widgets/custom_button.dart';

class DailyChestUnlockedView extends GetView<PracticeHubController> {
  const DailyChestUnlockedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(29.w, 38.h, 24.w, 40.h),
          child: Column(
            children: <Widget>[
              const _ChestUnlockedHeader(),
              Image.asset(
                'assets/heroes/Hero Section_ Treasure Chest.png',
                width: double.infinity,
                height: 390.h,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: double.infinity,
                    height: 390.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3D675),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  );
                },
              ),
              // SizedBox(height: 20.h),
              // const _UnlockedChestHero(),
              // SizedBox(height: 24.h),
              // Text(
              //   'Daily Chest Unlocked!',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 27.sp,
              //     height: 1,
              //     fontWeight: FontWeight.w900,
              //     letterSpacing: -1.1,
              //     color: const Color(0xFF2D3236),
              //   ),
              // ),
              // SizedBox(height: 14.h),
              // Text(
              //   'You completed all 3 quests today.',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: AppFont.font16.sp,
              //     height: 1,
              //     fontWeight: FontWeight.w500,
              //     color: const Color(0xFF71767A),
              //   ),
              // ),
              SizedBox(height: 34.h),
              const Row(
                children: <Widget>[
                  Expanded(child: _XpRewardCard()),
                  SizedBox(width: 16),
                  Expanded(child: _FreezeRewardCard()),
                ],
              ),
              SizedBox(height: 22.h),
              const _StreakIncreasePill(),
              SizedBox(height: 12.h),
              const XpBoostButton(),
              SizedBox(height: 12.h),
              SafeArea(
                top: false,
                child: CustomButton.primary(
                  text: 'back_to_practice'.tr,
                  onPressed: Get.back,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChestUnlockedHeader extends GetView<PracticeHubController> {
  const _ChestUnlockedHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back,
            child: Icon(
              Icons.close_rounded,
              size: 27.r,
              color: AppColors.primaryGreen,
            ),
          ),
          Expanded(
            child: Text(
              'daily_quests'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font17.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Icon(
            Icons.local_fire_department_outlined,
            size: 25.r,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class XpBoostButton extends GetView<PracticeHubController> {
  const XpBoostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final DailyChallengeXpBoostModel? boost =
          controller.dailyChallengeDashboard.value?.xpBoost;
      final double multiplier = boost?.multiplier ?? 1;
      final int seconds = boost?.remainingSeconds ?? 0;
      final String remaining = _formatDuration(seconds);

      return Container(
        height: 64.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(17.w, 8.h, 24.w, 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 55.r,
              height: 39.r,
              decoration: BoxDecoration(
                color: const Color(0xFF8DFF4A),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Center(
                child: Text(
                  'formatmultiplier_multiplier'.trParams(<String, String>{
                    'multiplier': _formatMultiplier(multiplier).toString(),
                  }),
                  style: TextStyle(
                    fontSize: 18.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F6E00),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    boost?.isActive == true ? 'boost_active'.tr : 'xp_boost'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    boost?.isActive == true
                        ? '$remaining remaining'
                        : 'no_active_boost'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(
      seconds: seconds.clamp(0, 864000).toInt(),
    );
    final String hours = duration.inHours.toString().padLeft(2, '0');
    final String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$remainingSeconds';
  }

  String _formatMultiplier(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _XpRewardCard extends GetView<PracticeHubController> {
  const _XpRewardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9EAD1),
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 49.r,
            height: 49.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 28.r,
              color: const Color(0xFF523200),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'xp_earned'.tr,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF754B14),
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () => Text(
              'controller_lastdailychestreward_value_totalxpawarded_0_xp'
                  .trParams(<String, String>{
                    'totalxpawarded':
                        controller.lastDailyChestReward.value?.totalXpAwarded
                            ?.toString() ??
                        '0',
                  }),
              style: TextStyle(
                fontSize: AppFont.font22.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4C2B05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreezeRewardCard extends GetView<PracticeHubController> {
  const _FreezeRewardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 49.r,
            height: 49.r,
            decoration: const BoxDecoration(
              color: Color(0xFFABD3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.ac_unit_rounded,
              size: 26.r,
              color: const Color(0xFF005A91),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'streak_freeze'.tr,
            style: TextStyle(
              fontSize: AppFont.font11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF005A91),
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () => Text(
              'controller_lastdailychestreward_value_streakfreezecount_0_awarded'
                  .trParams(<String, String>{
                    'streakfreezecount':
                        controller.lastDailyChestReward.value?.streakFreezeCount
                            ?.toString() ??
                        '0',
                  }),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1.2,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                color: const Color(0xFF005A91),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakIncreasePill extends GetView<PracticeHubController> {
  const _StreakIncreasePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.fromLTRB(21.w, 0, 18.w, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.local_fire_department_rounded,
            size: 28.r,
            color: const Color(0xFFFF5533),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Obx(
              () => Text(
                'your_streak_is_controller_dailystreakdays_days'.trParams(
                  <String, String>{
                    'dailystreakdays': controller.dailyStreakDays.toString(),
                  },
                ),
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3236),
                ),
              ),
            ),
          ),
          Icon(
            Icons.arrow_upward_rounded,
            size: 24.r,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _BackToPracticeButton extends GetView<PracticeHubController> {
  const _BackToPracticeButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        width: double.infinity,
        height: 72.h,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF174B00),
              offset: Offset(0, 6.h),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'back_to_practice'.tr,
            style: TextStyle(
              fontSize: AppFont.font21.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
