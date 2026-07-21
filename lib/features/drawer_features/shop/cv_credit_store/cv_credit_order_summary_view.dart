import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../shop_controller.dart';
import '../widgets/shop_coupon_section.dart';

class CvCreditOrderSummaryView extends GetView<ShopController> {
  const CvCreditOrderSummaryView({super.key});

  static const Color _background = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: const _SummaryTopBar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'review_your_order'.tr,
                      style: TextStyle(
                        fontSize: 24.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D3032),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'confirm_package_before_checkout'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 22.h),

                    const _SelectedCvPackCard(),

                    SizedBox(height: 20.h),

                    Obx(
                          () => controller.canUseCoupon
                          ? Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: <Widget>[
                          const _SectionTitle(
                            titleKey: 'coupon_code',
                            icon:
                            Icons.local_offer_outlined,
                          ),

                          SizedBox(height: 10.h),

                          const ShopCouponSection(),


                        ],
                      )
                          : const SizedBox.shrink(),
                    ),

                    SizedBox(height: 20.h),

                    const _PurchaseInformationCard(),

                    SizedBox(height: 12.h),

                    Center(
                      child: TextButton(
                        onPressed: Get.back,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF666666),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          'change_package'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _CheckoutBottomBar(),
    );
  }
}

class _SummaryTopBar extends StatelessWidget {
  const _SummaryTopBar();

  static const Color _green = Color(0xFF267A05);
  static const Color _text = Color(0xFF2D3032);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: Get.back,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 42.r,
                height: 42.r,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22.r,
                  color: _green,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'gen_order_summary'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(width: 42.r),
        ],
      ),
    );
  }
}

class _SelectedCvPackCard extends GetView<ShopController> {
  const _SelectedCvPackCard();

  static const Color _green = Color(0xFF267A05);
  static const Color _brown = Color(0xFF9B5B00);
  static const Color _cream = Color(0xFFFFF2DA);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);
  static const Color _border = Color(0xFFE7E7E7);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedOffer = controller.selectedCvCreditOffer;
      final bool hasBadge = selectedOffer.badgeLabel.trim().isNotEmpty;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: _border,
            width: 1.w,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    selectedOffer.isMonthly
                        ? Icons.all_inclusive_rounded
                        : Icons.history_edu_rounded,
                    size: 27.r,
                    color: _brown,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (hasBadge) ...<Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            selectedOffer.badgeLabel.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: _brown,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 7.h),
                      ],
                      Text(
                        selectedOffer.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        controller.selectedCvCreditOfferSummary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: _border,
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'total_price'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                ),
                if (controller.hasDiscount) ...<Widget>[
                  Flexible(
                    child: Text(
                      controller.cvCreditOriginalPriceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF999999),
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    controller.cvCreditPayablePriceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: _green,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            if (selectedOffer.isMonthly) ...<Widget>[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F8EF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.autorenew_rounded,
                      size: 18.r,
                      color: _green,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'subscription_renews_automatically'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.titleKey,
    required this.icon,
  });

  final String titleKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 19.r,
          color: const Color(0xFF2D3032),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            titleKey.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D3032),
            ),
          ),
        ),
      ],
    );
  }
}

class _PurchaseInformationCard extends GetView<ShopController> {
  const _PurchaseInformationCard();

  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);
  static const Color _border = Color(0xFFE7E7E7);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isMonthly =
          controller.selectedCvCreditOffer.isMonthly;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: _border,
            width: 1.w,
          ),
        ),
        child: Column(
          children: <Widget>[
            _InformationRow(
              icon: Icons.verified_user_outlined,
              title: 'secure_payment'.tr,
              description: 'payment_processed_securely'.tr,
            ),
            SizedBox(height: 14.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: _border,
            ),
            SizedBox(height: 14.h),
            _InformationRow(
              icon: isMonthly
                  ? Icons.event_repeat_rounded
                  : Icons.check_circle_outline_rounded,
              title: isMonthly
                  ? 'recurring_purchase'.tr
                  : 'one_time_purchase'.tr,
              description: isMonthly
                  ? 'cancel_subscription_anytime'.tr
                  : 'you_will_only_be_charged_once'.tr,
            ),
          ],
        ),
      );
    });
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F8EF),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            size: 19.r,
            color: const Color(0xFF267A05),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3032),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends GetView<ShopController> {
  const _CheckoutBottomBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18.r,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: Obx(
              () => _BuyButton(
            isLoading: controller.isCheckoutLoading.value,
            onTap: controller.confirmCvCreditPurchase,
          ),
        ),
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _green,
          disabledBackgroundColor: _green.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? SizedBox(
            key: const ValueKey<String>('loading'),
            width: 22.r,
            height: 22.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
              : Row(
            key: const ValueKey<String>('button'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'continue_to_checkout'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}