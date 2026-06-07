import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';

class CreateCvContactController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final RxDouble progress = 0.33.obs;

  void onContinueTap() {
    Get.toNamed(AppRoutes.createCvExperience);
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