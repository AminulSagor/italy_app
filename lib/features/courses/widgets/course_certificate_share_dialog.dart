import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/course_certificate_models.dart';
import 'course_certificate_widgets.dart';

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
          padding: EdgeInsets.fromLTRB(28.w, 38.h, 28.w, 38.h),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Icon(Icons.close_rounded, color: AppColors.white, size: 36.w),
                  ),
                  Expanded(
                    child: Text(
                      'Achievement Unlocked',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font32.sp,
                        fontWeight: FontWeight.w900,
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
                padding: EdgeInsets.fromLTRB(30.w, 38.h, 30.w, 46.h),
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
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.verified_rounded, color: AppColors.homeLime, size: 24.w),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'ItalirPothe',
                          style: TextStyle(
                            fontSize: AppFont.font30.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.homePrimaryText,
                          ),
                        ),
                      ],
                    ),
                    const CourseCertificateHero(compact: true),
                    SizedBox(height: 12.h),
                    Text(
                      'Congratulazioni!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font44.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "You've reached a new milestone",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font22.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 48.h),
                    Text(
                      'THIS CERTIFIES THAT',
                      style: TextStyle(
                        fontSize: AppFont.font14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.8,
                        color: AppColors.quizAnswerShadow,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Text(
                      certificate.learnerName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFont.font42.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(width: 74.w, height: 2.h, color: AppColors.coursesCertificationBorder),
                    SizedBox(height: 32.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.homeSoftGreen.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(kHomePillRadius.r),
                        border: Border.all(color: AppColors.coursesCertificationBorder),
                      ),
                      child: Text(
                        'Proficiency Level: ${certificate.proficiencyLevel}',
                        style: TextStyle(
                          fontSize: AppFont.font18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    CustomButton(
                      onPressed: () {},
                      text: 'Join the Italian journey!',
                      height: 58,
                      width: 320,
                      showShadow: true,
                      textSize: AppFont.font17,
                      textColor: AppColors.limeTextColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 38.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 52.w, vertical: 26.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(kRadius42.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.16),
                      blurRadius: 28.r,
                      offset: Offset(0, 14.h),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'SHARE YOUR VICTORY',
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _ShareRoundButton(icon: Icons.download_rounded, onTap: () {}),
                        _ShareRoundButton(icon: Icons.share_outlined, onTap: () {}),
                      ],
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
        width: 82.w,
        height: 82.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGreen, width: 4.w),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 38.w),
      ),
    );
  }
}
