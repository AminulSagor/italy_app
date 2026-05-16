import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCvContactController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final RxDouble progress = 0.33.obs;

  void onContinueTap() {
    // Next step navigation will be added later.
  }

  void onUploadPhotoTap() {
    Get.snackbar(
      'Upload Photo',
      'Photo upload will be connected later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.onClose();
  }
}