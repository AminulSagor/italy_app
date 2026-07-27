import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../../ai_content_reports/models/ai_content_report_model.dart';
import '../../ai_content_reports/widgets/ai_report_button.dart';
import '../controllers/cv_generation_controller.dart';
import '../models/cv_generation_models.dart';
import '../widgets/cv_design_instruction_sheet.dart';
import '../widgets/cv_edit_options_sheet.dart';
import '../widgets/cv_zoomable_preview.dart';

class CvGenerationView
    extends GetView<CvGenerationController> {
  const CvGenerationView({
    required this.controllerTag,
    super.key,
  });

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        final CvGenerationModel? generation =
            controller.generation.value;

        final String? imageUrl =
            controller.generatedImageUrl;

        if (controller.isFullScreenPreview.value &&
            imageUrl != null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: _FullScreenPreview(
              imageUrl: imageUrl,
              controller: controller,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.homeBackground,
          appBar: SimpleAppbar(
            title: 'cv_generation_title'.tr,
            onBackTap: Get.back,
          ),
          body: SafeArea(
            top: false,
            child: _buildBody(
              context: context,
              generation: generation,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required CvGenerationModel? generation,
  }) {
    final bool hasFatalError =
        controller.errorMessage.value.isNotEmpty &&
            (generation == null || generation.isFailed);

    if (hasFatalError) {
      return _ErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.retry,
      );
    }

    if (controller.isLoading.value ||
        generation == null ||
        generation.isProcessing) {
      return const _GeneratingState();
    }

    if (generation.isFailed) {
      return _ErrorState(
        message: generation.errorMessage ??
            controller.errorMessage.value,
        onRetry: controller.retry,
      );
    }

    final String imageUrl =
        generation.generatedImageUrl?.trim() ?? '';

    if (imageUrl.isEmpty) {
      return _ErrorState(
        message: 'cv_generation_image_unavailable'.tr,
        onRetry: controller.retry,
      );
    }

    return _CompletedState(
      generation: generation,
      imageUrl: imageUrl,
      controller: controller,
      onEdit: () {
        _showEditOptions(context);
      },
      onDownloadPdf: controller.createPdf,
      onOpenFullScreen:
      controller.openFullScreenPreview,
    );
  }

  Future<void> _showEditOptions(
      BuildContext context,
      ) async {
    if (!controller.canEdit) {
      return;
    }

    final CvEditOption? option =
    await showModalBottomSheet<CvEditOption>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return const CvEditOptionsSheet();
      },
    );

    if (option == null || !context.mounted) {
      return;
    }

    switch (option) {
      case CvEditOption.factsOnly:
        await _runWithProcessingOverlay(
          context: context,
          title:   'cv_generation_opening_information_editor'.tr,
          message:
          'cv_generation_preparing_information_editor'.tr,
          action: controller.startFactsOnlyEdit,
        );
        return;

      case CvEditOption.designAndFacts:
        await _runWithProcessingOverlay(
          context: context,
          title:
          'cv_generation_preparing_cv_editor'.tr,
          message:
          'cv_generation_loading_information_design'.tr,
          action:
          controller.startDesignAndFactsEdit,
        );
        return;

      case CvEditOption.designOnly:
      // Brief transition feedback before opening
      // the next design-instruction bottom sheet.
        await _runWithProcessingOverlay(
          context: context,
          title:
          'cv_generation_opening_design_editor'.tr,
          message:
          'cv_generation_preparing_design_form'.tr,
          action: () async {
            await Future<void>.delayed(
              const Duration(milliseconds: 350),
            );
          },
        );

        if (!context.mounted) {
          return;
        }

        await _showDesignInstructionSheet(
          context,
        );
        return;
    }
  }

  Future<void> _runWithProcessingOverlay({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    final Route<dynamic>? sourceRoute =
    ModalRoute.of(context);

    final OverlayState overlay = Overlay.of(
      context,
      rootOverlay: true,
    );

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _EditProcessingOverlay(
          title: title,
          message: message,
        );
      },
    );

    overlay.insert(overlayEntry);

    // Let Flutter render the overlay first.
    await Future<void>.delayed(
      const Duration(milliseconds: 80),
    );

    bool actionFinished = false;
    Object? actionError;
    StackTrace? actionStackTrace;

    // Start the request/navigation, but do not directly
    // await it because Get.to() finishes only after the
    // destination page is closed.
    action().then<void>(
          (_) {
        actionFinished = true;
      },
      onError: (
          Object error,
          StackTrace stackTrace,
          ) {
        actionFinished = true;
        actionError = error;
        actionStackTrace = stackTrace;
      },
    );

    while (overlayEntry.mounted) {
      await Future<void>.delayed(
        const Duration(milliseconds: 50),
      );

      final bool navigationCompleted =
          sourceRoute != null &&
              !sourceRoute.isCurrent;

      if (navigationCompleted) {
        // Allow the new page to render before removing
        // the loading overlay.
        await Future<void>.delayed(
          const Duration(milliseconds: 120),
        );

        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }

        return;
      }

      // The action ended without navigating, usually
      // because it failed or was cancelled.
      if (actionFinished || !context.mounted) {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }

        if (actionError != null &&
            actionStackTrace != null) {
          Error.throwWithStackTrace(
            actionError!,
            actionStackTrace!,
          );
        }

        return;
      }
    }
  }

  Future<void> _showDesignInstructionSheet(
      BuildContext context,
      ) async {
    final String? instruction =
    await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return const CvDesignInstructionSheet();
      },
    );

    if (instruction == null ||
        instruction.trim().isEmpty) {
      return;
    }

    await controller.regenerateDesign(
      instruction,
    );
  }
}

