import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../models/settings_localization.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
          children: <Widget>[
            Obx(
              () => SettingsTopBar(
                title: controller.hasPassword
                    ? SettingsL10n.text('change_password')
                    : SettingsL10n.text('set_password'),
              ),
            ),
            SizedBox(height: 20.h),
            _PasswordHeader(),
            SizedBox(height: 20.h),
            Obx(
              () => controller.hasPassword
                  ? SettingsPillField(
                      label: SettingsL10n.text('current_password'),
                      hint: SettingsL10n.text('current_password_hint'),
                      icon: Icons.lock_outline_rounded,
                      controller: controller.currentPasswordController,
                      maxLength: 128,
                      obscureText: controller.obscureCurrentPassword.value,
                      suffixIcon: controller.obscureCurrentPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: controller.toggleCurrentPasswordVisibility,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.password],
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => controller.hasPassword
                  ? SizedBox(height: 16.h)
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => SettingsPillField(
                label: SettingsL10n.text('new_password'),
                hint: SettingsL10n.text('new_password_hint'),
                icon: Icons.password_rounded,
                controller: controller.newPasswordController,
                maxLength: 128,
                obscureText: controller.obscureNewPassword.value,
                suffixIcon: controller.obscureNewPassword.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixTap: controller.toggleNewPasswordVisibility,
                onChanged: controller.onNewPasswordChanged,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.newPassword],
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => SettingsPillField(
                label: SettingsL10n.text('confirm_password'),
                hint: SettingsL10n.text('confirm_password_hint'),
                icon: Icons.check_circle_outline_rounded,
                controller: controller.confirmPasswordController,
                obscureText: controller.obscureConfirmPassword.value,
                suffixIcon: controller.obscureConfirmPassword.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixTap: controller.toggleConfirmPasswordVisibility,
                onChanged: controller.onConfirmPasswordChanged,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
              ),
            ),
            SizedBox(height: 18.h),
            Obx(
              () => _PasswordRequirements(
                minimumLength: controller.hasPasswordMinimumLength,
                matches: controller.passwordsMatch,
              ),
            ),
            SizedBox(height: 22.h),
            Obx(
              () => SettingsPrimaryButton(
                text: controller.hasPassword
                    ? SettingsL10n.text('update_password')
                    : SettingsL10n.text('set_password'),
                icon: Icons.lock_reset_rounded,
                enabled: !controller.isChangingPassword.value,
                isLoading: controller.isChangingPassword.value,
                onTap: () async {
                  final bool saved = await controller.submitPasswordChange();
                  if (!saved) return;
                  await SettingsSuccessBottomSheet.show(
                    title: SettingsL10n.text('password_updated'),
                    subtitle: SettingsL10n.text('password_updated_desc'),
                    onDone: Get.back,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security_rounded,
              size: 25.r,
              color: SettingsUi.primary,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Text(
              SettingsL10n.text('password_intro'),
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: SettingsUi.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({
    required this.minimumLength,
    required this.matches,
  });

  final bool minimumLength;
  final bool matches;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: SettingsUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            SettingsL10n.text('password_requirements'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: SettingsUi.text,
            ),
          ),
          SizedBox(height: 12.h),
          _Requirement(
            text: SettingsL10n.text('password_minimum'),
            met: minimumLength,
          ),
          _Requirement(
            text: SettingsL10n.text('password_match'),
            met: matches,
            showBottomPadding: false,
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.text,
    required this.met,
    this.showBottomPadding = true,
  });

  final String text;
  final bool met;
  final bool showBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomPadding ? 9.h : 0),
      child: Row(
        children: <Widget>[
          Icon(
            met
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18.r,
            color: met ? SettingsUi.primary : const Color(0xFFA7B0AC),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: met ? SettingsUi.primaryDark : SettingsUi.muted,
                fontWeight: met ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
