import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class ServiceActionCard extends StatelessWidget {
  final double height;
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const ServiceActionCard({
    super.key,
    required this.height,
    required this.gradientColors,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 32;
    const double titleGap = 12;
    final double contentStart = iconSize + titleGap;

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.26),
            blurRadius: 18.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: iconSize.w,
                height: iconSize.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppFont.font16.sp,
                  color: gradientColors.last,
                ),
              ),
              SizedBox(width: titleGap.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: AppFont.font20.sp,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      SizedBox(height: 8.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.82),
                          fontSize: AppFont.font9.sp,
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(left: contentStart.w),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                child: Container(
                  height: 34.h,
                  constraints: BoxConstraints(minWidth: 120.w),
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  alignment: Alignment.center,
                  child: Text(
                    'buttontext'.trParams(<String, String>{'buttontext': buttonText.toString()}),
                    style: TextStyle(
                      color: gradientColors.last,
                      fontSize: AppFont.font10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
