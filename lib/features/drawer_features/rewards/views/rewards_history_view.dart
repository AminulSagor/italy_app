import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(26.w, 39.h, 26.w, 54.h),
          child: Column(
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
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3032),
                  letterSpacing: -0.75,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Italian Shikhi Achievements',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),

              SizedBox(height: 44.h),

              Column(
                children: controller.historyItems
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _HistoryTile(
                          item: item,
                          onTap: () => controller.openRewardDetails(item.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final RewardHistoryItem item;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
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
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(item.icon, size: 27.r, color: item.iconColor),
            ),
            SizedBox(width: 25.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 21.sp,
                      height: 1.14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3032),
                      letterSpacing: -0.35,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: <Widget>[
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.22,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      SizedBox(width: 18.w),
                      Container(
                        height: 24.h,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.badgeBgColor,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          item.badge,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: item.badgeTextColor,
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
