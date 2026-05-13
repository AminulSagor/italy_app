import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCvEducationController extends GetxController {
  final RxString selectedEducationType = ''.obs;
  final RxString selectedLevel = ''.obs;

  final TextEditingController schoolController = TextEditingController();
  final TextEditingController nativeLanguageController = TextEditingController();
  final TextEditingController otherLanguageController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  final RxList<String> nativeLanguages = <String>['Bengali (Native)'].obs;
  final RxList<String> otherLanguages = <String>['English (B2)'].obs;

  final RxList<String> skills = <String>[
    'Project Management',
    'Italian (C1)',
    'Problem Solving',
  ].obs;

  final List<String> educationTypes = <String>[
    'High School',
    'Diploma',
    'Bachelor',
    'Master',
    'Other',
  ];

  final List<String> educationLevels = <String>[
    'Basic',
    'Intermediate',
    'Advanced',
    'Professional',
  ];

  final List<String> aiSuggestedSkills = <String>[
    'MS Excel',
    'CNC Programming',
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
    // Navigate to summary later.
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