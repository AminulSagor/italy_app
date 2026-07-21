import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../models/settings_localization.dart';
import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class VerifyContactView extends GetView<SettingsController> {
  const VerifyContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.clearPendingContact();
        return true;
      },
      child: Scaffold(
        backgroundColor: SettingsUi.background,
        body: SafeArea(
          child: Obx(() {
            final String destination = controller.pendingContactValue.value;
            final bool expired = destination.isEmpty;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
              children: <Widget>[
                SettingsTopBar(
                  title: SettingsL10n.text('verification_code'),
                  onBack: () {
                    controller.clearPendingContact();
                    Get.back<void>();
                  },
                ),
                SizedBox(height: 28.h),
                Center(
                  child: Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.pendingContactType.value == 'phone'
                          ? Icons.sms_outlined
                          : Icons.mark_email_read_outlined,
                      size: 34.r,
                      color: SettingsUi.primary,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  SettingsL10n.text('verify_code'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w800,
                    color: SettingsUi.text,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  expired
                      ? SettingsL10n.text('verification_expired')
                      : SettingsL10n.text(
                          'code_sent_to',
                          params: <String, String>{'destination': destination},
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: SettingsUi.muted,
                  ),
                ),
                SizedBox(height: 28.h),
                if (!expired) ...<Widget>[
                  _OtpInputRow(controller: controller),
                  SizedBox(height: 20.h),
                  SettingsPrimaryButton(
                    text: SettingsL10n.text('verify_code'),
                    icon: Icons.verified_outlined,
                    enabled: controller.isOtpComplete &&
                        !controller.isVerifyingContactOtp.value,
                    isLoading: controller.isVerifyingContactOtp.value,
                    onTap: controller.verifyPendingContact,
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Obx(() {
                      final bool coolingDown =
                          controller.contactOtpResendCooldown.isActive;
                      final String label = coolingDown
                          ? SettingsL10n.text(
                              'resend_in',
                              params: <String, String>{
                                'time': controller
                                    .contactOtpResendCooldown.remainingLabel,
                              },
                            )
                          : SettingsL10n.text('resend_code');

                      return TextButton.icon(
                        onPressed: coolingDown ||
                                controller.isResendingContactOtp.value
                            ? null
                            : controller.resendPendingContactOtp,
                        icon: controller.isResendingContactOtp.value
                            ? SizedBox(
                                width: 16.r,
                                height: 16.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.refresh_rounded, size: 19.r),
                        label: Text(label),
                        style: TextButton.styleFrom(
                          foregroundColor: SettingsUi.primary,
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  _SecurityTip(),
                ] else ...<Widget>[
                  SettingsPrimaryButton(
                    text: SettingsL10n.text('back_to_profile'),
                    onTap: Get.back,
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(4, (int index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: SizedBox(
            width: 54.r,
            height: 58.r,
            child: TextField(
              controller: controller.otpControllers[index],
              focusNode: controller.otpFocusNodes[index],
              autofocus: index == 0,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (String value) {
                controller.onOtpDigitChanged(index, value);
              },
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: SettingsUi.text,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: SettingsUi.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: SettingsUi.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(
                    color: SettingsUi.primary,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SecurityTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_outline_rounded, size: 21.r, color: const Color(0xFFA46A00)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              SettingsL10n.text('verification_tip'),
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color: const Color(0xFF7A5512),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
