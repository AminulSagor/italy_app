import 'package:get/get.dart';

import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/cv_builder_models.dart';
import 'create_cv_contact_controller.dart';
import 'create_cv_education_controller.dart';
import 'create_cv_experience_controller.dart';
import 'cv_template_controller.dart';

class CreateCvSummaryController extends GetxController {
  final RxBool hasGeneratedSummary = false.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isSaving = false.obs;

  final String generatedSummary =
      'Experienced worker with strong communication, teamwork, and customer service skills. Able to work efficiently in fast paced environments and adapt quickly to new responsibilities.';

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

  Future<void> onSaveContinueTap() async {
    if (isSaving.value) return;

    final CvTemplateController templateController =
        Get.find<CvTemplateController>();
    final CvTemplateModel? template = templateController.selectedTemplate.value;
    if (template == null) {
      Get.snackbar('Template', 'Please select a CV template first.');
      return;
    }

    isSaving.value = true;
    try {
      Get.toNamed(
        AppRoutes.createCvTheme,
        arguments: CvThemeRouteArguments(
          template: template,
          documentTitle: _documentTitle(template.title),
          primaryColor: _colorToHex(templateController.selectedColor),
          accentColor: template.accentColor,
          formData: _buildFormData(),
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _documentTitle(String templateTitle) {
    if (Get.isRegistered<CreateCvContactController>()) {
      final String fullName = Get.find<CreateCvContactController>()
          .fullNameController
          .text
          .trim();
      if (fullName.isNotEmpty) return '$fullName CV';
    }
    return templateTitle;
  }

  Map<String, dynamic> _buildFormData() {
    final Map<String, dynamic> data = <String, dynamic>{
      'summary': generatedSummary,
    };

    if (Get.isRegistered<CreateCvContactController>()) {
      final CreateCvContactController contact =
          Get.find<CreateCvContactController>();
      data['contact'] = <String, dynamic>{
        'fullName': contact.fullNameController.text.trim(),
        'email': contact.emailController.text.trim(),
        'phone': contact.phoneController.text.trim(),
        'city': contact.cityController.text.trim(),
      };
    }

    if (Get.isRegistered<CreateCvExperienceController>()) {
      final CreateCvExperienceController experience =
          Get.find<CreateCvExperienceController>();
      data['experience'] = <String, dynamic>{
        'jobPosition': experience.jobPositionController.text.trim(),
        'companyName': experience.companyNameController.text.trim(),
        'startDate': experience.startDateController.text.trim(),
        'endDate': experience.endDateController.text.trim(),
        'isPresent': experience.isPresent.value,
        'responsibilities': experience.responsibilities.toList(),
        'hobbies': experience.hobbies.toList(),
        'licenses': experience.licenses.toList(),
      };
    }

    if (Get.isRegistered<CreateCvEducationController>()) {
      final CreateCvEducationController education =
          Get.find<CreateCvEducationController>();
      data['education'] = <String, dynamic>{
        'educationType': education.selectedEducationType.value,
        'level': education.selectedLevel.value,
        'school': education.schoolController.text.trim(),
        'nativeLanguages': education.nativeLanguages.toList(),
        'otherLanguages': education.otherLanguages.toList(),
        'skills': education.skills.toList(),
      };
    }

    return data;
  }

  String _colorToHex(dynamic color) {
    final int value = color.value as int;
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
