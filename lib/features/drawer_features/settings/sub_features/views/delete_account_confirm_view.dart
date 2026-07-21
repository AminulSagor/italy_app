import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../models/settings_localization.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class DeleteAccountConfirmView extends GetView<SettingsController> {
  const DeleteAccountConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: Obx(() {
          final String accountName = controller.profile.value?.fullName.trim() ?? '';
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
            children: <Widget>[
              SettingsTopBar(title: SettingsL10n.text('delete_account')),
              SizedBox(height: 24.h),
              Center(
                child: Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECEC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 36.r,
                    color: SettingsUi.danger,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                SettingsL10n.text('delete_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: SettingsUi.text,
                ),
              ),
              SizedBox(height: 9.h),
              Text(
                SettingsL10n.text('delete_warning'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.45,
                  color: SettingsUi.muted,
                ),
              ),
              SizedBox(height: 18.h),
              _DangerInformationCard(),
              SizedBox(height: 20.h),
              Text(
                SettingsL10n.text(
                  'type_name_to_confirm',
                  params: <String, String>{'name': accountName},
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: SettingsUi.text,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                enabled: accountName.isNotEmpty && !controller.isDeletingAccount.value,
                onChanged: (String value) => controller.deleteConfirmText.value = value,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: SettingsUi.text,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: accountName,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(color: SettingsUi.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(color: SettingsUi.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(
                      color: SettingsUi.danger,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (controller.deleteConfirmText.value.isNotEmpty &&
                  !controller.canDeleteAccount) ...<Widget>[
                SizedBox(height: 7.h),
                Text(
                  SettingsL10n.text('name_does_not_match'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: SettingsUi.danger,
                  ),
                ),
              ],
              SizedBox(height: 22.h),
              SettingsPrimaryButton(
                text: SettingsL10n.text('delete_my_account'),
                icon: Icons.delete_forever_outlined,
                color: SettingsUi.danger,
                loadingColor: SettingsUi.danger,
                enabled: controller.canDeleteAccount &&
                    !controller.isDeletingAccount.value,
                isLoading: controller.isDeletingAccount.value,
                onTap: controller.deleteAccountPermanently,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 52.h,
                child: OutlinedButton(
                  onPressed: controller.isDeletingAccount.value ? null : Get.back,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SettingsUi.text,
                    side: const BorderSide(color: SettingsUi.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    SettingsL10n.text('keep_account'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DangerInformationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, size: 22.r, color: SettingsUi.danger),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              SettingsL10n.text('delete_consequences'),
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: const Color(0xFF873A3A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
