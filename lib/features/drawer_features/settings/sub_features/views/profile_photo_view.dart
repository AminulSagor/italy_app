import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class ProfilePhotoView extends GetView<SettingsController> {
  const ProfilePhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 28.h),
          child: Column(
            children: <Widget>[
              SettingsTopBar(title: 'gen_profile_photo'.tr),
              SizedBox(height: 61.h),
              Obx(
                () => _PhotoPreview(
                  selectedPath: controller.selectedAvatar.value?.path,
                  avatarUrl: controller.profile.value?.avatarUrl,
                ),
              ),
              SizedBox(height: 34.h),
              Text(
                'say_cheese'.tr,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w900,
                  color: SettingsUi.text,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Add a photo so your friends can\nrecognize you in the Italian class.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: SettingsUi.muted,
                ),
              ),
              SizedBox(height: 47.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PhotoOptionCard(
                      title: 'gen_take_a_photo'.tr,
                      icon: Icons.camera_alt_outlined,
                      bgColor: const Color(0xFFD7FFC6),
                      iconBgColor: SettingsUi.lightGreen,
                      iconColor: SettingsUi.green,
                      onTap: () => controller.pickAvatar(ImageSource.camera),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _PhotoOptionCard(
                      title: 'gen_choose_from_ngallery'.tr,
                      icon: Icons.image_rounded,
                      bgColor: const Color(0xFFDCEBFF),
                      iconBgColor: const Color(0xFFA9D0FF),
                      iconColor: const Color(0xFF005A97),
                      onTap: () => controller.pickAvatar(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),
              const _PhotoTipCard(),
              SizedBox(height: 39.h),
              Obx(
                () => SettingsPrimaryButton(
                  text: 'confirm_photo'.tr,
                  enabled: controller.selectedAvatar.value != null,
                  isLoading: controller.isUploadingAvatar.value,
                  onTap: () async {
                    final bool uploaded =
                        await controller.uploadSelectedAvatar();
                    if (!uploaded) return;

                    await SettingsSuccessBottomSheet.show(
                      title: 'gen_profile_picture_updated'.tr,
                      subtitle:
                          'your_profile_picture_has_been_updated_successfully'.tr,
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

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.selectedPath, required this.avatarUrl});

  final String? selectedPath;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 246.r,
      height: 246.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 246.r,
            height: 246.r,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: SettingsUi.lightGreen.withValues(alpha: 0.18),
                  blurRadius: 50.r,
                  spreadRadius: 18.r,
                ),
              ],
            ),
            child: ClipOval(child: _SelectedPhoto(path: selectedPath, url: avatarUrl)),
          ),
          Positioned(
            right: 14.w,
            bottom: 25.h,
            child: Container(
              width: 55.r,
              height: 55.r,
              decoration: const BoxDecoration(
                color: SettingsUi.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPhoto extends StatelessWidget {
  const _SelectedPhoto({required this.path, required this.url});

  final String? path;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final String localPath = path?.trim() ?? '';
    if (localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PhotoFallback(),
      );
    }

    final String networkUrl = url?.trim() ?? '';
    if (networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PhotoFallback(),
      );
    }

    return const _PhotoFallback();
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD1DCE2),
      child: Icon(
        Icons.person_rounded,
        size: 150.r,
        color: const Color(0xFFE8D6CE),
      ),
    );
  }
}

class _PhotoOptionCard extends StatelessWidget {
  const _PhotoOptionCard({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(38.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 27.r, color: iconColor),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.25,
                fontWeight: FontWeight.w900,
                color: SettingsUi.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTipCard extends StatelessWidget {
  const _PhotoTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE9BD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 24.r,
              color: const Color(0xFFFF9900),
            ),
          ),
          SizedBox(width: 17.w),
          Expanded(
            child: Text(
              'use_a_clear_jpg_png_or_webp_image_smaller_than_5_m'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: SettingsUi.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
