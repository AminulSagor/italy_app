import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';

class ShopCouponSection extends GetView<ShopController> {
  const ShopCouponSection({super.key});

  static const Color _green = AppColors.primaryGreen;
  static const Color _textDark = AppColors.black;
  static const Color _bodyText = AppColors.bodyText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool applied = controller.isCouponApplied.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: applied
            ? _AppliedCouponField(
                key: const ValueKey<String>('shop-applied-coupon'),
                couponCode: controller.couponCode.value,
                onTap: () => _showAppliedCouponDialog(context),
              )
            : _CouponEntryField(
                key: const ValueKey<String>('shop-coupon-entry'),
                controller: controller.couponTextController,
                isLoading: controller.isLoadingQuote.value,
                onChanged: controller.onCouponChanged,
                onApplyTap: controller.applyCoupon,
              ),
      );
    });
  }

  void _showAppliedCouponDialog(BuildContext context) {
    final StoreQuotePricingModel? pricing = controller.pricing;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9FFDF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Coupon applied',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  controller.couponCode.value,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                if ((pricing?.discountPercentage ?? 0) > 0) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Discount: ${pricing!.discountPercentage}%',
                    style: const TextStyle(
                      color: _bodyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Text(
                  'Final price is controlled by Google Play/App Store and may include VAT, tax, currency conversion, or regional pricing.',
                  style: TextStyle(
                    color: _bodyText,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      controller.clearCoupon();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.notificationRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Remove coupon',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShopCouponError extends GetView<ShopController> {
  const ShopCouponError({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.checkoutError.value.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          controller.checkoutError.value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.notificationRed,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    });
  }
}

class _CouponEntryField extends StatelessWidget {
  const _CouponEntryField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onChanged,
    required this.onApplyTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onApplyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 58,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textCapitalization: TextCapitalization.characters,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: ShopCouponSection._textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'gen_enter_coupon_code'.tr,
              hintStyle: const TextStyle(
                color: Color(0xFFB7B9BB),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 22),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Color(0xFFD4D6D7),
                  width: 1.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: ShopCouponSection._green,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton(
            onPressed: isLoading ? null : onApplyTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: ShopCouponSection._green,
              side: const BorderSide(
                color: ShopCouponSection._green,
                width: 2,
              ),
              shape: const StadiumBorder(),
              disabledForegroundColor: ShopCouponSection._bodyText,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ShopCouponSection._green,
                    ),
                  )
                : Text(
                    'apply'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _AppliedCouponField extends StatelessWidget {
  const _AppliedCouponField({
    super.key,
    required this.couponCode,
    required this.onTap,
  });

  final String couponCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 58,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4EF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: ShopCouponSection._green.withValues(alpha: 0.28),
                width: 1.4,
              ),
            ),
            child: Text(
              couponCode.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ShopCouponSection._textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: ShopCouponSection._green, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: ShopCouponSection._green,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
