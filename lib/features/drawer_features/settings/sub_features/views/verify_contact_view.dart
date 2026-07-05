import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../settings_controller.dart';
import '../../widgets/settings_ui_widgets.dart';

class VerifyContactView extends GetView<SettingsController> {
  const VerifyContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isEmail = controller.pendingContactType.value != 'phone';
      final String destination = controller.pendingContactValue.value;

      return Scaffold(
        backgroundColor: SettingsUi.bg,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned(
                left: -56.w,
                top: -40.h,
                child: _GlowCircle(color: SettingsUi.lightGreen, size: 170.r),
              ),
              Positioned(
                right: -52.w,
                top: 230.h,
                child: _GlowCircle(
                  color: const Color(0xFF65B9FF),
                  size: 150.r,
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 56.h),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          controller.clearPendingContact();
                          Get.back<void>();
                        },
                        child: Container(
                          width: 54.r,
                          height: 54.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 27.r,
                            color: SettingsUi.text,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 13.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 35.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45.r),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 40.r,
                            offset: Offset(0, 20.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 80.r,
                            height: 80.r,
                            decoration: const BoxDecoration(
                              color: SettingsUi.lightGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEmail
                                  ? Icons.mark_email_unread_rounded
                                  : Icons.sms_outlined,
                              size: 38.r,
                              color: SettingsUi.green,
                            ),
                          ),
                          SizedBox(height: 28.h),
                          Text(
                            'verify_code'.tr,
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w900,
                              color: SettingsUi.text,
                              letterSpacing: -0.65,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Enter the 4-digit code sent to\n$destination',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: SettingsUi.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 52.h),
                    _OtpInputRow(controller: controller),
                    SizedBox(height: 40.h),
                    SettingsPrimaryButton(
                      text: 'verify_continue_1'.tr,
                      height: 68,
                      isLoading: controller.isVerifyingContactOtp.value,
                      onTap: controller.verifyPendingContact,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      "didn_t_receive_the_code".tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: SettingsUi.muted,
                      ),
                    ),
                    SizedBox(height: 11.h),
                    GestureDetector(
                      onTap: controller.isResendingContactOtp.value
                          ? null
                          : controller.resendPendingContactOtp,
                      child: Text(
                        controller.isResendingContactOtp.value
                            ? 'sending'.tr
                            : 'resend_code_1'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: SettingsUi.green,
                        ),
                      ),
                    ),
                    SizedBox(height: 41.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24.w, 23.h, 24.w, 23.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEBFF),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: const Color(0xFFBEDDFF)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.info_rounded,
                            size: 22.r,
                            color: const Color(0xFF0064A8),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Text(
                              isEmail
                                  ? 'check_your_spam_folder_if_the_email_does_not_arriv'.tr
                                  : 'the_sms_code_is_valid_for_10_minutes_confirm_that'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF005A97),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(
        controller.otpControllers.length,
        (int index) => _OtpBox(controller: controller, index: index),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.controller, required this.index});

  final SettingsController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r,
      height: 78.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F2),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        autofocus: index == 0,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textInputAction: index == controller.otpControllers.length - 1
            ? TextInputAction.done
            : TextInputAction.next,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (String value) =>
            controller.onOtpDigitChanged(index, value),
        onSubmitted: (_) {
          if (controller.isOtpComplete) {
            controller.verifyPendingContact();
          }
        },
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w900,
          color: SettingsUi.text,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: '•'.tr,
          hintStyle: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF6F7785),
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 70.r,
            spreadRadius: 20.r,
          ),
        ],
      ),
    );
  }
}
