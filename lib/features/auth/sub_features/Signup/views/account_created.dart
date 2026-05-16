import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class AccountCreatedView extends GetView<SignupController> {
  const AccountCreatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: Get.back,
                icon: Icon(
                  Icons.close,
                  color: AppColors.legacyColorFF5A5D60,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Center(child: _buildSuccessBadge()),
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  'account_created_title'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: AppFont.font36.sp.clamp(AppFont.font28, AppFont.font40).toDouble(),
                    height: 1.15,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  'account_created_desc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.legacyColorFF5D6164,
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Obx(
                () => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.legacyColorFFF1F2F2,
                    borderRadius: BorderRadius.circular(kRadius34.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kRadius34.r),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: -100.h,
                          right: -70.w,
                          child: Container(
                            width: 160.w,
                            height: 160.w,
                            decoration: const BoxDecoration(
                              color: AppColors.legacyColorFFE4E8EB,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            children: <Widget>[
                              _buildInfoRow(
                                icon: Icons.person_outline,
                                iconBg: AppColors.legacyColorFFA9CCF0,
                                title: 'field_full_name'.tr,
                                value:
                                    controller.accountCreatedUi.value.fullName,
                              ),
                              SizedBox(height: 14.h),
                              _buildInfoRow(
                                icon: Icons.mail_outline,
                                iconBg: AppColors.legacyColorFFC8E8B7,
                                title: controller.form.value.isEmailMode
                                    ? 'field_email'.tr
                                    : 'field_phone'.tr,
                                value: controller
                                    .accountCreatedUi
                                    .value
                                    .identifier,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.accountCreatedUi.value.isStarting
                        ? null
                        : controller.onStartLearningTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: AppColors.primaryGreen.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius34.r),
                      ),
                      elevation: 10,
                      shadowColor: AppColors.primaryGreen.withAlpha(70),
                    ),
                    child: controller.accountCreatedUi.value.isStarting
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'start_learning'.tr,
                                style: TextStyle(
                                  color: AppColors.legacyColorFFE8F4DF,
                                  fontSize: AppFont.font18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.legacyColorFFE8F4DF,
                                size: 24.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return SizedBox(
      width: 150.w,
      height: 150.w,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 132.w,
            height: 132.w,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.legacyColorFF6FE13B, width: 3),
              // boxShadow: const <BoxShadow>[
              //   BoxShadow(
              //     color: Color.fromARGB(255, 255, 255, 255),
              //     blurRadius: 18,
              //     spreadRadius: 2,
              //   ),
              // ],
            ),
          ),
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.white, size: 36.sp),
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: Center(
              child: SizedBox(
                width: 56.sp,
                height: 56.sp,
                child: Image.asset(
                  'assets/icons_png/Background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(kRadius14.r),
          ),
          child: Icon(icon, color: AppColors.legacyColorFF0F5F21, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: AppColors.legacyColorFF6C7074,
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.legacyColorFF2B2F32,
                  fontSize: AppFont.font18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
