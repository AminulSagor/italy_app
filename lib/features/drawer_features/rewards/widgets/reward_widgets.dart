import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RewardTopBar extends StatelessWidget {
  final String title;

  const RewardTopBar({super.key, required this.title});

  static const Color green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_rounded, size: 25.r, color: green),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: green,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class RewardPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? suffixIcon;
  final double height;
  final Color color;
  final Color shadowColor;
  final Color textColor;

  const RewardPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.suffixIcon,
    this.height = 62,
    this.color = const Color(0xFF267A05),
    this.shadowColor = const Color(0xFF155200),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.15,
              ),
            ),
            if (suffixIcon != null) ...[
              SizedBox(width: 10.w),
              Icon(suffixIcon, size: 22.r, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}
