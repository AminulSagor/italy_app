import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../drawer_features/shop/widgets/app_store_subscription_disclosure.dart';
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 66.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProBackHeader(
                  title: 'gen_checkout'.tr,
                  onBackTap: () => Get.back<void>(),
                ),
                SizedBox(height: 20.h),
                CheckoutProductCard(
                  courseName: order.courseName,
                  lessonCount: order.lessonCount,
                  plan: order.plan,
                  currency: controller.selectedCurrency.value,
                  isCouponApplied: order.hasCoupon,
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Text(
                    order.storeProduct.accessType == 'time_limited'
                        ? 'time_limited_course_access'.trParams(<
                            String,
                            String
                          >{'days': order.storeProduct.durationDays.toString()})
                        : 'lifetime_course_access'.tr,
                    style: TextStyle(
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Text(
                    'payment_method'.tr,
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
                  method: Platform.isIOS
                      ? ProPaymentMethod.appStore
                      : ProPaymentMethod.googlePlay,
                  isSelected: true,
                  onTap: () => controller.selectPaymentMethod(
                    Platform.isIOS
                        ? ProPaymentMethod.appStore
                        : ProPaymentMethod.googlePlay,
                  ),
                ),
                if (controller.isAppStoreSubscription) ...<Widget>[
                  SizedBox(height: 24.h),
                  AppStoreSubscriptionDisclosure(
                    title: controller.appStoreSubscriptionTitle,
                    price: controller.appStoreSubscriptionPrice,
                    billingDuration:
                        controller.appStoreSubscriptionBillingDuration,
                    isRestoring: controller.isRestoringSubscription.value,
                    isAutoRenewing: false,
                    onRestore: () =>
                        controller.restoreAppStorePurchase(controllerTag),
                  ),
                ],
                if (Platform.isIOS &&
                    controller.isAppStorePurchase &&
                    !controller.isAppStoreSubscription) ...<Widget>[
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton.icon(
                      onPressed: controller.isRestoringSubscription.value
                          ? null
                          : () => controller.restoreAppStorePurchase(
                              controllerTag,
                            ),
                      icon: controller.isRestoringSubscription.value
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore_rounded),
                      label: Text(
                        controller.isRestoringSubscription.value
                            ? 'restoring_purchases'.tr
                            : 'restore_purchases'.tr,
                      ),
                    ),
                  ),
                ],
                if (controller.billingError.value.isNotEmpty) ...<Widget>[
                  SizedBox(height: 26.h),
                  Text(
                    controller.billingError.value,
                    style: TextStyle(
                      color: AppColors.notificationRed,
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(height: 36.h),
                CustomButton.primary(
                  text: controller.hasAppStoreSubscriptionPrice
                      ? 'complete_purchase'.tr
                      : 'loading_app_store_price'.tr,
                  isLoading: controller.isPurchasing.value,
                  onPressed: controller.hasAppStoreSubscriptionPrice
                      ? () => controller.completePurchase(controllerTag)
                      : () {},
                ),
                SizedBox(height: 26.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.lock, size: 16.w, color: AppColors.bodyText),
                      SizedBox(width: 8.w),
                      Text(
                        'secure_ssl_encryption'.tr,
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
