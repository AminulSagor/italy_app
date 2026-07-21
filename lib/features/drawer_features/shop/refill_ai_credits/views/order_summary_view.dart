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
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            130.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Obx(
                    () => _summaryCard(
                  title: controller.selectedPlanTitle,
                  subtitle: controller.selectedPlanSubtitle,
                  price: controller.payablePriceText,
                  originalPrice:
                  controller.checkoutOriginalPriceText,
                  savedAmount: controller.savedAmountText,
                  isCouponApplied: controller.hasDiscount,
                ),
              ),

              SizedBox(height: 18.h),

              Obx(
                    () {
                  if (!controller.canUseCoupon) {
                    return const SizedBox.shrink();
                  }

                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ShopCouponSection(),
                      ShopCouponError(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            14.h,
            20.w,
            18.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE8ECE9),
                width: 1.w,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 18.r,
                offset: Offset(0, -5.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: CustomButton.primary(
                  text: 'continue_to_checkout'.tr,
                  onPressed: controller.buySelectedPlan,
                  btnColor: green,
                  borderRadius: 26.r,
                  btnShadowColor: darkGreen,
                ),
              ),

              SizedBox(height: 8.h),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () => Get.back(),
                  text: 'maybe_later'.tr,
                  height: 38.h,
                  showShadow: false,
                  btnColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  textColor: const Color(0xFF696969),
                ),
              ),
            ],
          ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white,
            Color(0xFFF7FFF3),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFDCECD6),
          width: 1.w,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 18.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E3),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'gen_order_summary'.tr.toUpperCase(),
              style: TextStyle(
                color: green,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textDark,
              fontSize: 20.sp,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (subtitle.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: 7.h),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted,
                fontSize: 12.5.sp,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          SizedBox(height: 18.h),

          Divider(
            height: 1.h,
            color: const Color(0xFFE4EAE5),
          ),

          SizedBox(height: 17.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    price,
                    maxLines: 1,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 28.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              if (isCouponApplied) ...<Widget>[
                SizedBox(width: 10.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    originalPrice,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF9A9E9B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 1.8.w,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 9.h),

          if (isCouponApplied)
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F3DC),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.redeem_outlined,
                        size: 13.w,
                        color: green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        savedAmount,
                        style: TextStyle(
                          color: green,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'one_time'.tr,
                  style: TextStyle(
                    color: const Color(0xFF626763),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Text(
              'one_time'.tr,
              style: TextStyle(
                color: const Color(0xFF626763),
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }




}
