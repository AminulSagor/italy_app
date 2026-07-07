import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/pro_checkout_controller.dart';
import '../models/pro_checkout_models.dart';
import '../widgets/pro_order_widgets.dart';
import '../widgets/pro_shared_widgets.dart';

class ProOrderSummaryView extends GetView<ProCheckoutController> {
  final String controllerTag;

  const ProOrderSummaryView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coursesDetailBg,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final ProOrderModel? order = controller.order.value;
          if (controller.isLoading.value && order == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (order == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 60.h),
            child: Column(
              children: <Widget>[
                ProBackHeader(
                  title: 'gen_order_summary'.tr,
                  onBackTap: () => Get.back<void>(),
                ),
                SizedBox(height: 10.h),
                Image.asset('assets/decor_png/order_summary.png'),
                Text(
                  order.headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font34.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    height: 1.08,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  order.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.bodyText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 30.h),
                ProFeatureGrid(features: order.features),
                ProPlanCard(
                  plan: order.plan,
                  currency: controller.selectedCurrency.value,
                  isCouponApplied: order.hasCoupon,
                ),
                SizedBox(height: 26.h),
                ProCouponInput(
                  controller: controller.couponTextController,
                  isCouponApplied: order.hasCoupon,
                  isLoading: controller.isApplyingCoupon.value ||
                      controller.isPreparingGooglePlay.value,
                  appliedCode: order.couponCode,
                  discountPercentage: order.discountPercentage,
                  pricingNote: order.pricingNote,
                  onChanged: controller.onCouponChanged,
                  onApplyTap: controller.applyCoupon,
                  onRemoveTap: controller.clearCoupon,
                ),
                if (controller.billingError.value.isNotEmpty) ...<Widget>[
                  SizedBox(height: 12.h),
                  Text(
                    controller.billingError.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.notificationRed,
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(height: 42.h),
                CustomButton.primary(
                  text: 'buy_full_course_now'.tr,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => controller.openCheckout(controllerTag),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () => Get.back<void>(),
                  child: Text(
                    'maybe_later'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                SizedBox(height: 44.h),
                TrustedLearnersPill(label: order.trustedLabel),
              ],
            ),
          );
        }),
      ),
    );
  }
}
