import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../shop_controller.dart';

class CvCreditOrderSummaryView extends GetView<ShopController> {
  const CvCreditOrderSummaryView({super.key});

  static const Color _bg = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 54.h),
          child: Column(
            children: <Widget>[
              const _SummaryTopBar(),
              SizedBox(height: 40.h),
              const _CurrencyToggle(),
              SizedBox(height: 32.h),
              const _SelectedCvPackCard(),
              SizedBox(height: 34.h),
              const _CouponSection(),
              SizedBox(height: 54.h),
              const _BuyButton(),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: Get.back,
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
              SizedBox(height: 54.h),
              const _TrustedLearnersPill(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTopBar extends StatelessWidget {
  const _SummaryTopBar();

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Icon(Icons.arrow_back_rounded, size: 24.r, color: _green),
            ),
          ),
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyToggle extends GetView<ShopController> {
  const _CurrencyToggle();

  static const Color _green = Color(0xFF267A05);
  static const Color _toggleBg = Color(0xFFE0E1E1);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 46.h,
        width: double.infinity,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: _toggleBg,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          children: <Widget>[
            _CurrencyItem(
              title: 'gen_eur'.tr.tr,
              selected: controller.selectedCurrency.value == RefillCurrency.eur,
              onTap: () => controller.selectCurrency(RefillCurrency.eur),
            ),
            _CurrencyItem(
              title: 'gen_bdt'.tr.tr,
              selected: controller.selectedCurrency.value == RefillCurrency.bdt,
              onTap: () => controller.selectCurrency(RefillCurrency.bdt),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 5.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: selected ? _green : const Color(0xFF5D6164),
            ),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 320.h,
        padding: EdgeInsets.fromLTRB(28.w, 56.h, 28.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 40.r,
              spreadRadius: 4.r,
              offset: Offset(0, 24.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 96.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Icon(
                controller.selectedCvCreditOffer.icon,
                size: 34.r,
                color: _brown,
              ),
            ),
            const Spacer(),
            Text(
              controller.selectedCvCreditOffer.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 25.sp,
                height: 1.12,
                fontWeight: FontWeight.w900,
                color: _text,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              controller.selectedCvCreditOfferSummary,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
            SizedBox(height: 36.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (controller.isCouponApplied.value) ...<Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.h),
                    child: Text(
                      controller.cvCreditOriginalPriceText,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB8B8B8),
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Text(
                  controller.cvCreditPayablePriceText,
                  style: TextStyle(
                    fontSize: 38.sp,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    color: _green,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponSection extends GetView<ShopController> {
  const _CouponSection();

  static const Color _green = Color(0xFF267A05);
  static const Color _greenLight = Color(0xFFD4E8CC);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool applied = controller.isCouponApplied.value;

      if (applied) {
        return Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 64.h,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(34.r),
                  border: Border.all(color: _greenLight, width: 2.w),
                ),
                child: Text(
                  controller.couponCode.value.isEmpty
                      ? 'WELCOME10'
                      : controller.couponCode.value.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3032),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: controller.clearCoupon,
              child: Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _green, width: 3.w),
                ),
                child: Icon(Icons.check_rounded, size: 24.r, color: _green),
              ),
            ),
          ],
        );
      }

      return Column(
        children: <Widget>[
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34.r),
              border: Border.all(color: const Color(0xFFE0E1E1), width: 1.5.w),
            ),
            child: TextField(
              controller: controller.couponTextController,
              onChanged: controller.onCouponChanged,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'gen_enter_coupon_code'.tr.tr,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB0B0B0),
                ),
              ),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D3032),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: controller.applyCoupon,
            child: Container(
              height: 64.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34.r),
                border: Border.all(color: _green, width: 2.4.w),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _green,
                    blurRadius: 0,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Text(
                'APPLY',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: _green,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _BuyButton extends GetView<ShopController> {
  const _BuyButton();

  static const Color _green = Color(0xFF267A05);
  static const Color _greenDark = Color(0xFF174F00);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isCheckoutLoading.value
            ? null
            : controller.confirmCvCreditPurchase,
        child: Container(
          height: 70.h,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _greenDark,
                blurRadius: 0,
                offset: Offset(0, 7.h),
              ),
            ],
          ),
          child: controller.isCheckoutLoading.value
              ? SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Buy CV Credits Now',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.25,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 24.r,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TrustedLearnersPill extends StatelessWidget {
  const _TrustedLearnersPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.fromLTRB(18.w, 5.h, 18.w, 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 56.w,
            height: 28.h,
            child: Stack(
              children: <Widget>[
                _AvatarDot(left: 0.w, color: const Color(0xFF1E2528)),
                _AvatarDot(left: 16.w, color: const Color(0xFFCED6D8)),
                _AvatarDot(left: 32.w, color: const Color(0xFF123A45)),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'TRUSTED BY 5K+ LEARNERS',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  final double left;
  final Color color;

  const _AvatarDot({required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: Icon(Icons.person, size: 14.r, color: Colors.white),
      ),
    );
  }
}
