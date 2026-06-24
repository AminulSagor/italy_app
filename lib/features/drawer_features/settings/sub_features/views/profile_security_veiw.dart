import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';
import '../../../../../routes/routes.dart';

class ProfileSecurityView extends GetView<SettingsController> {
  const ProfileSecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 58.h),
          child: Column(
            children: <Widget>[
              const SettingsTopBar(title: 'Edit Profile'),
              SizedBox(height: 49.h),
              Obx(
                () => _ProfileAvatar(
                  avatarUrl: controller.profile.value?.avatarUrl,
                  onTap: () => Get.toNamed(AppRoutes.profilePhoto),
                ),
              ),
              SizedBox(height: 27.h),
              SettingsPillField(
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                controller: controller.fullNameController,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 24.h),
              Obx(() {
                final bool isEmail = controller.editProfileTab.value == 'email';
                return _SegmentedSwitch(
                  isEmail: isEmail,
                  onEmailTap: () => controller.setEditProfileTab('email'),
                  onPhoneTap: () => controller.setEditProfileTab('phone'),
                );
              }),
              SizedBox(height: 13.h),
              Obx(() {
                final bool isEmail = controller.editProfileTab.value == 'email';
                return _ReadOnlyContactField(
                  label: isEmail ? 'Email' : 'Phone',
                  value: controller.selectedContactValue,
                  icon: isEmail
                      ? Icons.alternate_email_rounded
                      : Icons.phone_rounded,
                );
              }),
              SizedBox(height: 24.h),
              Obx(
                () => _ContactLockCard(
                  isVerified: controller.selectedContactVerified,
                  isEmail: controller.editProfileTab.value == 'email',
                ),
              ),
              SizedBox(height: 36.h),
              Obx(
                () => SettingsPrimaryButton(
                  text: 'SAVE CHANGES',
                  icon: Icons.save_rounded,
                  isLoading: controller.isSavingName.value,
                  onTap: () async {
                    final bool updated = await controller.saveFullName();
                    if (!updated) return;

                    await SettingsSuccessBottomSheet.show(
                      title: 'Profile Updated!',
                      subtitle: 'Your full name has been updated successfully.',
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.onTap});

  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128.r,
      height: 128.r,
      child: Stack(
        children: <Widget>[
          Container(
            width: 128.r,
            height: 128.r,
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SettingsUi.lightGreen, width: 4.w),
            ),
            child: ClipOval(child: _AvatarImage(avatarUrl: avatarUrl)),
          ),
          Positioned(
            right: 0,
            bottom: 9.h,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: SettingsUi.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 22.r,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String url = avatarUrl?.trim() ?? '';
    if (url.isEmpty) return const _AvatarFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B242D),
      child: Icon(Icons.person_rounded, size: 72.r, color: Colors.white),
    );
  }
}

class _SegmentedSwitch extends StatelessWidget {
  const _SegmentedSwitch({
    required this.isEmail,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  final bool isEmail;
  final VoidCallback onEmailTap;
  final VoidCallback onPhoneTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              text: 'EMAIL',
              selected: isEmail,
              onTap: onEmailTap,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              text: 'PHONE',
              selected: !isEmail,
              onTap: onPhoneTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: selected ? SettingsUi.green : SettingsUi.muted,
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyContactField extends StatelessWidget {
  const _ReadOnlyContactField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 24.w, bottom: 10.h),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22.r, color: SettingsUi.green),
              SizedBox(width: 18.w),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: SettingsUi.text,
                  ),
                ),
              ),
              Icon(Icons.lock_outline_rounded, size: 20.r),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactLockCard extends StatelessWidget {
  const _ContactLockCard({required this.isVerified, required this.isEmail});

  final bool isVerified;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    final String contactName = isEmail ? 'email address' : 'phone number';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFFE3F8D9)
            : const Color(0xFFFFF1D3),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: isVerified ? SettingsUi.green : const Color(0xFFB36A00),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              isVerified
                  ? 'Your verified $contactName cannot be changed.'
                  : 'This $contactName is not verified and cannot be edited from settings.',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: SettingsUi.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
