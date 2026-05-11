import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_theme.dart';
import '../models/signup_models.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19.sp,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Expanded(child: Center(child: _buildLanguageSwitcher())),
                  SizedBox(width: 40.w),
                ],
              ),
              SizedBox(height: 18.h),
              _buildBrandMark(),
              SizedBox(height: 14.h),
              Text(
                'welcome'.tr,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 40.sp.clamp(28, 52),
                  height: 1,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'signup_tagline'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.bodyText,
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(42.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      _buildFieldLabel('field_full_name'.tr),
                      SizedBox(height: 8.h),
                      _buildInputField(
                        controller: controller.fullNameController,
                        prefix: Icons.person_outline,
                        hint: 'hint_full_name'.tr,
                      ),
                      SizedBox(height: 16.h),
                      _buildEmailPhoneSwitcher(),
                      SizedBox(height: 16.h),
                      Obx(() {
                        final SignupFormModel form = controller.form.value;
                        final bool isEmailMode = form.isEmailMode;

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
                                  ? Icons.mail_outline
                                  : Icons.phone_outlined,
                              hint: isEmailMode
                                  ? 'hint_email_signup'.tr
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
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Obx(
                        () => InkWell(
                          onTap: controller.toggleTermsAgreement,
                          borderRadius: BorderRadius.circular(20.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 2.h),
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFA2A2A2),
                                      width: 1.7,
                                    ),
                                    color: controller.form.value.agreedToTerms
                                        ? AppTheme.primaryGreen
                                        : Colors.transparent,
                                  ),
                                  child: controller.form.value.agreedToTerms
                                      ? Icon(
                                          Icons.check,
                                          size: 14.sp,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'terms_prefix'.tr,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4D5053),
                                      ),
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: 'terms_and_conditions'.tr,
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: 'terms_join'.tr),
                                        TextSpan(
                                          text: 'privacy_policy'.tr,
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                      SizedBox(height: 18.h),
                      SizedBox(
                        width: double.infinity,
                        height: 58.h,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.form.value.isLoading
                                ? null
                                : controller.onCreateAccountTap,
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
                            child: controller.form.value.isLoading
                                ? SizedBox(
                                    height: 22.h,
                                    width: 22.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'create_account'.tr,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 20.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'already_have_account'.tr,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5B5D60),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextButton(
                        onPressed: controller.onLoginTap,
                        child: Text(
                          'log_in'.tr,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildBottomBadge(Icons.shield_outlined, 'securedata'.tr),
                  SizedBox(width: 12.w),
                  _buildBottomBadge(
                    Icons.verified_outlined,
                    'official_badge'.tr,
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  _BottomDot(color: Color(0xFFCDE6BD)),
                  _BottomDot(color: Color(0xFFD8DEE9)),
                  _BottomDot(color: Color(0xFFEBD8B6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    final List<String> languages = <String>['EN', 'IT', 'বাং'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (String language) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22.r),
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
                            ? AppTheme.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              controller.form.value.selectedLanguage == language
                              ? Colors.white
                              : const Color(0xFF545454),
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
    return Container(
      width: 110.w,
      height: 110.w,
      decoration: BoxDecoration(
        color: const Color(0xFF7CEE3E),
        borderRadius: BorderRadius.circular(38.r),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 8),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPhoneSwitcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD0D1D2),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Obx(
        () => Row(
          children: <Widget>[
            Expanded(
              child: _buildModeItem(
                label: 'email'.tr,
                isSelected: controller.form.value.selectedSignupMode == 'email',
                onTap: () => controller.setSignupMode('email'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildModeItem(
                label: 'phone'.tr,
                isSelected: controller.form.value.selectedSignupMode == 'phone',
                onTap: () => controller.setSignupMode('phone'),
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
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F0F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.primaryGreen : const Color(0xFF5A5A5A),
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
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: const Color(0xFF67686A),
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
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF3E4042),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(prefix, color: const Color(0xFF676767), size: 23.sp),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFABABAB),
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

  Widget _buildBottomBadge(IconData icon, String label) {
    return Row(
      children: <Widget>[
        Icon(icon, color: const Color(0xFF9A9B9C), size: 16.sp),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9A9B9C),
          ),
        ),
      ],
    );
  }
}

class _BottomDot extends StatelessWidget {
  const _BottomDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
