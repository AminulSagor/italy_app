import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/settings_localization.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class ProfilePhotoView extends GetView<SettingsController> {
  const ProfilePhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
          children: <Widget>[
            SettingsTopBar(title: SettingsL10n.text('profile_photo')),
            SizedBox(height: 22.h),
            Obx(
              () => Center(
                child: _PhotoPreview(
                  selectedImage: controller.selectedAvatar.value,
                  currentAvatarUrl: controller.profile.value?.avatarUrl,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              SettingsL10n.text('photo_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: SettingsUi.text,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              SettingsL10n.text('photo_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.4,
                color: SettingsUi.muted,
              ),
            ),
            SizedBox(height: 22.h),
            _PhotoSourceButton(
              icon: Icons.camera_alt_outlined,
              title: SettingsL10n.text('take_photo'),
              onTap: () => controller.pickAvatar(ImageSource.camera),
            ),
            SizedBox(height: 10.h),
            _PhotoSourceButton(
              icon: Icons.photo_library_outlined,
              title: SettingsL10n.text('choose_gallery'),
              onTap: () => controller.pickAvatar(ImageSource.gallery),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => SettingsPrimaryButton(
                text: SettingsL10n.text('confirm_photo'),
                icon: Icons.check_rounded,
                enabled: controller.selectedAvatar.value != null &&
                    !controller.isUploadingAvatar.value,
                isLoading: controller.isUploadingAvatar.value,
                onTap: () async {
                  final bool saved = await controller.uploadSelectedAvatar();
                  if (!saved) return;
                  await SettingsSuccessBottomSheet.show(
                    title: SettingsL10n.text('photo_updated'),
                    subtitle: SettingsL10n.text('photo_updated_desc'),
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

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.selectedImage,
    required this.currentAvatarUrl,
  });

  final XFile? selectedImage;
  final String? currentAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184.r,
      height: 184.r,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F2E8),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SettingsUi.primary.withValues(alpha: 0.12),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipOval(child: _image()),
    );
  }

  Widget _image() {
    if (selectedImage != null) {
      return Image.file(
        File(selectedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackPhoto(),
      );
    }

    final String url = currentAvatarUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackPhoto(),
      );
    }

    return const _FallbackPhoto();
  }
}

class _FallbackPhoto extends StatelessWidget {
  const _FallbackPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SettingsUi.primaryDark,
      child: Icon(Icons.person_rounded, size: 105.r, color: Colors.white),
    );
  }
}

class _PhotoSourceButton extends StatelessWidget {
  const _PhotoSourceButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: SettingsUi.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F2),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(icon, size: 22.r, color: SettingsUi.primary),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: SettingsUi.text,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 23.r,
                color: SettingsUi.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
