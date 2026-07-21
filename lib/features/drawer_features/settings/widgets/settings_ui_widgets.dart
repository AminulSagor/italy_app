import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/settings_localization.dart';

class SettingsUi {
  const SettingsUi._();

  static const Color background = Color(0xFFF5F8F7);
  static const Color surface = Colors.white;
  static const Color field = Color(0xFFF0F4F2);
  static const Color primary = Color(0xFF0A7C58);
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color text = Color(0xFF18211E);
  static const Color muted = Color(0xFF69756F);
  static const Color border = Color(0xFFE1E9E5);
  static const Color danger = Color(0xFFC93B3B);
}

class SettingsTopBar extends StatelessWidget {
  const SettingsTopBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack ?? Get.back,
                child: SizedBox(
                  width: 44.r,
                  height: 44.r,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 23.r,
                    color: SettingsUi.primary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 58.w),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: SettingsUi.text,
                letterSpacing: -0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPrimaryButton extends StatelessWidget {
  const SettingsPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.height = 54,
    this.enabled = true,
    this.isLoading = false,
    this.color = SettingsUi.primary,
    this.loadingColor = SettingsUi.primary,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final bool enabled;
  final bool isLoading;
  final Color color;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isLoading ? loadingColor : color;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.48,
      duration: const Duration(milliseconds: 160),
      child: SizedBox(
        height: height.h,
        width: double.infinity,
        child: FilledButton(
          onPressed: enabled && !isLoading ? onTap : null,
          style: FilledButton.styleFrom(
            backgroundColor: effectiveColor,
            disabledBackgroundColor: effectiveColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 20.r),
                      SizedBox(width: 9.w),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SettingsPillField extends StatelessWidget {
  const SettingsPillField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.controller,
    this.onSuffixTap,
    this.readOnly = false,
    this.enabled = true,
    this.helperText,
    this.autofillHints,
    this.maxLength,
  });

  final String label;
  final String hint;
  final IconData icon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap;
  final bool readOnly;
  final bool enabled;
  final String? helperText;
  final Iterable<String>? autofillHints;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 7.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: SettingsUi.muted,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          readOnly: readOnly,
          enabled: enabled,
          autofillHints: autofillHints,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: SettingsUi.text,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: enabled ? SettingsUi.field : const Color(0xFFE9ECEB),
            prefixIcon: Icon(
              icon,
              size: 21.r,
              color: enabled ? SettingsUi.primary : SettingsUi.muted,
            ),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    onPressed: enabled ? onSuffixTap : null,
                    icon: Icon(
                      suffixIcon,
                      size: 21.r,
                      color: SettingsUi.muted,
                    ),
                  ),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9AA39F),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: SettingsUi.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(
                color: SettingsUi.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: SettingsUi.border),
            ),
          ),
        ),
        if (helperText != null && helperText!.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: 7.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.35,
                color: SettingsUi.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SettingsSuccessBottomSheet extends StatelessWidget {
  const SettingsSuccessBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.onDone,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onDone;

  static Future<void> show({
    required String title,
    required String subtitle,
    VoidCallback? onDone,
  }) {
    return Get.bottomSheet<void>(
      SettingsSuccessBottomSheet(
        title: title,
        subtitle: subtitle,
        onDone: onDone,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD7DEDA),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 22.h),
            Container(
              width: 66.r,
              height: 66.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F7F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 34.r,
                color: SettingsUi.primary,
              ),
            ),
            SizedBox(height: 17.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: SettingsUi.text,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                color: SettingsUi.muted,
              ),
            ),
            SizedBox(height: 22.h),
            SettingsPrimaryButton(
              text: SettingsL10n.text('done'),
              onTap: () {
                Get.back<void>();
                onDone?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
