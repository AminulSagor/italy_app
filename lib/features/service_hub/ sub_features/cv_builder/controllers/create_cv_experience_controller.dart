import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCvExperienceController extends GetxController {
  final TextEditingController jobPositionController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  final RxBool isPresent = true.obs;

  final RxList<String> responsibilities = <String>[
    'Dought Preparation',
    'Oven Handling',
    'Ingredient Prep',
    'Kitchen Hygiene',
  ].obs;

  final RxList<String> hobbies = <String>[
    'Reading',
    'Cooking',
  ].obs;

  final RxList<String> licenses = <String>[
    'Category B',
    'Category A1',
  ].obs;

  void togglePresent(bool? value) {
    isPresent.value = value ?? false;
  }

  void addCustomResponsibility() {
    responsibilities.add('Custom Task');
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
      'Experience',
      'Another experience section will be added later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onContinueTap() {
    // Next step navigation will be added later.
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