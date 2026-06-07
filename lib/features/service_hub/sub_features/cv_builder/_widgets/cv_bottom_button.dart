import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvBottomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool hasOuterPadding;

  const CvBottomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.hasOuterPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: hasOuterPadding
          ? EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h)
          : EdgeInsets.zero,
      color: hasOuterPadding ? AppColors.white : AppColors.transparent,
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            child: Container(
              height: 48.h,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}