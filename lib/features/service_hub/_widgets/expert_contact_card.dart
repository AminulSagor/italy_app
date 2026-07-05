import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class ExpertContactCard extends StatelessWidget {
  const ExpertContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
        border: Border.all(
          color: AppColors.serviceHubLightGreen,
          width: 1.2.w,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: AppColors.serviceHubLightGreen,
              borderRadius: BorderRadius.circular(kRadius10.r),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.primaryGreen,
              size: AppFont.font20.sp,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'confused_speak_to_an_expert'.tr,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font14.sp,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 7.h),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'contact_us'.tr,
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: AppFont.font10.sp,
                      fontWeight: FontWeight.w800,
                    ),
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