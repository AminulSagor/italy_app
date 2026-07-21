import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/themes/app_font.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import '../shop_controller.dart';
import '../widgets/shop_coupon_section.dart';

class StreakOrderSummaryView extends GetView<ShopController> {
  const StreakOrderSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const _OrderTopBar(),

      // Keeps the main purchase action visible and easy to reach.
      bottomNavigationBar: const _BottomPurchaseBar(),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
          child: Column(
            children: <Widget>[
              const _SelectedPackCard(),
              SizedBox(height: 20.h),
              Obx(
                    () => controller.canUseCoupon
                    ? const Column(
                  children: <Widget>[
                    ShopCouponSection(),
                    ShopCouponError(),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
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
  Size get preferredSize => Size.fromHeight(82.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () => Get.back<void>(),
                borderRadius: BorderRadius.circular(22.r),
                child: SizedBox(
                  width: 44.r,
                  height: 44.r,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22.r,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'gen_order_summary'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Balances the back-button width so the title stays centered.
              SizedBox(width: 44.r),
            ],
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
    return Obx(() {
      final bool isUnlimited =
          controller.selectedStreakPackage?.isUnlimitedStreak ?? false;

      final String packageTitle =
      controller.selectedStreakFreezePackTitle.trim();

      final String packageSummary = isUnlimited
          ? 'unlimited_protection'.tr
          : 'streak_freeze_pack_count'.trParams(
        <String, String>{
          'count': controller.selectedStreakFreezeCount.toString(),
        },
      );

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 220.h),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 22.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 76.r,
              height: 76.r,
              decoration: BoxDecoration(
                color: AppColors.blockSuccessBlueBg,
                shape: BoxShape.circle,
              ),
              child: _PackIcon(
                isUnlimited: isUnlimited,
                count:
                controller
                    .selectedStreakFreezeCount,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              packageTitle.isEmpty ? 'streak_freeze'.tr : packageTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: AppColors.headerText,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              packageSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 18.h),
            _PriceLine(isCouponApplied: controller.hasDiscount),
          ],
        ),
      );
    });
  }
}

class _PackIcon extends StatelessWidget {
  const _PackIcon({
    required this.isUnlimited,
    required this.count,
  });

  final bool isUnlimited;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (isUnlimited) {
      return Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: <Widget>[
          Icon(
            Icons.ac_unit_rounded,

            size: 27.r,

            color: AppColors
                .blockSuccessBlueText,
          ),

          Text(
            '∞',

            style: TextStyle(
              fontSize: 26.sp,

              fontWeight:
              FontWeight.w900,

              height: 0.75,

              color: AppColors
                  .blockSuccessBlueText,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: <Widget>[
        Icon(
          Icons.ac_unit_rounded,

          size: 31.r,

          color: AppColors
              .blockSuccessBlueText,
        ),

        SizedBox(height: 2.h),

        Text(
          '×$count',

          style: TextStyle(
            fontSize:
            AppFont.font14.sp,

            fontWeight:
            FontWeight.w900,

            color: AppColors
                .blockSuccessBlueText,
          ),
        ),
      ],
    );
  }
}

class _PriceLine extends GetView<ShopController> {
  const _PriceLine({
    required this.isCouponApplied,
  });

  final bool isCouponApplied;

  @override
  Widget build(BuildContext context) {
    if (!isCouponApplied) {
      return SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            controller.streakFreezePayablePriceText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              height: 1.05,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10.w,
      runSpacing: 7.h,
      children: <Widget>[
        Text(
          controller.streakFreezeOriginalPriceText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.font17.sp,
            fontWeight: FontWeight.w900,
            height: 1.25,
            color: AppColors.bodyText.withValues(alpha: 0.5),
            decoration: TextDecoration.lineThrough,
            decorationColor:
            AppColors.bodyText.withValues(alpha: 0.5),
            decorationThickness: 2,
          ),
        ),
        Text(
          controller.streakFreezePayablePriceText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _BottomPurchaseBar extends GetView<ShopController> {
  const _BottomPurchaseBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Obx(
                    () => CustomButton.primary(
                  text: 'continue_to_checkout'.tr,
                  icon: Icons.arrow_forward_rounded,
                  isLoading: controller.isCheckoutLoading.value,
                  onPressed: controller.isCheckoutLoading.value
                      ? () {}
                      : controller.confirmStreakFreezePurchase,
                ),
              ),
              SizedBox(height: 6.h),
              TextButton(
                onPressed: () => Get.back<void>(),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 42.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'maybe_later'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bodyText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
