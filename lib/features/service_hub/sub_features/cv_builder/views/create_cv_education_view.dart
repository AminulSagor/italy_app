import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_education_dropdown_field.dart';
import '../_widgets/cv_language_skills_card.dart';
import '../_widgets/cv_skill_section_card.dart';
import '../_widgets/cv_ai_suggested_skills_card.dart';
import '../_widgets/cv_step_progress.dart';
import '../controllers/create_cv_education_controller.dart';

class CreateCvEducationView extends GetView<CreateCvEducationController> {
  const CreateCvEducationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: 12.h),
                    const CvStepProgress(
                      title: 'Step 3: Skills & Education',
                      progressText: '33%',
                      progress: 0.33,
                    ),
                    SizedBox(height: 14.h),
                    _EducationProfileCard(controller: controller),
                    SizedBox(height: 18.h),
                    CvLanguageSkillsCard(controller: controller),
                    SizedBox(height: 22.h),
                    const _SectionTitle(title: 'Your Skills'),
                    SizedBox(height: 10.h),
                    CvSkillSectionCard(controller: controller),
                    SizedBox(height: 22.h),
                    const _SectionTitle(title: 'AI Suggested Skills'),
                    SizedBox(height: 10.h),
                    CvAiSuggestedSkillsCard(controller: controller),
                  ],
                ),
              ),
            ),
            _BottomButton(
              title: 'Continue to Summary',
              onTap: controller.onContinueTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: AppFont.font17.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Create CV',
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationProfileCard extends StatelessWidget {
  final CreateCvEducationController controller;

  const _EducationProfileCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
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
                  Icons.school_rounded,
                  color: AppColors.primaryGreen,
                  size: AppFont.font15.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Education Profile',
                style: TextStyle(
                  color: AppColors.homePrimaryText,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Obx(
            () => CvEducationDropdownField(
              label: 'TYPE OF EDUCATION',
              hintText: 'Select type...',
              value: controller.selectedEducationType.value.isEmpty
                  ? null
                  : controller.selectedEducationType.value,
              items: controller.educationTypes,
              onChanged: controller.selectEducationType,
            ),
          ),
          SizedBox(height: 14.h),
          Obx(
            () => CvEducationDropdownField(
              label: 'LEVEL',
              hintText: 'Select level...',
              value: controller.selectedLevel.value.isEmpty
                  ? null
                  : controller.selectedLevel.value,
              items: controller.educationLevels,
              onChanged: controller.selectLevel,
            ),
          ),
          SizedBox(height: 14.h),
          _SchoolField(controller: controller.schoolController),
        ],
      ),
    );
  }
}

class _SchoolField extends StatelessWidget {
  final TextEditingController controller;

  const _SchoolField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'SCHOOL OR INSTITUTION NAME',
              style: TextStyle(
                color: AppColors.homeSecondaryText,
                fontSize: AppFont.font8.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
                height: 1,
              ),
            ),
            const Spacer(),
            Text(
              'Optional',
              style: TextStyle(
                color: AppColors.homeSecondaryText.withValues(alpha: 0.7),
                fontSize: AppFont.font8.sp,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 7.h),
        Container(
          height: 39.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.legacyColorFFF1F2F2,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          ),
          child: TextField(
            controller: controller,
            cursorColor: AppColors.primaryGreen,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Politecnico di Milano',
              hintStyle: TextStyle(
                color: AppColors.homeSecondaryText.withValues(alpha: 0.55),
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.only(top: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 7.w),
        Text(
          title,
          style: TextStyle(
            color: AppColors.homePrimaryText,
            fontSize: AppFont.font12.sp,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _BottomButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            child: Container(
              height: 48.h,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppFont.font13.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: AppFont.font15.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
