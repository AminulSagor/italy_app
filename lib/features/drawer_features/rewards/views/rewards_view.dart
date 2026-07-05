import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/reward_models.dart';
import '../models/reward_response_models.dart';
import '../reward_controller.dart';
import '../widgets/reward_shipping_dialog.dart';
import '../widgets/reward_widgets.dart';

class RewardsView extends GetView<RewardController> {
  const RewardsView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingDashboard.value &&
              controller.dashboard.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          final RewardDashboardModel? dashboard = controller.dashboard.value;
          return RefreshIndicator(
            color: green,
            onRefresh: controller.refreshDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 52.h),
              children: <Widget>[
                RewardTopBar(title: 'gen_rewards'.tr),
                SizedBox(height: 24.h),
                if (dashboard == null)
                  RewardStateMessage(
                    icon: Icons.error_outline_rounded,
                    title: 'rewards_unavailable'.tr,
                    message: controller.dashboardError.value.isEmpty
                        ? 'could_not_load_your_rewards'.tr
                        : controller.dashboardError.value,
                    buttonText: 'retry'.tr,
                    onTap: controller.loadDashboard,
                  )
                else ...<Widget>[
                  if (dashboard.pendingChest != null)
                    _WinnerCard(
                      chest: dashboard.pendingChest!,
                      onOpenChest: controller.openChest,
                    )
                  else
                    RewardStateMessage(
                      icon: Icons.inventory_2_outlined,
                      title: 'no_unopened_chest'.tr,
                      message:
                          'keep_learning_and_climbing_the_leaderboard_to_unlo'.tr,
                    ),
                  SizedBox(height: 34.h),
                  _HistoryHeader(onSeeAll: controller.openRewardsHistory),
                  SizedBox(height: 20.h),
                  if (dashboard.recentRewards.isEmpty)
                    RewardStateMessage(
                      icon: Icons.emoji_events_outlined,
                      title: 'no_rewards_yet'.tr,
                      message:
                          'your_claimed_and_unlocked_rewards_will_appear_here'.tr,
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboard.recentRewards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 238.h,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 18.h,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final RewardModel item =
                            dashboard.recentRewards[index];
                        return _RewardCard(
                          item: item,
                          onDetailsTap: () =>
                              controller.openRewardDetails(item.id),
                          onActionTap: () => _handleRewardAction(item),
                        );
                      },
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleRewardAction(RewardModel reward) async {
    if (reward.action?.type == RewardActionType.shippingAddress) {
      final bool ready = await controller.prepareShippingAddress(reward);
      if (ready) {
        await Get.dialog<void>(
          const RewardShippingDialog(),
          barrierColor: Colors.black.withValues(alpha: 0.38),
        );
      }
      return;
    }
    await controller.handleRewardAction(reward);
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'reward_history'.tr,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3032),
              letterSpacing: -0.35,
            ),
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'see_all'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: RewardsView.green,
            ),
          ),
        ),
      ],
    );
  }
}

class _WinnerCard extends StatelessWidget {
  const _WinnerCard({required this.chest, required this.onOpenChest});

  final RewardChestModel chest;
  final VoidCallback onOpenChest;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 428.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(62.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF166800),
            Color(0xFF195E02),
            Color(0xFF00617A),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 32.r,
            offset: Offset(0, 22.h),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 48.h,
            child: Container(
              width: 158.r,
              height: 158.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: RewardImage(
                rewardType: chest.rewardType,
                imageUrl: chest.imageUrl,
                size: 135,
              ),
            ),
          ),
          Positioned(
            top: 205.h,
            left: 30.w,
            right: 30.w,
            child: Text(
              chest.headline.isEmpty ? chest.title : chest.headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27.sp,
                height: 1.18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.65,
              ),
            ),
          ),
          Positioned(
            top: 282.h,
            left: 45.w,
            right: 45.w,
            child: Text(
              chest.congratulatoryNote.isEmpty
                  ? 'you_unlocked_a_special_reward_for_your_progress'.tr
                  : chest.congratulatoryNote,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ),
          Positioned(
            bottom: 32.h,
            child: GestureDetector(
              onTap: onOpenChest,
              child: Container(
                height: 58.h,
                width: 170.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  chest.action?.label.isNotEmpty == true
                      ? chest.action!.label
                      : 'open_chest'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: RewardsView.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.item,
    required this.onDetailsTap,
    required this.onActionTap,
  });

  final RewardModel item;
  final VoidCallback onDetailsTap;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = RewardVisuals.accent(item.rewardType);
    final String subtitle = item.subtitle.isNotEmpty
        ? item.subtitle
        : item.valueLabel;

    return GestureDetector(
      onTap: onDetailsTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: RewardVisuals.background(item.rewardType),
          borderRadius: BorderRadius.circular(42.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    RewardVisuals.icon(item.rewardType),
                    size: 25.r,
                    color: accent,
                  ),
                ),
                const Spacer(),
                if (!item.isSeen)
                  Container(
                    width: 9.r,
                    height: 9.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD71920),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              item.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: accent,
                letterSpacing: -0.25,
              ),
            ),
            if (subtitle.isNotEmpty) ...<Widget>[
              SizedBox(height: 7.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: accent.withValues(alpha: 0.82),
                ),
              ),
            ],
            const Spacer(),
            if (item.action != null)
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  height: 35.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.rewardType == RewardType.courseAccess
                        ? Colors.white
                        : accent,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    item.action!.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w900,
                      color: item.rewardType == RewardType.courseAccess
                          ? accent
                          : Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 26.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  item.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
