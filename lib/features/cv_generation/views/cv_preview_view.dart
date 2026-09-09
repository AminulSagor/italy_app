import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/cv_preview_controller.dart';

class CvPreviewView extends GetView<CvPreviewController> {
  const CvPreviewView({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECEA),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _PreviewToolbar(),
            if (controller.generation.warnings.isNotEmpty)
              _WarningsBanner(warnings: controller.generation.warnings),
            Expanded(
              child: Obx(() {
                if (controller.pdfLoadFailed.value) {
                  return _PdfError(onRetry: controller.retryPdf);
                }

                return Stack(
                  children: <Widget>[
                    // No horizontal card padding: the document uses the full
                    // available width. Syncfusion preserves the PDF's original
                    // page aspect ratio while pages scroll vertically.
                    Positioned.fill(
                      child: SfPdfViewer.network(
                        controller.generation.pdfUrl,
                        key: ValueKey<String>(
                          '${controller.generation.id}-${controller.pdfReloadKey.value}',
                        ),
                        pageLayoutMode: PdfPageLayoutMode.continuous,
                        scrollDirection: PdfScrollDirection.vertical,
                        canShowScrollHead: false,
                        canShowScrollStatus: false,
                        canShowPaginationDialog: false,
                        onDocumentLoaded: (_) => controller.markPdfLoaded(),
                        onDocumentLoadFailed: (_) =>
                            controller.markPdfLoadFailed(),
                      ),
                    ),
                    if (controller.isPdfLoading.value)
                      const Positioned.fill(child: _PdfLoadingState()),
                  ],
                );
              }),
            ),
            Material(
              color: Colors.white,
              elevation: 10,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                  child: Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: controller.isDownloading.value
                            ? null
                            : controller.downloadPdf,
                        icon: controller.isDownloading.value
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(
                          controller.isDownloading.value
                              ? 'cvb_downloading'.tr
                              : 'cvb_download_pdf'.tr,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.homeBackground,
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 12.w, 5.h),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'cvb_back'.tr,
            onPressed: () => Get.back<void>(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'cvb_preview_title'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _PdfLoadingState extends StatelessWidget {
  const _PdfLoadingState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE9ECEA),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: <Widget>[
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.96,
                child: AspectRatio(
                  aspectRatio: 210 / 297,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 28.w,
                            height: 28.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'cvb_loading_cv'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homeSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningsBanner extends StatelessWidget {
  const _WarningsBanner({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DD),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: Color(0xFF8A5A00)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              warnings.join('\n'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: const Color(0xFF6C4A08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfError extends StatelessWidget {
  const _PdfError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 48.w,
              color: AppColors.homeSecondaryText,
            ),
            SizedBox(height: 12.h),
            Text(
              'cvb_preview_load_failed'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('cvb_try_again'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
