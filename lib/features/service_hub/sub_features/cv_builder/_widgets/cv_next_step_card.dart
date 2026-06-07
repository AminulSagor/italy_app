import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class CvNextStepCard extends StatelessWidget {
  const CvNextStepCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 86.h,
      ),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.safetyBlockedBg,
        borderRadius: BorderRadius.circular(kRadius26.r),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.08),
          width: 1.w,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42.w,
            height: 42.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppColors.primaryGreen,
              size: AppFont.font20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Next Step',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'Send this CV to local restaurants\nor agencies in your area to start\nyour journey!',
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font10.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}