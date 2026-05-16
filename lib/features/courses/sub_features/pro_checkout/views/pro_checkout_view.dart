import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/pro_checkout_controller.dart';
import '../models/pro_checkout_models.dart';
import '../widgets/pro_checkout_widgets.dart';
import '../widgets/pro_shared_widgets.dart';

class ProCheckoutView extends GetView<ProCheckoutController> {
  final String controllerTag;

  const ProCheckoutView({super.key, required this.controllerTag});

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
          if (order == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final bool showCurrencyToggle =
              controller.selectedPaymentMethod.value == ProPaymentMethod.card ||
              controller.selectedPaymentMethod.value == ProPaymentMethod.bkash;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 66.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProBackHeader(
                  title: 'Checkout',
                  onBackTap: () => Get.back<void>(),
                ),
                if (showCurrencyToggle) ...<Widget>[
                  SizedBox(height: 20.h),
                  ProCurrencyToggle(
                    selectedCurrency: controller.selectedCurrency.value,
                    onChanged: controller.setCurrency,
                  ),
                ],
                SizedBox(height: 20.h),
                CheckoutProductCard(
                  plan: order.plan,
                  currency: controller.selectedCurrency.value,
                  isCouponApplied: controller.isCouponApplied.value,
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Text(
                    'PAYMENT METHOD',
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                CheckoutPaymentMethodCard(
                  method: ProPaymentMethod.card,
                  isSelected:
                      controller.selectedPaymentMethod.value ==
                      ProPaymentMethod.card,
                  onTap: () =>
                      controller.selectPaymentMethod(ProPaymentMethod.card),
                ),
                SizedBox(height: 24.h),
                CheckoutPaymentMethodCard(
                  method: ProPaymentMethod.paypal,
                  isSelected:
                      controller.selectedPaymentMethod.value ==
                      ProPaymentMethod.paypal,
                  onTap: () =>
                      controller.selectPaymentMethod(ProPaymentMethod.paypal),
                ),
                SizedBox(height: 24.h),
                CheckoutPaymentMethodCard(
                  method: ProPaymentMethod.applePay,
                  isSelected:
                      controller.selectedPaymentMethod.value ==
                      ProPaymentMethod.applePay,
                  onTap: () =>
                      controller.selectPaymentMethod(ProPaymentMethod.applePay),
                ),
                SizedBox(height: 24.h),
                CheckoutPaymentMethodCard(
                  method: ProPaymentMethod.bkash,
                  isSelected:
                      controller.selectedPaymentMethod.value ==
                      ProPaymentMethod.bkash,
                  onTap: () =>
                      controller.selectPaymentMethod(ProPaymentMethod.bkash),
                ),
                SizedBox(height: 58.h),
                CustomButton.primary(
                  text: 'Complete Purchase',
                  isLoading: controller.isPurchasing.value,
                  onPressed: () => controller.completePurchase(controllerTag),
                ),
                SizedBox(height: 26.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.lock, size: 16.w, color: AppColors.bodyText),
                      SizedBox(width: 8.w),
                      Text(
                        'SECURE SSL ENCRYPTION',
                        style: TextStyle(
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
