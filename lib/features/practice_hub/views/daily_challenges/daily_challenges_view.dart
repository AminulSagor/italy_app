import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/daily_challenge_models.dart';
import '_widgets/claimed_xp_chip.dart';

class DailyChallengesView extends GetView<PracticeHubController> {
  const DailyChallengesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => controller.loadDailyChallenges(showError: true),
          child: Obx(() {
            if (controller.isDailyChallengesLoading.value &&
                controller.dailyChallengeDashboard.value == null) {
              return const _DailyChallengesLoadingView();
            }
            if (controller.dailyChallengeDashboard.value == null) {
              return _DailyChallengesEmptyView(
                message: controller.dailyChallengesError.value.isEmpty
                    ? 'daily_challenges_are_not_available_right_now'.tr
                    : controller.dailyChallengesError.value,
                onRetry: () => controller.loadDailyChallenges(showError: true),
              );
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(40.w, 33.h, 24.w, 60.h),
              child: Column(
                children: <Widget>[
                  const _DailyChallengeHeader(),
                  SizedBox(height: 15.h),
                  const _StreakHeroCard(),
                  SizedBox(height: 25.h),
                  ...controller.dailyChallengeTasks.map(
                    (DailyChallengeTaskModel task) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: task.isClaimed
                          ? _ClaimedTaskCard(task: task)
                          : _DailyTaskCard(task: task),
                    ),
                  ),
                  SizedBox(height: 9.h),
                  const _DailyChestCard(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DailyChallengesLoadingView extends StatelessWidget {
  const _DailyChallengesLoadingView();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(40.w, 33.h, 24.w, 0),
                child: const _DailyChallengeHeader(),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyChallengesEmptyView extends StatelessWidget {
  const _DailyChallengesEmptyView({
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(40.w, 33.h, 24.w, 40.h),
            child: Column(
              children: <Widget>[
                const _DailyChallengeHeader(),
                const Spacer(),
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 62.r,
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6A6F73),
                  ),
                ),
                SizedBox(height: 14.h),
                TextButton(onPressed: onRetry, child: Text('retry'.tr)),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
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
              'gen_daily_challenges'.tr,
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
                    'daily_challenge_xp'.trParams(
                      <String, String>{
                        'xp': controller.dailyChallengeXp.toString(),
                      },
                    ),
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
                  '${controller.dailyStreakDays} Day\nStreak!',
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
                      controller.dailyChallengeLevelLabel,
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
  const _DailyTaskCard({required this.task});
  final DailyChallengeTaskModel task;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            width: 59.r,
            height: 59.r,
            decoration: const BoxDecoration(
              color: Color(0xFF237900),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _taskIcon(task.taskKey),
              size: 29.r,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF606367),
                  ),
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: task.progress,
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
                      'task_progress'.trParams(
                        <String, String>{
                          'current': task.progressValue.toString(),
                          'target': task.targetValue.toString(),
                          'unit': task.unit,
                        },
                      ),
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF666A6D),
                      ),
                    ),
                    const Spacer(),
                    _TaskRewardButton(task: task),
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

class _TaskRewardButton extends GetView<PracticeHubController> {
  const _TaskRewardButton({required this.task});
  final DailyChallengeTaskModel task;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isClaimingDailyTask.value;
      return GestureDetector(
        onTap: task.canClaim && !loading
            ? () => controller.claimDailyChallengeTask(task)
            : null,
        child: Container(
          height: 38.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            color: task.canClaim
                ? const Color(0xFFFFF5E8)
                : const Color(0xFFF0F1F1),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: task.canClaim
                  ? const Color(0xFFFFC16B)
                  : const Color(0xFFD7D9DA),
              width: 1.w,
            ),
          ),
          child: Center(
            child: loading && task.canClaim
                ? SizedBox(
                    width: 15.r,
                    height: 15.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    task.canClaim
                        ? 'Claim +${task.rewardXp} XP'
                        : '+${task.rewardXp} XP',
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w900,
                      color: task.canClaim
                          ? const Color(0xFF8C5200)
                          : const Color(0xFF8B8F91),
                    ),
                  ),
          ),
        ),
      );
    });
  }
}

class _ClaimedTaskCard extends StatelessWidget {
  const _ClaimedTaskCard({required this.task});
  final DailyChallengeTaskModel task;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  task.title,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen.withValues(alpha: 0.58),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(height: 7.h),
                ClaimedXpChip(rewardXp: task.rewardXp),
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
    return Obx(() {
      final bool unlocked = controller.isDailyChestUnlocked;
      final bool opened = controller.isDailyChestOpened;
      final bool loading = controller.isOpeningDailyChest.value;
      final int taskCount = controller.dailyChallengeTasks.length;
      final int completed = controller.dailyCompletedTaskCount;
      return GestureDetector(
        onTap: loading ? null : controller.onDailyChestTap,
        child: Container(
          width: double.infinity,
          height: 177.h,
          padding: EdgeInsets.fromLTRB(20.w, 25.h, 20.w, 24.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: <Color>[
                Color(0xFF68A833),
                Color(0xFF2D7030),
                Color(0xFF1B461E),
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
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/heroes/daily_chest.png',
                width: 112.w,
                height: 94.h,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.inventory_2_rounded,
                  size: 90.r,
                  color: const Color(0xFFD3F17C),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      opened
                          ? 'daily_chest_nopened'.tr
                          : unlocked
                          ? 'daily_chest_nunlocked'.tr
                          : 'unlock_the_ndaily_chest'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font18.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      opened
                          ? 'tap_to_view_your_reward'.tr
                          : unlocked
                          ? 'tap_to_open_your_reward'.tr
                          : 'Complete all $taskCount tasks to open',
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    if (loading)
                      SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          color: Color(0xFF75FF35),
                          strokeWidth: 2.5,
                        ),
                      )
                    else
                      Row(
                        children: List<Widget>.generate(taskCount, (int index) {
                          final bool active = index < completed;
                          return Container(
                            width: 12.r,
                            height: 12.r,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF75FF35)
                                  : AppColors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

IconData _taskIcon(String taskKey) => taskKey.contains('minute')
    ? Icons.schedule_rounded
    : taskKey.contains('xp')
    ? Icons.bolt_rounded
    : taskKey.contains('lesson')
    ? Icons.menu_book_rounded
    : taskKey.contains('quiz')
    ? Icons.quiz_rounded
    : Icons.flag_rounded;
