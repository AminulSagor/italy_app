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

  const ProPlanCard({super.key, required this.plan, required this.currency});

  @override
  Widget build(BuildContext context) {
    final String price = plan.priceLabel(currency);
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
