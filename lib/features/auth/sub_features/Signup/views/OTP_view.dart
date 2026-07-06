import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/widgets/otp_code_input_row.dart';
import '../../../../../core/widgets/otp_resend_button.dart';

class OtpView extends GetView<SignupController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: controller.onBackFromOtp,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryGreen,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 10.h),

              Center(child: _buildOtpHero()),
              SizedBox(height: 26.h),

              Center(
                child: Text(
                  'verify'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: AppFont.font48.sp.clamp(AppFont.font28, AppFont.font48).toDouble(),
                    height: 1,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              Center(
                child: Text(
                  'otp_enter_code_to'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF5D6164,
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              Center(
                child: Obx(
                  () => Text(
                    controller.otpUi.value.maskedIdentifier,
                    style: TextStyle(
                      color: AppColors.headerText,
                      fontSize: AppFont.font18.sp.clamp(AppFont.font20, AppFont.font34).toDouble(),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              OtpCodeInputRow(
                controllers: controller.otpControllers,
                focusNodes: controller.otpFocusNodes,
                onChanged: controller.onOtpDigitChanged,
                onCompleted: controller.onOtpContinueTap,
              ),
              SizedBox(height: 26.h),

              Center(
                child: Text(
                  'otp_didnt_receive_code'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF4E5255,
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              Center(
                child: Obx(
                  () => OtpResendButton(
                    label: 'resend'.tr,
                    isLoading: controller.otpUi.value.isResending,
                    remainingSeconds:
                        controller.resendCooldown.remainingSeconds.value,
                    remainingLabel: controller.resendCooldown.remainingLabel,
                    onTap: controller.onResendOtpTap,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.otpUi.value.isVerifying
                        ? null
                        : controller.onOtpContinueTap,
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
                    child: controller.otpUi.value.isVerifying
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
                                'continue'.tr,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppFont.font18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 20.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.legacyColorFFECEFF0,
                  borderRadius: BorderRadius.circular(kRadius68.r),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 66.w,
                      height: 66.w,
                      decoration: const BoxDecoration(
                        color: AppColors.legacyColorFFCDE6BD,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppColors.primaryGreen,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'otp_security_title'.tr,
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: AppFont.font17.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'otp_security_desc'.tr,
                            style: TextStyle(
                              color: AppColors.legacyColorFF4E5255,
                              fontSize: AppFont.font12.sp,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpHero() {
    return SizedBox(
      width: 180.w,
      height: 150.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 10.w,
            bottom: 24.h,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: const BoxDecoration(
                color: AppColors.legacyColorFFD4DEE8,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: 6.h,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.legacyColorFFECCF9D,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 130.w,
            height: 130.w,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFFA2EE4A,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              size: 46.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

}