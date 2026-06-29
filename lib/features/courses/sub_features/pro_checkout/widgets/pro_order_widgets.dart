import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/pro_checkout_models.dart';

class ProPlanCard extends StatelessWidget {
  final ProPlanModel plan;
  final ProCurrency currency;
  final bool isCouponApplied;

  const ProPlanCard({
    super.key,
    required this.plan,
    required this.currency,
    required this.isCouponApplied,
  });

  @override
  Widget build(BuildContext context) {
    if (isCouponApplied) {
      return _CouponPlanCard(plan: plan, currency: currency);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius48.r),
        border: Border.all(color: AppColors.proPlanBorder, width: 1.2.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  plan.subtitle,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Text(
            plan.priceLabel(currency),
            style: TextStyle(
              fontSize: AppFont.font30.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponPlanCard extends StatelessWidget {
  final ProPlanModel plan;
  final ProCurrency currency;

  const _CouponPlanCard({required this.plan, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 34.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kProPlanCardRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            plan.title,
            style: TextStyle(
              fontSize: AppFont.font24.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            plan.subtitle,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 34.h),
          if (plan.oldPriceLabel(currency) != plan.priceLabel(currency))
            Text(
              plan.oldPriceLabel(currency),
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.proPriceStruck,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          Text(
            plan.priceLabel(currency),
            style: TextStyle(
              fontSize: AppFont.font60.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
          if (plan.oldPriceLabel(currency) != plan.priceLabel(currency))
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.homeLime,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeLime.withValues(alpha: 0.3),
                    blurRadius: 14.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Text(
                plan.couponSaveLabelFor(currency),
                style: TextStyle(
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProCouponInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isCouponApplied;
  final bool isLoading;
  final VoidCallback onApplyTap;

  const ProCouponInput({
    super.key,
    required this.controller,
    required this.isCouponApplied,
    required this.isLoading,
    required this.onApplyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCouponApplied) {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 70.h,
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.proCouponAppliedBg,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
                border: Border.all(
                  color: AppColors.proPlanBorder,
                  width: 1.2.w,
                ),
              ),
              child: Text(
                controller.text,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onApplyTap,
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 3.w),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.primaryGreen,
                size: 22.w,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
          ),
          decoration: InputDecoration(
            hintText: 'Enter Coupon Code',
            hintStyle: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.proHintText,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 28.w,
              vertical: 20.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              borderSide: BorderSide(
                color: AppColors.modalBorderGrey,
                width: 1.5.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              borderSide: BorderSide(
                color: AppColors.primaryGreen,
                width: 1.8.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: isLoading ? null : onApplyTap,
          child: Container(
            height: 66.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(color: AppColors.primaryGreen, width: 2.w),
            ),
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : Text(
                    'APPLY',
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class TrustedLearnersPill extends StatelessWidget {
  final String label;

  const TrustedLearnersPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.proTrustedBg,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 54.w,
            height: 24.h,
            child: Stack(
              children: List<Widget>.generate(3, (int index) {
                return Positioned(
                  left: (index * 16).w,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0
                          ? AppColors.chatIncomingBubbleBg
                          : AppColors.primaryGreen,
                      border: Border.all(color: AppColors.white, width: 2.w),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 13.w,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
