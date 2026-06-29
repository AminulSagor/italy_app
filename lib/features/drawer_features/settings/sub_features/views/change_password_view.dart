import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/features/drawer_features/settings/widgets/settings_ui_widgets.dart';

class ChangePasswordView extends StatelessWidget {
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
              SettingsPillField(
                label: 'gen_current_password'.tr.tr,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              SizedBox(height: 28.h),
              SettingsPillField(
                label: 'gen_new_password'.tr.tr,
                hint: 'Create a new password',
                icon: Icons.key_rounded,
                suffixIcon: Icons.visibility_outlined,
                obscureText: true,
              ),
              SizedBox(height: 28.h),
              SettingsPillField(
                label: 'gen_confirm_new_password'.tr.tr,
                hint: 'Repeat new password',
                icon: Icons.verified_user_outlined,
                obscureText: true,
              ),
              SizedBox(height: 36.h),
              const _SecurityRequirementsCard(),
              SizedBox(height: 48.h),
              SettingsPrimaryButton(
                text: 'RESET PASSWORD  →',
                onTap: () {
                  SettingsSuccessBottomSheet.show(
                    title: 'gen_password_updated'.tr.tr,
                    subtitle: 'gen_your_password_has_been_nsucces'.tr.tr,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityRequirementsCard extends StatelessWidget {
  const _SecurityRequirementsCard();

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
          const _RequirementItem(text: 'At least 8 characters', isDone: true),
          SizedBox(height: 14.h),
          const _RequirementItem(text: 'Include a number (0–9)'),
          SizedBox(height: 14.h),
          const _RequirementItem(text: 'One special character (!@#\$)'),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isDone;

  const _RequirementItem({required this.text, this.isDone = false});

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
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: SettingsUi.text,
          ),
        ),
      ],
    );
  }
}
