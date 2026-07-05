import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_report_controller.dart';
import '../widgets/report_evidence_picker.dart';
import '../widgets/report_profile_card.dart';
import '../widgets/report_reason_chip.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class MessageReportView extends GetView<MessageReportController> {
  const MessageReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 150.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _ReportHeader(),
                  SizedBox(height: 44.h),
                  ReportProfileCard(profile: controller.profile),
                  SizedBox(height: 42.h),
                  _SectionLabel(text: 'why_are_you_reporting_this_user'.tr),
                  SizedBox(height: 22.h),
                  const _ReasonSelector(),
                  SizedBox(height: 42.h),
                  _SectionLabel(text: 'detailed_description'.tr),
                  SizedBox(height: 20.h),
                  const _DescriptionField(),
                  SizedBox(height: 42.h),
                  _SectionLabel(text: 'evidence_optional'.tr),
                  SizedBox(height: 20.h),
                  Obx(
                    () => ReportEvidencePicker(
                      selectedImage: controller.evidenceImage.value,
                      onPickImage: controller.pickEvidenceImage,
                      onRemoveImage: controller.removeEvidenceImage,
                    ),
                  ),
                ],
              ),
            ),
            const _SubmitFooter(),
          ],
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back<void>(),
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 18.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.homePrimaryText,
                  size: 34.w,
                ),
              ),
            ),
          ),
          Text(
            'report_user'.tr,
            style: TextStyle(
              fontSize: AppFont.font24.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppFont.font18.sp,
        fontWeight: FontWeight.w900,
        color: AppColors.bodyText,
      ),
    );
  }
}

class _ReasonSelector extends GetView<MessageReportController> {
  const _ReasonSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReasons.value) {
        return SizedBox(
          height: 80.h,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      // Error state: backend returned nothing or non-UUID ids.
      if (controller.hasReasonsError.value || controller.reportReasons.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'could_not_load_report_reasons_please_check_your_co'.tr,
              style: TextStyle(
                fontSize: AppFont.font16.sp,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: controller.retryLoadReasons,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'reload_reasons'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Wrap(
        spacing: 18.w,
        runSpacing: 18.h,
        children: controller.reportReasons
            .map(
              (Map<String, dynamic> r) => ReportReasonChip(
                label:
                    r['title']?.toString() ?? r['name']?.toString() ?? 'reason'.tr,
                isSelected:
                    controller.selectedReasonId.value ==
                    (r['id']?.toString() ?? ''),
                onTap: () => controller.selectReason(r['id']?.toString() ?? ''),
              ),
            )
            .toList(),
      );
    });
  }
}

class _DescriptionField extends GetView<MessageReportController> {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kReportDescriptionHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius38.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.homeNeutralShadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller.descriptionController,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: TextStyle(
          fontSize: AppFont.font20.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.homePrimaryText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              'gen_describe_what_happened_e_g_n_t'.tr,
          hintStyle: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: AppColors.messageCheckGrey,
          ),
        ),
      ),
    );
  }
}

class _SubmitFooter extends GetView<MessageReportController> {
  const _SubmitFooter();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28.w,
      right: 28.w,
      bottom: 24.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.homeBackground.withValues(alpha: 0),
              AppColors.homeBackground,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 26.h),
          child: Obx(
            () => CustomButton.primary(
              text: 'submit_report'.tr,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.submitReport,
            ),
          ),
        ),
      ),
    );
  }
}
