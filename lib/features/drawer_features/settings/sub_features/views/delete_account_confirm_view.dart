import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class DeleteAccountConfirmView extends GetView<SettingsController> {
  const DeleteAccountConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 49.h, 24.w, 42.h),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 36.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: Get.back,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 27.r,
                          color: SettingsUi.text,
                        ),
                      ),
                    ),
                    Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: SettingsUi.text,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 68.h),
              Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5538),
                  borderRadius: BorderRadius.circular(38.r),
                ),
                child: Center(
                  child: Container(
                    width: 88.r,
                    height: 88.r,
                    decoration: BoxDecoration(
                      color: SettingsUi.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE24B2C),
                        width: 5.w,
                      ),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 52.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 59.h),
              Text(
                'Are you absolutely\nsure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 29.sp,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF164D08),
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 27.h),
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(30.w, 27.h, 30.w, 27.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(38.r),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 17.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: SettingsUi.muted,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'To permanently delete this account, type your full name exactly as shown:\n\n',
                        ),
                        TextSpan(
                          text: controller.displayName,
                          style: const TextStyle(
                            color: SettingsUi.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const TextSpan(
                          text: '\n\nThis action is irreversible and signs you out on all devices.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 31.h),
              Container(
                height: 64.h,
                padding: EdgeInsets.symmetric(horizontal: 26.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (String value) =>
                      controller.deleteConfirmText.value = value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: SettingsUi.text,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 39.h),
              Obx(() {
                final bool canDelete = controller.canDeleteAccount;

                return Opacity(
                  opacity: canDelete ? 1 : 0.55,
                  child: SettingsPrimaryButton(
                    text: 'PERMANENTLY DELETE',
                    color: SettingsUi.red,
                    shadowColor: SettingsUi.redShadow,
                    isLoading: controller.isDeletingAccount.value,
                    onTap: canDelete
                        ? controller.deleteAccountPermanently
                        : () {},
                  ),
                );
              }),
              SizedBox(height: 28.h),
              GestureDetector(
                onTap: Get.back,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: SettingsUi.muted,
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
