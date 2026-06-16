import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_builder_api_service.dart';
import 'cv_template_controller.dart';

class CreateCvDynamicFormController extends GetxController {
  CreateCvDynamicFormController({
    required CvBuilderApiService cvBuilderApiService,
  }) : _cvBuilderApiService = cvBuilderApiService;

  final CvBuilderApiService _cvBuilderApiService;

  late final CvTemplateModel template;
  late final String themeColor;

  final RxBool isSaving = false.obs;
  final RxInt currentStepIndex = 0.obs;
  final Map<String, TextEditingController> fieldControllers =
      <String, TextEditingController>{};

  List<CvTemplateSectionModel> get sections {
    final List<CvTemplateSectionModel> templateSections = template
        .schema
        .sections
        .where((CvTemplateSectionModel section) => section.fields.isNotEmpty)
        .toList();

    if (templateSections.isNotEmpty) return templateSections;

    return <CvTemplateSectionModel>[
      const CvTemplateSectionModel(
        key: 'personalDetails',
        title: 'Personal Details',
        required: false,
        designerJson: <String, dynamic>{},
        fields: <CvTemplateFieldModel>[
          CvTemplateFieldModel(
            key: 'fullName',
            label: 'Full Name',
            type: 'text',
            required: false,
            placeholder: 'Enter your full name',
          ),
          CvTemplateFieldModel(
            key: 'email',
            label: 'Email',
            type: 'email',
            required: false,
            placeholder: 'Enter your email',
          ),
        ],
      ),
    ];
  }

  CvTemplateSectionModel get currentSection => sections[currentStepIndex.value];

  bool get isFirstStep => currentStepIndex.value == 0;

  bool get isLastStep => currentStepIndex.value >= sections.length - 1;

  double get progress => (currentStepIndex.value + 1) / sections.length;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _createFieldControllers();
  }

  void _readArguments() {
    final Object? rawArguments = Get.arguments;

    if (rawArguments is CvTemplateFormRouteArguments) {
      template = rawArguments.template;
      themeColor = rawArguments.themeColor;
      return;
    }

    if (Get.isRegistered<CvTemplateController>()) {
      final CvTemplateController templateController =
          Get.find<CvTemplateController>();
      final CvTemplateModel? selectedTemplate =
          templateController.selectedTemplate.value;
      if (selectedTemplate != null) {
        template = selectedTemplate;
        themeColor = _colorToHex(templateController.selectedColor);
        return;
      }
    }

    throw Exception('CV template is required to start the form.');
  }

  void _createFieldControllers() {
    for (final CvTemplateSectionModel section in sections) {
      for (final CvTemplateFieldModel field in section.fields) {
        fieldControllers[_controllerKey(section.key, field.key)] =
            TextEditingController();
      }
    }
  }

  TextEditingController controllerFor(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    return fieldControllers[_controllerKey(section.key, field.key)]!;
  }

  void goBackStep() {
    if (isFirstStep) {
      Get.back();
      return;
    }

    currentStepIndex.value -= 1;
  }

  Future<void> goNextStep() async {
    if (!validateCurrentSection()) return;

    if (!isLastStep) {
      currentStepIndex.value += 1;
      return;
    }

    await saveCvDocument();
  }

  bool validateCurrentSection() {
    for (final CvTemplateFieldModel field in currentSection.fields) {
      if (!field.required) continue;

      final String value = controllerFor(currentSection, field).text.trim();
      if (value.isEmpty) {
        Get.snackbar(
          currentSection.title,
          '${field.label} is required.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> saveCvDocument() async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final ApiResult<void> result = await ApiErrorHandler.call(
        () => _cvBuilderApiService.saveCvDocument(
          CvDocumentPayloadModel(
            templateId: template.id,
            title: _documentTitle(),
            themeColor: themeColor,
            formData: buildFormData(),
          ),
        ),
      );

      if (result.isSuccess) {
        Get.offNamed(AppRoutes.cvReady);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> buildFormData() {
    final Map<String, dynamic> formData = <String, dynamic>{};

    for (final CvTemplateSectionModel section in sections) {
      final Map<String, dynamic> sectionData = <String, dynamic>{};

      for (final CvTemplateFieldModel field in section.fields) {
        final String value = controllerFor(section, field).text.trim();
        if (value.isEmpty) continue;

        if (field.type == 'list') {
          sectionData[field.key] = value
              .split('\n')
              .map((String item) => item.trim())
              .where((String item) => item.isNotEmpty)
              .toList();
        } else {
          sectionData[field.key] = value;
        }
      }

      if (sectionData.isNotEmpty) {
        formData[section.key] = sectionData;
      }
    }

    return formData;
  }

  String _documentTitle() {
    for (final CvTemplateSectionModel section in sections) {
      for (final CvTemplateFieldModel field in section.fields) {
        final String normalizedKey = field.key.toLowerCase();
        if (normalizedKey == 'fullname' || normalizedKey == 'name') {
          final String fullName = controllerFor(section, field).text.trim();
          if (fullName.isNotEmpty) return '$fullName CV';
        }
      }
    }

    return '${template.title} CV';
  }

  String _controllerKey(String sectionKey, String fieldKey) {
    return '$sectionKey.$fieldKey';
  }

  String _colorToHex(Color color) {
    final int value = color.toARGB32();
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  void onClose() {
    for (final TextEditingController controller in fieldControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
