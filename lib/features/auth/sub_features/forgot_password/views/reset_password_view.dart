import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../models/forgot_password_models.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: controller.onBackTap,
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.legacyColorFF3A3E42,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.legacyColorFFE9EAEA,
                  borderRadius: BorderRadius.circular(kRadius38.r),
                ),
                child: Column(
                  children: <Widget>[
                    _buildHero(),
                    SizedBox(height: 20.h),
                    Text(
                      'reset_title'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontSize: AppFont.font32.sp.clamp(AppFont.font30, AppFont.font50).toDouble(),
                            height: 1.06,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'reset_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Obx(
                      () => _buildInputField(
                        controller: controller.newPasswordController,
                        hint: 'new_password'.tr,
                        obscureText:
                            controller.resetForm.value.obscureNewPassword,
                        onToggleVisibility:
                            controller.toggleNewPasswordVisibility,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => _buildInputField(
                        controller: controller.confirmPasswordController,
                        hint: 'confirm_password'.tr,
                        obscureText:
                            controller.resetForm.value.obscureConfirmPassword,
                        onToggleVisibility:
                            controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Obx(() => _buildPasswordChecklist()),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 64.h,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.resetForm.value.isSubmitting
                              ? null
                              : controller.onResetPasswordTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            disabledBackgroundColor: AppColors.primaryGreen
                                .withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadius34.r),
                            ),
                            elevation: 10,
                            shadowColor: AppColors.primaryGreen.withAlpha(70),
                          ),
                          child: controller.resetForm.value.isSubmitting
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
                                      'reset_password'.tr,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: AppFont.font18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 9.w),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.white,
                                      size: 22.sp,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 56.h),
              Text(
                'encrypted_verification'.tr,
                style: TextStyle(
                  color: AppColors.legacyColorFFAFB2B5,
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      width: 130.w,
      height: 120.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 102.w,
            height: 102.w,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFFA5F04B,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_open,
              color: AppColors.primaryGreen,
              size: 46.sp,
            ),
          ),
          Positioned(
            right: 12.w,
            top: 18.h,
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: AppColors.legacyColorFF8A560E,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh, color: AppColors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFDBDCDD,
        borderRadius: BorderRadius.circular(kRadius30.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: AppColors.legacyColorFF33383C,
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.legacyColorFF8A8E92,
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.legacyColorFF65696E,
              size: 24.sp,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadius30.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    final ResetPasswordFormModel reset = controller.resetForm.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD4D6D7,
        borderRadius: BorderRadius.circular(kRadius24.r),
      ),
      child: Column(
        children: <Widget>[
          _ChecklistItem(
            label: 'check_min_length'.tr,
            passed: reset.hasMinLength,
          ),
          SizedBox(height: 10.h),
          _ChecklistItem(
            label: 'check_upper_number'.tr,
            passed: reset.hasUppercaseAndNumber,
          ),
          SizedBox(height: 10.h),
          _ChecklistItem(label: 'check_match'.tr, passed: reset.matchesConfirm),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: passed ? AppColors.primaryGreen : AppColors.legacyColorFF8C8F93,
          size: 17.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: passed ? AppColors.legacyColorFF2A2F33 : AppColors.legacyColorFF7A7E82,
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
