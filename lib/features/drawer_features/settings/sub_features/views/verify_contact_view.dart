import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/features/drawer_features/settings/widgets/settings_ui_widgets.dart';
import 'package:italir_pothe/routes/routes.dart';

class VerifyContactView extends StatelessWidget {
  const VerifyContactView({super.key});

  bool get _isEmail {
    final args = Get.arguments;
    if (args is Map && args['mode'] == 'phone') return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmail = _isEmail;

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
              child: _GlowCircle(color: const Color(0xFF65B9FF), size: 150.r),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 56.h),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: Get.back,
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
                            Icons.mark_email_unread_rounded,
                            size: 38.r,
                            color: SettingsUi.green,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                            color: SettingsUi.text,
                            letterSpacing: -0.65,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isEmail
                              ? 'Enter the 4-digit code sent to your\nemail'
                              : 'Enter the 4-digit code sent to\nyour phone number',
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
                  const _OtpInputRow(),
                  SizedBox(height: 40.h),
                  SettingsPrimaryButton(
                    text: 'Verify & Continue  →',
                    height: 68,
                    onTap: () {
                      Get.offNamed(
                        AppRoutes.profileSuccess,
                        arguments: {
                          'type': isEmail ? 'emailUpdated' : 'phoneUpdated',
                        },
                      );
                    },
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: SettingsUi.muted,
                    ),
                  ),
                  SizedBox(height: 11.h),
                  Text(
                    'Resend Code',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: SettingsUi.green,
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
                                ? "Please check your spam folder if\nyou don't see the email within 2\nminutes. The code is valid for 10\nminutes."
                                : "Please check your spam folder if\nyou don't see the email within 2\nminutes. The code is valid for 10\nminutes.",
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
  }
}

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(4, (_) => const _OtpBox()),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox();

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
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
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
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

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
