import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../../../core/themes/app_constants.dart';

class PasswordChangedView extends GetView<ForgotPasswordController> {
  const PasswordChangedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTopBackButton(),
              SizedBox(height: 18.h),
              Center(child: _buildSuccessHero()),
              SizedBox(height: 26.h),
              Center(
                child: Text(
                  'password_changed'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: AppFont.font46.sp.clamp(AppFont.font30, AppFont.font52).toDouble(),
                    height: 1.04,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Center(
                child: Text(
                  'password_changed_desc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 44.h),
              _buildLoginReadyCard(),
              SizedBox(height: 60.h),
              SizedBox(
                width: double.infinity,
                height: 66.h,
                child: ElevatedButton(
                  onPressed: controller.onBackToLoginTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadius35.r),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.primaryGreen.withAlpha(70),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'back_to_login'.tr,
                        style: TextStyle(
                          color: AppColors.legacyColorFFE8F4DF,
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.legacyColorFFE8F4DF,
                        size: 23.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.legacyColorFF9FA3A7,
                      size: 15.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'secure_protected'.tr,
                      style: TextStyle(
                        color: AppColors.legacyColorFF9FA3A7,
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
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

  Widget _buildTopBackButton() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.legacyColorFFE0E1E1,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: controller.onBackToLoginTap,
        icon: Icon(
          Icons.arrow_back,
          size: 21.sp,
          color: AppColors.legacyColorFF44484C,
        ),
      ),
    );
  }

  Widget _buildSuccessHero() {
    return SizedBox(
      width: 250.w,
      height: 208.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: 40.w,
            top: 40.h,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromARGB(129, 73, 227, 26),
                    blurRadius: 150,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 226, 226, 226),
              borderRadius: BorderRadius.circular(kRadius38.r),
            ),
            child: Center(
              child: Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: AppColors.legacyColorFFF4F5F4,
                  borderRadius: BorderRadius.circular(kRadius30.r),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: AppColors.legacyColor24000000,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.primaryGreen,
                  size: 46.sp,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: 12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.legacyColorFFFFA500,
                borderRadius: BorderRadius.circular(kRadius24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      178,
                      104,
                      104,
                      104,
                    ).withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.verified,
                    color: AppColors.legacyColorFF2F2110,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'secure'.tr,
                    style: TextStyle(
                      color: AppColors.legacyColorFF2F2110,
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginReadyCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 214, 214),
        borderRadius: BorderRadius.circular(kRadius38.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.legacyColorFFAAD2F6,
              borderRadius: BorderRadius.circular(kRadius20.r),
              //shape: BoxShape.circle,
            ),
            child: Icon(Icons.key, color: AppColors.legacyColorFF1164A2, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'login_ready'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF2D3236,
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'login_ready_desc'.tr,
                  style: TextStyle(
                    color: AppColors.legacyColorFF5E6367,
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
