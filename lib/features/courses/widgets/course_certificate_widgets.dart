import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/course_certificate_models.dart';

class CourseCertificateCard extends StatelessWidget {
  final CourseCertificateModel certificate;

  const CourseCertificateCard({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final bool isSmallScreen = constraints.maxWidth < 350;
        final double padding = isSmallScreen ? 18.w : 28.w;
        final double logoSize = isSmallScreen ? 48.w : 56.w;
        final double sealSize = isSmallScreen ? 50.w : 64.w;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              isSmallScreen ? kRadius24.r : kRadius42.r,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.coursesCreamLightBg.withValues(
                  alpha: 0.4,
                ),
                AppColors.white,
                AppColors.coursesCreamLightBg.withValues(
                  alpha: 0.4,
                ),
              ],
            ),
            border: Border.all(
              color: AppColors.coursesCertificationBorder.withValues(
                alpha: 0.35,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.homeNeutralShadow,
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(kRadius18.r),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: AppColors.white,
                  size: isSmallScreen ? 27.w : 31.w,
                ),
              ),
              SizedBox(height: 10.h),

              Text(
                'gen_italir_pothe'.tr,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _responsiveSp(
                    AppFont.font10.sp,
                    minimum: 9,
                    maximum: 11,
                  ),
                  fontWeight: FontWeight.w700,
                  letterSpacing: isSmallScreen ? 1.5 : 2.5,
                  color: AppColors.primaryGreen,
                ),
              ),

              SizedBox(height: 26.h),

              Text(
                'certificate_of_achievement'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _responsiveSp(
                    AppFont.font20.sp,
                    minimum: 17,
                    maximum: 22,
                  ),
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.headerText,
                ),
              ),

              SizedBox(height: 26.h),

              Text(
                'this_certifies_that'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _responsiveSp(
                    AppFont.font12.sp,
                    minimum: 10,
                    maximum: 13,
                  ),
                  fontWeight: FontWeight.w700,
                  letterSpacing: isSmallScreen ? 1.2 : 1.8,
                  color: AppColors.bodyText,
                ),
              ),

              SizedBox(height: 10.h),

              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    certificate.learnerName.trim().isEmpty
                        ? 'not_available'.tr
                        : certificate.learnerName,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _responsiveSp(
                        AppFont.font30.sp,
                        minimum: 22,
                        maximum: 32,
                      ),
                      fontWeight: FontWeight.w700,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                ),
              ),

              if (certificate.courseTitle.trim().isNotEmpty) ...<Widget>[
                SizedBox(height: 12.h),
                Text(
                  certificate.courseTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _responsiveSp(
                      AppFont.font16.sp,
                      minimum: 13,
                      maximum: 17,
                    ),
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
              ],

              SizedBox(height: 14.h),

              Container(
                width: 48.w,
                height: 2.h,
                color: AppColors.coursesCertificationBorder,
              ),

              SizedBox(height: 24.h),

              Container(
                constraints: const BoxConstraints(
                  maxWidth: 360,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 14.w : 22.w,
                  vertical: 11.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.homeSoftGreen.withValues(
                    alpha: 0.34,
                  ),
                  borderRadius: BorderRadius.circular(
                    kHomePillRadius.r,
                  ),
                  border: Border.all(
                    color: AppColors.coursesCertificationBorder.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Text(
                  'proficiency_level_value'.trParams(
                    <String, String>{
                      'level': certificate.proficiencyLevel.trim().isEmpty
                          ? 'not_available'.tr
                          : certificate.proficiencyLevel,
                    },
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _responsiveSp(
                      AppFont.font14.sp,
                      minimum: 12,
                      maximum: 15,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),

              SizedBox(height: 26.h),

              Divider(
                color: AppColors.modalBorderGrey.withValues(
                  alpha: 0.4,
                ),
              ),

              SizedBox(height: 18.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: _CertificateMeta(
                      label: 'issue_date'.tr,
                      value: certificate.issueDate,
                    ),
                  ),

                  SizedBox(width: isSmallScreen ? 8.w : 14.w),

                  Container(
                    width: sealSize,
                    height: sealSize,
                    padding: EdgeInsets.all(
                      isSmallScreen ? 8.w : 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? kRadius18.r : kRadius24.r,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons_svg/app_icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(width: isSmallScreen ? 8.w : 14.w),

                  Expanded(
                    child: _CertificateMeta(
                      label: 'final_score'.tr,
                      value: '${certificate.finalScore} / 100',
                      alignEnd: true,
                    ),
                  ),
                ],
              ),

              if (certificate.certificateNumber.trim().isNotEmpty)
                ...<Widget>[
                  SizedBox(height: 24.h),
                  Text(
                    'certificate_number_value'.trParams(
                      <String, String>{
                        'number': certificate.certificateNumber,
                      },
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _responsiveSp(
                        AppFont.font11.sp,
                        minimum: 10,
                        maximum: 12,
                      ),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],

              SizedBox(height: 26.h),

              Text(
                'verified_digital_signature'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _responsiveSp(
                    AppFont.font9.sp,
                    minimum: 9,
                    maximum: 11,
                  ),
                  fontWeight: FontWeight.w800,
                  letterSpacing: isSmallScreen ? 0.8 : 1.4,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CourseCertificateActions extends StatelessWidget {
  final VoidCallback? onDownloadTap;
  final bool isLoading;

  const CourseCertificateActions({
    super.key,
    required this.onDownloadTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onDownloadTap == null || isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDisabled ? 0.65 : 1,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
        child: InkWell(
          onTap: isDisabled ? null : onDownloadTap,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 54.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 13.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                kHomePillRadius.r,
              ),
              border: Border.all(
                color: AppColors.coursesCertificationBorder,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primaryGreen,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryGreen,
                  size: 21.w,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'download_pdf_certificate'.tr,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _responsiveSp(
                        AppFont.font16.sp,
                        minimum: 14,
                        maximum: 17,
                      ),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    final String displayValue =
    value.trim().isEmpty ? 'not_available'.tr : value;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 2,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _responsiveSp(
              AppFont.font9.sp,
              minimum: 9,
              maximum: 11,
            ),
            fontWeight: FontWeight.w700,
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          displayValue,
          maxLines: 2,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _responsiveSp(
              AppFont.font14.sp,
              minimum: 12,
              maximum: 15,
            ),
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

double _responsiveSp(
    double value, {
      required double minimum,
      required double maximum,
    }) {
  return value.clamp(minimum, maximum).toDouble();
}