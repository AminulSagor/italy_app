import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/themes/app_constants.dart';
import 'package:italir_pothe/core/themes/app_font.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import '../models/shop_models.dart';
import '../shop_controller.dart';

class StreakOrderSummaryView extends GetView<ShopController> {
  const StreakOrderSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const _OrderTopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 42.h),
          child: Column(
            children: <Widget>[
              const _CurrencySwitch(),
              SizedBox(height: 32.h),
              const _SelectedPackCard(),
              SizedBox(height: 33.h),
              const _CouponArea(),
              SizedBox(height: 52.h),
              Obx(
                () => CustomButton.primary(
                  text: 'Continue to Checkout',
                  icon: Icons.play_arrow_rounded,
                  isLoading: controller.isCheckoutLoading.value,
                  onPressed: controller.confirmStreakFreezePurchase,
                ),
              ),
              SizedBox(height: 23.h),
              TextButton(
                onPressed: Get.back,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              SizedBox(height: 42.h),
              const _TrustedBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _OrderTopBar();

  @override
  Size get preferredSize => Size.fromHeight(104.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 17.h),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: Get.back,
                  child: SizedBox(
                    width: 48.r,
                    height: 48.r,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 23.r,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              Text(
                'Order Summary',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySwitch extends GetView<ShopController> {
  const _CurrencySwitch();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 45.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.legacyColorFFE0E1E1,
          borderRadius: BorderRadius.circular(kRadius60.r),
        ),
        child: Row(
          children: <Widget>[
            _CurrencyPill(
              label: 'EUR',
              selected: controller.selectedCurrency.value == RefillCurrency.eur,
              onTap: () => controller.selectCurrency(RefillCurrency.eur),
            ),
            _CurrencyPill(
              label: 'BDT',
              selected: controller.selectedCurrency.value == RefillCurrency.bdt,
              onTap: () => controller.selectCurrency(RefillCurrency.bdt),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(kRadius60.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w900,
              color: selected ? AppColors.primaryGreen : AppColors.bodyText,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedPackCard extends GetView<ShopController> {
  const _SelectedPackCard();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 319.h,
        padding: EdgeInsets.fromLTRB(24.w, 31.h, 24.w, 28.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(44.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 40.r,
              spreadRadius: 8.r,
              offset: Offset(0, 25.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: AppColors.blockSuccessBlueBg,
                shape: BoxShape.circle,
              ),
              child: const _TripleSnowIcon(),
            ),
            SizedBox(height: 28.h),
            Text(
              _packTitle(controller.selectedStreakFreezePackTitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font24.sp,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: -0.6,
                color: AppColors.headerText,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '${controller.selectedStreakFreezeCount}× Streak Freezes | Instant Activation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font15.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 32.h),
            _PriceLine(isCouponApplied: controller.isCouponApplied.value),
          ],
        ),
      ),
    );
  }

  String _packTitle(String title) {
    if (title.toLowerCase().contains('pack')) return title;
    return '$title Pack';
  }
}

class _TripleSnowIcon extends StatelessWidget {
  const _TripleSnowIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: 23.h,
          child: Icon(
            Icons.ac_unit_rounded,
            size: 34.r,
            color: AppColors.blockSuccessBlueText,
          ),
        ),
        Positioned(
          left: 24.w,
          top: 41.h,
          child: Icon(
            Icons.ac_unit_rounded,
            size: 27.r,
            color: AppColors.blockSuccessBlueText,
          ),
        ),
        Positioned(
          right: 24.w,
          top: 41.h,
          child: Icon(
            Icons.ac_unit_rounded,
            size: 27.r,
            color: AppColors.blockSuccessBlueText,
          ),
        ),
      ],
    );
  }
}

class _PriceLine extends GetView<ShopController> {
  final bool isCouponApplied;

  const _PriceLine({required this.isCouponApplied});

  @override
  Widget build(BuildContext context) {
    if (!isCouponApplied) {
      return Text(
        controller.streakFreezePayablePriceText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 38.sp,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: -1.1,
          color: AppColors.primaryGreen,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          controller.streakFreezeOriginalPriceText,
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w900,
            height: 1.25,
            color: AppColors.bodyText.withValues(alpha: 0.5),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.bodyText.withValues(alpha: 0.5),
            decorationThickness: 2.2,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          controller.streakFreezePayablePriceText,
          style: TextStyle(
            fontSize: 38.sp,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -1.1,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _CouponArea extends GetView<ShopController> {
  const _CouponArea();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCouponApplied.value) {
        return Row(
          children: <Widget>[
            Expanded(
              child: _CouponField(
                enabled: false,
                showAppliedBorder: true,
                hintText: 'gen_welcome10'.tr.tr,
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: controller.applyCoupon,
              child: Container(
                width: 82.w,
                height: 68.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kRadius30.r),
                  border: Border.all(color: AppColors.primaryGreen, width: 2.w),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.95),
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 24.r,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        children: <Widget>[
          _CouponField(
            enabled: true,
            showAppliedBorder: false,
            hintText: 'Enter Coupon Code',
          ),
          SizedBox(height: 13.h),
          GestureDetector(
            onTap: controller.applyCoupon,
            child: Container(
              width: double.infinity,
              height: 64.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(kRadius30.r),
                border: Border.all(color: AppColors.primaryGreen, width: 2.w),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.95),
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Text(
                'APPLY',
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CouponField extends GetView<ShopController> {
  final bool enabled;
  final bool showAppliedBorder;
  final String hintText;

  const _CouponField({
    required this.enabled,
    required this.showAppliedBorder,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: showAppliedBorder ? AppColors.safetyBlockedBg : AppColors.white,
        borderRadius: BorderRadius.circular(kRadius30.r),
        border: Border.all(
          color: showAppliedBorder
              ? AppColors.safetyBlockedBorder
              : AppColors.legacyColorFFE0E1E1,
          width: showAppliedBorder ? 2.w : 1.5.w,
        ),
      ),
      child: enabled
          ? TextField(
              controller: controller.couponTextController,
              onChanged: controller.onCouponChanged,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText.withValues(alpha: 0.48),
                ),
              ),
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.headerText,
              ),
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.couponTextController.text.trim().isEmpty
                    ? hintText
                    : controller.couponTextController.text.trim().toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.headerText,
                ),
              ),
            ),
    );
  }
}

class _TrustedBadge extends StatelessWidget {
  const _TrustedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37.h,
      padding: EdgeInsets.only(left: 18.w, right: 18.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(kRadius60.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 53.w,
            height: 24.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                _AvatarDot(left: 0.w, label: '👨'.tr),
                _AvatarDot(left: 14.w, label: '👩'.tr),
                _AvatarDot(left: 28.w, label: '🧑'.tr),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'TRUSTED BY 5K+ LEARNERS',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  final double left;
  final String label;

  const _AvatarDot({required this.left, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 24.r,
        height: 24.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.headerText,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 1.5.w),
        ),
        child: Text(label, style: TextStyle(fontSize: 12.sp)),
      ),
    );
  }
}
