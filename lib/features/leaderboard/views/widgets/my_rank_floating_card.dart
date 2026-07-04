import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';

class MyRankFloatingCard extends StatelessWidget {
  final VoidCallback onInfoTap;
  final String rankLabel;
  final String xpLabel;
  final String? zoneLabel;

  const MyRankFloatingCard({
    required this.onInfoTap,
    required this.rankLabel,
    required this.xpLabel,
    this.zoneLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.20),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOUR RANK',
                  style: TextStyle(
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.limeTextColor.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  rankLabel,
                  style: TextStyle(
                    fontSize: AppFont.font17.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF83FF45),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                xpLabel,
                style: TextStyle(
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF83FF45),
                ),
              ),
              SizedBox(height: 3.h),
              if (zoneLabel != null && zoneLabel!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D9416),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    zoneLabel!,
                    style: TextStyle(
                      fontSize: AppFont.font9.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.limeTextColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          GestureDetector(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline_rounded,
              size: 24.r,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

