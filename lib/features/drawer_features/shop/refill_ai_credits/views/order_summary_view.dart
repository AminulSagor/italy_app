import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import 'package:italir_pothe/core/widgets/custom_button.dart';
import 'package:italir_pothe/core/widgets/simple_appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/shop_models.dart';
import '../../shop_controller.dart';
import '../../widgets/shop_coupon_section.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({super.key});

  static const Color bg = AppColors.scaffoldBackground;
  static const Color green = AppColors.primaryGreen;
  static const Color darkGreen = AppColors.primaryBtnShadow;
  static const Color textDark = AppColors.black;
  static const Color muted = AppColors.bodyText;

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: SimpleAppbar(
        title: 'gen_order_summary'.tr,
        onBackTap: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 28.h),

                      Obx(
                        () => _currencySwitcher(
                          selectedCurrency: controller.selectedCurrency.value,
                          enabled: controller.canChangeCurrency,
                          onEurTap: () =>
                              controller.selectCurrency(RefillCurrency.eur),
                          onBdtTap: () =>
                              controller.selectCurrency(RefillCurrency.bdt),
                        ),
                      ),

                      SizedBox(height: 34.h),

                      Obx(
                        () => _summaryCard(
                          title: controller.selectedPlanTitle,
                          subtitle: controller.selectedPlanSubtitle,
                          price: controller.payablePriceText,
                          originalPrice: controller.checkoutOriginalPriceText,
                          savedAmount: controller.savedAmountText,
                          isCouponApplied: controller.hasDiscount,
                        ),
                      ),

                      SizedBox(height: 26.h),

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

                      SizedBox(height: 34.h),

                      CustomButton.primary(
                        text: 'continue_to_checkout'.tr,
                        onPressed: controller.buySelectedPlan,
                        btnColor: green,
                        borderRadius: 30,
                        btnShadowColor: darkGreen,
                      ),

                      SizedBox(height: 24.h),

                      CustomButton(
                        onPressed: () => Get.back(),
                        text: 'maybe_later'.tr,
                        height: 44,
                        showShadow: false,
                        btnColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        textColor: const Color(0xFF696969),
                      ),

                      SizedBox(height: 46.h),
                      _trustedLearners(),
                      SizedBox(height: 58.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _currencySwitcher({
    required RefillCurrency selectedCurrency,
    required bool enabled,
    required VoidCallback onEurTap,
    required VoidCallback onBdtTap,
  }) {
    final bool isEur = selectedCurrency == RefillCurrency.eur;

    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.6,
        child: Container(
          height: 42.h,
          width: double.infinity,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFDADCDC),
            borderRadius: BorderRadius.circular(26.r),
          ),
          child: Row(
            children: [
          Expanded(
            child: GestureDetector(
              onTap: onEurTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isEur ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    'gen_eur'.tr,
                    style: TextStyle(
                      color: isEur ? green : const Color(0xFF666A6D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onBdtTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !isEur ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    'gen_bdt'.tr,
                    style: TextStyle(
                      color: !isEur ? green : const Color(0xFF666A6D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String subtitle,
    required String price,
    required String originalPrice,
    required String savedAmount,
    required bool isCouponApplied,
  }) {
    return Container(
      width: double.infinity,
      height: 240.h,
      padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, 28.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.topRight,
          colors: [Colors.white, Colors.white, Color(0xFFE4FFDA)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'gen_order_summary'.tr,
            style: TextStyle(
              color: green,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textDark,
              fontSize: 25.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 39.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              if (!isCouponApplied) ...[
                SizedBox(width: 6.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    'one_time'.tr,
                    style: TextStyle(
                      color: const Color(0xFF575A60),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (isCouponApplied) ...[
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Text(
                    originalPrice,
                    style: TextStyle(
                      color: const Color(0xFFA0A0A0),
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 2.w,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (isCouponApplied) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  height: 18.h,
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F3DC),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.redeem_outlined,
                        size: 11.w,
                        color: green,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        savedAmount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: green,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'one_time'.tr,
                  style: TextStyle(
                    color: const Color(0xFF575A60),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _trustedLearners() {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56.w,
            height: 24.r,
            child: Stack(
              children: [
                _avatar(left: 0, color: const Color(0xFF111111), text: '👤'),
                _avatar(left: 16, color: const Color(0xFFD7F1FF), text: '🎓'),
                _avatar(left: 32, color: const Color(0xFF253647), text: '👥'),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'trusted_by_5k_learners'.tr,
            style: TextStyle(
              color: Color(0xFF5B5E63),
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar({
    required double left,
    required Color color,
    required String text,
  }) {
    return Positioned(
      left: left.w,
      child: Container(
        height: 24.r,
        width: 24.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 10.sp)),
        ),
      ),
    );
  }
}
