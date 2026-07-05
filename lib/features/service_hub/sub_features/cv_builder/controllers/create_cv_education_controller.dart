import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';

class CreateCvEducationController extends GetxController {
  final RxString selectedEducationType = ''.obs;
  final RxString selectedLevel = ''.obs;

  final TextEditingController schoolController = TextEditingController();
  final TextEditingController nativeLanguageController =
      TextEditingController();
  final TextEditingController otherLanguageController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  final RxList<String> nativeLanguages = <String>[
    'language_bengali_native'.tr,
  ].obs;
  final RxList<String> otherLanguages = <String>['language_english_b2'.tr].obs;

  final RxList<String> skills = <String>[
    'skill_project_management'.tr,
    'skill_italian_c1'.tr,
    'skill_problem_solving'.tr,
  ].obs;

  final List<String> educationTypes = <String>[
    'education_high_school'.tr,
    'education_diploma'.tr,
    'education_bachelor'.tr,
    'education_master'.tr,
    'education_other'.tr,
  ];

  final List<String> educationLevels = <String>[
    'level_basic'.tr,
    'level_intermediate'.tr,
    'level_advanced'.tr,
    'level_professional'.tr,
  ];

  final List<String> aiSuggestedSkills = <String>[
    'skill_ms_excel'.tr,
    'skill_cnc_programming'.tr,
  ];

  void selectEducationType(String? value) {
    selectedEducationType.value = value ?? '';
  }

  void selectLevel(String? value) {
    selectedLevel.value = value ?? '';
  }

  void addNativeLanguage() {
    final String value = nativeLanguageController.text.trim();
    if (value.isEmpty) return;

    nativeLanguages.add(value);
    nativeLanguageController.clear();
  }

  void addOtherLanguage() {
    final String value = otherLanguageController.text.trim();
    if (value.isEmpty) return;

    otherLanguages.add(value);
    otherLanguageController.clear();
  }

  void removeNativeLanguage(String value) {
    nativeLanguages.remove(value);
  }

  void removeOtherLanguage(String value) {
    otherLanguages.remove(value);
  }

  void addSkill() {
    final String value = skillController.text.trim();
    if (value.isEmpty) return;

    skills.add(value);
    skillController.clear();
  }

  void addSuggestedSkill(String value) {
    if (skills.contains(value)) return;
    skills.add(value);
  }

  void removeSkill(String value) {
    skills.remove(value);
  }

  void onContinueTap() {
    Get.toNamed(AppRoutes.createCvSummary);
  }

  @override
  void onClose() {
    schoolController.dispose();
    nativeLanguageController.dispose();
    otherLanguageController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
