import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_experience_text_field.dart';
import '../_widgets/cv_selectable_chip.dart';
import '../_widgets/cv_small_section_card.dart';
import '../_widgets/cv_step_progress.dart';
import '../controllers/create_cv_experience_controller.dart';

class CreateCvExperienceView extends GetView<CreateCvExperienceController> {
  const CreateCvExperienceView({super.key});

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
                    CvStepProgress(
                      title: 'gen_step_2_work_experience'.tr,
                      progressText: '33%',
                      progress: 0.33,
                    ),
                    SizedBox(height: 14.h),
                    _WorkExperienceCard(controller: controller),
                    SizedBox(height: 18.h),
                    _HobbiesCard(controller: controller),
                    SizedBox(height: 18.h),
                    _DrivingLicenseCard(controller: controller),
                  ],
                ),
              ),
            ),
            _BottomButton(
              title: 'gen_continue_to_education'.tr,
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
            'create_cv'.tr,
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

class _WorkExperienceCard extends StatelessWidget {
  final CreateCvExperienceController controller;

  const _WorkExperienceCard({required this.controller});

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
          CvExperienceTextField(
            label: 'gen_job_position'.tr,
            hintText: 'gen_pizza_maker'.tr,
            controller: controller.jobPositionController,
          ),
          SizedBox(height: 14.h),
          CvExperienceTextField(
            label: 'gen_company_name'.tr,
            hintText: 'gen_pizzeria_da_michele'.tr,
            controller: controller.companyNameController,
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              Expanded(
                child: CvExperienceTextField(
                  label: 'gen_start_date'.tr,
                  hintText: 'gen_01_01_2020'.tr,
                  controller: controller.startDateController,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CvExperienceTextField(
                  label: 'gen_end_date'.tr,
                  hintText: 'gen_10_01_2023'.tr,
                  controller: controller.endDateController,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 17.w,
                  height: 17.w,
                  child: Checkbox(
                    value: controller.isPresent.value,
                    onChanged: controller.togglePresent,
                    activeColor: AppColors.primaryGreen,
                    checkColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.3.w,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'present'.tr,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font8.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Divider(
            color: AppColors.homeSecondaryText.withValues(alpha: 0.14),
            height: 1.h,
            thickness: 1.h,
          ),
          SizedBox(height: 14.h),
          Text(
            'select_your_responsibilities'.tr,
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font9.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          SizedBox(height: 8.h),
          const _AiSuggestedBadge(),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              CvSelectableChip(
                title: 'gen_dough_preparation'.tr,
                isSelected: true,
                onTap: () {},
              ),
              CvSelectableChip(
                title: 'gen_oven_handling'.tr,
                isSelected: true,
                onTap: () {},
              ),
              CvSelectableChip(
                title: 'gen_ingredient_prep'.tr,
                isSelected: false,
                isAiSuggested: true,
                onTap: () {},
              ),
              CvSelectableChip(
                title: 'gen_kitchen_hygiene'.tr,
                isSelected: false,
                isAiSuggested: true,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 14.h),
          CvSelectableChip(
            title: 'gen_add_custom_responsibility'.tr,
            isSelected: false,
            isOutline: true,
            fullWidth: true,
            icon: Icons.add_rounded,
            onTap: controller.addCustomResponsibility,
          ),
          SizedBox(height: 18.h),

          _AddAnotherExperienceButton(
            onTap: controller.onAddAnotherExperienceTap,
          ),
        ],
      ),
    );
  }
}

class _AiSuggestedBadge extends StatelessWidget {
  const _AiSuggestedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.homePaleGreen,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Text(
        'ai_suggested'.tr,
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: AppFont.font7.sp,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _AddAnotherExperienceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAnotherExperienceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 1.2.w),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primaryGreen,
                size: AppFont.font13.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'add_another_experience'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: AppFont.font10.sp,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HobbiesCard extends StatelessWidget {
  final CreateCvExperienceController controller;

  const _HobbiesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CvSmallSectionCard(
      icon: Icons.sports_esports_rounded,
      title: 'gen_hobbies_interests'.tr,
      hintText: 'gen_e_g_photography'.tr,
      controller: controller.hobbyController,
      onAddTap: controller.addHobby,
      footerText: 'gen_added_hobbies_will_appear_here'.tr,
      child: Obx(
        () => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.hobbies
              .map(
                (String item) => CvSelectableChip(
                  title: item,
                  isSelected: true,
                  showCloseIcon: true,
                  onTap: () => controller.removeHobby(item),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DrivingLicenseCard extends StatelessWidget {
  final CreateCvExperienceController controller;

  const _DrivingLicenseCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CvSmallSectionCard(
      icon: Icons.directions_car_filled_rounded,
      title: 'gen_driving_license'.tr,
      hintText: 'gen_e_g_category_b_c'.tr,
      controller: controller.licenseController,
      onAddTap: controller.addLicense,
      footerText: 'gen_manage_your_driving_categories'.tr,
      child: Obx(
        () => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.licenses
              .map(
                (String item) => CvSelectableChip(
                  title: item,
                  isSelected: true,
                  showCloseIcon: true,
                  onTap: () => controller.removeLicense(item),
                ),
              )
              .toList(),
        ),
      ),
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
