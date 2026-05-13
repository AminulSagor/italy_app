import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../models/course_certificate_models.dart';
import '../services/course_certificate_mock_service.dart';
import '../widgets/course_certificate_share_dialog.dart';

class CourseCertificateController extends GetxController {
  final CourseCertificateMockService _certificateMockService;

  CourseCertificateController({
    required CourseCertificateMockService certificateMockService,
  }) : _certificateMockService = certificateMockService;

  final RxBool isLoading = false.obs;
  final Rxn<CourseCertificateModel> certificate = Rxn<CourseCertificateModel>();

  @override
  void onInit() {
    super.onInit();
    loadCertificate();
  }

  Future<void> loadCertificate() async {
    if (isLoading.value || certificate.value != null) {
      return;
    }

    isLoading.value = true;
    try {
      certificate.value = await _certificateMockService.fetchCertificate();
    } finally {
      isLoading.value = false;
    }
  }

  void showShareDialog() {
    final CourseCertificateModel? data = certificate.value;
    if (data == null) {
      return;
    }

    Get.dialog<void>(
      CourseCertificateShareDialog(certificate: data),
      barrierColor: AppColors.black.withValues(alpha: 0.42),
      useSafeArea: false,
    );
  }

  void closeCertificate() {
    Get.back<void>();
  }

  void startLevelA2() {
    Get.offAllNamed(AppRoutes.wrapper);
  }
}
