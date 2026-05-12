import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../shop_controller.dart';

class CvCreditStoreView extends GetView<ShopController> {
  const CvCreditStoreView({super.key});

  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 56.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _TopBar(),
              SizedBox(height: 48.h),

              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'CV Credit Store',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: _text,
                        letterSpacing: -1.1,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Never pause your career growth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 34.h),
              const _InventoryCard(),
              SizedBox(height: 32.h),

              Obx(
                () => Column(
                  children: controller.cvCreditOffers
                      .map(
                        (offer) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _CvCreditOfferCard(offer: offer),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: 84.h),
              _ConfirmButton(onTap: controller.goToCvCreditOrderSummary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _blue = Color(0xFF005A94);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_rounded, size: 24.r, color: _blue),
              ),
            ),
          ),
          Text(
            'CV Credit Refiller',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _brown,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends GetView<ShopController> {
  const _InventoryCard();

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _cream = Color(0xFFFFF2DA);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 142.h,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 28.w, 24.h),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOUR INVENTORY',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    color: _brown,
                  ),
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => Text(
                    '${controller.cvCreditBalance.value} CV Credit${controller.cvCreditBalance.value == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 30.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: _brown,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 76.r,
            height: 76.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 20.r,
                  offset: Offset(0, 12.h),
                ),
              ],
            ),
            child: Icon(Icons.history_edu_rounded, size: 34.r, color: _brown),
          ),
        ],
      ),
    );
  }
}

class _CvCreditOfferCard extends GetView<ShopController> {
  final CvCreditOffer offer;

  const _CvCreditOfferCard({required this.offer});

  static const Color _brown = Color(0xFF9B5B00);
  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF666666);
  static const Color _cream = Color(0xFFFFF2DA);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool selected = controller.isCvCreditOfferSelected(offer.id);
      final bool isBestValue = offer.badge.isNotEmpty;

      return GestureDetector(
        onTap: () => controller.selectCvCreditOffer(offer.id),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: selected ? 160.h : 120.h,
              padding: EdgeInsets.fromLTRB(
                selected ? 26.w : 28.w,
                selected ? 30.h : 26.h,
                selected ? 14.w : 28.w,
                selected ? 26.h : 26.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: selected
                    ? Border.all(color: _brown, width: 3.w)
                    : Border.all(color: Colors.transparent, width: 3.w),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: selected ? 74.w : 64.w,
                    child: Center(
                      child: Container(
                        width: selected ? 82.w : 42.r,
                        height: selected ? 48.h : 42.r,
                        decoration: selected
                            ? BoxDecoration(
                                color: _cream,
                                borderRadius: BorderRadius.circular(26.r),
                              )
                            : null,
                        child: Icon(
                          offer.icon,
                          size: selected ? 38.r : 28.r,
                          color: _brown,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: selected ? 22.w : 20.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          offer.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 21.sp,
                            height: 1.28,
                            fontWeight: FontWeight.w900,
                            color: _text,
                            letterSpacing: -0.35,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          offer.subtitle,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    controller.cvCreditOfferPriceText(offer),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w900,
                      color: selected ? _brown : _text,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            if (selected && isBestValue)
              Positioned(
                top: -12.h,
                child: Container(
                  height: 24.h,
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _brown,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    offer.badge.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConfirmButton({required this.onTap});

  static const Color _green = Color(0xFF267A05);
  static const Color _greenDark = Color(0xFF174F00);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(color: _greenDark, blurRadius: 0, offset: Offset(0, 8.h)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Confirm Purchase',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 12.w),
            Icon(Icons.play_arrow_rounded, size: 24.r, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
