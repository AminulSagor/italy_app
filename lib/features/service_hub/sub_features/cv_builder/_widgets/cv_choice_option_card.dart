import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvChoiceOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color? borderColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const CvChoiceOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    this.borderColor,
    this.isPrimary = false,
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
          height: isPrimary ? 112.h : 116.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius26.r),
            border: borderColor == null
                ? null
                : Border.all(
              color: borderColor!,
              width: 1.4.w,
            ),
            boxShadow: isPrimary
                ? <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.22),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: isPrimary
                      ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.serviceHubLightGreen.withOpacity(
                        0.32,
                      ),
                      blurRadius: 22.r,
                      spreadRadius: 4.r,
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppFont.font22.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: AppFont.font16.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.25,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                SizedBox(height: 8.h),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}