class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 66.w,
              height: 66.w,
              child: const CircularProgressIndicator(
                strokeWidth: 5,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'cv_generation_creating_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 9.h),
            Text(
              'cv_generation_creating_description'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.homeSecondaryText,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'cv_generation_do_not_leave'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.generation,
    required this.imageUrl,
    required this.controller,
    required this.onEdit,
    required this.onDownloadPdf,
    required this.onOpenFullScreen,
  });

  final CvGenerationModel generation;
  final String imageUrl;
  final CvGenerationController controller;

  final VoidCallback onEdit;
  final VoidCallback onDownloadPdf;
  final VoidCallback onOpenFullScreen;

  @override
  Widget build(BuildContext context) {
    final bool isBusy =
        controller.isStartingEdit.value ||
            controller.isRegenerating.value ||
            controller.isCreatingPdf.value;

    final bool isOpeningEditor =
        controller.isStartingEdit.value;

    final bool isApplyingDesign =
        controller.isRegenerating.value;

    final bool isDownloadingPdf =
        controller.isCreatingPdf.value;

    final bool isProcessingAction =
        isOpeningEditor ||
            isApplyingDesign ||
            isDownloadingPdf;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        24.h,
      ),
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1 / 1.25,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(22.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CvZoomablePreview(
                    imageUrl: imageUrl,
                    transformationController:
                    controller
                        .previewTransformationController,
                    onInteractionEnd:
                    controller.syncPreviewScale,
                  ),
                ),

                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Material(
                    color: Colors.black.withValues(
                      alpha: 0.72,
                    ),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'cv_generation_open_fullscreen'.tr,
                      onPressed: onOpenFullScreen,
                      icon: const Icon(
                        Icons.zoom_out_map_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                if (controller.previewScale.value > 1)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Material(
                      color: Colors.black.withValues(
                        alpha: 0.72,
                      ),
                      borderRadius:
                      BorderRadius.circular(20.r),
                      child: InkWell(
                        onTap: controller.resetZoom,
                        borderRadius:
                        BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 7.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'cv_generation_reset_zoom'.tr,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
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
          ),
        ),

        SizedBox(height: 8.h),

        Align(
          alignment: Alignment.centerRight,
          child: AiReportButton(
            source: AiContentReportSource(
              featureType: AiReportFeatureType.cvBuilder,

              // Automatically attaches the generated CV preview.
              aiContentUrl: imageUrl,
            ),
          ),
        ),

        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7E4),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.copy_all_outlined,
                size: 22.w,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  generation.isEditedOrRegeneratedVersion
                      ? 'cv_generation_new_version_notice'.tr
                      : 'cv_generation_edit_version_notice'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 13.h),

        Text(
          'cv_generation_review_notice'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            height: 1.4,
            color: AppColors.homeSecondaryText,
          ),
        ),

        if (controller.errorMessage.value.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],

        if (isProcessingAction) ...<Widget>[
          _ActionStatusCard(
            icon: isDownloadingPdf
                ? Icons.download_rounded
                : isApplyingDesign
                ? Icons.auto_fix_high_rounded
                : Icons.edit_rounded,
            title: isDownloadingPdf
                ? 'cv_generation_download_started'.tr
                : isApplyingDesign
                ? 'cv_generation_applying_design'.tr
                : 'cv_generation_opening_editor'.tr,
            message: isDownloadingPdf
                ? 'cv_generation_pdf_preparing_saving'.tr
                : isApplyingDesign
                ? 'cv_generation_ai_creating_version'.tr
                : 'cv_generation_preparing_edit_information'.tr,
          ),
          SizedBox(height: 14.h),
        ],

        SizedBox(height: 16.h),

        CustomButton.primary(
          text: isOpeningEditor
              ? 'cv_generation_opening_editor_button'.tr
              : isApplyingDesign
              ? 'cv_generation_applying_design_button'.tr
              : 'cv_generation_edit_design_button'.tr,
          prefixIcon: isApplyingDesign
              ? Icons.auto_fix_high_rounded
              : Icons.edit_rounded,
          isLoading:
          isOpeningEditor || isApplyingDesign,
          onPressed: () {
            if (isBusy) {
              return;
            }



            onEdit();
          },
        ),

        SizedBox(height: 10.h),

        OutlinedButton.icon(
          onPressed:
          controller.canCreatePdf && !isBusy
              ? () {
            Get.snackbar(
              'cv_generation_download_started'.tr,
              'cv_generation_download_snackbar'.tr,
              snackPosition: SnackPosition.TOP,
              duration:
              const Duration(seconds: 3),
              margin: EdgeInsets.all(14.w),
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.primaryGreen,
              ),
            );

            onDownloadPdf();
          }
              : null,
          icon: isDownloadingPdf
              ? SizedBox(
            width: 18.w,
            height: 18.w,
            child:
            const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Icon(
            Icons.download_rounded,
          ),
          label: Text(
            isDownloadingPdf
                ? 'cv_generation_preparing_download'.tr
                : 'cv_generation_download_pdf'.tr,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize:
            Size(double.infinity, 50.h),
            foregroundColor:
            AppColors.primaryGreen,
            side: const BorderSide(
              color: AppColors.primaryGreen,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(15.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionStatusCard
    extends StatelessWidget {
  const _ActionStatusCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E4),
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryGreen
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 22.w,
              height: 22.w,
              child: const
              CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 18.w,
                      color:
                      AppColors.primaryGreen,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                          FontWeight.w800,
                          color: AppColors
                              .homePrimaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color: AppColors
                        .homeSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenPreview extends StatelessWidget {
  const _FullScreenPreview({
    required this.imageUrl,
    required this.controller,
  });

  final String imageUrl;
  final CvGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CvZoomablePreview(
              imageUrl: imageUrl,
              transformationController:
              controller
                  .previewTransformationController,
              onInteractionEnd:
              controller.syncPreviewScale,
              backgroundColor: Colors.black,
            ),
          ),

          Positioned(
            top: 12.h,
            left: 12.w,
            child: Material(
              color: Colors.black.withValues(
                alpha: 0.7,
              ),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'cv_generation_close_preview'.tr,
                onPressed:
                controller.closeFullScreenPreview,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            right: 14.w,
            bottom: 22.h,
            child: Column(
              children: <Widget>[
                _PreviewControlButton(
                  icon: Icons.add_rounded,
                  tooltip: 'cv_generation_zoom_in'.tr,
                  onTap: controller.zoomIn,
                ),
                SizedBox(height: 9.h),
                _PreviewControlButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'cv_generation_zoom_out'.tr,
                  onTap: controller.zoomOut,
                ),
                SizedBox(height: 9.h),
                _PreviewControlButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'cv_generation_reset_zoom'.tr,
                  onTap: controller.resetZoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewControlButton
    extends StatelessWidget {
  const _PreviewControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.72,
      ),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(26.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: 54.w,
                color: Colors.red,
              ),
              SizedBox(height: 15.h),
              Text(
                'cv_generation_failed'.tr,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
              SizedBox(height: 20.h),
              CustomButton.primary(
                text: 'cv_generation_try_again'.tr,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );


  }




}

class _EditProcessingOverlay
    extends StatelessWidget {
  const _EditProcessingOverlay({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.45,
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: SafeArea(
          child: Center(
            child: Container(
              width: 300.w,
              margin: EdgeInsets.symmetric(
                horizontal: 28.w,
              ),
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(24.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 58.w,
                    height: 58.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF7E4),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color:
                      AppColors.homePrimaryText,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.45,
                      color: AppColors
                          .homeSecondaryText,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 16.w,
                        color:
                        AppColors.primaryGreen,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'cv_generation_do_not_close_page'.tr,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          AppColors.primaryGreen,
                        ),
                      ),
                    ],
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