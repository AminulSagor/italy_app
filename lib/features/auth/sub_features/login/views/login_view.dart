import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../controllers/login_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 8.h),
                _buildLanguageSwitcher(controller),
                SizedBox(height: 16.h),
                _buildBrandMark(),
                SizedBox(height: 14.h),
                Text(
                  'app_name'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: AppFont.font40.sp.clamp(AppFont.font24, AppFont.font48).toDouble(),
                    height: 1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'unlock_career'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.legacyColorFFDFDFDF,
                    borderRadius: BorderRadius.circular(kRadius32.r),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        _buildEmailPhoneSwitcher(controller),
                        SizedBox(height: 20.h),
                        Obx(() {
                          final bool isEmailMode =
                              controller.form.value.selectedLoginMode ==
                              'email';

                          return Column(
                            children: <Widget>[
                              _buildFieldLabel(
                                isEmailMode
                                    ? 'field_email_address'.tr
                                    : 'field_phone_number'.tr,
                              ),
                              SizedBox(height: 8.h),
                              _buildInputField(
                                controller: controller.identifierController,
                                prefix: isEmailMode
                                    ? Icons.alternate_email
                                    : Icons.phone_outlined,
                                hint: isEmailMode
                                    ? 'hint_email_login'.tr
                                    : 'hint_phone'.tr,
                                keyboardType: isEmailMode
                                    ? TextInputType.emailAddress
                                    : TextInputType.phone,
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 16.h),
                        _buildFieldLabel('field_password'.tr),
                        SizedBox(height: 8.h),
                        Obx(
                          () => _buildInputField(
                            controller: controller.passwordController,
                            prefix: Icons.lock_outline,
                            hint: 'hint_password_mask'.tr,
                            obscureText: controller.form.value.obscurePassword,
                            suffix: IconButton(
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                controller.form.value.obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.legacyColorFF666666,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.forgotPassword),
                          child: Text(
                            'forgot_password'.tr,
                            style: TextStyle(
                              fontSize: AppFont.font17.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: double.infinity,
                          height: 58.h,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller.form.value.isLoading
                                  ? null
                                  : controller.onLoginTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: AppColors.primaryGreen
                                    .withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadius34.r),
                                ),
                                elevation: 0,
                              ),
                              child: controller.form.value.isLoading
                                  ? SizedBox(
                                      height: 22.h,
                                      width: 22.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : Text(
                                      'log_in'.tr,
                                      style: TextStyle(
                                        fontSize: AppFont.font20.sp.clamp(AppFont.font12, AppFont.font32).toDouble(),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'dont_have_account'.tr,
                              style: TextStyle(
                                fontSize: AppFont.font16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.legacyColorFF57595B,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.signup),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'signup'.tr,
                                style: TextStyle(
                                  fontSize: AppFont.font16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(LoginController controller) {
    final List<String> languages = <String>['EN', 'IT', 'বাং'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD5D5D5,
        borderRadius: BorderRadius.circular(kRadius26.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (String language) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kRadius22.r),
                    onTap: () => controller.setLanguage(language),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            controller.form.value.selectedLanguage == language
                            ? AppColors.primaryGreen
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(kRadius18.r),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: AppFont.font13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              controller.form.value.selectedLanguage == language
                              ? AppColors.white
                              : AppColors.legacyColorFF545454,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return SizedBox(
      height: 138.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: AppColors.legacyColorFF7CEE3E,
              borderRadius: BorderRadius.circular(kRadius38.r),
            ),
          ),
          Positioned(
            right: -12.w,
            bottom: 0.h,
            child: SizedBox(
              width: 55.sp,
              height: 55.sp,
              child: Image.asset(
                'assets/icons_png/Background_login.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPhoneSwitcher(LoginController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD0D1D2,
        borderRadius: BorderRadius.circular(kRadius22.r),
      ),
      child: Obx(
        () => Row(
          children: <Widget>[
            Expanded(
              child: _buildModeItem(
                label: 'email'.tr,
                isSelected: controller.form.value.selectedLoginMode == 'email',
                onTap: () => controller.setLoginMode('email'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildModeItem(
                label: 'phone'.tr,
                isSelected: controller.form.value.selectedLoginMode == 'phone',
                onTap: () => controller.setLoginMode('phone'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadius20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.legacyColorFFF0F0F0 : AppColors.transparent,
          borderRadius: BorderRadius.circular(kRadius18.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryGreen : AppColors.legacyColorFF5A5A5A,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppFont.font13.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.legacyColorFF67686A,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData prefix,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFF0F0F0,
        borderRadius: BorderRadius.circular(kRadius28.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: AppFont.font16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.legacyColorFF3E4042,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(prefix, color: AppColors.legacyColorFF676767, size: 23.sp),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: AppFont.font17.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.legacyColorFFABABAB,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 15.h,
          ),
        ),
      ),
    );
  }
}
