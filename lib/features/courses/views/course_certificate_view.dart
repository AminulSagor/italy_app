import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/course_certificate_controller.dart';
import '../models/course_certificate_models.dart';
import '../widgets/course_certificate_widgets.dart';

class CourseCertificateView
    extends GetView<CourseCertificateController> {
  final String controllerTag;

  const CourseCertificateView({
    super.key,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coursesDetailBg,
      appBar: AppBar(
        backgroundColor: AppColors.coursesDetailBg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'close'.tr,
          onPressed: controller.closeCertificate,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(
          'official_certificate'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppFont.font18.sp.clamp(16.0, 20.0),
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final CourseCertificateModel? certificate =
              controller.certificate.value;

          final String pdfUrl =
              controller.certificatePdfUrl.value;

          if (controller.isLoading.value &&
              pdfUrl.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (certificate == null || pdfUrl.isEmpty) {
            return _CertificateErrorState(
              onRetry: controller.retryCertificate,
            );
          }

          if (controller.pdfLoadFailed.value) {
            return _CertificateErrorState(
              onRetry: controller.retryCertificate,
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                      ) {
                    final double horizontalPadding =
                    constraints.maxWidth < 360
                        ? 8.w
                        : 16.w;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8.h,
                        horizontalPadding,
                        0,
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(16.r),
                        child: ColoredBox(
                          color: AppColors.white,
                          child: SfPdfViewer.network(
                            pdfUrl,
                            key: ValueKey<String>(pdfUrl),
                            pageLayoutMode:
                            PdfPageLayoutMode.single,
                            scrollDirection:
                            PdfScrollDirection.vertical,
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            canShowPaginationDialog: false,
                            onDocumentLoaded: (_) {
                              controller.markPdfLoaded();
                            },
                            onDocumentLoadFailed: (_) {
                              controller.markPdfLoadFailed();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  14.h,
                  16.w,
                  18.h,
                ),
                child: CourseCertificateActions(
                  isLoading:
                  controller.isDownloading.value,
                  onDownloadTap:
                  controller.isDownloading.value
                      ? null
                      : controller.downloadCertificate,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CertificateErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _CertificateErrorState({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 52.w.clamp(44.0, 58.0),
                color: AppColors.bodyText,
              ),
              SizedBox(height: 16.h),
              Text(
                'certificate_unavailable'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                  AppFont.font18.sp.clamp(16.0, 20.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimaryText,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onRetry,
                child: Text('try_again'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}