import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_contact_input_field.dart';
import '../_widgets/cv_profile_photo_card.dart';
import '../_widgets/cv_step_progress.dart';
import '../controllers/create_cv_contact_controller.dart';

class CreateCvContactView extends GetView<CreateCvContactController> {
  const CreateCvContactView({super.key});

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
                    SizedBox(height: 16.h),
                    CvStepProgress(
                      title: 'gen_step_1_identity_contact'.tr.tr,
                      progressText: 'gen_33'.tr.tr,
                      progress: 0.33,
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(kRadius26.r),
                      ),
                      child: Column(
                        children: <Widget>[
                          CvContactInputField(
                            label: 'gen_full_name'.tr.tr,
                            hintText: 'gen_e_g_fahid_hasan'.tr.tr,
                            icon: Icons.person_outline_rounded,
                            controller: controller.fullNameController,
                          ),
                          SizedBox(height: 14.h),
                          CvContactInputField(
                            label: 'gen_email_address'.tr.tr,
                            hintText: 'gen_email_example_com'.tr.tr,
                            icon: Icons.email_outlined,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 14.h),
                          CvContactInputField(
                            label: 'gen_phone_number'.tr.tr,
                            hintText: 'gen_39_xxx_xxx_xxxx'.tr.tr,
                            icon: Icons.call_outlined,
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    CvContactInputField(
                      label: 'gen_current_city_in_italy'.tr.tr,
                      hintText: 'gen_e_g_milano_roma'.tr.tr,
                      icon: Icons.location_on_rounded,
                      controller: controller.cityController,
                      isStandalone: true,
                      iconColor: AppColors.homeBlueIcon,
                    ),
                    SizedBox(height: 18.h),
                    CvProfilePhotoCard(
                      onUploadTap: controller.onUploadPhotoTap,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.white,
              padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
              child: SafeArea(
                top: false,
                child: Material(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                  child: InkWell(
                    onTap: controller.onContinueTap,
                    borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                    child: Container(
                      height: 54.h,
                      alignment: Alignment.center,
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppFont.font15.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
      height: 42.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryGreen,
                size: AppFont.font18.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Create CV',
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}
