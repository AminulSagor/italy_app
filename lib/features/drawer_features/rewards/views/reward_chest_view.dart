import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/reward_models.dart';
import '../models/reward_response_models.dart';
import '../reward_controller.dart';
import '../widgets/reward_shipping_dialog.dart';
import '../widgets/reward_widgets.dart';

class RewardChestView extends GetView<RewardController> {
  const RewardChestView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          final RewardChestModel? chest = controller.activeChest;
          final RewardModel? openedReward = controller.selectedReward.value;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 48.h),
            child: Column(
              children: <Widget>[
                RewardTopBar(title: 'gen_chest'.tr),
                SizedBox(height: 24.h),
                if (chest == null && openedReward == null)
                  RewardStateMessage(
                    icon: Icons.inventory_2_outlined,
                    title: 'chest_unavailable'.tr,
                    message:
                        'this_reward_is_no_longer_available_or_has_already'.tr,
                    buttonText: 'back_to_rewards'.tr,
                    onTap: Get.back,
                  )
                else
                  _ChestContent(
                    chest: chest,
                    reward: openedReward,
                    isOpening: controller.isOpeningReward.value,
                    onPrimaryAction: () =>
                        _onPrimaryAction(chest: chest, reward: openedReward),
                  ),
                SizedBox(height: 33.h),
                const _LearningTip(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _onPrimaryAction({
    required RewardChestModel? chest,
    required RewardModel? reward,
  }) async {
    if (reward == null) {
      await controller.openSelectedChest();
      return;
    }

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

class _ChestContent extends StatelessWidget {
  const _ChestContent({
    required this.chest,
    required this.reward,
    required this.isOpening,
    required this.onPrimaryAction,
  });

  final RewardChestModel? chest;
  final RewardModel? reward;
  final bool isOpening;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final RewardType rewardType = reward?.rewardType ?? chest!.rewardType;
    final String? imageUrl = reward?.imageUrl ?? chest?.imageUrl;
    final String title = reward?.title ?? chest?.headline ?? 'gen_reward'.tr;
    final String subtitle =
        reward?.congratulatoryNote ??
        chest?.congratulatoryNote ??
        'Congratulations on your achievement!';
    final String buttonText = _buttonText();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(31.w, 28.h, 31.w, 32.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE4FFD7),
        borderRadius: BorderRadius.circular(58.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 34.r,
            offset: Offset(0, 24.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 270.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(44.r),
            ),
            child: reward == null
                ? Image.asset(
                    'assets/heroes/chest_img.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => RewardImage(
                      rewardType: rewardType,
                      imageUrl: imageUrl,
                      size: 180,
                    ),
                  )
                : RewardImage(
                    rewardType: rewardType,
                    imageUrl: imageUrl,
                    size: 190,
                  ),
          ),
          SizedBox(height: 30.h),
          Text(
            reward == null ? 'a_new_reward_is_waiting'.tr : 'congratulazioni'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: const Color(0xFF161616),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31.sp,
              height: 1.16,
              fontWeight: FontWeight.w900,
              color: RewardChestView.green,
              letterSpacing: -0.65,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            subtitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF555555),
            ),
          ),
          SizedBox(height: 34.h),
          RewardPrimaryButton(
            text: buttonText,
            suffixIcon: _buttonIcon(),
            onTap: _hasAction ? onPrimaryAction : null,
            isLoading: isOpening,
          ),
          if (reward != null && reward!.statusLabel.isNotEmpty) ...<Widget>[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: RewardVisuals.statusBackground(reward!.status),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                reward!.statusLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: RewardVisuals.statusText(reward!.status),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasAction => reward == null || reward!.action != null;

  String _buttonText() {
    if (reward == null) return chest?.action?.label ?? 'open_chest'.tr;
    return reward!.action?.label ?? 'reward_claimed'.tr;
  }

  IconData? _buttonIcon() {
    final RewardActionType? type = reward?.action?.type;
    if (type == RewardActionType.shippingAddress) {
      return Icons.local_shipping_outlined;
    }
    if (type == RewardActionType.downloadFile ||
        type == RewardActionType.viewCertificate) {
      return Icons.file_download_outlined;
    }
    if (reward == null) return Icons.redeem_rounded;
    return null;
  }
}

class _LearningTip extends StatelessWidget {
  const _LearningTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              color: Color(0xFFE4FFD7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 22.r,
              color: RewardChestView.green,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              'keep_learning_to_unlock_more_prizes'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
