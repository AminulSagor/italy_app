import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import 'forgot_password_controller.dart';
import 'forgot_password_models.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
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
                    color: const Color(0xFF3A3E42),
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EAEA),
                  borderRadius: BorderRadius.circular(38.r),
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
                            fontSize: 32.sp.clamp(30, 50),
                            height: 1.06,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'reset_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.bodyText,
                        fontSize: 16.sp,
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
                            backgroundColor: AppTheme.primaryGreen,
                            disabledBackgroundColor: AppTheme.primaryGreen
                                .withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34.r),
                            ),
                            elevation: 10,
                            shadowColor: AppTheme.primaryGreen.withAlpha(70),
                          ),
                          child: controller.resetForm.value.isSubmitting
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'reset_password'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 9.w),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
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
                  color: const Color(0xFFAFB2B5),
                  fontSize: 12.sp,
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
              color: Color(0xFFA5F04B),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_open,
              color: AppTheme.primaryGreen,
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
                color: Color(0xFF8A560E),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh, color: Colors.white, size: 18.sp),
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
        color: const Color(0xFFDBDCDD),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: const Color(0xFF33383C),
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF8A8E92),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF65696E),
              size: 24.sp,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
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
        color: const Color(0xFFD4D6D7),
        borderRadius: BorderRadius.circular(24.r),
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
          _ChecklistItem(
            label: 'check_match'.tr,
            passed: reset.matchesConfirm,
          ),
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
          color: passed ? AppTheme.primaryGreen : const Color(0xFF8C8F93),
          size: 17.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: passed ? const Color(0xFF2A2F33) : const Color(0xFF7A7E82),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
