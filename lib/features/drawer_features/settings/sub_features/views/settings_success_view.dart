import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/features/drawer_features/settings/widgets/settings_ui_widgets.dart';
import 'package:italir_pothe/routes/routes.dart';

class SettingsSuccessView extends StatelessWidget {
  const SettingsSuccessView({super.key});

  String get _type {
    final args = Get.arguments;
    if (args is Map && args['type'] is String) return args['type'] as String;
    return 'emailUpdated';
  }

  @override
  Widget build(BuildContext context) {
    final String type = _type;
    final bool isDelete = type == 'accountDeleted';
    final bool isPhone = type == 'phoneUpdated';

    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -80.w,
              top: isDelete ? 10.h : 70.h,
              child: _SuccessGlow(size: 230.r),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24.w, 39.h, 24.w, 44.h),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 24.r,
                          color: SettingsUi.text,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isDelete ? 98.h : 67.h),
                  isDelete ? const _DeletedHeroIcon() : const _SecureHeroIcon(),
                  SizedBox(height: isDelete ? 39.h : 45.h),
                  Text(
                    isDelete
                        ? 'Account Deleted'
                        : isPhone
                        ? 'Phone Updated'
                        : 'Email Updated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDelete ? 29.sp : 37.sp,
                      fontWeight: FontWeight.w900,
                      color: isDelete ? SettingsUi.green : SettingsUi.text,
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Text(
                    isDelete
                        ? 'Your data, progress, and certificates\nhave been permanently removed.\nArrivederci!'
                        : isPhone
                        ? 'Your Phone Number has been\nsuccessfully updated. You can now\nlog in with your new credentials.'
                        : 'Your Email ID has been\nsuccessfully updated. You can now\nlog in with your new credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      height: 1.48,
                      fontWeight: FontWeight.w500,
                      color: SettingsUi.muted,
                    ),
                  ),
                  if (!isDelete) ...[
                    SizedBox(height: 47.h),
                    const _LoginReadyCard(),
                  ],
                  SizedBox(height: isDelete ? 69.h : 64.h),
                  SettingsPrimaryButton(
                    text: isDelete
                        ? 'back_to_login'.tr.toUpperCase()
                        : 'Back to Edit Profile  →',
                    height: isDelete ? 62 : 68,
                    onTap: () {
                      if (isDelete) {
                        Get.offAllNamed(AppRoutes.login);
                      } else {
                        Get.offNamed(AppRoutes.profileSecurity);
                      }
                    },
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    isDelete ? '' : '🔒  SECURE & PROTECTED',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFB1B1B1),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecureHeroIcon extends StatelessWidget {
  const _SecureHeroIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196.r,
      height: 204.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEEF),
              borderRadius: BorderRadius.circular(42.r),
            ),
          ),
          Container(
            width: 96.r,
            height: 96.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.13),
                  blurRadius: 22.r,
                  offset: Offset(0, 12.h),
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 58.r,
              color: SettingsUi.green,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 38.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA015),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                '🛡 SECURE',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF111111),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedHeroIcon extends StatelessWidget {
  const _DeletedHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142.r,
      height: 142.r,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SettingsUi.lightGreen.withValues(alpha: 0.28),
            blurRadius: 28.r,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: SettingsUi.lightGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.restore_from_trash_rounded,
          size: 54.r,
          color: SettingsUi.green,
        ),
      ),
    );
  }
}

class _LoginReadyCard extends StatelessWidget {
  const _LoginReadyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(38.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Color(0xFFA9D0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.key_rounded,
              size: 24.r,
              color: const Color(0xFF005A97),
            ),
          ),
          SizedBox(width: 17.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Login Ready',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: SettingsUi.text,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Access your Italian lessons instantly.',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: SettingsUi.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessGlow extends StatelessWidget {
  final double size;

  const _SuccessGlow({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SettingsUi.lightGreen.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SettingsUi.lightGreen.withValues(alpha: 0.34),
            blurRadius: 70.r,
            spreadRadius: 20.r,
          ),
        ],
      ),
    );
  }
}
