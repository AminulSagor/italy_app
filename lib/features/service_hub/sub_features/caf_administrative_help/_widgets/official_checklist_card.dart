import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import 'package:get/get.dart';

class OfficialChecklistCard extends StatelessWidget {
  const OfficialChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 0, 12.w, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
        border: Border.all(
          color: AppColors.homeSecondaryText.withOpacity(0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 29.w,
            height: 29.w,
            decoration: const BoxDecoration(
              color: AppColors.profileOrangeCardBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.profileRedText,
              size: AppFont.font15.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'official_checklist_pdf'.tr,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'label_lib_features_service_hub_sub_features_caf_administrative_help__widgets_official_checklist_card_59'.tr,
                  style: TextStyle(
                    color: AppColors.homeSecondaryText,
                    fontSize: AppFont.font8.sp,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.safetyBlockedBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove_red_eye_outlined,
              color: AppColors.primaryGreen,
              size: AppFont.font15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
