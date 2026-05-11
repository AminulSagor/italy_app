import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';

class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kProfileInfoCardHeight.h,
      padding: EdgeInsets.fromLTRB(18.w, 28.h, 18.w, 22.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kRadius38.r),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(kRadius18.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.18),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Icon(icon, size: 22.w, color: AppColors.white),
          ),
          Column(
            children: <Widget>[
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font24.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
