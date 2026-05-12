import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 52.h),
          child: Column(
            children: <Widget>[
              const RewardTopBar(title: 'Rewards'),
              SizedBox(height: 24.h),

              _WinnerCard(onOpenChest: controller.openChest),

              SizedBox(height: 34.h),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Reward History',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3032),
                        letterSpacing: -0.35,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.openRewardsHistory,
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.rewardCards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 220.h,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 18.h,
                ),
                itemBuilder: (context, index) {
                  final RewardCardItem item = controller.rewardCards[index];

                  return _RewardCard(
                    item: item,
                    onTap: () {
                      if (item.id == 'boat-headphones') {
                        Get.dialog(
                          const RewardShippingDialog(),
                          barrierColor: Colors.black.withValues(alpha: 0.38),
                        );
                        return;
                      }

                      controller.handleRewardCardTap(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final VoidCallback onOpenChest;

  const _WinnerCard({required this.onOpenChest});

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
            top: 70.h,
            child: Container(
              width: 128.r,
              height: 128.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6CFF3B).withValues(alpha: 0.18),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF79F535).withValues(alpha: 0.25),
                    blurRadius: 42.r,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 67.h,
            child: SizedBox(
              width: 132.r,
              height: 104.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: 12.w,
                    top: 20.h,
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      size: 90.r,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF79F535),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 24.r,
                        color: const Color(0xFF267A05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 195.h,
            left: 34.w,
            right: 34.w,
            child: Text(
              'Admin Giveaway\nWinner!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 29.sp,
                height: 1.18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.65,
              ),
            ),
          ),
          Positioned(
            top: 285.h,
            left: 54.w,
            right: 54.w,
            child: Text(
              'You won a special\nreward for your performance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.72),
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
                  'Open Chest',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF267A05),
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
  final RewardCardItem item;
  final VoidCallback onTap;

  const _RewardCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 25.r, color: item.iconColor),
          ),
          SizedBox(height: 26.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.08,
              fontWeight: FontWeight.w900,
              color: item.textColor,
              letterSpacing: -0.25,
            ),
          ),
          if (item.subtitle.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 9.5.sp,
                height: 1.28,
                fontWeight: FontWeight.w500,
                color: item.textColor.withValues(alpha: 0.82),
              ),
            ),
          ],
          const Spacer(),
          if (item.buttonText != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: 35.h,
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.buttonColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.id == 'boat-headphones') ...[
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 12.r,
                        color: item.buttonTextColor,
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      item.buttonText!,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: item.buttonTextColor,
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
