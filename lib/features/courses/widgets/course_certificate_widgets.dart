import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/course_certificate_models.dart';

class CourseCertificateHero extends StatelessWidget {
  final bool compact;

  const CourseCertificateHero({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 205.w : 224.w;

    return SizedBox(
      width: double.infinity,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (compact)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeLime.withValues(alpha: 0.1),
                    blurRadius: 46.r,
                    spreadRadius: 20.r,
                  ),
                ],
              ),
            ),
          Image.asset('assets/decor_png/achievement.png'),
        ],
      ),
    );
  }
}

class CourseCertificateCard extends StatelessWidget {
  final CourseCertificateModel certificate;
  final bool compact;

  const CourseCertificateCard({
    super.key,
    required this.certificate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius42.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.coursesCreamLightBg.withValues(alpha: 0.4),
            AppColors.white,
            AppColors.coursesCreamLightBg.withValues(alpha: 0.4),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(kRadius18.r),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.white,
              size: 32.w,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'gen_italir_pothe'.tr,
            style: TextStyle(
              fontSize: AppFont.font10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: compact ? 30.h : 30.h),
          Text(
            'CERTIFICATE OF\nACHIEVEMENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? AppFont.font20.sp : AppFont.font20.sp,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: AppColors.headerText,
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            'this_certifies_that'.tr,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 8.h),
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
            width: 48.w,
            height: 2.h,
            color: AppColors.coursesCertificationBorder,
          ),
          SizedBox(height: 30.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.homeSoftGreen.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(
                color: AppColors.coursesCertificationBorder.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Text(
              'Proficiency Level: ${certificate.proficiencyLevel}',
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          if (!compact) ...<Widget>[
            SizedBox(height: 30.h),
            Divider(color: AppColors.modalBorderGrey.withValues(alpha: 0.4)),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: <Widget>[
                _CertificateMeta(
                  label: 'gen_issue_date'.tr,
                  value: certificate.issueDate,
                ),
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(kRadius24.r),
                  ),
                  child: SvgPicture.asset('assets/icons_svg/app_icon.svg'),
                ),
                _CertificateMeta(
                  label: 'gen_final_score'.tr,
                  value: '${certificate.finalScore} / 100',
                  alignEnd: true,
                ),
              ],
            ),
            SizedBox(height: 60.h),
            Text(
              'verified_digital_signature'.tr,
              style: TextStyle(
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CourseCertificateStatsRow extends StatelessWidget {
  final CourseCertificateModel certificate;

  const CourseCertificateStatsRow({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _CertificateStatCard(
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.reportReviewText,
            value: _formatNumber(certificate.wordsLearned),
            label: 'gen_words'.tr,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _CertificateStatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.blockDangerRed,
            value: '${certificate.streakDays}',
            label: 'gen_days'.tr,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _CertificateStatCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primaryGreen,
            value: '${certificate.quizzesCompleted}',
            label: 'gen_quizzes'.tr,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int value) {
    final String text = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i != 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

class CourseCertificateActions extends StatelessWidget {
  final VoidCallback onDownloadTap;
  final VoidCallback onStartLevelTap;

  const CourseCertificateActions({
    super.key,
    required this.onDownloadTap,
    required this.onStartLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onDownloadTap,
          child: Container(
            width: double.infinity,
            height: 60.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: AppColors.coursesCertificationBorder,
                width: 2.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryGreen,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'download_pdf_certificate'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 22.h),
        CustomButton.primary(
          onPressed: onStartLevelTap,
          text: 'start_level_a2'.tr,
          icon: Icons.play_arrow_rounded,
        ),
      ],
    );
  }
}

class _CertificateMeta extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _CertificateMeta({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w700,
            color: alignEnd
                ? AppColors.primaryGreen
                : AppColors.homePrimaryText,
          ),
        ),
      ],
    );
  }
}

class _CertificateStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _CertificateStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius24.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 20.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
