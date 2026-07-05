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
          final CourseCertificateModel? certificate =
              controller.certificate.value;

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
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 34.h),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: controller.closeCertificate,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.bodyText,
                        size: 22.w,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'achievement_unlocked'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFont.font16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.showShareDialog,
                      child: Icon(
                        Icons.share_outlined,
                        color: AppColors.bodyText,
                        size: 22.w,
                      ),
                    ),
                  ],
                ),
                const CourseCertificateHero(),
                Text(
                  'congratulazioni'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font36.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  "you_ve_reached_a_new_milestone".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 30.h),
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
