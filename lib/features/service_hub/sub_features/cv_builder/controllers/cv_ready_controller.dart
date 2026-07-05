import 'dart:typed_data';

import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_pdf_download_service.dart';
import '../views/cv_ready_pdf_viewer_view.dart';

class CvReadyController extends GetxController {
  CvReadyController({required CvPdfDownloadService cvPdfDownloadService})
    : _cvPdfDownloadService = cvPdfDownloadService;

  final CvPdfDownloadService _cvPdfDownloadService;
  final RxBool isDownloading = false.obs;
  final RxBool isPreparingPdf = false.obs;
  final Rxn<Uint8List> pdfBytes = Rxn<Uint8List>();

  CvReadyRouteArguments? _readyArguments;

  CvDocumentModel? get document => _readyArguments?.document;
  CvTemplateModel? get template =>
      _readyArguments?.template ?? _readyArguments?.document.template;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
  }

  @override
  void onReady() {
    super.onReady();
    preparePdfPreview();
  }

  void _readArguments() {
    final Object? rawArguments = Get.arguments;
    if (rawArguments is CvReadyRouteArguments) {
      _readyArguments = rawArguments;
    }
  }

  Future<void> preparePdfPreview() async {
    await _ensurePdfBytes(showErrors: false);
  }

  Future<void> onPreviewTap() async {
    final Uint8List? bytes = await _ensurePdfBytes();
    if (bytes == null) return;
    _openPdfViewer(bytes);
  }

  Future<void> onDownloadPdfTap() async {
    final CvDocumentModel? currentDocument = document;
    final CvTemplateModel? currentTemplate = template;

    if (isDownloading.value) return;
    if (currentDocument == null || currentTemplate == null) {
      Get.snackbar(
        'gen_download_pdf'.tr,
        'cv_data_is_not_available_for_download'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;
    try {
      final Uint8List? bytes = await _ensurePdfBytes();
      if (bytes == null) return;

      final ApiResult<String> result = await ApiErrorHandler.call(
        () => _cvPdfDownloadService.downloadCreatedCv(
          document: currentDocument,
          template: currentTemplate,
          pdfBytes: bytes,
        ),
        errorTitle: 'gen_download_pdf'.tr,
      );

      if (result.isSuccess) {
        _openPdfViewer(bytes);
        Get.snackbar(
          'gen_download_pdf'.tr,
          'cv_pdf_downloaded_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDownloading.value = false;
    }
  }

  void onShareWhatsAppTap() {
    Get.snackbar(
      'share'.tr,
      'whatsapp_sharing_will_be_connected_later'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onFinishTap() {
    // Later navigate to dashboard/wrapper.
    Get.back();
  }

  Future<Uint8List?> _ensurePdfBytes({bool showErrors = true}) async {
    final Uint8List? existingBytes = pdfBytes.value;
    if (existingBytes != null && existingBytes.isNotEmpty) return existingBytes;

    final CvDocumentModel? currentDocument = document;
    final CvTemplateModel? currentTemplate = template;
    if (currentDocument == null || currentTemplate == null) {
      if (showErrors) {
        Get.snackbar(
          'cv_preview'.tr,
          'cv_data_is_not_available_for_preview'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    }

    if (isPreparingPdf.value) {
      for (int index = 0; index < 30; index += 1) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final Uint8List? preparedBytes = pdfBytes.value;
        if (preparedBytes != null && preparedBytes.isNotEmpty)
          return preparedBytes;
        if (!isPreparingPdf.value) break;
      }
      if (pdfBytes.value != null && pdfBytes.value!.isNotEmpty)
        return pdfBytes.value;
      return null;
    }

    isPreparingPdf.value = true;
    try {
      final ApiResult<Uint8List> result = await ApiErrorHandler.call(
        () => _cvPdfDownloadService.buildCreatedCvPdfBytes(
          document: currentDocument,
          template: currentTemplate,
        ),
        showError: showErrors,
        errorTitle: 'cv_preview'.tr,
      );

      if (result.isSuccess && result.data != null) {
        pdfBytes.value = result.data!;
        return result.data!;
      }
      return null;
    } finally {
      isPreparingPdf.value = false;
    }
  }

  void _openPdfViewer(Uint8List bytes) {
    final String title = document?.title ?? 'cv_preview'.tr;
    Get.to<void>(() => CvReadyPdfViewerView(title: title, pdfBytes: bytes));
  }
}
