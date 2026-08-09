import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';
import '../models/signup_models.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildTopBar(),
                          SizedBox(height: 14.h),

                          _buildCompactHeader(context),
                          SizedBox(height: 18.h),

                          _buildSignupCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: Get.back,
          tooltip: MaterialLocalizations.of(Get.context!).backButtonTooltip,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 42.w, minHeight: 42.w),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19.sp,
            color: AppColors.primaryGreen,
          ),
        ),
        const Spacer(),
        _buildLanguageSwitcher(),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 62.w,
          height: 62.w,
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/icons_svg/app_icon.svg',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'welcome'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: AppFont.font28.sp
                      .clamp(AppFont.font28, AppFont.font40)
                      .toDouble(),
                  height: 1.05,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'signup_tagline'.tr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildFieldLabel('field_full_name'.tr),
          SizedBox(height: 7.h),
          _buildInputField(
            controller: controller.fullNameController,
            prefix: Icons.person_outline_rounded,
            hint: 'hint_full_name'.tr,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const <String>[AutofillHints.name],
          ),

          SizedBox(height: 14.h),

          _buildEmailPhoneSwitcher(),

          SizedBox(height: 14.h),

          Obx(() {
            final SignupFormModel form = controller.form.value;
            final bool isEmailMode = form.isEmailMode;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildFieldLabel(
                  isEmailMode
                      ? 'field_email_address'.tr
                      : 'field_phone_number'.tr,
                ),
                SizedBox(height: 7.h),
                _buildInputField(
                  controller: controller.identifierController,
                  prefix: isEmailMode
                      ? Icons.mail_outline_rounded
                      : Icons.phone_outlined,
                  hint: isEmailMode ? 'hint_email_signup'.tr : 'hint_phone'.tr,
                  keyboardType: isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: isEmailMode
                      ? const <String>[AutofillHints.email]
                      : const <String>[AutofillHints.telephoneNumber],
                ),
              ],
            );
          }),

          SizedBox(height: 14.h),

          _buildFieldLabel('field_password'.tr),
          SizedBox(height: 7.h),

          Obx(
            () => _buildInputField(
              controller: controller.passwordController,
              prefix: Icons.lock_outline_rounded,
              hint: 'hint_password_mask'.tr,
              obscureText: controller.form.value.obscurePassword,
              maxLength: 128,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.newPassword],
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();

                if (!controller.form.value.isLoading) {
                  controller.onCreateAccountTap();
                }
              },
              suffix: IconButton(
                onPressed: controller.togglePasswordVisibility,
                tooltip: controller.form.value.obscurePassword
                    ? 'Show password'
                    : 'Hide password',
                icon: Icon(
                  controller.form.value.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 21.sp,
                  color: AppColors.legacyColorFF666666,
                ),
              ),
            ),
          ),

          SizedBox(height: 7.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14.sp,
                  color: AppColors.legacyColorFF67686A,
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'snack_need_upper_number'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF67686A,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 13.h),

          _buildAgreementSection(),

          SizedBox(height: 14.h),

          _buildCreateAccountButton(),

          SizedBox(height: 13.h),

          _buildLoginSection(),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Obx(() {
      final bool isAgreed = controller.form.value.agreedToTerms;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isAgreed
              ? AppColors.primaryGreen.withValues(alpha: 0.055)
              : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isAgreed
                ? AppColors.primaryGreen.withValues(alpha: 0.6)
                : AppColors.legacyColorFFECEFF0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 38.w,
              height: 38.w,
              child: Checkbox(
                value: isAgreed,
                onChanged: (_) => controller.toggleTermsAgreement(),
                activeColor: AppColors.primaryGreen,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: <Widget>[
                    Text('terms_prefix'.tr, style: _agreementTextStyle()),
                    _ExternalPolicyLink(
                      label: 'terms_and_conditions'.tr,
                      onTap: controller.openTermsAndConditions,
                    ),
                    Text('terms_join'.tr, style: _agreementTextStyle()),
                    _ExternalPolicyLink(
                      label: 'privacy_policy'.tr,
                      onTap: controller.openPrivacyPolicy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: Obx(() {
        final bool isLoading = controller.form.value.isLoading;

        return ElevatedButton(
          onPressed: isLoading ? null : controller.onCreateAccountTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            disabledBackgroundColor: AppColors.primaryGreen.withValues(
              alpha: 0.6,
            ),
            foregroundColor: AppColors.white,
            elevation: 4,
            shadowColor: AppColors.primaryGreen.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey<String>('loading'),
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey<String>('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'create_account'.tr,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppFont.font17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildLoginSection() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3.w,
      children: <Widget>[
        Text(
          'already_have_account'.tr,
          style: TextStyle(
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.legacyColorFF5B5D60,
          ),
        ),
        TextButton(
          onPressed: controller.onLoginTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'log_in'.tr,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    final List<String> languages = <String>['EN', 'IT', 'বাং'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD5D5D5,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((String language) {
            final bool isSelected =
                controller.form.value.selectedLanguage == language;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w),
              child: InkWell(
                onTap: () async {
                  await controller.setLanguage(language);
                },
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    language,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.legacyColorFF545454,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmailPhoneSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD0D1D2,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Row(
          children: <Widget>[
            Expanded(
              child: _buildModeItem(
                label: 'email'.tr,
                icon: Icons.mail_outline_rounded,
                isSelected: controller.form.value.selectedSignupMode == 'email',
                onTap: () => controller.setSignupMode('email'),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildModeItem(
                label: 'phone'.tr,
                icon: Icons.phone_outlined,
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
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(13.r),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 17.sp,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.legacyColorFF5A5A5A,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.legacyColorFF5A5A5A,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppFont.font12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.legacyColorFF67686A,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData prefix,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      obscureText: obscureText,
      autocorrect: !obscureText,
      enableSuggestions: !obscureText,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: AppFont.font16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.legacyColorFF3E4042,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppColors.legacyColorFFF0F0F0,
        prefixIcon: Icon(
          prefix,
          color: AppColors.legacyColorFF676767,
          size: 21.sp,
        ),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: AppFont.font15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.legacyColorFFABABAB,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  TextStyle _agreementTextStyle() {
    return TextStyle(
      color: AppColors.legacyColorFF4E5255,
      fontSize: AppFont.font13.sp,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );
  }
}

class _ExternalPolicyLink extends StatelessWidget {
  const _ExternalPolicyLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: AppFont.font13.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.open_in_new_rounded,
                size: 12.sp,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
