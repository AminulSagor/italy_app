import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';

class SettingsUi {
  static const Color bg = Color(0xFFF6F6F6);
  static const Color green = Color(0xFF267A05);
  static const Color darkGreen = Color(0xFF1F6B00);
  static const Color lightGreen = Color(0xFF79F535);
  static const Color text = Color(0xFF2D3032);
  static const Color muted = Color(0xFF666666);
  static const Color field = Color(0xFFF0F0F0);
  static const Color red = Color(0xFFC92508);
  static const Color redShadow = Color(0xFF8F1600);
}

class SettingsTopBar extends StatelessWidget {
  final String title;
  final Color titleColor;

  const SettingsTopBar({
    super.key,
    required this.title,
    this.titleColor = SettingsUi.green,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24.r,
                  color: titleColor,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: titleColor,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;
  final Color shadowColor;
  final double height;

  const SettingsPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.color = SettingsUi.green,
    this.shadowColor = SettingsUi.darkGreen,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: Offset(0, 7.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...[
              Icon(icon, size: 22.r, color: Colors.white),
              SizedBox(width: 12.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPillField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const SettingsPillField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

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
              letterSpacing: 1.5,
              color: const Color(0xFF5F6062),
            ),
          ),
        ),
        Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          decoration: BoxDecoration(
            color: SettingsUi.field,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: TextField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: SettingsUi.text,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, size: 22.r, color: const Color(0xFF777777)),
              suffixIcon: suffixIcon == null
                  ? null
                  : Icon(
                      suffixIcon,
                      size: 22.r,
                      color: const Color(0xFF777777),
                    ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB5B5B5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsSuccessBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onDone;

  const SettingsSuccessBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.onDone,
  });

  static Future<void> show({
    required String title,
    required String subtitle,
    VoidCallback? onDone,
  }) {
    return Get.bottomSheet(
      SettingsSuccessBottomSheet(
        title: title,
        subtitle: subtitle,
        onDone: onDone,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.fromLTRB(28.w, 14.h, 28.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          SizedBox(height: 45.h),
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: SettingsUi.lightGreen,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: SettingsUi.lightGreen.withValues(alpha: 0.35),
                  blurRadius: 28.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 54.r,
              color: SettingsUi.green,
            ),
          ),
          SizedBox(height: 27.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: SettingsUi.text,
              letterSpacing: -0.45,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: SettingsUi.muted,
            ),
          ),
          SizedBox(height: 34.h),
          SettingsPrimaryButton(
            text: 'DONE',
            height: 58,
            onTap: onDone ?? Get.back,
          ),
        ],
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  static Future<void> show() {
    return Get.dialog(
      const DeleteAccountDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.36),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(30.w, 34.h, 30.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 90.r,
              height: 90.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECE8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 50.r,
                color: SettingsUi.red,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Delete Account?',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: SettingsUi.text,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 17.h),
            Text(
              'Are you sure? This action is\npermanent and all your\nprogress, XP, and certificates\nwill be lost forever. This cannot\nbe undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                height: 1.42,
                fontWeight: FontWeight.w500,
                color: SettingsUi.muted,
              ),
            ),
            SizedBox(height: 34.h),
            SettingsPrimaryButton(
              text: 'DELETE MY ACCOUNT',
              color: SettingsUi.red,
              shadowColor: const Color(0xFFE98A6F),
              height: 66,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.deleteAccountConfirm);
              },
            ),
            SizedBox(height: 22.h),
            GestureDetector(
              onTap: Get.back,
              child: Text(
                'Keep My Account',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: SettingsUi.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
