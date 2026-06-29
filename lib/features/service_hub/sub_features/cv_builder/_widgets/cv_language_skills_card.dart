import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/create_cv_education_controller.dart';
import 'cv_selectable_chip.dart';

class CvLanguageSkillsCard extends StatelessWidget {
  final CreateCvEducationController controller;

  const CvLanguageSkillsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      icon: Icons.language_rounded,
      title: 'gen_language_skills'.tr.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _LabelText('Native Language (Mother Tongue)'),
          SizedBox(height: 8.h),
          Obx(() {
            final List<String> languages = controller.nativeLanguages.toList();

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: languages
                  .map(
                    (String item) => CvSelectableChip(
                      title: item,
                      isSelected: true,
                      showCloseIcon: true,
                      onTap: () => controller.removeNativeLanguage(item),
                    ),
                  )
                  .toList(),
            );
          }),
          SizedBox(height: 10.h),
          _AddInput(
            controller: controller.nativeLanguageController,
            hintText: 'gen_set_native_language'.tr.tr,
            onTap: controller.addNativeLanguage,
          ),
          SizedBox(height: 16.h),
          _LabelText('Other Languages'),
          SizedBox(height: 8.h),
          Obx(() {
            final List<String> languages = controller.otherLanguages.toList();

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: languages
                  .map(
                    (String item) => CvSelectableChip(
                      title: item,
                      isSelected: true,
                      showCloseIcon: true,
                      onTap: () => controller.removeOtherLanguage(item),
                    ),
                  )
                  .toList(),
            );
          }),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: controller.addOtherLanguage,
            child: Container(
              height: 32.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.homePaleGreen,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              ),
              child: Text(
                '+ Add Another Language',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: AppFont.font9.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _BaseCard({
    required this.icon,
    required this.title,
    required this.child,
  });

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
                width: 30.w,
                height: 30.w,
                decoration: const BoxDecoration(
                  color: AppColors.homePaleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: AppFont.font15.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String value;

  const _LabelText(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: AppColors.homePrimaryText,
        fontSize: AppFont.font8.sp,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }
}

class _AddInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const _AddInput({
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.only(left: 12.w, right: 5.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF1F2F2,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primaryGreen,
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.homeSecondaryText.withValues(alpha: 0.55),
                  fontSize: AppFont.font8.sp,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: AppFont.font14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
