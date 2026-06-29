import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/reward_models.dart';
import '../reward_controller.dart';
import '../widgets/reward_widgets.dart';

class RewardsHistoryView extends GetView<RewardController> {
  const RewardsHistoryView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: green,
            onRefresh: () => controller.loadHistory(reset: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(26.w, 39.h, 26.w, 54.h),
              children: <Widget>[
                const RewardTopBar(title: 'Rewards History'),
                SizedBox(height: 36.h),
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF79F535),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 31.r,
                    color: green,
                  ),
                ),
                SizedBox(height: 23.h),
                Text(
                  'Reward History',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3032),
                    letterSpacing: -0.75,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  controller.historyTotal.value > 0
                      ? '${controller.historyTotal.value} achievements earned'
                      : 'Italian Shikhi Achievements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 44.h),
                if (controller.isLoadingHistory.value &&
                    controller.historyItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: green),
                    ),
                  )
                else if (controller.historyError.value.isNotEmpty &&
                    controller.historyItems.isEmpty)
                  RewardStateMessage(
                    icon: Icons.error_outline_rounded,
                    title: 'History unavailable',
                    message: controller.historyError.value,
                    buttonText: 'Retry',
                    onTap: () => controller.loadHistory(reset: true),
                  )
                else if (controller.historyItems.isEmpty)
                  const RewardStateMessage(
                    icon: Icons.history_rounded,
                    title: 'No rewards yet',
                    message: 'Rewards you unlock or claim will be saved here.',
                  )
                else ...<Widget>[
                  ...controller.historyItems.map(
                    (RewardModel item) => Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: _HistoryTile(
                        item: item,
                        onTap: () => controller.openRewardDetails(item.id),
                      ),
                    ),
                  ),
                  if (controller.hasMoreHistory)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
                      child: RewardPrimaryButton(
                        text: 'Load More',
                        height: 52,
                        onTap: controller.loadMoreHistory,
                        isLoading: controller.isLoadingMoreHistory.value,
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onTap});

  final RewardModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = RewardVisuals.accent(item.rewardType);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 18.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14.r,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: RewardVisuals.background(item.rewardType),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                RewardVisuals.icon(item.rewardType),
                size: 27.r,
                color: accent,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19.sp,
                      height: 1.14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3032),
                      letterSpacing: -0.35,
                    ),
                  ),
                  SizedBox(height: 13.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 8.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        formatRewardDate(item.awardedAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      Container(
                        height: 24.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: RewardVisuals.statusBackground(item.status),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          item.statusLabel,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            color: RewardVisuals.statusText(item.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 30.r,
              color: const Color(0xFFA5A5A5),
            ),
          ],
        ),
      ),
    );
  }
}
