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
      'upload_photo'.tr,
      'photo_upload_will_be_connected_later'.tr,
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
