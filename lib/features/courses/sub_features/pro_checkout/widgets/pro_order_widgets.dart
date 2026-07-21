import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/pro_checkout_models.dart';
import 'package:get/get.dart';

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
    final String price = plan.priceLabel(currency);
    final String oldPrice = plan.oldPriceLabel(currency);

    final bool hasDiscount =
        isCouponApplied && oldPrice.isNotEmpty && oldPrice != price;

    final double titleFontSize = (AppFont.font18.sp)
        .clamp(16.0, 19.0)
        .toDouble();

    final double subtitleFontSize = (AppFont.font13.sp)
        .clamp(12.0, 14.0)
        .toDouble();

    final double priceFontSize = (AppFont.font24.sp)
        .clamp(22.0, 27.0)
        .toDouble();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isNarrow = constraints.maxWidth < 330;

        final Widget courseInformation = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              plan.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
                height: 1.25,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              plan.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.bodyText,
                height: 1.35,
              ),
            ),
          ],
        );

        final Widget priceInformation = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isNarrow
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isNarrow ? 180.w : 130.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: isNarrow
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  price,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: priceFontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            if (hasDiscount) ...<Widget>[
              SizedBox(height: 3.h),
              Text(
                oldPrice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.proPriceStruck,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.proPriceStruck,
                  decorationThickness: 1.5.w,
                ),
              ),
              SizedBox(height: 7.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.homeSoftGreen,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.redeem_outlined,
                      size: 13.w,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        plan.couponSaveLabelFor(currency),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.font10.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.proPlanBorder, width: 1.w),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    courseInformation,
                    SizedBox(height: 14.h),
                    priceInformation,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child: courseInformation),
                    SizedBox(width: 16.w),
                    priceInformation,
                  ],
                ),
        );
      },
    );
  }
}

class ProCouponInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isCouponApplied;
  final bool isLoading;
  final String appliedCode;
  final int discountPercentage;
  final String pricingNote;
  final ValueChanged<String> onChanged;
  final VoidCallback onApplyTap;
  final VoidCallback onRemoveTap;

  const ProCouponInput({
    super.key,
    required this.controller,
    required this.isCouponApplied,
    required this.isLoading,
    required this.appliedCode,
    required this.discountPercentage,
    required this.pricingNote,
    required this.onChanged,
    required this.onApplyTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isCouponApplied
          ? _ProAppliedCouponField(
              key: const ValueKey<String>('pro-applied-coupon'),
              appliedCode: appliedCode,
              onTap: () => _showAppliedCouponDialog(context),
            )
          : _ProCouponEntryField(
              key: const ValueKey<String>('pro-coupon-entry'),
              controller: controller,
              isLoading: isLoading,
              onChanged: onChanged,
              onApplyTap: onApplyTap,
            ),
    );
  }

  void _showAppliedCouponDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 22.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 24.r,
                  offset: Offset(0, 12.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42.w,
                      height: 42.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.chatIncomingBubbleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.primaryGreen,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'coupon_applied'.tr,
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(
                  appliedCode,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                if (discountPercentage > 0) ...<Widget>[
                  SizedBox(height: 8.h),
                  Text(
                    'discount_value'.trParams(<String, String>{
                      'discount': discountPercentage.toString(),
                    }),
                    style: TextStyle(
                      color: AppColors.bodyText,
                      fontSize: AppFont.font14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  pricingNote.isEmpty
                      ? 'Final price is controlled by Google Play/App Store and may include VAT, tax, currency conversion, or regional pricing.'
                      : pricingNote,
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: AppFont.font12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onRemoveTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.notificationRed,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'remove_coupon'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font15.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProCouponEntryField extends StatelessWidget {
  const _ProCouponEntryField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onChanged,
    required this.onApplyTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onApplyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 58.h,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textCapitalization: TextCapitalization.characters,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.homePrimaryText,
            ),
            decoration: InputDecoration(
              hintText: 'gen_enter_coupon_code'.tr,
              hintStyle: TextStyle(
                fontSize: AppFont.font15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.proHintText,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 22.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
                borderSide: BorderSide(
                  color: AppColors.modalBorderGrey,
                  width: 1.6.w,
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
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 58.h,
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: isLoading ? null : onApplyTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(color: AppColors.primaryGreen, width: 1.6.w),
                shape: const StadiumBorder(),
                disabledForegroundColor: AppColors.primaryGreen,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? Row(
                        key: const ValueKey<String>('coupon-loading'),
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Text(
                            'applying_coupon'.tr,
                            style: TextStyle(
                              fontSize: AppFont.font14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'apply'.tr,
                        key: const ValueKey<String>('coupon-apply'),
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProAppliedCouponField extends StatelessWidget {
  const _ProAppliedCouponField({
    super.key,
    required this.appliedCode,
    required this.onTap,
  });

  final String appliedCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 58.h,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColors.chatIncomingBubbleBg,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.28),
                width: 1.4.w,
              ),
            ),
            child: Text(
              appliedCode.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70.w,
            height: 58.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(color: AppColors.primaryGreen, width: 2.w),
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.primaryGreen,
              size: 24.w,
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
