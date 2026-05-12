import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        insetPadding: EdgeInsets.symmetric(horizontal: 46.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(32.w, 33.h, 32.w, 33.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(44.r),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                top: 1.h,
                right: -8.w,
                child: GestureDetector(
                  onTap: Get.back,
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
                      Icons.tablet_android_rounded,
                      size: 38.r,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Text(
                    'Where should we send\nyour Tablet?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3032),
                      letterSpacing: -0.45,
                    ),
                  ),

                  SizedBox(height: 31.h),

                  _ShippingField(
                    controller: controller.fullNameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  SizedBox(height: 17.h),
                  _ShippingField(
                    controller: controller.whatsappController,
                    hint: 'Whatsapp Number',
                    icon: Icons.phone_in_talk_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 17.h),
                  _ShippingField(
                    controller: controller.addressController,
                    hint: 'Italian Home Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    height: 104,
                  ),

                  SizedBox(height: 32.h),

                  RewardPrimaryButton(
                    text: 'Confirm Delivery',
                    onTap: controller.confirmDelivery,
                  ),

                  SizedBox(height: 34.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18.w, 17.h, 18.w, 17.h),
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
                            'Our team will contact you on\nWhatsApp to confirm tracking info.',
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
        ),
      ),
    );
  }
}

class _ShippingField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final double height;

  const _ShippingField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: const Color(0xFF267A05),
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3032),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E8E8E),
          ),
          border: InputBorder.none,
          suffixIcon: Icon(icon, size: 17.r, color: const Color(0xFF777777)),
          contentPadding: EdgeInsets.only(top: maxLines == 1 ? 16.h : 18.h),
        ),
      ),
    );
  }
}
