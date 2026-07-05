import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import 'guide_step_tile.dart';

class GuideInfoCard extends StatelessWidget {
  const GuideInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 17.h, 18.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.description_rounded,
                color: AppColors.primaryGreen,
                size: AppFont.font17.sp,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'প্রয়োজনীয় কাগজপত্র /\nDocumenti Richiesti',
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font15.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _RequirementItem(
            title: 'gen_passport'.tr,
            subtitle: 'passport_photocopy'.tr,
          ),
          _RequirementItem(
            title: 'gen_revenue_stamp_16_00'.tr,
            subtitle: 'gen_marca_da_bollo'.tr,
          ),
          _RequirementItem(
            title: 'gen_proof_of_residence'.tr,
            subtitle: 'proof_of_residence_bn'.tr,
          ),
          SizedBox(height: 12.h),
          Divider(
            color: AppColors.homeSecondaryText.withOpacity(0.18),
            height: 1.h,
          ),
          SizedBox(height: 14.h),
          Text(
            'come_fare'.tr,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 14.h),
          GuideStepTile(
            number: '1',
            text: 'collect_kit_from_post_office'.tr,
          ),
          SizedBox(height: 10.h),
          GuideStepTile(
            number: '2',
            text: 'fill_form_and_submit'.tr,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RequirementItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.serviceHubLightGreen,
            size: AppFont.font15.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font11.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
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
        ],
      ),
    );
  }
}
