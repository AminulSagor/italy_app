import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class MessageVideoPlaceholder extends StatelessWidget {
  const MessageVideoPlaceholder({
    super.key,
    required this.isCameraOff,
    required this.isFrontCamera,
  });

  final bool isCameraOff;
  final bool isFrontCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: AppColors.black,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(kRadius24.r),
        ),
        child: Text(
          isCameraOff ? 'camera_off'.tr : 'waiting_for_video'.tr,
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
