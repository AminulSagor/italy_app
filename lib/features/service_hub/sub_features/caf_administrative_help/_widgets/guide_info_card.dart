import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          const _RequirementItem(
            title: 'খোলা Passport',
            subtitle: 'পাসপোর্টের ফটোকপি',
          ),
          const _RequirementItem(
            title: 'Revenue Stamp (€16.00)',
            subtitle: 'সু marca da bollo',
          ),
          const _RequirementItem(
            title: 'Proof of Residence',
            subtitle: 'রেসিডেন্সির প্রমাণপত্র',
          ),
          SizedBox(height: 12.h),
          Divider(
            color: AppColors.homeSecondaryText.withOpacity(0.18),
            height: 1.h,
          ),
          SizedBox(height: 14.h),
          Text(
            'আবেদন পদ্ধতি / Come Fare',
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 14.h),
          const GuideStepTile(
            number: '1',
            text: 'কিট সংগ্রহ করুন নিকটস্থ পোস্ট অফিস\n(Poste Italiane) থেকে',
          ),
          SizedBox(height: 10.h),
          const GuideStepTile(
            number: '2',
            text: 'সঠিকভাবে ফরম পূরণ করুন এবং\nপ্রয়োজনীয় কাগজপত্র জমা সংযুক্ত করুন।',
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RequirementItem({
    required this.title,
    required this.subtitle,
  });

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