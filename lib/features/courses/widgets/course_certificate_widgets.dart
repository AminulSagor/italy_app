import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final double size = compact ? 214.w : 232.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homeSoftGreen.withValues(alpha: 0.56),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.homeLime.withValues(alpha: 0.18),
                  blurRadius: 46.r,
                  spreadRadius: 20.r,
                ),
              ],
            ),
          ),
          Icon(
            Icons.school_rounded,
            color: AppColors.primaryGreen,
            size: compact ? 122.w : 142.w,
          ),
          Positioned(
            right: compact ? 28.w : 18.w,
            bottom: compact ? 42.h : 46.h,
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.vocabularyOrangeShadow,
              size: 48.w,
            ),
          ),
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 34.w : 38.w,
        vertical: compact ? 42.h : 52.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius42.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.white,
            AppColors.homeSoftGreen.withValues(alpha: 0.2),
            AppColors.coursesCreamLightBg.withValues(alpha: 0.35),
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
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(kRadius18.r),
            ),
            child: Icon(Icons.school_rounded, color: AppColors.limeTextColor, size: 34.w),
          ),
          SizedBox(height: 20.h),
          Text(
            'ITALIR POTHE',
            style: TextStyle(
              fontSize: AppFont.font12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: compact ? 42.h : 54.h),
          Text(
            'CERTIFICATE OF\nACHIEVEMENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? AppFont.font24.sp : AppFont.font22.sp,
              fontWeight: FontWeight.w900,
              height: 1.25,
              color: AppColors.bodyText,
            ),
          ),
          SizedBox(height: 44.h),
          Text(
            'THIS CERTIFIES THAT',
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
              color: AppColors.quizAnswerShadow,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            certificate.learnerName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? AppFont.font42.sp : AppFont.font36.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Container(width: 70.w, height: 2.h, color: AppColors.coursesCertificationBorder),
          SizedBox(height: 42.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.homeSoftGreen.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(color: AppColors.coursesCertificationBorder),
            ),
            child: Text(
              'Proficiency Level: ${certificate.proficiencyLevel}',
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          if (!compact) ...<Widget>[
            SizedBox(height: 54.h),
            Divider(color: AppColors.modalBorderGrey.withValues(alpha: 0.5)),
            SizedBox(height: 28.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: _CertificateMeta(label: 'ISSUE DATE', value: certificate.issueDate),
                ),
                Container(
                  width: 86.w,
                  height: 86.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(kRadius24.r),
                  ),
                  child: Icon(Icons.verified_rounded, color: AppColors.homeLime, size: 46.w),
                ),
                Expanded(
                  child: _CertificateMeta(
                    label: 'FINAL SCORE',
                    value: '${certificate.finalScore} / 100',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 96.h),
            Text(
              'VERIFIED DIGITAL SIGNATURE',
              style: TextStyle(
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.quizAnswerShadow.withValues(alpha: 0.6),
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
            label: 'WORDS',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _CertificateStatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.blockDangerRed,
            value: '${certificate.streakDays}',
            label: 'DAYS',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _CertificateStatCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primaryGreen,
            value: '${certificate.quizzesCompleted}',
            label: 'QUIZZES',
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
            height: 66.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              border: Border.all(color: AppColors.coursesCertificationBorder, width: 2.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.download_rounded, color: AppColors.primaryGreen, size: 22.w),
                SizedBox(width: 10.w),
                Text(
                  'Download PDF Certificate',
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w900,
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
          text: 'Start Level A2',
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
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: AppFont.font11.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFont.font16.sp,
            fontWeight: FontWeight.w900,
            color: alignEnd ? AppColors.primaryGreen : AppColors.homePrimaryText,
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
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.homePrimaryText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font9.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
