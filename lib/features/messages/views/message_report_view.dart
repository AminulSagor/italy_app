import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_report_controller.dart';
import '../widgets/report_evidence_picker.dart';
import '../widgets/report_profile_card.dart';
import '../widgets/report_reason_chip.dart';

class MessageReportView
    extends GetView<MessageReportController> {
  const MessageReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus
                ?.unfocus();
          },
          child: SingleChildScrollView(
            physics:
            const BouncingScrollPhysics(),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior
                .onDrag,
            padding: EdgeInsets.fromLTRB(
              20.w,
              14.h,
              20.w,
              28.h,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    const _ReportHeader(),

                    SizedBox(height: 22.h),

                    ReportProfileCard(
                      profile: controller.profile,
                    ),

                    SizedBox(height: 26.h),

                    _SectionLabel(
                      text:
                      'why_are_you_reporting_this_user'
                          .tr,
                    ),

                    SizedBox(height: 12.h),

                    const _ReasonSelector(),

                    SizedBox(height: 26.h),

                    _SectionLabel(
                      text:
                      'detailed_description'.tr,
                    ),

                    SizedBox(height: 12.h),

                    const _DescriptionField(),

                    SizedBox(height: 26.h),

                    _SectionLabel(
                      text: 'evidence_optional'.tr,
                    ),

                    SizedBox(height: 12.h),

                    Obx(
                          () => ReportEvidencePicker(
                        selectedImage: controller
                            .evidenceImage.value,
                        onPickImage:
                        controller
                            .pickEvidenceImage,
                        onRemoveImage:
                        controller
                            .removeEvidenceImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
      const _SubmitFooter(),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Get.back<void>(),
                customBorder:
                const CircleBorder(),
                child: SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors
                        .homePrimaryText,
                    size: 22.w,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 56.w,
            ),
            child: Text(
              'report_user'.tr,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w700,
                color:
                AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppFont.font14.sp,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.homePrimaryText,
      ),
    );
  }
}

class _ReasonSelector
    extends GetView<MessageReportController> {
  const _ReasonSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReasons.value) {
        return SizedBox(
          height: 56.h,
          child: Center(
            child: SizedBox(
              width: 22.w,
              height: 22.w,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2.2,
                color:
                AppColors.primaryGreen,
              ),
            ),
          ),
        );
      }

      if (controller.hasReasonsError.value ||
          controller.reportReasons.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
            BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'could_not_load_report_reasons_please_check_your_co'
                    .tr,
                style: TextStyle(
                  fontSize:
                  AppFont.font13.sp,
                  height: 1.4,
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed:
                controller.retryLoadReasons,
                style: TextButton.styleFrom(
                  foregroundColor:
                  AppColors.primaryGreen,
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
                ),
                child: Text(
                  'reload_reasons'.tr,
                  style: TextStyle(
                    fontSize:
                    AppFont.font13.sp,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: controller.reportReasons
            .map(
              (
              Map<String, dynamic> reason,
              ) {
            final String reasonId =
                reason['id']
                    ?.toString() ??
                    '';

            final String label =
                reason['title']
                    ?.toString() ??
                    reason['name']
                        ?.toString() ??
                    'reason'.tr;

            return ReportReasonChip(
              label: label,
              isSelected: controller
                  .selectedReasonId
                  .value ==
                  reasonId,
              onTap: () => controller
                  .selectReason(reasonId),
            );
          },
        )
            .toList(growable: false),
      );
    });
  }
}

class _DescriptionField
    extends GetView<MessageReportController> {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 142.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.modalBorderGrey
              .withValues(alpha: 0.7),
        ),
      ),
      child: TextField(
        controller:
        controller.descriptionController,
        minLines: 5,
        maxLines: 7,
        keyboardType:
        TextInputType.multiline,
        textInputAction:
        TextInputAction.newline,
        style: TextStyle(
          fontSize: AppFont.font14.sp,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color:
          AppColors.homePrimaryText,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText:
          'gen_describe_what_happened_e_g_n_t'
              .tr,
          hintStyle: TextStyle(
            fontSize: AppFont.font14.sp,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color:
            AppColors.messageCheckGrey,
          ),
        ),
      ),
    );
  }
}

class _SubmitFooter
    extends GetView<MessageReportController> {
  const _SubmitFooter();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.homeBackground,
          border: Border(
            top: BorderSide(
              color: AppColors.modalBorderGrey
                  .withValues(alpha: 0.45),
            ),
          ),
        ),
        child: Obx(
              () => CustomButton.primary(
            text: 'submit_report'.tr,
            isLoading:
            controller.isSubmitting.value,
            onPressed: () {
              if (controller
                  .isSubmitting.value) {
                return;
              }

              controller.submitReport();
            },
          ),
        ),
      ),
    );
  }
}