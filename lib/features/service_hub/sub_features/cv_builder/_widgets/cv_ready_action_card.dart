import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvReadyActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final VoidCallback onTap;

  const CvReadyActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
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
          height: 118.h,
          padding: EdgeInsets.fromLTRB(12.w, 15.h, 12.w, 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius26.r),
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
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppFont.font22.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}