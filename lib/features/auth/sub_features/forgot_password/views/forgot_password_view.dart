import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                  color: AppColors.primaryGreen,
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
                    fontSize: AppFont.font36.sp.clamp(AppFont.font30, AppFont.font50).toDouble(),
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
                    color: AppColors.bodyText,
                    fontSize: AppFont.font17.sp,
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
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: AppColors.primaryGreen.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius35.r),
                      ),
                      elevation: 10,
                      shadowColor: AppColors.primaryGreen.withAlpha(70),
                    ),
                    child: controller.form.value.isSubmitting
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'send_reset_link'.tr,
                                style: TextStyle(
                                  color: AppColors.legacyColorFFE8F4DF,
                                  fontSize: AppFont.font18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 9.w),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.legacyColorFFE8F4DF,
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
                      color: AppColors.primaryGreen,
                      fontSize: AppFont.font18.sp,
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
              color: AppColors.legacyColorFFA6F04B,
              borderRadius: BorderRadius.circular(kRadius34.r),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primaryGreen,
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
        color: AppColors.legacyColorFFC8C9CA,
        borderRadius: BorderRadius.circular(kRadius24.r),
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
        color: AppColors.legacyColorFFDBDCDD,
        borderRadius: BorderRadius.circular(kRadius30.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: AppColors.legacyColorFF33383C,
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.legacyColorFF6B6F73, size: 25.sp),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.legacyColorFF8A8E92,
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w900,
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
      borderRadius: BorderRadius.circular(kRadius22.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.legacyColorFFF3F4F3 : AppColors.transparent,
          borderRadius: BorderRadius.circular(kRadius20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.legacyColorFF293034
                : AppColors.legacyColorFF5E6165,
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
