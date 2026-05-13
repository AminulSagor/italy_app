import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/course_certificate_controller.dart';
import '../models/course_certificate_models.dart';
import '../widgets/course_certificate_widgets.dart';

class CourseCertificateView extends GetView<CourseCertificateController> {
  final String controllerTag;

  const CourseCertificateView({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      body: SafeArea(
        child: Obx(() {
          final CourseCertificateModel? certificate = controller.certificate.value;

          if (controller.isLoading.value && certificate == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (certificate == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(30.w, 32.h, 30.w, 34.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: controller.closeCertificate,
                      child: Icon(Icons.close_rounded, color: AppColors.bodyText, size: 34.w),
                    ),
                    Expanded(
                      child: Text(
                        'Achievement Unlocked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.showShareDialog,
                      child: Icon(Icons.share_outlined, color: AppColors.bodyText, size: 30.w),
                    ),
                  ],
                ),
                SizedBox(height: 54.h),
                const CourseCertificateHero(),
                SizedBox(height: 28.h),
                Text(
                  'Congratulazioni!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font42.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "You've reached a new milestone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 42.h),
                CourseCertificateCard(certificate: certificate),
                SizedBox(height: 28.h),
                CourseCertificateStatsRow(certificate: certificate),
                SizedBox(height: 78.h),
                CourseCertificateActions(
                  onDownloadTap: () {},
                  onStartLevelTap: controller.startLevelA2,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
