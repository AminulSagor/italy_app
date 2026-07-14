import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/course_certificate_models.dart';
import '../services/course_certificate_api_service.dart';

class CourseCertificateController extends GetxController {
  final String attemptId;
  final CourseCertificateApiService _certificateApiService;

  CourseCertificateController({
    required this.attemptId,
    required CourseCertificateApiService certificateApiService,
  }) : _certificateApiService = certificateApiService;

  final RxBool isLoading = false.obs;
  final RxBool isDownloading = false.obs;
  final RxBool pdfLoadFailed = false.obs;

  final Rxn<CourseCertificateModel> certificate =
  Rxn<CourseCertificateModel>();

  final RxString certificatePdfUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCertificate();
  }

  Future<void> loadCertificate() async {
    await _loadCertificate(force: false);
  }

  Future<void> retryCertificate() async {
    await _loadCertificate(force: true);
  }

  Future<void> _loadCertificate({
    required bool force,
  }) async {
    if (isLoading.value) {
      return;
    }

    if (!force &&
        certificate.value != null &&
        certificatePdfUrl.value.isNotEmpty) {
      return;
    }

    final String resolvedAttemptId = attemptId.trim();

    if (resolvedAttemptId.isEmpty) {
      Get.snackbar(
        'certificate_unavailable'.tr,
        'final_exam_attempt_not_found'.tr,
      );
      return;
    }

    isLoading.value = true;
    pdfLoadFailed.value = false;

    if (force) {
      certificatePdfUrl.value = '';
    }

    try {
      final ApiResult<CourseCertificateModel> certificateResult =
      await ApiErrorHandler.call<CourseCertificateModel>(
            () => _certificateApiService.fetchCertificateByAttemptId(
          attemptId: resolvedAttemptId,
        ),
        errorTitle: 'official_certificate'.tr,
      );

      final CourseCertificateModel? data =
          certificateResult.data;

      if (!certificateResult.isSuccess || data == null) {
        return;
      }

      certificate.value = data;

      if (!data.isIssued || data.id.trim().isEmpty) {
        Get.snackbar(
          'certificate_unavailable'.tr,
          'certificate_not_active'.tr,
        );
        return;
      }

      final String? signedPdfUrl =
      await _fetchFreshPdfUrl(data);

      if (signedPdfUrl == null) {
        return;
      }

      certificatePdfUrl.value = signedPdfUrl;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _fetchFreshPdfUrl(
      CourseCertificateModel data,
      ) async {
    final ApiResult<String> result =
    await ApiErrorHandler.call<String>(
          () => _certificateApiService.fetchDownloadUrl(
        certificateId: data.id,
      ),
      errorTitle: 'official_certificate'.tr,
    );

    if (!result.isSuccess) {
      return null;
    }

    final String url = result.data?.trim() ?? '';

    final Uri? uri = Uri.tryParse(url);

    if (url.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      Get.snackbar(
        'certificate_download'.tr,
        'invalid_certificate_download_url'.tr,
      );
      return null;
    }

    return url;
  }

  void markPdfLoaded() {
    pdfLoadFailed.value = false;
  }

  void markPdfLoadFailed() {
    pdfLoadFailed.value = true;
  }

  Future<void> downloadCertificate() async {
    if (isDownloading.value) {
      return;
    }

    final CourseCertificateModel? data = certificate.value;

    if (data == null || data.id.trim().isEmpty) {
      Get.snackbar(
        'certificate_download'.tr,
        'certificate_information_unavailable'.tr,
      );
      return;
    }

    if (!data.isIssued) {
      Get.snackbar(
        'certificate_download'.tr,
        'certificate_not_active'.tr,
      );
      return;
    }

    isDownloading.value = true;

    try {
      // Request a new signed URL because the previous one may have expired.
      final String? downloadUrl =
      await _fetchFreshPdfUrl(data);

      if (downloadUrl == null) {
        return;
      }

      final bool opened = await launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        Get.snackbar(
          'certificate_download'.tr,
          'unable_to_open_certificate_pdf'.tr,
        );
      }
    } catch (_) {
      Get.snackbar(
        'certificate_download'.tr,
        'unable_to_open_certificate_pdf'.tr,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  void closeCertificate() {
    Get.back<void>();
  }
}