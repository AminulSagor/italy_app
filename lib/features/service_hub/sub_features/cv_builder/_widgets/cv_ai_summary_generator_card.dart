import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../controllers/create_cv_summary_controller.dart';

class CvAiSummaryGeneratorCard extends StatelessWidget {
  final CreateCvSummaryController controller;

  const CvAiSummaryGeneratorCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(kRadius26.r),
        border: Border.all(color: AppColors.homeBlueIcon, width: 2.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeBlueIcon.withValues(alpha: 0.30),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.serviceHubLightGreen,
                  borderRadius: BorderRadius.circular(kRadius14.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryGreen,
                  size: AppFont.font28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'AI Summary\nGenerator',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Container(
            height: 48.h,
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.12),
                width: 1.w,
              ),
            ),
            child: Text(
              '"Tell us what types of job\nyou are looking for..."',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.64),
                fontSize: AppFont.font11.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(
            () => Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
              child: InkWell(
                onTap: controller.isGenerating.value
                    ? null
                    : controller.generateSummary,
                borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                child: Container(
                  height: 46.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: controller.isGenerating.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primaryGreen,
                              size: AppFont.font18.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Generate Summary',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: AppFont.font12.sp,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
