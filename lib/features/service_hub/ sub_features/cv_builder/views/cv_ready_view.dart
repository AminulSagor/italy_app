import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_next_step_card.dart';
import '../_widgets/cv_ready_action_card.dart';
import '../_widgets/cv_ready_preview_card.dart';
import '../controllers/cv_ready_controller.dart';

class CvReadyView extends GetView<CvReadyController> {
  const CvReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
                child: Column(
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: 28.h),
                    Text(
                      'Your CV is Ready!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: AppFont.font22.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Professionally formatted and ready to send.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.homeSecondaryText,
                        fontSize: AppFont.font11.sp,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    CvReadyPreviewCard(
                      onTap: controller.onPreviewTap,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CvReadyActionCard(
                            title: 'Download PDF',
                            icon: Icons.download_rounded,
                            backgroundColor: AppColors.homePaleGreen,
                            iconBackgroundColor: AppColors.safetyBlockedBg,
                            iconColor: AppColors.primaryGreen,
                            titleColor: AppColors.primaryGreen,
                            onTap: controller.onDownloadPdfTap,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: CvReadyActionCard(
                            title: 'Share to\nWhatsApp',
                            icon: Icons.chat_rounded,
                            backgroundColor: AppColors.messageOnlineGreen,
                            iconBackgroundColor:
                            AppColors.white.withOpacity(0.22),
                            iconColor: AppColors.white,
                            titleColor: AppColors.white,
                            onTap: controller.onShareWhatsAppTap,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    const CvNextStepCard(),
                  ],
                ),
              ),
            ),
            _BottomButton(
              title: 'Finish & Go to Dashboard',
              onTap: controller.onFinishTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
              size: AppFont.font17.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _BottomButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
            child: Container(
              height: 52.h,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: AppFont.font15.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}