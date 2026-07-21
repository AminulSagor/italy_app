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
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final ProOrderModel? order = controller.order.value;

          if (controller.isLoading.value && order == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (order == null) {
            return Center(
              child: Text(
                'course_information_unavailable'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ProBackHeader(
                          title: 'gen_order_summary'.tr,
                          onBackTap: () => Get.back<void>(),
                        ),
                        SizedBox(height: 18.h),

                        // Important information appears first.
                        Text(
                          order.courseName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          order.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFont.font14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.bodyText,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Price is shown near the top without the static image.
                        ProPlanCard(
                          plan: order.plan,
                          currency: controller.selectedCurrency.value,
                          isCouponApplied: order.hasCoupon,
                        ),
                        SizedBox(height: 22.h),

                        _SectionTitle(title: 'course_features'.tr),
                        SizedBox(height: 12.h),
                        ProFeatureGrid(features: order.features),
                        SizedBox(height: 24.h),

                        _SectionTitle(title: 'coupon_code'.tr),
                        SizedBox(height: 12.h),
                        ProCouponInput(
                          controller: controller.couponTextController,
                          isCouponApplied: order.hasCoupon,
                          isLoading: controller.isApplyingCoupon.value,
                          appliedCode: order.couponCode,
                          discountPercentage: order.discountPercentage,
                          pricingNote: order.pricingNote,
                          onChanged: controller.onCouponChanged,
                          onApplyTap: controller.applyCoupon,
                          onRemoveTap: controller.clearCoupon,
                        ),

                        if (controller
                            .billingError
                            .value
                            .isNotEmpty) ...<Widget>[
                          SizedBox(height: 14.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.notificationRed.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              controller.billingError.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.notificationRed,
                                fontSize: AppFont.font12.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),

      // The main action remains visible without scrolling.
      bottomNavigationBar: Obx(() {
        final ProOrderModel? order = controller.order.value;

        if (order == null) {
          return const SizedBox.shrink();
        }

        final bool isBusy =
            controller.isLoading.value ||
            controller.isApplyingCoupon.value ||
            controller.isPreparingGooglePlay.value;

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.modalBorderGrey, width: 1.w),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _BottomPriceSummary(
                      order: order,
                      currency: controller.selectedCurrency.value,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: IgnorePointer(
                      ignoring: isBusy,
                      child: CustomButton.primary(
                        text: 'buy_full_course_now',
                        icon: Icons.lock_open_rounded,
                        fontSize: AppFont.font14.sp,
                        fontWeight: FontWeight.w800,
                        isLoading: isBusy,
                        onPressed: () {
                          if (isBusy) return;

                          controller.openCheckout(controllerTag);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppFont.font18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.homePrimaryText,
        height: 1.25,
      ),
    );
  }
}

class _BottomPriceSummary extends StatelessWidget {
  const _BottomPriceSummary({required this.order, required this.currency});

  final ProOrderModel order;
  final ProCurrency currency;

  @override
  Widget build(BuildContext context) {
    final String price = currency == ProCurrency.bdt
        ? order.plan.bdtPrice
        : order.plan.eurPrice;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'total_price'.tr,
          style: TextStyle(
            fontSize: AppFont.font12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 2.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            price,
            maxLines: 1,
            style: TextStyle(
              fontSize: AppFont.font20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}
