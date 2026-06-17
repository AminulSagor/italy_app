import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvContactInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isStandalone;
  final Color? iconColor;

  const CvContactInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.isStandalone = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.homeSecondaryText,
            fontSize: AppFont.font8.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            height: 1,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: iconColor ?? AppColors.primaryGreen,
                size: AppFont.font17.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  cursorColor: AppColors.primaryGreen,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.homeSecondaryText.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!isStandalone) return field;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: field,
    );
  }
}
