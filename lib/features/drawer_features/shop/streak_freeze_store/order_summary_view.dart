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
              SizedBox(height: 52.h),
              Obx(
                () => CustomButton.primary(
                  text: 'continue_to_checkout'.tr,
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
                  'maybe_later'.tr,
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
                'gen_order_summary'.tr,
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
      () => IgnorePointer(
        ignoring: !controller.canChangeCurrency,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: controller.canChangeCurrency ? 1 : 0.6,
          child: Container(
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
                  label: 'gen_eur'.tr,
                  selected:
                      controller.selectedCurrency.value == RefillCurrency.eur,
                  onTap: () => controller.selectCurrency(RefillCurrency.eur),
                ),
                _CurrencyPill(
                  label: 'gen_bdt'.tr,
                  selected:
                      controller.selectedCurrency.value == RefillCurrency.bdt,
                  onTap: () => controller.selectCurrency(RefillCurrency.bdt),
                ),
              ],
            ),
          ),
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
              '${controller.selectedStreakFreezeCount}x ${'streak_freezes'.tr}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font15.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 32.h),
            _PriceLine(isCouponApplied: controller.hasDiscount),
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
            'trusted_by_5k_learners'.tr,
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
