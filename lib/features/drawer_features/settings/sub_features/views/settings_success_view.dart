import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../models/settings_localization.dart';
import '../../widgets/settings_ui_widgets.dart';

class SettingsSuccessView extends StatelessWidget {
  const SettingsSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : <String, dynamic>{};
    final String type = arguments['type']?.toString() ?? 'emailUpdated';
    final _SuccessContent content = _contentFor(type);

    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _navigate(type),
                    child: SizedBox(
                      width: 44.r,
                      height: 44.r,
                      child: Icon(
                        Icons.close_rounded,
                        size: 22.r,
                        color: SettingsUi.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 104.r,
                height: 104.r,
                decoration: BoxDecoration(
                  color: content.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  content.icon,
                  size: 51.r,
                  color: content.iconColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                content.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w800,
                  color: SettingsUi.text,
                ),
              ),
              SizedBox(height: 9.h),
              Text(
                content.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: SettingsUi.muted,
                ),
              ),
              const Spacer(),
              SettingsPrimaryButton(
                text: content.buttonText,
                icon: content.buttonIcon,
                onTap: () => _navigate(type),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SuccessContent _contentFor(String type) {
    switch (type) {
      case 'phoneUpdated':
        return _SuccessContent(
          title: SettingsL10n.text('phone_updated'),
          subtitle: SettingsL10n.text('phone_updated_desc'),
          buttonText: SettingsL10n.text('back_to_profile'),
          icon: Icons.phone_iphone_rounded,
          buttonIcon: Icons.arrow_back_rounded,
          iconColor: SettingsUi.primary,
          backgroundColor: const Color(0xFFE6F7F0),
        );
      case 'accountDeleted':
        return _SuccessContent(
          title: SettingsL10n.text('account_deleted'),
          subtitle: SettingsL10n.text('account_deleted_desc'),
          buttonText: SettingsL10n.text('back_to_login'),
          icon: Icons.person_off_outlined,
          buttonIcon: Icons.login_rounded,
          iconColor: SettingsUi.danger,
          backgroundColor: const Color(0xFFFFECEC),
        );
      default:
        return _SuccessContent(
          title: SettingsL10n.text('email_updated'),
          subtitle: SettingsL10n.text('email_updated_desc'),
          buttonText: SettingsL10n.text('back_to_profile'),
          icon: Icons.mark_email_read_outlined,
          buttonIcon: Icons.arrow_back_rounded,
          iconColor: SettingsUi.primary,
          backgroundColor: const Color(0xFFE6F7F0),
        );
    }
  }

  void _navigate(String type) {
    if (type == 'accountDeleted') {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    Get.back<void>();
  }
}

class _SuccessContent {
  const _SuccessContent({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.buttonIcon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final IconData buttonIcon;
  final Color iconColor;
  final Color backgroundColor;
}
