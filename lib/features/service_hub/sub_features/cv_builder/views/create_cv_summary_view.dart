import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_ai_summary_generator_card.dart';
import '../_widgets/cv_step_progress.dart';
import '../_widgets/cv_summary_preview_card.dart';
import '../controllers/create_cv_summary_controller.dart';

class CreateCvSummaryView extends GetView<CreateCvSummaryController> {
  const CreateCvSummaryView({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: 12.h),
                    CvStepProgress(
                      title: 'gen_step_4_professional_summary'.tr.tr,
                      progressText: '33%',
                      progress: 0.33,
                    ),
                    SizedBox(height: 22.h),
                    CvAiSummaryGeneratorCard(
                      controller: controller,
                    ),
                    SizedBox(height: 26.h),
                    Obx(
                          () => CvSummaryPreviewCard(
                        hasGeneratedSummary:
                        controller.hasGeneratedSummary.value,
                        summary: controller.generatedSummary,
                        onRegenerateTap: controller.regenerateSummary,
                        onEditTap: controller.editText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomButton(
              title: 'gen_save_continue'.tr.tr,
              onTap: controller.onSaveContinueTap,
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
      child: Row(
        children: <Widget>[
          GestureDetector(
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
          SizedBox(width: 10.w),
          Text(
            'Create CV',
            style: TextStyle(
              color: AppColors.homePrimaryText,
              fontSize: AppFont.font18.sp,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.4,
            ),
          ),
        ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppFont.font15.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: AppFont.font18.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
