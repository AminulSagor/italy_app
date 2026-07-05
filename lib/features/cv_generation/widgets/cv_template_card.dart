import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';

class CvTemplateCard extends StatelessWidget {
  const CvTemplateCard({
    required this.template,
    required this.onTap,
    required this.isAnalyzing,
    required this.isDisabled,
    required this.hasError,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final CvTemplateModel template;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  final bool isAnalyzing;
  final bool isDisabled;
  final bool hasError;

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool canOpen =
        !isDisabled &&
            !isAnalyzing &&
            !hasError;

    final bool isSelected =
        isAnalyzing || hasError;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity:
      isDisabled && !isAnalyzing ? 0.55 : 1,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            InkWell(
              onTap: canOpen ? onTap : null,
              child: Padding(
                padding: EdgeInsets.all(9.w),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          14.r,
                        ),
                        child: Container(
                          width: double.infinity,
                          color:
                          const Color(0xFFF0F1F1),
                          child: Image.network(
                            template.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? progress,
                                ) {
                              if (progress == null) {
                                return child;
                              }

                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                                ) {
                              return const Center(
                                child: Icon(
                                  Icons
                                      .broken_image_outlined,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      template.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color:
                        AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 14.w,
                          color: AppColors.primaryGreen,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'cv_template_card_use_template'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                            AppColors.primaryGreen,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isAnalyzing)
              _AnalysisOverlay(
                templateName: template.name,
              ),

            if (hasError)
              _AnalysisFailureOverlay(
                message: errorMessage,
                onRetry:
                isDisabled ? null : onRetry,
              ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisOverlay extends StatelessWidget {
  const _AnalysisOverlay({
    required this.templateName,
  });

  final String templateName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(
        alpha: 0.62,
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              width: 25.w,
              height: 25.w,
              child:
              const CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'cv_template_card_analyzing'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            templateName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.35,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisFailureOverlay
    extends StatelessWidget {
  const _AnalysisFailureOverlay({
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final String displayedMessage =
    message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'cv_template_card_analysis_default_error'.tr;

    return Container(
      color: Colors.black.withValues(
        alpha: 0.72,
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 27.w,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'cv_template_card_analysis_failed'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            displayedMessage,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.35,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 13.h),
          SizedBox(
            height: 38.h,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: Text(
                'cv_template_card_retry'.tr,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                AppColors.primaryGreen,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}