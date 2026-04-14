import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import 'signup_controller.dart';

class OtpView extends GetView<SignupController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: controller.onBackFromOtp,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryGreen,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 10.h),

              Center(child: _buildOtpHero()),
              SizedBox(height: 26.h),

              Center(
                child: Text(
                  'verify'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 48.sp.clamp(28, 48),
                        height: 1,
                      ),
                ),
              ),
              SizedBox(height: 8.h),

              Center(
                child: Text(
                  'otp_enter_code_to'.tr,
                  style: TextStyle(
                    color: const Color(0xFF5D6164),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              Center(
                child: Obx(
                  () => Text(
                    controller.otpUi.value.maskedIdentifier,
                    style: TextStyle(
                      color: const Color(0xFF2F3337),
                      fontSize: 18.sp.clamp(20, 34),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(
                  4,
                  (int index) => _buildOtpInput(index),
                ),
              ),
              SizedBox(height: 26.h),

              Center(
                child: Text(
                  'otp_didnt_receive_code'.tr,
                  style: TextStyle(
                    color: const Color(0xFF4E5255),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              Center(
                child: Obx(
                  () => TextButton(
                    onPressed: controller.otpUi.value.isResending
                        ? null
                        : controller.onResendOtpTap,
                    child: controller.otpUi.value.isResending
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryGreen,
                            ),
                          )
                        : Text(
                          'resend'.tr,
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.otpUi.value.isVerifying
                        ? null
                        : controller.onOtpContinueTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      disabledBackgroundColor:
                          AppTheme.primaryGreen.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34.r),
                      ),
                      elevation: 10,
                      shadowColor: AppTheme.primaryGreen.withAlpha(70),
                    ),
                    child: controller.otpUi.value.isVerifying
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'continue'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF0),
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 66.w,
                      height: 66.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDE6BD),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppTheme.primaryGreen,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'otp_security_title'.tr,
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'otp_security_desc'.tr,
                            style: TextStyle(
                              color: const Color(0xFF4E5255),
                              fontSize: 15.sp,
                              height: 1.3,
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
      ),
    );
  }

  Widget _buildOtpHero() {
    return SizedBox(
      width: 180.w,
      height: 150.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 10.w,
            bottom: 24.h,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: const BoxDecoration(
                color: Color(0xFFD4DEE8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: 6.h,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Color(0xFFECCF9D),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 130.w,
            height: 130.w,
            decoration: const BoxDecoration(
              color: Color(0xFFA2EE4A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              size: 46.sp,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput(int index) {
    return AnimatedBuilder(
      animation: controller.otpFocusNodes[index],
      builder: (context, _) {
        final bool isFocused = controller.otpFocusNodes[index].hasFocus;

        return SizedBox(
          width: 76.w,
          height: 76.w,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8F8F8),
              border: Border.all(
                color: isFocused
                    ? AppTheme.primaryGreen
                    : Colors.transparent,
                width: 1.6,
              ),
            ),
            child: TextField(
              controller: controller.otpControllers[index],
              focusNode: controller.otpFocusNodes[index],
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: TextStyle(
                color: const Color(0xFF646C7A),
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              onChanged: (String value) {
                controller.onOtpDigitChanged(index: index, value: value);
              },
            ),
          ),
        );
      },
    );
  }
}