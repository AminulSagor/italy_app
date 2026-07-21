import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../models/settings_localization.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class ProfileSecurityView extends GetView<SettingsController> {
  const ProfileSecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: Obx(() {
          final profile = controller.profile.value;
          if (profile == null) {
            return Center(
              child: CircularProgressIndicator(color: SettingsUi.primary),
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
            children: <Widget>[
              SettingsTopBar(title: SettingsL10n.text('edit_profile')),
              SizedBox(height: 18.h),
              Center(
                child: _EditableAvatar(
                  avatarUrl: profile.avatarUrl,
                  onTap: () => Get.toNamed(AppRoutes.profilePhoto),
                ),
              ),
              SizedBox(height: 20.h),
              SettingsPillField(
                label: SettingsL10n.text('full_name'),
                hint: SettingsL10n.text('full_name_hint'),
                icon: Icons.person_outline_rounded,
                controller: controller.fullNameController,
                textInputAction: TextInputAction.next,
                maxLength: 120,
                autofillHints: const <String>[AutofillHints.name],
              ),
              SizedBox(height: 18.h),
              _ContactSelector(
                selected: controller.editProfileTab.value,
                emailEnabled: profile.canChangeEmail,
                phoneEnabled: profile.canChangePhone,
                onSelected: controller.setEditProfileTab,
              ),
              SizedBox(height: 12.h),
              SettingsPillField(
                label: controller.selectedContactIsEmail
                    ? SettingsL10n.text('email')
                    : SettingsL10n.text('phone'),
                hint: controller.selectedContactIsEmail
                    ? SettingsL10n.text('email_hint')
                    : SettingsL10n.text('phone_hint'),
                icon: controller.selectedContactIsEmail
                    ? Icons.email_outlined
                    : Icons.phone_outlined,
                controller: controller.selectedContactController,
                keyboardType: controller.selectedContactIsEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: controller.canChangeSelectedContact,
                autofillHints: controller.selectedContactIsEmail
                    ? const <String>[AutofillHints.email]
                    : const <String>[AutofillHints.telephoneNumber],
                onChanged: controller.selectedContactIsEmail
                    ? controller.onEmailChanged
                    : controller.onPhoneChanged,
                helperText: controller.canChangeSelectedContact
                    ? null
                    : SettingsL10n.text('change_unavailable'),
              ),
              SizedBox(height: 10.h),
              _VerificationStatus(
                isVerified: controller.selectedContactVerified,
              ),
              SizedBox(height: 14.h),
              _OtpInformationCard(),
              SizedBox(height: 22.h),
              SettingsPrimaryButton(
                text: SettingsL10n.text('save_changes'),
                icon: Icons.save_outlined,
                enabled: !controller.isProfileBusy,
                isLoading: controller.isProfileBusy,
                onTap: () async {
                  final ProfileSaveResult result =
                      await controller.saveProfileAndContinue();
                  if (result == ProfileSaveResult.saved) {
                    await SettingsSuccessBottomSheet.show(
                      title: SettingsL10n.text('profile_updated'),
                      subtitle: SettingsL10n.text('profile_updated_desc'),
                    );
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({required this.avatarUrl, required this.onTap});

  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: SettingsL10n.text('profile_photo'),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: 94.r,
              height: 94.r,
              padding: EdgeInsets.all(3.r),
              decoration: const BoxDecoration(
                color: Color(0xFFD7F2E8),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: avatarUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            Positioned(
              right: -1.w,
              bottom: 1.h,
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: SettingsUi.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 17.r,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: SettingsUi.primaryDark,
        child: Icon(Icons.person_rounded, size: 57.r, color: Colors.white),
      );
}

class _ContactSelector extends StatelessWidget {
  const _ContactSelector({
    required this.selected,
    required this.emailEnabled,
    required this.phoneEnabled,
    required this.onSelected,
  });

  final String selected;
  final bool emailEnabled;
  final bool phoneEnabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFEC),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ContactTab(
              title: SettingsL10n.text('email'),
              icon: Icons.email_outlined,
              selected: selected == 'email',
              enabled: emailEnabled,
              onTap: () => onSelected('email'),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: _ContactTab(
              title: SettingsL10n.text('phone'),
              icon: Icons.phone_outlined,
              selected: selected == 'phone',
              enabled: phoneEnabled,
              onTap: () => onSelected('phone'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTab extends StatelessWidget {
  const _ContactTab({
    required this.title,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 160),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(13.r),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(13.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 18.r,
                  color: selected ? SettingsUi.primary : SettingsUi.muted,
                ),
                SizedBox(width: 7.w),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: selected ? SettingsUi.text : SettingsUi.muted,
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
}

class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
          size: 18.r,
          color: isVerified ? SettingsUi.primary : SettingsUi.muted,
        ),
        SizedBox(width: 7.w),
        Text(
          SettingsL10n.text(isVerified ? 'verified' : 'not_verified'),
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: isVerified ? SettingsUi.primary : SettingsUi.muted,
          ),
        ),
      ],
    );
  }
}

class _OtpInformationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.shield_outlined, size: 21.r, color: SettingsUi.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              SettingsL10n.text('otp_required_notice'),
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color: SettingsUi.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
