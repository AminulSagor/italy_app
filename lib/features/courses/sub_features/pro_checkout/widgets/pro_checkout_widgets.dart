import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final String price = plan.priceLabel(
      currency,
      isCouponApplied: isCouponApplied,
    );
    final String oldPrice = plan.oldPriceLabel(
      currency,
      isCouponApplied: isCouponApplied,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
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
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.coursesChapterBlue,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Full Italian Mastery\n(A1–B1)',
                      style: TextStyle(
                        fontSize: AppFont.font22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.homePrimaryText,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52.w,
                height: 52.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppColors.proColosseumSky,
                      AppColors.proFeatureOrangeBg,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.proColosseum,
                  size: 42.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(
            color: AppColors.modalBorderGrey.withValues(alpha: 0.48),
            height: 1.h,
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                price,
                style: TextStyle(
                  fontSize: AppFont.font30.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                oldPrice,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.homeOrange,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  plan.discountLabel,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
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
        padding: EdgeInsets.symmetric(vertical: 20.h),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.proCheckoutProductBg,
          borderRadius: BorderRadius.circular(kRadius48.r),
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
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w700,
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
      return SvgPicture.asset('assets/icons_svg/paypal.svg', height: 25.h);
    }

    if (method == ProPaymentMethod.bkash) {
      return SvgPicture.asset('assets/icons_svg/bkash.svg', height: 25.h);
    }

    if (method == ProPaymentMethod.applePay) {
      return Icon(Icons.apple_rounded, color: AppColors.black, size: 34.w);
    }

    return Icon(
      Icons.credit_card_rounded,
      color: AppColors.primaryGreen,
      size: 26.w,
    );
  }
}
