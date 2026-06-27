import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';

import '../models/reward_models.dart';
import '../reward_controller.dart';
import 'reward_widgets.dart';

class RewardShippingDialog extends GetView<RewardController> {
  const RewardShippingDialog({super.key});

  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Obx(() {
          final RewardModel? reward = controller.selectedReward.value;
          final bool isLocked = reward?.shippingAddress?.isLocked ?? false;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 31.h, 24.w, 29.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(44.r),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: -5.w,
                  child: GestureDetector(
                    onTap: controller.isSavingShippingAddress.value
                        ? null
                        : Get.back,
                    child: Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20.r,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 76.r,
                      height: 76.r,
                      decoration: const BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        RewardVisuals.icon(
                          reward?.rewardType ?? RewardType.physicalPrize,
                        ),
                        size: 38.r,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 27.h),
                    Text(
                      isLocked
                          ? 'Shipping Address Locked'
                          : 'Where should we send\n${reward?.title ?? 'your reward'}?',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3032),
                        letterSpacing: -0.45,
                      ),
                    ),
                    SizedBox(height: 27.h),
                    _ShippingField(
                      controller: controller.fullNameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      enabled: !isLocked,
                    ),
                    SizedBox(height: 15.h),
                    _ShippingField(
                      controller: controller.whatsappController,
                      hint: 'WhatsApp Number',
                      icon: Icons.phone_in_talk_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !isLocked,
                    ),
                    SizedBox(height: 15.h),
                    _ShippingField(
                      controller: controller.addressController,
                      hint: 'Italian Home Address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      height: 78,
                      enabled: !isLocked,
                    ),
                    SizedBox(height: 28.h),
                    RewardPrimaryButton(
                      text: isLocked ? 'Address Locked' : 'Save Address',
                      suffixIcon: Icons.local_shipping_outlined,
                      onTap: isLocked ? null : controller.submitShippingAddress,
                      isLoading: controller.isSavingShippingAddress.value,
                    ),
                    SizedBox(height: 25.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.chat_rounded, size: 20.r, color: green),
                          SizedBox(width: 13.w),
                          Expanded(
                            child: Text(
                              isLocked
                                  ? 'The address can no longer be changed after dispatch.'
                                  : 'Our team will contact you on WhatsApp with tracking information.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ShippingField extends StatelessWidget {
  const _ShippingField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.maxLines = 1,
    this.height = 56,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.only(left: 17.w, right: 17.w),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(maxLines > 1 ? 24.r : 100.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              cursorColor: AppColors.primaryBtnColor,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3032),
              ),
              decoration: InputDecoration(
                isCollapsed: maxLines == 1,
                contentPadding: maxLines > 1
                    ? EdgeInsets.symmetric(vertical: 14.h)
                    : EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8E8E),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(icon, size: 17.r, color: const Color(0xFF777777)),
        ],
      ),
    );
  }
}
