import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/core/themes/app_theme.dart';

class DarkGreenButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;
  final bool isLoading;
  final bool showShadow;
  final bool isElevated;
  final IconData? icon;
  const DarkGreenButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    required this.width,
    this.isLoading = false,
    this.showShadow = false,
    this.isElevated = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final shadowDepth = showShadow ? 7.h : 0.0;
    final darkShadowColor = Color.lerp(
      AppTheme.primaryGreen,
      Colors.black,
      0.35,
    )!;

    return SizedBox(
      width: width.w,
      height: height.h,
      child: Stack(
        children: [
          if (showShadow)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: darkShadowColor,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: shadowDepth,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                elevation: isElevated ? 10 : 0,
                shadowColor: AppTheme.primaryGreen.withAlpha(140),
                backgroundColor: AppTheme.primaryGreen,
                disabledBackgroundColor: AppTheme.primaryGreen.withAlpha(180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppTheme.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text.tr,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                        // SizedBox(width: 4.w),
                        if (icon != null) ...[
                          SizedBox(width: 8.w),
                          Icon(icon, size: 24.sp, color: AppTheme.white),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
