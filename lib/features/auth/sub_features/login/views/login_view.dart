import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../routes/routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double height = constraints.maxHeight;
            final double width = constraints.maxWidth;

            final bool keyboardOpen =
                MediaQuery.viewInsetsOf(context).bottom > 0;

            final bool ultraCompact = height < 540;
            final bool veryCompact = height < 650;
            final bool compact = height < 760;
            final bool dense = compact || keyboardOpen;

            final bool showBranding = !keyboardOpen && !ultraCompact;
            final bool showSubtitle = !keyboardOpen && height >= 650;
            final bool showSocialLogin = !keyboardOpen;
            final bool showSignup = !keyboardOpen;

            final double horizontalPadding = width < 360 ? 20.w : 24.w;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: keyboardOpen ? 12.h : 20.h,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // TOP SECTION: Language + Header + Form
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (!keyboardOpen) ...<Widget>[
                              _buildLanguageSwitcher(
                                controller,
                                compact: dense,
                              ),
                              SizedBox(height: dense ? 12.h : 20.h),
                            ],

                            // Branding
                            if (showBranding) ...<Widget>[
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons_svg/app_icon.svg',
                                  width: veryCompact ? 40.w : 48.w,
                                  height: veryCompact ? 40.w : 48.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: veryCompact ? 8.h : 12.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'app_name'.tr,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        fontSize: compact ? 22.sp : 26.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: const Color(0xFF1F2937),
                                        height: 1.1,
                                      ),
                                ),
                              ),
                              if (showSubtitle) ...<Widget>[
                                SizedBox(height: 4.h),
                                Text(
                                  'unlock_career'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppFont.font13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                              SizedBox(height: dense ? 16.h : 22.h),
                            ],

                            // Email / Phone Mode Switcher
                            _buildEmailPhoneSwitcher(
                              controller,
                              compact: dense,
                            ),
                            SizedBox(height: keyboardOpen ? 12.h : 16.h),

                            // Dynamic Input Field (Email/Phone)
                            Obx(() {
                              final bool isEmailMode =
                                  controller.form.value.selectedLoginMode ==
                                  'email';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _buildFieldLabel(
                                    isEmailMode
                                        ? 'field_email_address'.tr
                                        : 'field_phone_number'.tr,
                                    compact: dense,
                                  ),
                                  SizedBox(height: 6.h),
                                  _buildInputField(
                                    controller: controller.identifierController,
                                    prefix: isEmailMode
                                        ? Icons.alternate_email_rounded
                                        : Icons.phone_outlined,
                                    hint: isEmailMode
                                        ? 'hint_email_login'.tr
                                        : 'hint_phone'.tr,
                                    keyboardType: isEmailMode
                                        ? TextInputType.emailAddress
                                        : TextInputType.phone,
                                    compact: dense,
                                  ),
                                ],
                              );
                            }),
                            SizedBox(height: keyboardOpen ? 10.h : 14.h),

                            // Password
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildFieldLabel(
                                'field_password'.tr,
                                compact: dense,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Obx(
                              () => _buildInputField(
                                controller: controller.passwordController,
                                prefix: Icons.lock_outline_rounded,
                                hint: 'hint_password_mask'.tr,
                                obscureText:
                                    controller.form.value.obscurePassword,
                                compact: dense,
                                suffix: IconButton(
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                  padding: EdgeInsets.zero,
                                  splashRadius: 18.r,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    controller.form.value.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF9CA3AF),
                                    size: 19.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.forgotPassword),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.h,
                                    horizontal: 4.w,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  'forgot_password'.tr,
                                  style: TextStyle(
                                    fontSize: AppFont.font13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 12.h : 18.h),

                            // Primary Action Button (Login)
                            SizedBox(
                              width: double.infinity,
                              height: compact ? 46.h : 50.h,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed: controller.form.value.isLoading
                                      ? null
                                      : controller.onLoginTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors
                                        .primaryGreen
                                        .withValues(alpha: 0.55),
                                    elevation: 0,
                                    shadowColor: AppColors.primaryGreen
                                        .withValues(alpha: 0.25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  child: controller.form.value.isLoading
                                      ? SizedBox(
                                          height: 20.r,
                                          width: 20.r,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: AppColors.white,
                                              ),
                                        )
                                      : Text(
                                          'log_in'.tr,
                                          style: TextStyle(
                                            fontSize: AppFont.font15.sp,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // BOTTOM SECTION: Social Options & Signup
                        if (showSocialLogin || showSignup)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (showSocialLogin) ...<Widget>[
                                SizedBox(height: dense ? 16.h : 22.h),
                                _buildSocialDivider(compact: dense),
                                SizedBox(height: dense ? 14.h : 18.h),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Obx(
                                        () => _buildPrimaryGoogleButton(
                                          isLoading:
                                              controller
                                                  .socialLoadingProvider
                                                  .value ==
                                              'google',
                                          enabled:
                                              controller
                                                      .socialLoadingProvider
                                                      .value ==
                                                  null &&
                                              !controller.form.value.isLoading,
                                          onTap: controller.onGoogleLogin,
                                          compact: dense,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Obx(
                                        () => _buildFacebookButton(
                                          isLoading:
                                              controller
                                                  .socialLoadingProvider
                                                  .value ==
                                              'facebook',
                                          enabled:
                                              controller
                                                      .socialLoadingProvider
                                                      .value ==
                                                  null &&
                                              !controller.form.value.isLoading,
                                          onTap: controller.onFacebookLogin,
                                          compact: dense,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (Platform.isIOS) ...<Widget>[
                                  SizedBox(height: 12.h),
                                  Obx(
                                    () => _buildAppleButton(
                                      isLoading:
                                          controller
                                              .socialLoadingProvider
                                              .value ==
                                          'apple',
                                      enabled:
                                          controller
                                                  .socialLoadingProvider
                                                  .value ==
                                              null &&
                                          !controller.form.value.isLoading,
                                      onTap: controller.onAppleLogin,
                                      compact: dense,
                                    ),
                                  ),
                                ],
                              ],
                              if (showSignup) ...<Widget>[
                                SizedBox(height: dense ? 18.h : 24.h),
                                _buildSignupFooter(compact: dense),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Google Standard Brand Button (#4285F4)
  Widget _buildPrimaryGoogleButton({
    required bool isLoading,
    required bool enabled,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return SizedBox(
      height: compact ? 46.h : 50.h,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFF4285F4,
          ).withValues(alpha: 0.55),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 26.r,
                    height: 26.r,
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: FittedBox(fit: BoxFit.contain, child: _GoogleIcon()),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Google',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: compact
                              ? AppFont.font13.sp
                              : AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Facebook Standard Button (#1877F2)
  Widget _buildFacebookButton({
    required bool isLoading,
    required bool enabled,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return SizedBox(
      height: compact ? 46.h : 50.h,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFF1877F2,
          ).withValues(alpha: 0.55),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 26.r,
                    height: 26.r,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'f',
                      style: TextStyle(
                        color: const Color(0xFF1877F2),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Facebook',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: compact
                              ? AppFont.font13.sp
                              : AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppleButton({
    required bool isLoading,
    required bool enabled,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final double height = compact ? 46.h : 50.h;
    if (isLoading) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: SignInWithAppleButton(
          onPressed: onTap,
          style: SignInWithAppleButtonStyle.black,
          height: height,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }

  Widget _buildSocialDivider({required bool compact}) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12.w : 14.w,
              vertical: compact ? 5.h : 6.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.login_rounded,
                  size: compact ? 13.sp : 14.sp,
                  color: AppColors.primaryGreen,
                ),
                SizedBox(width: 6.w),
                Text(
                  _socialText('or'),
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: compact ? AppFont.font12.sp : AppFont.font13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
      ],
    );
  }

  String _socialText(String key) {
    final String language = Get.locale?.languageCode.toLowerCase() ?? 'en';

    const Map<String, Map<String, String>> labels =
        <String, Map<String, String>>{
          'en': <String, String>{'or': 'Or continue with'},
          'it': <String, String>{'or': 'Oppure accedi con'},
          'bn': <String, String>{'or': 'অথবা লগইন করুন'},
        };

    return labels[language]?[key] ?? labels['en']![key]!;
  }

  Widget _buildLanguageSwitcher(
    LoginController controller, {
    required bool compact,
  }) {
    final List<String> languages = <String>['EN', 'IT', 'বাং'];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F3),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((String language) {
            final bool isSelected =
                controller.form.value.selectedLanguage == language;

            return InkWell(
              onTap: () => controller.setLanguage(language),
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12.w : 14.w,
                  vertical: compact ? 5.h : 6.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: isSelected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.white
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmailPhoneSwitcher(
    LoginController controller, {
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Obx(
        () => Row(
          children: <Widget>[
            Expanded(
              child: _buildModeItem(
                label: 'email'.tr,
                isSelected: controller.form.value.selectedLoginMode == 'email',
                onTap: () => controller.setLoginMode('email'),
                compact: compact,
              ),
            ),
            Expanded(
              child: _buildModeItem(
                label: 'phone'.tr,
                isSelected: controller.form.value.selectedLoginMode == 'phone',
                onTap: () => controller.setLoginMode('phone'),
                compact: compact,
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
    required bool compact,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: compact ? 8.h : 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: AppFont.font13.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF111827)
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, {required bool compact}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? AppFont.font12.sp : AppFont.font13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData prefix,
    required String hint,
    required bool compact,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      height: compact ? 46.h : 50.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(prefix, color: const Color(0xFF9CA3AF), size: 20.sp),
          prefixIconConstraints: BoxConstraints(
            minWidth: compact ? 42.w : 46.w,
          ),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: compact ? 12.h : 14.h,
            horizontal: 14.w,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupFooter({required bool compact}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            'dont_have_account'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? AppFont.font13.sp : AppFont.font14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.signup),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            child: Text(
              'signup'.tr,
              style: TextStyle(
                fontSize: compact ? AppFont.font13.sp : AppFont.font14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Vector Google 'G' icon for standard brand compliance
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(20, 20), painter: _GoogleIconPainter());
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint redPaint = Paint()..color = const Color(0xFEEA4335);
    final Paint bluePaint = Paint()..color = const Color(0xFE4285F4);
    final Paint yellowPaint = Paint()..color = const Color(0xFEFBBC05);
    final Paint greenPaint = Paint()..color = const Color(0xFE34A853);

    final Path redPath = Path()
      ..moveTo(width * 0.5, height * 0.19)
      ..cubicTo(
        width * 0.63,
        height * 0.19,
        width * 0.74,
        height * 0.24,
        width * 0.82,
        height * 0.32,
      )
      ..lineTo(width * 0.95, height * 0.19)
      ..cubicTo(width * 0.83, height * 0.07, width * 0.68, 0, width * 0.5, 0)
      ..cubicTo(
        width * 0.31,
        0,
        width * 0.15,
        height * 0.11,
        width * 0.07,
        height * 0.27,
      )
      ..lineTo(width * 0.23, height * 0.39)
      ..cubicTo(
        width * 0.28,
        height * 0.27,
        width * 0.38,
        height * 0.19,
        width * 0.5,
        height * 0.19,
      );
    canvas.drawPath(redPath, redPaint);

    final Path bluePath = Path()
      ..moveTo(width, height * 0.5)
      ..cubicTo(
        width,
        height * 0.46,
        width * 0.99,
        height * 0.41,
        width * 0.98,
        height * 0.36,
      )
      ..lineTo(width * 0.5, height * 0.36)
      ..lineTo(width * 0.5, height * 0.55)
      ..lineTo(width * 0.78, height * 0.55)
      ..cubicTo(
        width * 0.77,
        height * 0.63,
        width * 0.71,
        height * 0.72,
        width * 0.62,
        height * 0.78,
      )
      ..lineTo(width * 0.78, height * 0.9)
      ..cubicTo(
        width * 0.91,
        height * 0.78,
        width,
        height * 0.6,
        width,
        height * 0.5,
      );
    canvas.drawPath(bluePath, bluePaint);

    final Path yellowPath = Path()
      ..moveTo(width * 0.23, height * 0.39)
      ..cubicTo(
        width * 0.2,
        height * 0.45,
        width * 0.19,
        height * 0.5,
        width * 0.19,
        height * 0.55,
      )
      ..cubicTo(
        width * 0.19,
        height * 0.61,
        width * 0.2,
        height * 0.66,
        width * 0.23,
        height * 0.72,
      )
      ..lineTo(width * 0.07, height * 0.84)
      ..cubicTo(width * 0.02, height * 0.75, 0, height * 0.63, 0, height * 0.53)
      ..cubicTo(
        0,
        height * 0.43,
        width * 0.02,
        height * 0.31,
        width * 0.07,
        height * 0.22,
      )
      ..lineTo(width * 0.23, height * 0.39);
    canvas.drawPath(yellowPath, yellowPaint);

    final Path greenPath = Path()
      ..moveTo(width * 0.5, height)
      ..cubicTo(
        width * 0.68,
        height,
        width * 0.83,
        height * 0.94,
        width * 0.92,
        height * 0.83,
      )
      ..lineTo(width * 0.76, height * 0.71)
      ..cubicTo(
        width * 0.69,
        height * 0.76,
        width * 0.6,
        height * 0.79,
        width * 0.5,
        height * 0.79,
      )
      ..cubicTo(
        width * 0.38,
        height * 0.79,
        width * 0.28,
        height * 0.71,
        width * 0.23,
        height * 0.59,
      )
      ..lineTo(width * 0.07, height * 0.71)
      ..cubicTo(
        width * 0.15,
        height * 0.88,
        width * 0.31,
        height,
        width * 0.5,
        height,
      );
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
