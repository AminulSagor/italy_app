import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_pdf_download_service.dart';

class CvReadyController extends GetxController {
  CvReadyController({required CvPdfDownloadService cvPdfDownloadService})
      : _cvPdfDownloadService = cvPdfDownloadService;

  final CvPdfDownloadService _cvPdfDownloadService;
  final RxBool isDownloading = false.obs;

  CvReadyRouteArguments? _readyArguments;

  CvDocumentModel? get document => _readyArguments?.document;
  CvTemplateModel? get template => _readyArguments?.template;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
  }

  void _readArguments() {
    final Object? rawArguments = Get.arguments;
    if (rawArguments is CvReadyRouteArguments) {
      _readyArguments = rawArguments;
    }
  }

  void onPreviewTap() {
    Get.snackbar(
      'Preview',
      'CV zoom preview will be added later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> onDownloadPdfTap() async {
    final CvDocumentModel? currentDocument = document;
    final CvTemplateModel? currentTemplate = template;

    if (isDownloading.value) return;
    if (currentDocument == null || currentTemplate == null) {
      Get.snackbar(
        'Download PDF',
        'CV data is not available for download.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;
    try {
      final ApiResult<String> result = await ApiErrorHandler.call(
        () => _cvPdfDownloadService.downloadCreatedCv(
          document: currentDocument,
          template: currentTemplate,
        ),
        errorTitle: 'Download PDF',
      );

      if (result.isSuccess) {
        Get.snackbar(
          'Download PDF',
          'CV PDF downloaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDownloading.value = false;
    }
  }

  void onShareWhatsAppTap() {
    Get.snackbar(
      'Share',
      'WhatsApp sharing will be connected later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onFinishTap() {
    // Later navigate to dashboard/wrapper.
    Get.back();
  }
}
