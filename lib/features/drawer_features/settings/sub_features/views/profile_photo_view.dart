import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:italir_pothe/features/drawer_features/settings/widgets/settings_ui_widgets.dart';

class ProfilePhotoView extends StatelessWidget {
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
              SettingsTopBar(title: 'gen_profile_photo'.tr.tr),
              SizedBox(height: 61.h),
              const _PhotoPreview(),
              SizedBox(height: 34.h),
              Text(
                'Say Cheese!',
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
                      title: 'gen_take_a_photo'.tr.tr,
                      icon: Icons.camera_alt_outlined,
                      bgColor: const Color(0xFFD7FFC6),
                      iconBgColor: SettingsUi.lightGreen,
                      iconColor: SettingsUi.green,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _PhotoOptionCard(
                      title: 'gen_choose_from_ngallery'.tr.tr,
                      icon: Icons.image_rounded,
                      bgColor: const Color(0xFFDCEBFF),
                      iconBgColor: const Color(0xFFA9D0FF),
                      iconColor: const Color(0xFF005A97),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),
              Container(
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
                        'A clear face photo helps you gain\n15% more interactions with fellow\nlearners!',
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
              ),
              SizedBox(height: 39.h),
              SettingsPrimaryButton(
                text: 'CONFIRM PHOTO',
                onTap: () {
                  SettingsSuccessBottomSheet.show(
                    title: 'gen_profile_picture_updated'.tr.tr,
                    subtitle:
                        'gen_your_profile_picture_has_been'.tr.tr,
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

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview();

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
            child: ClipOval(
              child: Container(
                color: const Color(0xFFD1DCE2),
                child: Icon(
                  Icons.person_rounded,
                  size: 150.r,
                  color: const Color(0xFFE8D6CE),
                ),
              ),
            ),
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

class _PhotoOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _PhotoOptionCard({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

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
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 31.r, color: iconColor),
            ),
            SizedBox(height: 19.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.05,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
