import 'package:get/get.dart';

class CreateCvSummaryController extends GetxController {
  final RxBool hasGeneratedSummary = false.obs;
  final RxBool isGenerating = false.obs;

  final String generatedSummary =
      'Experienced waiter with over 2 years of experience in the Italian hospitality industry. Specialized in providing excellent customer service, managing reservations, and possessing in depth knowledge of local cuisine. Results oriented and capable of working efficiently in fast paced environments.';

  Future<void> generateSummary() async {
    isGenerating.value = true;

    await Future<void>.delayed(const Duration(milliseconds: 600));

    hasGeneratedSummary.value = true;
    isGenerating.value = false;
  }

  void regenerateSummary() {
    generateSummary();
  }

  void editText() {
    Get.snackbar(
      'Edit Text',
      'Manual editing will be added later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onSaveContinueTap() {
    Get.snackbar(
      'Saved',
      'Professional summary saved.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}