import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/create_cv_education_controller.dart';
import 'cv_selectable_chip.dart';

class CvAiSuggestedSkillsCard extends StatelessWidget {
  final CreateCvEducationController controller;

  const CvAiSuggestedSkillsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: AppColors.homePaleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.primaryGreen,
                  size: AppFont.font14.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Text(
                'skills'.tr,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.aiSuggestedSkills
                .map(
                  (String item) => CvSelectableChip(
                    title: item,
                    isSelected: false,
                    isAiSuggested: true,
                    onTap: () => controller.addSuggestedSkill(item),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.legacyColorFFF1F2F2,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            ),
            child: Center(
              child: TextField(
                controller: controller.skillController,
                cursorColor: AppColors.primaryGreen,
                onSubmitted: (_) => controller.addSkill(),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                decoration: InputDecoration(
                  hintText: 'gen_type_skill_here'.tr,
                  hintStyle: TextStyle(
                    color: AppColors.homeSecondaryText.withValues(alpha: 0.55),
                    fontSize: AppFont.font8.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 1.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
