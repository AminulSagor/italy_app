import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/pro_checkout_models.dart';

class CheckoutProductCard extends StatelessWidget {
  final ProPlanModel plan;
  final ProCurrency currency;
  final bool isCouponApplied;

  const CheckoutProductCard({
    super.key,
    required this.plan,
    required this.currency,
    required this.isCouponApplied,
  });

  @override
  Widget build(BuildContext context) {
    final String price = plan.priceLabel(currency, isCouponApplied: isCouponApplied);
    final String oldPrice = plan.oldPriceLabel(currency, isCouponApplied: isCouponApplied);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30.w, 30.h, 26.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.proCheckoutProductBg,
        borderRadius: BorderRadius.circular(kProCheckoutCardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ITALIAN SHIKHI',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: AppColors.coursesChapterBlue,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Full Italian Mastery\n(A1–B1)',
                      style: TextStyle(
                        fontSize: AppFont.font28.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.homePrimaryText,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 72.w,
                height: 72.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.proColosseumSky, AppColors.proFeatureOrangeBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Icon(Icons.account_balance_rounded, color: AppColors.proColosseum, size: 42.w),
              ),
            ],
          ),
          SizedBox(height: 34.h),
          Divider(color: AppColors.modalBorderGrey.withValues(alpha: 0.48), height: 1.h),
          SizedBox(height: 24.h),
          Row(
            children: <Widget>[
              Text(
                price,
                style: TextStyle(
                  fontSize: AppFont.font34.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 24.w),
              Text(
                oldPrice,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bodyText,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: AppColors.homeOrange,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  plan.discountLabel,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckoutPaymentMethodCard extends StatelessWidget {
  final ProPaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const CheckoutPaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.proCheckoutProductBg,
          borderRadius: BorderRadius.circular(kProPaymentCardRadius.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _PaymentMethodIcon(method: method),
            SizedBox(height: 12.h),
            Text(
              _label(method),
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(ProPaymentMethod method) {
    switch (method) {
      case ProPaymentMethod.paypal:
        return 'PayPal';
      case ProPaymentMethod.applePay:
        return 'Apple Pay';
      case ProPaymentMethod.bkash:
        return 'Bkash';
      case ProPaymentMethod.card:
        return 'Card';
    }
  }
}

class _PaymentMethodIcon extends StatelessWidget {
  final ProPaymentMethod method;

  const _PaymentMethodIcon({required this.method});

  @override
  Widget build(BuildContext context) {
    if (method == ProPaymentMethod.paypal) {
      return Text(
        'P',
        style: TextStyle(
          fontSize: AppFont.font34.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.proPaypalBlue,
          height: 0.92,
        ),
      );
    }

    if (method == ProPaymentMethod.bkash) {
      return Icon(Icons.flutter_dash_rounded, color: AppColors.proBkashPink, size: 34.w);
    }

    if (method == ProPaymentMethod.applePay) {
      return Icon(Icons.apple_rounded, color: AppColors.black, size: 34.w);
    }

    return Icon(Icons.credit_card_rounded, color: AppColors.primaryGreen, size: 34.w);
  }
}
