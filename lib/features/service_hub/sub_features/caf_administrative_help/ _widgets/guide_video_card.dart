import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';

class GuideVideoCard extends StatelessWidget {
  const GuideVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius26.r),
        color: AppColors.homePrimaryText,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.homePrimaryText.withOpacity(0.45),
                  AppColors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.32),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: AppFont.font34.sp,
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            bottom: 8.h,
            child: Container(
              height: 20.h,
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              ),
              child: Center(
                child: Text(
                  'VIDEO GUIDE',
                  style: TextStyle(
                    color: AppColors.serviceHubLightGreen,
                    fontSize: AppFont.font8.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
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