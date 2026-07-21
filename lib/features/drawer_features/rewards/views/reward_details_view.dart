import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/reward_models.dart';
import '../reward_controller.dart';
import '../widgets/reward_shipping_dialog.dart';
import '../widgets/reward_widgets.dart';

class RewardDetailsView extends GetView<RewardController> {
  const RewardDetailsView({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          final RewardModel? reward = controller.selectedReward.value;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(25.w, 39.h, 25.w, 56.h),
            child: Column(
              children: <Widget>[
                RewardTopBar(title: 'gen_reward_details'.tr),
                SizedBox(height: 30.h),
                if (controller.isLoadingDetails.value && reward == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 120),
                    child: CircularProgressIndicator(color: green),
                  )
                else if (reward == null)
                  RewardStateMessage(
                    icon: Icons.error_outline_rounded,
                    title: 'reward_unavailable'.tr,
                    message: controller.detailsError.value.isEmpty
                        ? 'could_not_load_this_reward'.tr
                        : controller.detailsError.value,
                    buttonText: 'back_1'.tr,
                    onTap: Get.back,
                  )
                else ...<Widget>[
                  _RewardHeroCard(reward: reward),
                  SizedBox(height: 30.h),
                  _RewardMetaRow(reward: reward),
                  if (reward.valueLabel.isNotEmpty) ...<Widget>[
                    SizedBox(height: 28.h),
                    _RewardValueCard(reward: reward),
                  ],
                  if (reward.earnedReason?.isNotEmpty == true) ...<Widget>[
                    SizedBox(height: 28.h),
                    _EarnedReasonCard(reason: reward.earnedReason!),
                  ],
                  if (reward.rewardType.isPhysical) ...<Widget>[
                    SizedBox(height: 28.h),
                    _DeliveryCard(reward: reward),
                  ],
                  if (reward.action != null ||
                      reward.canConfirmDelivery) ...<Widget>[
                    SizedBox(height: 34.h),
                    RewardPrimaryButton(
                      text: reward.canConfirmDelivery
                          ? 'confirm_delivery'.tr
                          : reward.action!.label,
                      suffixIcon: _actionIcon(reward),
                      onTap: () => _handleAction(reward),
                      isLoading:
                          controller.isSavingShippingAddress.value ||
                          controller.isConfirmingDelivery.value ||
                          controller.isDownloadingReward.value,
                    ),
                  ],
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleAction(RewardModel reward) async {
    if (reward.canConfirmDelivery) {
      await controller.confirmDelivery(reward);
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

  IconData? _actionIcon(RewardModel reward) {
    if (reward.canConfirmDelivery) return Icons.inventory_2_outlined;
    switch (reward.action?.type) {
      case RewardActionType.shippingAddress:
      case RewardActionType.trackDelivery:
        return Icons.local_shipping_outlined;
      case RewardActionType.downloadFile:
      case RewardActionType.viewCertificate:
        return Icons.file_download_outlined;
      case RewardActionType.startCourse:
        return Icons.school_outlined;
      default:
        return null;
    }
  }
}

class _RewardHeroCard extends StatelessWidget {
  const _RewardHeroCard({required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(34.w, 31.h, 34.w, 33.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 191.h,
            width: 191.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RewardVisuals.background(reward.rewardType),
              borderRadius: BorderRadius.circular(36.r),
            ),
            child: RewardImage(
              rewardType: reward.rewardType,
              imageUrl: reward.imageUrl,
              size: 150,
            ),
          ),
          SizedBox(height: 25.h),
          Text(
            reward.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27.sp,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3032),
              letterSpacing: -0.8,
            ),
          ),
          if (reward.subtitle.isNotEmpty) ...<Widget>[
            SizedBox(height: 13.h),
            Text(
              reward.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF626262),
              ),
            ),
          ],
          if (reward.congratulatoryNote?.isNotEmpty == true) ...<Widget>[
            SizedBox(height: 16.h),
            Text(
              reward.congratulatoryNote!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: RewardVisuals.accent(reward.rewardType),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardMetaRow extends StatelessWidget {
  const _RewardMetaRow({required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 62.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: RewardVisuals.statusBackground(reward.status),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    color: RewardVisuals.statusText(reward.status),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Text(
                    reward.statusLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: RewardVisuals.statusText(reward.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Icon(
          Icons.calendar_today_outlined,
          size: 18.r,
          color: const Color(0xFF575757),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Text(
            'reward_awarded_date'.trParams(<String, String>{
              'date': formatRewardDate(reward.awardedAt),
            }),
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF626262),
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardValueCard extends StatelessWidget {
  const _RewardValueCard({required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    final Color accent = RewardVisuals.accent(reward.rewardType);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: RewardVisuals.background(reward.rewardType),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            RewardVisuals.icon(reward.rewardType),
            size: 32.r,
            color: accent,
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              reward.valueLabel,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnedReasonCard extends StatelessWidget {
  const _EarnedReasonCard({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28.w, 27.h, 28.w, 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9700),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 26.r,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 17.w),
              Expanded(
                child: Text(
                  'how_you_earned_this'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3032),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            reason,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF626262),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    final RewardFulfillmentModel? fulfillment = reward.fulfillment;
    final RewardShippingAddressModel? address = reward.shippingAddress;
    final String title = reward.status.toLowerCase() == 'delivered'
        ? 'delivery_confirmed'.tr
        : reward.status.toLowerCase() == 'dispatched'
        ? 'reward_dispatched'.tr
        : address == null
        ? 'shipping_address_required'.tr
        : 'shipping_in_progress'.tr;
    final String detail = fulfillment?.trackingNumber?.isNotEmpty == true
        ? 'Tracking: ${fulfillment!.trackingNumber}'
        : fulfillment?.carrierName?.isNotEmpty == true
        ? 'Carrier: ${fulfillment!.carrierName}'
        : address?.addressLine ??
              'add_your_delivery_information_to_continue'.tr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 22.w, 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 62.r,
            height: 62.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F3FF),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 29.r,
              color: const Color(0xFF0067A7),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3032),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF626262),
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
