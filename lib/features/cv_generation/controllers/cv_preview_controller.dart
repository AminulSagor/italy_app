import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/resume_studio_models.dart';
import '../services/resume_pdf_download_service.dart';
import '../services/resume_studio_api_service.dart';

class CvPreviewController extends GetxController {
  CvPreviewController({
    required ResumeStudioApiService apiService,
    required this.generation,
    required this.documentTitle,
    ResumePdfDownloadService? downloadService,
  }) : _apiService = apiService,
       _downloadService = downloadService ?? ResumePdfDownloadService();

  final ResumeStudioApiService _apiService;
  final ResumePdfDownloadService _downloadService;
  final ResumeGenerationModel generation;
  final String documentTitle;

  final RxBool isPdfLoading = true.obs;
  final RxBool pdfLoadFailed = false.obs;
  final RxBool isDownloading = false.obs;
  final RxInt pdfReloadKey = 0.obs;

  void markPdfLoaded() {
    isPdfLoading.value = false;
    pdfLoadFailed.value = false;
  }

  void markPdfLoadFailed() {
    isPdfLoading.value = false;
    pdfLoadFailed.value = true;
  }

  void retryPdf() {
    pdfLoadFailed.value = false;
    isPdfLoading.value = true;
    pdfReloadKey.value += 1;
  }

  Future<void> downloadPdf() async {
    if (isDownloading.value) return;
    isDownloading.value = true;

    try {
      final bytes = await _apiService.downloadPdf(generation.pdfUrl);
      final String safeName = documentTitle.trim().isEmpty
          ? 'my-cv.pdf'
          : '${documentTitle.trim()}.pdf';

      final String savedPath = await _downloadService.savePdfToDevice(
        pdfBytes: bytes,
        fileName: safeName,
      );

      Get.snackbar(
        'cvb_downloaded'.tr,
        'cvb_saved_to'.trParams(<String, String>{'path': savedPath}),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'cvb_download_failed'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }
}
