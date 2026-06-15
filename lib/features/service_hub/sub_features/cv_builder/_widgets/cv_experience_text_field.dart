import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvExperienceTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool enabled;

  const CvExperienceTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.homeSecondaryText,
            fontSize: AppFont.font8.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            height: 1,
          ),
        ),
        SizedBox(height: 7.h),
        Container(
          height: 39.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            cursorColor: AppColors.primaryGreen,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font11.sp,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.homePrimaryText.withOpacity(0.45),
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.only(top: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}