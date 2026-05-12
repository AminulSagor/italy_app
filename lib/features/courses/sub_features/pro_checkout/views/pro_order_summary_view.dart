import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
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
        child: Obx(
          () {
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
              padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 60.h),
              child: Column(
                children: <Widget>[
                  ProBackHeader(
                    title: 'Order Summary',
                    onBackTap: () => Get.back<void>(),
                  ),
                  SizedBox(height: 56.h),
                  const ProHeroIllustration(),
                  SizedBox(height: 28.h),
                  Text(
                    order.headline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font34.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      height: 1.08,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    order.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  ProFeatureGrid(features: order.features),
                  SizedBox(height: 38.h),
                  ProCurrencyToggle(
                    selectedCurrency: controller.selectedCurrency.value,
                    onChanged: controller.setCurrency,
                  ),
                  SizedBox(height: 34.h),
                  ProPlanCard(
                    plan: order.plan,
                    currency: controller.selectedCurrency.value,
                    isCouponApplied: controller.isCouponApplied.value,
                  ),
                  SizedBox(height: 32.h),
                  ProCouponInput(
                    controller: controller.couponController,
                    isCouponApplied: controller.isCouponApplied.value,
                    isLoading: controller.isCouponApplying.value,
                    onApplyTap: controller.applyCoupon,
                  ),
                  SizedBox(height: 42.h),
                  CustomButton.primary(
                    text: 'Buy Full Course Now',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => controller.openCheckout(controllerTag),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(
                        fontSize: AppFont.font18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ),
                  SizedBox(height: 44.h),
                  TrustedLearnersPill(label: order.trustedLabel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
