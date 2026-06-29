import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 39.h),
          child: Column(
            children: <Widget>[
              const SettingsTopBar(title: 'Change Password'),
              SizedBox(height: 52.h),
              Container(
                width: 80.r,
                height: 80.r,
                decoration: const BoxDecoration(
                  color: SettingsUi.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 42.r,
                  color: SettingsUi.green,
                ),
              ),
              SizedBox(height: 27.h),
              Text(
                'Keep your account secure by updating your\ncredentials frequently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: SettingsUi.muted,
                ),
              ),
              SizedBox(height: 43.h),
              Obx(
                () => SettingsPillField(
                  label: 'Current Password',
                  hint: 'Enter current password',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: controller.obscureCurrentPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  obscureText: controller.obscureCurrentPassword.value,
                  controller: controller.currentPasswordController,
                  onSuffixTap: controller.toggleCurrentPasswordVisibility,
                ),
              ),
              SizedBox(height: 28.h),
              Obx(
                () => SettingsPillField(
                  label: 'New Password',
                  hint: 'Create a new password',
                  icon: Icons.key_rounded,
                  suffixIcon: controller.obscureNewPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  obscureText: controller.obscureNewPassword.value,
                  controller: controller.newPasswordController,
                  onChanged: controller.onNewPasswordChanged,
                  onSuffixTap: controller.toggleNewPasswordVisibility,
                ),
              ),
              SizedBox(height: 28.h),
              Obx(
                () => SettingsPillField(
                  label: 'Confirm New Password',
                  hint: 'Repeat new password',
                  icon: Icons.verified_user_outlined,
                  suffixIcon: controller.obscureConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  obscureText: controller.obscureConfirmPassword.value,
                  controller: controller.confirmPasswordController,
                  onChanged: controller.onConfirmPasswordChanged,
                  onSuffixTap: controller.toggleConfirmPasswordVisibility,
                ),
              ),
              SizedBox(height: 36.h),
              Obx(
                () => _SecurityRequirementsCard(
                  hasMinimumLength: controller.hasPasswordMinimumLength,
                  hasUppercase: controller.hasPasswordUppercase,
                  hasNumber: controller.hasPasswordNumber,
                  hasSpecialCharacter:
                      controller.hasPasswordSpecialCharacter,
                  passwordsMatch: controller.passwordsMatch,
                ),
              ),
              SizedBox(height: 48.h),
              Obx(
                () => SettingsPrimaryButton(
                  text: 'RESET PASSWORD  →',
                  isLoading: controller.isChangingPassword.value,
                  onTap: () async {
                    final bool changed =
                        await controller.submitPasswordChange();
                    if (!changed) return;

                    await SettingsSuccessBottomSheet.show(
                      title: 'Password Updated!',
                      subtitle: 'Your password has been updated successfully.',
                      onDone: () {
                        Get.back<void>();
                        Get.back<void>();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityRequirementsCard extends StatelessWidget {
  const _SecurityRequirementsCard({
    required this.hasMinimumLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecialCharacter,
    required this.passwordsMatch,
  });

  final bool hasMinimumLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialCharacter;
  final bool passwordsMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(25.w, 25.h, 25.w, 25.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Security Requirements',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: SettingsUi.text,
            ),
          ),
          SizedBox(height: 19.h),
          _RequirementItem(
            text: 'At least 8 characters',
            isDone: hasMinimumLength,
          ),
          SizedBox(height: 14.h),
          _RequirementItem(
            text: 'One uppercase letter (A–Z)',
            isDone: hasUppercase,
          ),
          SizedBox(height: 14.h),
          _RequirementItem(
            text: 'Include a number (0–9)',
            isDone: hasNumber,
          ),
          SizedBox(height: 14.h),
          _RequirementItem(
            text: 'One special character (!@#\$)',
            isDone: hasSpecialCharacter,
          ),
          SizedBox(height: 14.h),
          _RequirementItem(
            text: 'Both new passwords match',
            isDone: passwordsMatch,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.text, required this.isDone});

  final String text;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color: isDone ? SettingsUi.green : const Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : Icons.circle,
            size: isDone ? 16.r : 7.r,
            color: isDone ? Colors.white : const Color(0xFF8A8A8A),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: SettingsUi.text,
            ),
          ),
        ),
      ],
    );
  }
}
