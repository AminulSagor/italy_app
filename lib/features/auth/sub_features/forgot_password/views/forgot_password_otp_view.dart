import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class ForgotPasswordOtpView extends GetView<ForgotPasswordController> {
  const ForgotPasswordOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: controller.onBackTap,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryGreen,
                  size: 23.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Center(child: _buildHero(context)),
              SizedBox(height: 26.h),
              // Center(
              //   child: Text(
              //     'Verify Code',
              //     style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              //       fontSize: AppFont.font46.sp.clamp(AppFont.font30, AppFont.font50).toDouble(),
              //       height: 1,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 12.h),
              // Center(
              //   child: Text(
              //     'Enter the 4-digit code sent to',
              //     style: TextStyle(
              //       color: AppColors.bodyText,
              //       fontSize: AppFont.font18.sp,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 4.h),
              // Center(
              //   child: Obx(
              //     () => Text(
              //       controller.otpUi.value.maskedIdentifier,
              //       style: TextStyle(
              //         color: AppColors.headerText,
              //         fontSize: AppFont.font20.sp,
              //         fontWeight: FontWeight.w800,
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(4, _buildOtpInput),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.otpUi.value.isVerifying
                        ? null
                        : controller.onVerifyCodeTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: AppColors.primaryGreen.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius34.r),
                      ),
                      elevation: 10,
                      shadowColor: AppColors.primaryGreen.withAlpha(70),
                    ),
                    child: controller.otpUi.value.isVerifying
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'verify_continue'.tr,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppFont.font18.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 9.w),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 21.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'fp_otp_didnt_receive'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF5A5D61,
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Center(
                child: Obx(
                  () => TextButton(
                    onPressed: controller.otpUi.value.isResending
                        ? null
                        : controller.onResendCodeTap,
                    child: controller.otpUi.value.isResending
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : Text(
                            'resend_code'.tr,
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: AppFont.font19.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFE7E8E8,
        borderRadius: BorderRadius.circular(kRadius38.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 152, 156, 160).withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 82.w,
            height: 82.w,
            decoration: const BoxDecoration(
              color: AppColors.legacyColorFF76EC37,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_unread,
              color: AppColors.primaryGreen,
              size: 38.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'verify_code'.tr,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: AppFont.font28.sp, height: 1),
          ),
          SizedBox(height: 10.h),
          Text(
            controller.isEmailMode
                ? 'fp_otp_hero_desc_email'.tr
                : 'fp_otp_hero_desc_phone'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: AppFont.font15.sp,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput(int index) {
    return AnimatedBuilder(
      animation: controller.otpFocusNodes[index],
      builder: (BuildContext context, Widget? child) {
        final bool isFocused = controller.otpFocusNodes[index].hasFocus;

        return SizedBox(
          width: 70.w,
          height: 84.w,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 199, 199, 199),
              borderRadius: BorderRadius.circular(kRadius36.r),
              border: Border.all(
                color: isFocused ? AppColors.primaryGreen : AppColors.transparent,
                width: 1.6,
              ),
            ),
            child: TextField(
              controller: controller.otpControllers[index],
              focusNode: controller.otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: TextStyle(
                color: AppColors.legacyColorFF626C7B,
                fontSize: AppFont.font30.sp,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFD3E2F4,
        borderRadius: BorderRadius.circular(kRadius28.r),
        border: Border.all(color: AppColors.legacyColorFFBCD4EF),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info, color: AppColors.legacyColorFF0B5B9A, size: 25.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'fp_otp_info'.tr,
              style: TextStyle(
                color: AppColors.legacyColorFF0B4A7D,
                fontSize: AppFont.font15.sp,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
