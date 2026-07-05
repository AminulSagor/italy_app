import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';

class CreateCvExperienceController extends GetxController {
  final TextEditingController jobPositionController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  final RxBool isPresent = true.obs;

  final RxList<String> responsibilities = <String>[
    'gen_dough_preparation'.tr,
    'gen_oven_handling'.tr,
    'gen_ingredient_prep'.tr,
    'gen_kitchen_hygiene'.tr,
  ].obs;

  final RxList<String> hobbies = <String>['reading'.tr, 'cooking'.tr].obs;

  final RxList<String> licenses = <String>[
    'gen_e_g_category_b_c'.tr,
    'category_a1'.tr,
  ].obs;

  void togglePresent(bool? value) {
    isPresent.value = value ?? false;
  }

  void addCustomResponsibility() {
    responsibilities.add('gen_add_custom_responsibility'.tr);
  }

  void addHobby() {
    final String value = hobbyController.text.trim();
    if (value.isEmpty) return;

    hobbies.add(value);
    hobbyController.clear();
  }

  void addLicense() {
    final String value = licenseController.text.trim();
    if (value.isEmpty) return;

    licenses.add(value);
    licenseController.clear();
  }

  void removeHobby(String value) {
    hobbies.remove(value);
  }

  void removeLicense(String value) {
    licenses.remove(value);
  }

  void onAddAnotherExperienceTap() {
    Get.snackbar(
      'Experience'.tr,
      'another_experience_section_will_be_added_later'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onContinueTap() {
    Get.toNamed(AppRoutes.createCvEducation);
  }

  @override
  void onClose() {
    jobPositionController.dispose();
    companyNameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    hobbyController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}
