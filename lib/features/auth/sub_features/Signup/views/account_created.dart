import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';

class AccountCreatedView extends GetView<SignupController> {
  const AccountCreatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Account verification is complete.
      // Do not return to the already-consumed OTP screen.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  20.h,
                  20.w,
                  24.h,
                ),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildOfficialBadge(),
                          SizedBox(height: 24.h),

                          _buildSuccessBadge(),
                          SizedBox(height: 24.h),

                          _buildHeader(context),
                          SizedBox(height: 26.h),

                          _buildAccountInformation(),
                          SizedBox(height: 24.h),

                          const Spacer(),

                          _buildStartLearningButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficialBadge() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 7.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryGreen,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'official_badge'.tr,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'account_created_title'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: AppFont.font36.sp
                .clamp(
              AppFont.font28,
              AppFont.font40,
            )
                .toDouble(),
            height: 1.12,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'account_created_desc'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.legacyColorFF5D6164,
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInformation() {
    return Obx(
          () {
        final String fullName =
        controller.accountCreatedUi.value.fullName.trim();

        final String identifier =
        controller.accountCreatedUi.value.identifier.trim();

        final bool isEmail = identifier.contains('@');

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(
                        alpha: 0.09,
                      ),
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.primaryGreen,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Text(
                      'account_created_title'.tr.replaceAll('\n', ' '),
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Divider(
                height: 1,
                color: AppColors.legacyColorFFECEFF0,
              ),
              SizedBox(height: 15.h),
              _buildInfoRow(
                icon: Icons.person_outline_rounded,
                title: 'field_full_name'.tr,
                value: fullName,
              ),
              SizedBox(height: 14.h),
              _buildInfoRow(
                icon: isEmail
                    ? Icons.mail_outline_rounded
                    : Icons.phone_outlined,
                title: isEmail
                    ? 'field_email'.tr
                    : 'field_phone'.tr,
                value: identifier,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.075),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            icon,
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
                title,
                style: TextStyle(
                  color: AppColors.legacyColorFF6C7074,
                  fontSize: AppFont.font11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isEmpty ? '—' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.legacyColorFF2B2F32,
                  fontSize: AppFont.font17.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartLearningButton() {
    return Obx(
          () {
        final bool isStarting =
            controller.accountCreatedUi.value.isStarting;

        return SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: isStarting
                ? null
                : controller.onStartLearningTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              disabledBackgroundColor:
              AppColors.primaryGreen.withValues(alpha: 0.6),
              foregroundColor: AppColors.white,
              elevation: 5,
              shadowColor:
              AppColors.primaryGreen.withValues(alpha: 0.28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isStarting
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
                key: const ValueKey<String>('button'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'start_learning'.tr,
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
                    size: 21.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessBadge() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        tween: Tween<double>(
          begin: 0.72,
          end: 1,
        ),
        builder: (
            BuildContext context,
            double value,
            Widget? child,
            ) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: SizedBox(
          width: 126.w,
          height: 126.w,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 118.w,
                height: 118.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.22),
                    width: 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(
                        alpha: 0.16,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              Container(
                width: 58.w,
                height: 58.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 36.sp,
                ),
              ),
              Positioned(
                right: 4.w,
                top: 11.h,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.legacyColorFFECCF9D,
                  size: 24.sp,
                ),
              ),
              Positioned(
                left: 3.w,
                bottom: 15.h,
                child: Container(
                  width: 17.w,
                  height: 17.w,
                  decoration: const BoxDecoration(
                    color: AppColors.legacyColorFFA9CCF0,
                    shape: BoxShape.circle,
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