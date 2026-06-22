import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';

class DailyChallengesView extends GetView<PracticeHubController> {
  const DailyChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(40.w, 33.h, 24.w, 60.h),
          child: Column(
            children: <Widget>[
              const _DailyChallengeHeader(),
              SizedBox(height: 15.h),
              const _StreakHeroCard(),
              SizedBox(height: 25.h),

              Obx(
                () => Column(
                  children: controller.dailyChallengeTasks
                      .map(
                        (Map<String, dynamic> task) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: task['isClaimed'] == true
                              ? _ClaimedTaskCard(task: task)
                              : _DailyTaskCard(task: task),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: 9.h),
              const _DailyChestCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeHeader extends GetView<PracticeHubController> {
  const _DailyChallengeHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onDailyChallengesBackTap,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 27.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Text(
              'Daily Challenges',
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
                color: const Color(0xFF2D3236),
              ),
            ),
          ),
          Obx(
            () => Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999.r),
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
                    Icons.flash_on_rounded,
                    size: 22.r,
                    color: const Color(0xFFFF9800),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    '${controller.dailyChallengeXp.value} XP',
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakHeroCard extends GetView<PracticeHubController> {
  const _StreakHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 228.h,
      padding: EdgeInsets.fromLTRB(32.w, 31.h, 28.w, 30.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFF4B2B), Color(0xFFFF8A00)],
        ),
        borderRadius: BorderRadius.circular(42.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFFF7B10).withValues(alpha: 0.30),
            blurRadius: 28.r,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -8.w,
            top: -57.h,
            child: Container(
              width: 155.r,
              height: 155.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -2.w,
            bottom: -3.h,
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 140.r,
              color: AppColors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Obx(
                () => Text(
                  '${controller.dailyStreakDays.value} Day\nStreak!',
                  style: TextStyle(
                    fontSize: AppFont.font30.sp,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(height: 11.h),
              Text(
                'Keep the flame\nalive',
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.dailyChallengeLevelLabel.value,
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
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

class _DailyTaskCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> task;

  const _DailyTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final int current = task['current'] as int? ?? 0;
    final int target = task['target'] as int? ?? 1;
    final int xp = task['xp'] as int? ?? 0;
    final String unit = task['unit'] as String? ?? '';
    final double progress = target == 0 ? 0 : current / target;

    return Container(
      width: double.infinity,
      //height: 164.h,
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 27.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(46.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 64.r,
            height: 64.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5E8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 27.r,
                height: 27.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF9B5A00),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 18.r,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 22.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task['title'] as String,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    height: 1.6,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF606367),
                  ),
                ),
                SizedBox(height: 9.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 9.h,
                    backgroundColor: const Color(0xFFE0E2E2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF76FF35),
                    ),
                  ),
                ),
                SizedBox(height: 13.h),
                Row(
                  children: <Widget>[
                    Text(
                      '$current / $target$unit',
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF666A6D),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => controller.claimDailyChallengeTask(
                        task['id'] as String,
                      ),
                      child: Container(
                        height: 38.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5E8),
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: const Color(0xFFFFC16B),
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+$xp XP',
                            style: TextStyle(
                              fontSize: AppFont.font12.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF8C5200),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimedTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _ClaimedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final int xp = task['xp'] as int? ?? 0;

    return Container(
      width: double.infinity,
      //height: 124.h,
      padding: EdgeInsets.fromLTRB(22.w, 25.h, 25.w, 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD4FFBE),
        borderRadius: BorderRadius.circular(45.r),
        border: Border.all(color: const Color(0xFF9CFF72), width: 2.w),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 58.r,
            height: 58.r,
            decoration: const BoxDecoration(
              color: Color(0xFF237900),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 34.r,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 17.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task['title'] as String,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    height: 1.65,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen.withValues(alpha: 0.58),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.primaryGreen.withValues(
                      alpha: 0.45,
                    ),
                    decorationThickness: 2,
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  height: 20.h,
                  width: 130.w,
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Center(
                    child: Text(
                      'CLAIMED +$xp XP',
                      style: TextStyle(
                        fontSize: AppFont.font11.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChestCard extends GetView<PracticeHubController> {
  const _DailyChestCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onDailyChestTap,
      child: Container(
        width: double.infinity,
        height: 177.h,

        decoration: BoxDecoration(
          //color: const Color(0xFF174B36),
          borderRadius: BorderRadius.circular(50.r),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            //end: Alignment.topRight,
            colors: [
              const Color.fromARGB(255, 104, 168, 51),
              const Color.fromARGB(255, 45, 112, 48),
              const Color.fromARGB(255, 27, 70, 30),
              const Color.fromARGB(255, 27, 70, 30),
              const Color.fromARGB(255, 27, 70, 30),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF174B36).withValues(alpha: 0.28),
              blurRadius: 26.r,
              offset: Offset(0, 15.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 25.h),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/heroes/daily_chest.png',
                width: 112.w,
                height: 94.h,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Icon(
                    Icons.inventory_2_rounded,
                    size: 96.r,
                    color: const Color(0xFFD3F17C),
                  );
                },
              ),
              //SizedBox(width: 22.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock the\nDaily Chest',
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      //height: 1.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Complete all 3 tasks\nto open',
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      //height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.62),
                    ),
                  ),
                  const Spacer(),
                  //SizedBox(height: 4.h),
                  Obx(
                    () => Row(
                      children: List<Widget>.generate(3, (int index) {
                        final bool active =
                            controller.dailyChestSlideIndex.value == index;

                        return Container(
                          width: active ? 13.r : 12.r,
                          height: active ? 13.r : 12.r,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF75FF35)
                                : AppColors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            boxShadow: active
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: const Color(
                                        0xFF75FF35,
                                      ).withValues(alpha: 0.55),
                                      blurRadius: 12.r,
                                      offset: Offset(0, 3.h),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
