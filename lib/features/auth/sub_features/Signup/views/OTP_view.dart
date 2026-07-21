import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/widgets/otp_code_input_row.dart';
import '../../../../../core/widgets/otp_resend_button.dart';

class OtpView extends GetView<SignupController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  18.w,
                  8.h,
                  18.w,
                  24.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(context),
                        SizedBox(height: 14.h),

                        _buildOtpHero(),
                        SizedBox(height: 16.h),

                        _buildHeader(context),
                        SizedBox(height: 18.h),

                        _buildOtpCard(),
                        SizedBox(height: 16.h),

                        _buildContinueButton(),
                        SizedBox(height: 14.h),

                        _buildSecurityCard(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: controller.onBackFromOtp,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 44.w,
            minHeight: 44.w,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryGreen,
          ),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.shield_outlined,
                size: 15.sp,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 5.w),
              Text(
                'securedata'.tr,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'verify'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: AppFont.font34.sp
                .clamp(
              AppFont.font28,
              AppFont.font40,
            )
                .toDouble(),
            height: 1.05,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'otp_enter_code_to'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.legacyColorFF5D6164,
            fontSize: AppFont.font15.sp,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        SizedBox(height: 10.h),
        Obx(
              () => Container(
            constraints: const BoxConstraints(
              maxWidth: 380,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.09,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 17.sp,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 9.w),
                Flexible(
                  child: Text(
                    controller.otpUi.value.maskedIdentifier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.headerText,
                      fontSize: AppFont.font15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        20.h,
        16.w,
        14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          OtpCodeInputRow(
            controllers: controller.otpControllers,
            focusNodes: controller.otpFocusNodes,
            onChanged: controller.onOtpDigitChanged,
            onCompleted: controller.onOtpContinueTap,
          ),
          SizedBox(height: 18.h),
          Divider(
            height: 1,
            color: AppColors.legacyColorFFECEFF0,
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5.w,
            runSpacing: 4.h,
            children: <Widget>[
              Text(
                'otp_didnt_receive_code'.tr,
                style: TextStyle(
                  color: AppColors.legacyColorFF4E5255,
                  fontSize: AppFont.font14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(
                    () => OtpResendButton(
                  label: 'resend'.tr,
                  isLoading: controller.otpUi.value.isResending,
                  remainingSeconds:
                  controller.resendCooldown.remainingSeconds.value,
                  remainingLabel:
                  controller.resendCooldown.remainingLabel,
                  onTap: controller.onResendOtpTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Obx(
          () {
        final bool isVerifying =
            controller.otpUi.value.isVerifying;

        final bool isCodeComplete =
            controller.otpUi.value.isCodeComplete;

        return SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: isVerifying || !isCodeComplete
                ? null
                : controller.onOtpContinueTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              disabledBackgroundColor:
              AppColors.primaryGreen.withValues(
                alpha: isVerifying ? 0.6 : 0.35,
              ),
              foregroundColor: AppColors.white,
              elevation: isCodeComplete ? 5 : 0,
              shadowColor:
              AppColors.primaryGreen.withValues(alpha: 0.28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isVerifying
                  ? SizedBox(
                key: const ValueKey<String>('loading'),
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : Row(
                key: const ValueKey<String>('button-label'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'continue'.tr,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppFont.font17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'otp_security_title'.tr,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'otp_security_desc'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF4E5255,
                    fontSize: AppFont.font12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpHero() {
    return Center(
      child: SizedBox(
        width: 112.w,
        height: 104.w,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 1.w,
              bottom: 6.h,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: AppColors.legacyColorFFD4DEE8,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 2.w,
              top: 1.h,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: AppColors.legacyColorFFECCF9D,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFA2EE4A,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.14,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 36.sp,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}