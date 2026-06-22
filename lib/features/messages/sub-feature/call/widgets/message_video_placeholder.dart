import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class MessageVideoPlaceholder extends StatelessWidget {
  final bool isCameraOff;
  final bool isFrontCamera;

  const MessageVideoPlaceholder({
    super.key,
    required this.isCameraOff,
    required this.isFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCameraOff) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: AppColors.black,
        child: Text(
          isFrontCamera ? 'Front Camera Preview' : 'Back Camera Preview',
          style: TextStyle(
            fontSize: AppFont.font18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: AppColors.homePrimaryText,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(kRadius24.r),
        ),
        child: Text(
          'Camera Off',
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
