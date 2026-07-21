import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/daily_challenge_models.dart';

class DailyChallengesView extends GetView<PracticeHubController> {
  const DailyChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final bool isLoading =
              controller.isDailyChallengesLoading.value;

          final bool hasDashboard =
              controller.dailyChallengeDashboard.value != null;

          if (isLoading && !hasDashboard) {
            return const _DailyChallengesLoadingView();
          }

          if (!hasDashboard) {
            return _DailyChallengesEmptyView(
              message: controller.dailyChallengesError.value.isEmpty
                  ? 'daily_challenges_are_not_available_right_now'.tr
                  : controller.dailyChallengesError.value,
              onRetry: () {
                controller.loadDailyChallenges(
                  showError: true,
                );
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () {
              return controller.loadDailyChallenges(
                showError: true,
              );
            },
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    bottom: 48.h,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 720,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          14.h,
                          16.w,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: <Widget>[
                            const _DailyChallengeHeader(),
                            SizedBox(height: 14.h),
                            const _StreakHeroCard(),
                            SizedBox(height: 18.h),
                            ...controller.dailyChallengeTasks.map(
                                  (
                                  DailyChallengeTaskModel task,
                                  ) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 12.h,
                                  ),
                                  child: task.isClaimed
                                      ? _ClaimedTaskCard(
                                    task: task,
                                  )
                                      : _DailyTaskCard(
                                    task: task,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 4.h),
                            const _DailyChestCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _DailyChallengesLoadingView extends StatelessWidget {
  const _DailyChallengesLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            0,
          ),
          child: const _DailyChallengeHeader(),
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryGreen,
            ),
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
            padding: EdgeInsets.fromLTRB(
              16.w,
              14.h,
              16.w,
              32.h,
            ),
            child: Column(
              children: <Widget>[
                const _DailyChallengeHeader(),
                const Spacer(),
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.track_changes_rounded,
                    size: 27.r,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 14.h),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 360,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF626865),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: Text(
                    'retry'.tr,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: Size(
                      130.w,
                      44.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        14.r,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyChallengeHeader
    extends GetView<PracticeHubController> {
  const _DailyChallengeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: AppColors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: controller.onDailyChallengesBackTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40.r,
              height: 40.r,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22.r,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Text(
            'gen_daily_challenges'.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3236),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Obx(
              () => Container(
            constraints: BoxConstraints(
              minHeight: 38.h,
              maxWidth: 130.w,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 11.w,
              vertical: 7.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                999.r,
              ),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.bolt_rounded,
                  size: 18.r,
                  color: const Color(0xFFFF9800),
                ),
                SizedBox(width: 3.w),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'daily_challenge_xp'.trParams(
                        <String, String>{
                          'xp': controller.dailyChallengeXp
                              .toString(),
                        },
                      ),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: AppFont.font13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakHeroCard
    extends GetView<PracticeHubController> {
  const _StreakHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 142.h,
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        14.w,
        18.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFF4B2B),
            Color(0xFFFF8A00),
          ],
        ),
        borderRadius: BorderRadius.circular(
          24.r,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFFF7B10).withValues(
              alpha: 0.20,
            ),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                      () => Text(
                    'daily_streak_count'.trParams(
                      <String, String>{
                        'count':
                        controller.dailyStreakDays.toString(),
                      },
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'keep_the_flame_alive'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withValues(
                      alpha: 0.90,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Obx(
                      () => Container(
                    constraints: BoxConstraints(
                      minHeight: 30.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(
                        alpha: 0.20,
                      ),
                      borderRadius: BorderRadius.circular(
                        999.r,
                      ),
                    ),
                    child: Text(
                      controller.dailyChallengeLevelLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.font11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.local_fire_department_rounded,
            size: 88.r,
            color: AppColors.white.withValues(
              alpha: 0.92,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTaskCard
    extends GetView<PracticeHubController> {
  const _DailyTaskCard({
    required this.task,
  });

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        16.r,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          20.r,
        ),
        border: Border.all(
          color: const Color(0xFFE8EBE9),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          _TaskIcon(
            icon: _taskIcon(task.taskKey),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF505653),
                  ),
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    999.r,
                  ),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    minHeight: 7.h,
                    backgroundColor:
                    const Color(0xFFE5E8E6),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      Color(0xFF62CC35),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'task_progress'.trParams(
                        <String, String>{
                          'current':
                          task.progressValue.toString(),
                          'target':
                          task.targetValue.toString(),
                          'unit': task.unit,
                        },
                      ),
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(
                          0xFF6D736F,
                        ),
                      ),
                    ),
                    _TaskRewardButton(
                      task: task,
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

class _TaskRewardButton
    extends GetView<PracticeHubController> {
  const _TaskRewardButton({
    required this.task,
  });

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading =
          controller.isClaimingDailyTask.value;

      final bool enabled =
          task.canClaim && !loading;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
            controller.claimDailyChallengeTask(
              task,
            );
          }
              : null,
          borderRadius: BorderRadius.circular(
            999.r,
          ),
          child: Container(
            constraints: BoxConstraints(
              minHeight: 34.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 13.w,
              vertical: 7.h,
            ),
            decoration: BoxDecoration(
              color: task.canClaim
                  ? const Color(0xFFFFF4E4)
                  : const Color(0xFFF1F3F2),
              borderRadius: BorderRadius.circular(
                999.r,
              ),
              border: Border.all(
                color: task.canClaim
                    ? const Color(0xFFFFC36E)
                    : const Color(0xFFD9DDDA),
              ),
            ),
            child: loading && task.canClaim
                ? SizedBox(
              width: 15.r,
              height: 15.r,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8C5200),
              ),
            )
                : Text(
              task.canClaim
                  ? 'claim_xp'.trParams(
                <String, String>{
                  'xp':
                  task.rewardXp.toString(),
                },
              )
                  : 'reward_xp'.trParams(
                <String, String>{
                  'xp':
                  task.rewardXp.toString(),
                },
              ),
              style: TextStyle(
                fontSize: AppFont.font11.sp,
                fontWeight: FontWeight.w900,
                color: task.canClaim
                    ? const Color(0xFF8C5200)
                    : const Color(0xFF858A87),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ClaimedTaskCard extends StatelessWidget {
  const _ClaimedTaskCard({
    required this.task,
  });

  final DailyChallengeTaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        15.r,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5FFD9),
        borderRadius: BorderRadius.circular(
          20.r,
        ),
        border: Border.all(
          color: const Color(0xFFA8E88C),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              color: Color(0xFF237900),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              size: 25.r,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font13.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF52734B),
                    decoration:
                    TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: 0.75,
                    ),
                    borderRadius: BorderRadius.circular(
                      999.r,
                    ),
                  ),
                  child: Text(
                    'reward_xp'.trParams(
                      <String, String>{
                        'xp': task.rewardXp.toString(),
                      },
                    ),
                    style: TextStyle(
                      fontSize: AppFont.font11.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
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

class _DailyChestCard
    extends GetView<PracticeHubController> {
  const _DailyChestCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool unlocked =
          controller.isDailyChestUnlocked;

      final bool opened =
          controller.isDailyChestOpened;

      final bool loading =
          controller.isOpeningDailyChest.value;

      final int taskCount =
          controller.dailyChallengeTasks.length;

      final int completed =
          controller.dailyCompletedTaskCount;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading
              ? null
              : controller.onDailyChestTap,
          borderRadius: BorderRadius.circular(
            22.r,
          ),
          child: Ink(
            width: double.infinity,
            padding: EdgeInsets.all(
              16.r,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                22.r,
              ),
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
                  color: const Color(0xFF174B36)
                      .withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 14.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 74.r,
                  height: 74.r,
                  child: Image.asset(
                    'assets/heroes/daily_chest.png',
                    fit: BoxFit.contain,
                    errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                        ) {
                      return Icon(
                        Icons.inventory_2_rounded,
                        size: 54.r,
                        color: const Color(
                          0xFFD3F17C,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        opened
                            ? 'daily_chest_nopened'.tr
                            : unlocked
                            ? 'daily_chest_nunlocked'
                            .tr
                            : 'unlock_the_ndaily_chest'
                            .tr,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                          AppFont.font16.sp,
                          height: 1.15,
                          fontWeight:
                          FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        opened
                            ? 'tap_to_view_your_reward'
                            .tr
                            : unlocked
                            ? 'tap_to_open_your_reward'
                            .tr
                            : 'complete_all_tasks_to_open'
                            .trParams(
                          <String, String>{
                            'count':
                            taskCount.toString(),
                          },
                        ),
                        maxLines: 3,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                          AppFont.font12.sp,
                          height: 1.3,
                          fontWeight:
                          FontWeight.w500,
                          color: AppColors.white
                              .withValues(
                            alpha: 0.80,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (loading)
                        SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child:
                          const CircularProgressIndicator(
                            color: Color(
                              0xFF75FF35,
                            ),
                            strokeWidth: 2.3,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children:
                          List<Widget>.generate(
                            taskCount,
                                (int index) {
                              final bool active =
                                  index < completed;

                              return Container(
                                width: 9.r,
                                height: 9.r,
                                decoration:
                                BoxDecoration(
                                  color: active
                                      ? const Color(
                                    0xFF75FF35,
                                  )
                                      : AppColors.white
                                      .withValues(
                                    alpha: 0.25,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17.r,
                  color: AppColors.white.withValues(
                    alpha: 0.75,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TaskIcon extends StatelessWidget {
  const _TaskIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.r,
      height: 46.r,
      decoration: const BoxDecoration(
        color: Color(0xFF237900),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 23.r,
        color: AppColors.white,
      ),
    );
  }
}

IconData _taskIcon(String taskKey) {
  if (taskKey.contains('minute')) {
    return Icons.schedule_rounded;
  }

  if (taskKey.contains('xp')) {
    return Icons.bolt_rounded;
  }

  if (taskKey.contains('lesson')) {
    return Icons.menu_book_rounded;
  }

  if (taskKey.contains('quiz')) {
    return Icons.quiz_rounded;
  }

  return Icons.flag_rounded;
}