import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../routes/routes.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

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
              SettingsTopBar(title: 'gen_edit_profile'.tr),
              SizedBox(height: 49.h),
              Obx(
                () => _ProfileAvatar(
                  avatarUrl: controller.profile.value?.avatarUrl,
                  onTap: () => Get.toNamed(AppRoutes.profilePhoto),
                ),
              ),
              SizedBox(height: 27.h),
              SettingsPillField(
                label: 'gen_full_name_1'.tr,
                hint: 'enter_your_full_name'.tr,
                icon: Icons.person_outline_rounded,
                controller: controller.fullNameController,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 24.h),
              Obx(
                () => _SegmentedSwitch(
                  isEmail: controller.selectedContactIsEmail,
                  onEmailTap: () => controller.setEditProfileTab('email'),
                  onPhoneTap: () => controller.setEditProfileTab('phone'),
                ),
              ),
              SizedBox(height: 13.h),
              Obx(
                () => SettingsPillField(
                  label: controller.selectedContactIsEmail ? 'email'.tr : 'phone'.tr,
                  hint: controller.selectedContactIsEmail
                      ? 'enter_your_new_email'.tr
                      : 'enter_your_new_phone_number'.tr,
                  icon: controller.selectedContactIsEmail
                      ? Icons.alternate_email_rounded
                      : Icons.phone_rounded,
                  controller: controller.selectedContactController,
                  onChanged: controller.selectedContactIsEmail
                      ? controller.onEmailChanged
                      : controller.onPhoneChanged,
                  keyboardType: controller.selectedContactIsEmail
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  suffixIcon: controller.selectedContactChanged
                      ? Icons.verified_user_outlined
                      : Icons.verified_rounded,
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => _ContactVerificationCard(
                  isVerified: controller.selectedContactVerified,
                  isEmail: controller.selectedContactIsEmail,
                  hasChanged: controller.selectedContactChanged,
                ),
              ),
              SizedBox(height: 36.h),
              Obx(
                () => SettingsPrimaryButton(
                  text: controller.selectedContactChanged
                      ? 'save_verify'.tr
                      : 'save_changes'.tr,
                  icon: controller.selectedContactChanged
                      ? Icons.mark_email_read_outlined
                      : Icons.save_rounded,
                  isLoading:
                      controller.isSavingName.value ||
                      controller.isRequestingContactOtp.value,
                  onTap: () async {
                    final ProfileSaveResult result =
                        await controller.saveProfileAndContinue();
                    if (result == ProfileSaveResult.saved) {
                      await SettingsSuccessBottomSheet.show(
                        title: 'profile_updated'.tr,
                        subtitle:
                            'your_profile_information_has_been_updated_successf'.tr,
                      );
                    } else if (result == ProfileSaveResult.noChanges) {
                      Get.snackbar('profile'.tr, 'there_are_no_changes_to_save'.tr);
                    }
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
              text: 'field_email'.tr,
              selected: isEmail,
              onTap: onEmailTap,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              text: 'field_phone'.tr,
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

class _ContactVerificationCard extends StatelessWidget {
  const _ContactVerificationCard({
    required this.isVerified,
    required this.isEmail,
    required this.hasChanged,
  });

  final bool isVerified;
  final bool isEmail;
  final bool hasChanged;

  @override
  Widget build(BuildContext context) {
    final String contactName = isEmail ? 'email_address'.tr : 'phone_number'.tr;
    final String message = hasChanged
        ? 'otp_will_be_sent'.trParams({'contact': contactName})
        : isVerified
        ? 'current_contact_verified'.trParams({'contact': contactName})
        : 'enter_contact_and_verify'.trParams({'contact': contactName});

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: hasChanged
            ? const Color(0xFFDCEBFF)
            : const Color(0xFFE3F8D9),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            hasChanged
                ? Icons.mark_email_unread_outlined
                : Icons.verified_user_outlined,
            color: hasChanged ? const Color(0xFF0064A8) : SettingsUi.green,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              message,
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
