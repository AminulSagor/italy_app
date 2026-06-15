import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_builder_api_service.dart';
import 'cv_template_controller.dart';

class CreateCvDynamicFormController extends GetxController {
  CreateCvDynamicFormController({required CvBuilderApiService cvBuilderApiService})
      : _cvBuilderApiService = cvBuilderApiService;

  final CvBuilderApiService _cvBuilderApiService;
  final ImagePicker _imagePicker = ImagePicker();

  late final CvTemplateModel template;
  late final String themeColor;

  final RxBool isSaving = false.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxMap<String, bool> photoUploadStates = <String, bool>{}.obs;
  final Map<String, TextEditingController> fieldControllers =
      <String, TextEditingController>{};

  List<CvTemplateSectionModel> get sections {
    return template.schema.sections
        .where((CvTemplateSectionModel section) => section.fields.isNotEmpty)
        .toList(growable: false);
  }

  bool get hasFormFields => sections.isNotEmpty;

  CvTemplateSectionModel? get currentSectionOrNull {
    if (sections.isEmpty) return null;

    final int safeIndex = currentStepIndex.value.clamp(0, sections.length - 1).toInt();
    return sections[safeIndex];
  }

  CvTemplateSectionModel get currentSection => currentSectionOrNull!;

  bool get isFirstStep => currentStepIndex.value == 0;

  bool get isLastStep =>
      sections.isEmpty || currentStepIndex.value >= sections.length - 1;

  double get progress {
    if (sections.isEmpty) return 0;
    return (currentStepIndex.value + 1) / sections.length;
  }

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
      final CvTemplateController templateController = Get.find<CvTemplateController>();
      final CvTemplateModel? selectedTemplate = templateController.selectedTemplate.value;
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
    final CvTemplateSectionModel? section = currentSectionOrNull;
    if (section == null) {
      Get.snackbar(
        'CV Template',
        'No fields are available for this template.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    for (final CvTemplateFieldModel field in section.fields) {
      if (!field.required) continue;

      final String value = controllerFor(section, field).text.trim();
      if (value.isEmpty) {
        Get.snackbar(
          section.title,
          '${field.label} is required.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> pickAndUploadPhoto(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) async {
    final String uploadKey = _controllerKey(section.key, field.key);
    if (photoUploadStates[uploadKey] == true) return;

    final XFile? selectedPhoto = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (selectedPhoto == null) return;

    photoUploadStates[uploadKey] = true;
    try {
      final ApiResult<String> result = await ApiErrorHandler.call(
        () => _cvBuilderApiService.uploadCvPhoto(selectedPhoto),
        errorTitle: 'Photo Upload',
      );

      if (result.isSuccess && result.data != null) {
        controllerFor(section, field).text = result.data!;
        Get.snackbar(
          'Photo Upload',
          'Photo uploaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      photoUploadStates[uploadKey] = false;
    }
  }

  bool isPhotoField(CvTemplateFieldModel field) {
    final String type = field.type.trim().toLowerCase();
    return type == 'photourl' ||
        type == 'photo_url' ||
        type == 'imageurl' ||
        type == 'photo';
  }

  bool isPhotoUploading(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    return photoUploadStates[_controllerKey(section.key, field.key)] == true;
  }

  Future<void> saveCvDocument() async {
    if (isSaving.value || !hasFormFields) return;

    isSaving.value = true;
    try {
      final ApiResult<CvDocumentModel> result = await ApiErrorHandler.call(
        () => _cvBuilderApiService.saveCvDocument(
          CvDocumentPayloadModel(
            templateId: template.id,
            title: _documentTitle(),
            themeColor: themeColor,
            formData: buildFormData(),
          ),
        ),
      );

      if (result.isSuccess && result.data != null) {
        Get.offNamed(
          AppRoutes.cvReady,
          arguments: CvReadyRouteArguments(
            document: result.data!,
            template: result.data!.template ?? template,
          ),
        );
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

        if (field.type.toLowerCase() == 'list') {
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
    final int value = color.value;
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
