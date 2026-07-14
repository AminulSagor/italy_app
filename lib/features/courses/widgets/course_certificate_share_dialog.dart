import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/course_certificate_models.dart';

class CourseCertificateShareDialog extends StatelessWidget {
  final CourseCertificateModel certificate;

  const CourseCertificateShareDialog({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 24.w,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'achievement_unlocked'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w),
                ],
              ),
              SizedBox(height: 28.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 30.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kRadius42.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.18),
                      blurRadius: 32.r,
                      offset: Offset(0, 16.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons_svg/app_icon.svg',
                          width: 25.w,
                          height: 25.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'italirpothe'.tr,
                          style: TextStyle(
                            fontSize: AppFont.font18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.homePrimaryText,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),
                    Text(
                      'congratulazioni'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font30.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "You've reached a new milestone",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'this_certifies_that'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.8,
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      certificate.learnerName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font30.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 74.w,
                      height: 2.h,
                      color: AppColors.coursesCertificationBorder,
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.homeSoftGreen.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(kHomePillRadius.r),
                        border: Border.all(
                          color: AppColors.coursesCertificationBorder,
                        ),
                      ),
                      child: Text(
                        'proficiency_level_certificate_proficiencylevel'.trParams(<String, String>{'proficiencylevel': certificate.proficiencyLevel.toString()}),
                        style: TextStyle(
                          fontSize: AppFont.font14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      onPressed: () {},
                      text: 'join_the_italian_journey'.tr,
                      height: 44,
                      showShadow: true,
                      fontSize: AppFont.font16,
                      textColor: AppColors.limeTextColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(9999.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.16),
                      blurRadius: 28.r,
                      offset: Offset(0, 14.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _ShareRoundButton(
                      icon: Icons.download_rounded,
                      onTap: () {},
                    ),
                    Text(
                      'share_your_victory'.tr,
                      style: TextStyle(
                        fontSize: AppFont.font12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.bodyText,
                      ),
                    ),
                    _ShareRoundButton(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ShareRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGreen, width: 3.w),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 24.w),
      ),
    );
  }
}
