import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvCreditCard extends StatelessWidget {
  final String title;
  final String price;
  final Color backgroundColor;
  final Color titleColor;
  final Color priceColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const CvCreditCard({
    super.key,
    required this.title,
    required this.price,
    required this.backgroundColor,
    required this.titleColor,
    required this.priceColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(kRadius26.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius26.r),
        child: Container(
          width: 76.w,
          padding: EdgeInsets.fromLTRB(9.w, 12.h, 9.w, 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius26.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 15.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                price,
                maxLines: 1,
                style: TextStyle(
                  color: priceColor,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const Spacer(),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: iconColor,
                  size: AppFont.font14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}