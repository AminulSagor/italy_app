import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_theme.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: controller.onBackTap,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryGreen,
                  size: 23.sp,
                ),
              ),
              SizedBox(height: 22.h),
              Center(child: _buildHero()),
              SizedBox(height: 26.h),
              Center(
                child: Text(
                  'forgot_password'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 36.sp.clamp(30, 50),
                    height: 1,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Center(
                child: Text(
                  'forgot_desc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.bodyText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              _buildModeSwitcher(),
              SizedBox(height: 18.h),
              Obx(() {
                final bool isEmailMode = controller.form.value.isEmailMode;
                return _buildInputField(
                  controller: controller.identifierController,
                  hint: isEmailMode
                      ? 'forgot_hint_email'.tr
                      : 'forgot_hint_phone'.tr,
                  icon: isEmailMode ? Icons.mail_outline : Icons.phone_outlined,
                  keyboardType: isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                );
              }),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 66.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.form.value.isSubmitting
                        ? null
                        : controller.onSendResetLinkTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      disabledBackgroundColor: AppTheme.primaryGreen.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                      elevation: 10,
                      shadowColor: AppTheme.primaryGreen.withAlpha(70),
                    ),
                    child: controller.form.value.isSubmitting
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'send_reset_link'.tr,
                                style: TextStyle(
                                  color: const Color(0xFFE8F4DF),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 9.w),
                              Icon(
                                Icons.arrow_forward,
                                color: const Color(0xFFE8F4DF),
                                size: 22.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Center(
                child: TextButton(
                  onPressed: controller.onBackToLoginTap,
                  child: Text(
                    'back_to_login'.tr,
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
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

  Widget _buildHero() {
    return SizedBox(
      width: 130.w,
      height: 130.w,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: const Color(0xFFA6F04B),
              borderRadius: BorderRadius.circular(34.r),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.primaryGreen,
              size: 48.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFC8C9CA),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Obx(
        () => Row(
          children: <Widget>[
            Expanded(
              child: _ModeItem(
                label: 'email'.tr,
                isSelected: controller.form.value.isEmailMode,
                onTap: () => controller.setResetMode('email'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ModeItem(
                label: 'phone'.tr,
                isSelected: !controller.form.value.isEmailMode,
                onTap: () => controller.setResetMode('phone'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDBDCDD),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: const Color(0xFF33383C),
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF6B6F73), size: 25.sp),
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF8A8E92),
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
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
}

class _ModeItem extends StatelessWidget {
  const _ModeItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF293034)
                : const Color(0xFF5E6165),
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
