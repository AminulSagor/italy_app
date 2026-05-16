import 'package:get/get.dart';

class CvReadyController extends GetxController {
  void onPreviewTap() {
    Get.snackbar(
      'Preview',
      'CV zoom preview will be added later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onDownloadPdfTap() {
    Get.snackbar(
      'Download PDF',
      'PDF download will be connected later.',
      snackPosition: SnackPosition.BOTTOM,
    );
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