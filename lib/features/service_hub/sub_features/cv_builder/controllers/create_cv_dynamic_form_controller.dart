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
  CreateCvDynamicFormController({
    required CvBuilderApiService cvBuilderApiService,
  }) : _cvBuilderApiService = cvBuilderApiService;

  final CvBuilderApiService _cvBuilderApiService;
  final ImagePicker _imagePicker = ImagePicker();

  late final CvTemplateModel template;
  late final String themeColor;

  final RxBool isSaving = false.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxMap<String, bool> photoUploadStates = <String, bool>{}.obs;
  final RxMap<String, String> photoPreviewPaths = <String, String>{}.obs;
  final RxMap<String, String> listStyleSelections = <String, String>{}.obs;
  final Map<String, XFile> pendingPhotoFiles = <String, XFile>{};
  final Map<String, TextEditingController> fieldControllers =
      <String, TextEditingController>{};
  final RxMap<String, List<Map<String, TextEditingController>>>
  dynamicItemControllers =
      <String, List<Map<String, TextEditingController>>>{}.obs;

  List<CvTemplateSectionModel> get sections {
    return template.schema.sections
        .where((CvTemplateSectionModel section) => section.fields.isNotEmpty)
        .toList(growable: false);
  }

  bool get hasFormFields => sections.isNotEmpty;

  CvTemplateSectionModel? get currentSectionOrNull {
    if (sections.isEmpty) return null;

    final int safeIndex = currentStepIndex.value
        .clamp(0, sections.length - 1)
        .toInt();
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
      final CvTemplateController templateController =
          Get.find<CvTemplateController>();
      final CvTemplateModel? selectedTemplate =
          templateController.selectedTemplate.value;
      if (selectedTemplate != null) {
        template = selectedTemplate;
        themeColor = selectedTemplate.primaryColor;
        return;
      }
    }

    throw Exception('cv_template_is_required_to_start_the_form'.tr);
  }

  void _createFieldControllers() {
    for (final CvTemplateSectionModel section in sections) {
      for (final CvTemplateFieldModel field in section.fields) {
        if (isDynamicItemsField(field)) {
          dynamicItemControllers[_controllerKey(
            section.key,
            field.key,
          )] = <Map<String, TextEditingController>>[
            _createDynamicItemControllerMap(field),
          ];
          continue;
        }

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

    goToThemeSelection();
  }

  bool validateCurrentSection() {
    final CvTemplateSectionModel? section = currentSectionOrNull;
    if (section == null) {
      Get.snackbar(
        'cv_template'.tr,
        'no_fields_are_available_for_this_template'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    for (final CvTemplateFieldModel field in section.fields) {
      if (!field.required) continue;

      if (isDynamicItemsField(field)) {
        final bool hasAnyItem = _dynamicItemsFor(section, field).any(
          (Map<String, TextEditingController> item) => item.values.any(
            (TextEditingController controller) =>
                controller.text.trim().isNotEmpty,
          ),
        );
        if (!hasAnyItem) {
          Get.snackbar(
            section.title,
            'field_is_required'.trParams(<String, String>{
              'field': field.label,
            }),
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        continue;
      }

      final String value = controllerFor(section, field).text.trim();
      final bool isListField = _isListFieldType(field.type);
      final bool isEmptyValue = isListField
          ? _normalizeListItems(value).isEmpty
          : value.isEmpty;
      if (isEmptyValue) {
        Get.snackbar(
          section.title,
          'field_is_required'.trParams(<String, String>{'field': field.label}),
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
    final String photoKey = _controllerKey(section.key, field.key);

    final XFile? selectedPhoto = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (selectedPhoto == null) return;

    pendingPhotoFiles[photoKey] = selectedPhoto;
    photoPreviewPaths[photoKey] = selectedPhoto.path;
    controllerFor(section, field).text = selectedPhoto.path;
  }

  bool isDynamicItemsField(CvTemplateFieldModel field) {
    final String type = _normalizeFieldType(field.type);
    return type == 'dynamicitems' ||
        type == 'dynamic_items' ||
        type == 'repeatable' ||
        type == 'repeatableitems';
  }

  List<Map<String, TextEditingController>> dynamicItemsFor(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    final String key = _controllerKey(section.key, field.key);
    return dynamicItemControllers[key] ??
        <Map<String, TextEditingController>>[];
  }

  void addDynamicItem(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    final String key = _controllerKey(section.key, field.key);
    final List<Map<String, TextEditingController>> current =
        List<Map<String, TextEditingController>>.from(
          dynamicItemControllers[key] ?? <Map<String, TextEditingController>>[],
        );
    current.add(_createDynamicItemControllerMap(field));
    dynamicItemControllers[key] = current;
  }

  void removeDynamicItem(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
    int index,
  ) {
    final String key = _controllerKey(section.key, field.key);
    final List<Map<String, TextEditingController>> current =
        List<Map<String, TextEditingController>>.from(
          dynamicItemControllers[key] ?? <Map<String, TextEditingController>>[],
        );
    if (current.length <= 1 || index < 0 || index >= current.length) return;

    final Map<String, TextEditingController> removed = current.removeAt(index);
    for (final TextEditingController controller in removed.values) {
      controller.dispose();
    }
    dynamicItemControllers[key] = current;
  }

  List<Map<String, TextEditingController>> _dynamicItemsFor(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    final String key = _controllerKey(section.key, field.key);
    return dynamicItemControllers[key] ??
        <Map<String, TextEditingController>>[];
  }

  Map<String, TextEditingController> _createDynamicItemControllerMap(
    CvTemplateFieldModel field,
  ) {
    return <String, TextEditingController>{
      for (final CvTemplateDynamicItemFieldModel itemField in field.itemFields)
        itemField.key: TextEditingController(),
    };
  }

  bool isPhotoField(CvTemplateFieldModel field) {
    final String type = _normalizeFieldType(field.type);
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

  String? photoPreviewPath(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    return photoPreviewPaths[_controllerKey(section.key, field.key)];
  }

  String selectedListStyle(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
  ) {
    return listStyleSelections[_controllerKey(section.key, field.key)] ??
        field.listStyle;
  }

  void setListStyle(
    CvTemplateSectionModel section,
    CvTemplateFieldModel field,
    String listStyle,
  ) {
    listStyleSelections[_controllerKey(section.key, field.key)] = listStyle;
  }

  Map<String, XFile> get pendingPhotos =>
      Map<String, XFile>.unmodifiable(pendingPhotoFiles);

  void goToThemeSelection() {
    if (!hasFormFields) return;

    Get.toNamed(
      AppRoutes.createCvTheme,
      arguments: CvThemeRouteArguments(
        template: template,
        documentTitle: _documentTitle(),
        primaryColor: themeColor,
        accentColor: template.accentColor,
        formData: buildFormData(),
        pendingPhotoFiles: pendingPhotos,
      ),
    );
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
            accentColor: template.accentColor,
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
        if (isDynamicItemsField(field)) {
          final List<Map<String, dynamic>> items =
              _dynamicItemsFor(section, field)
                  .map((Map<String, TextEditingController> itemControllers) {
                    final Map<String, dynamic> itemData = <String, dynamic>{};
                    for (final CvTemplateDynamicItemFieldModel itemField
                        in field.itemFields) {
                      final String value =
                          itemControllers[itemField.key]?.text.trim() ?? '';
                      if (value.isNotEmpty) itemData[itemField.key] = value;
                    }
                    return itemData;
                  })
                  .where((Map<String, dynamic> item) => item.isNotEmpty)
                  .toList();

          if (items.isNotEmpty) sectionData[field.key] = items;
          continue;
        }

        final String fieldKey = _controllerKey(section.key, field.key);
        final String value = controllerFor(section, field).text.trim();
        if (isPhotoField(field) && pendingPhotoFiles.containsKey(fieldKey)) {
          continue;
        }
        if (value.isEmpty) continue;

        if (_isListFieldType(field.type)) {
          final List<String> items = _normalizeListItems(value);
          if (items.isEmpty) continue;

          sectionData[field.key] = <String, dynamic>{
            'items': items,
            'listStyle': selectedListStyle(section, field),
          };
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

  List<String> _normalizeListItems(String value) {
    return value
        .split('\n')
        .map(_removeListMarker)
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _removeListMarker(String value) {
    return value
        .trimLeft()
        .replaceFirst(RegExp(r'^(?:[•\-*]\s*|\d+[\.)]\s*)'), '')
        .trimRight();
  }

  bool _isListFieldType(String value) {
    final String normalizedType = _normalizeFieldType(
      value,
    ).replaceAll('_', '');
    return normalizedType == 'list' ||
        normalizedType == 'bulletlist' ||
        normalizedType == 'numberlist' ||
        normalizedType == 'orderedlist' ||
        normalizedType == 'unorderedlist';
  }

  String _normalizeFieldType(String value) {
    return value.trim().toLowerCase().replaceAll('-', '_');
  }

  String _documentTitle() {
    for (final CvTemplateSectionModel section in sections) {
      for (final CvTemplateFieldModel field in section.fields) {
        final String normalizedKey = field.key.toLowerCase();
        if ((normalizedKey == 'fullname' || normalizedKey == 'name') &&
            !isDynamicItemsField(field)) {
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

  @override
  void onClose() {
    for (final TextEditingController controller in fieldControllers.values) {
      controller.dispose();
    }
    for (final List<Map<String, TextEditingController>> itemList
        in dynamicItemControllers.values) {
      for (final Map<String, TextEditingController> item in itemList) {
        for (final TextEditingController controller in item.values) {
          controller.dispose();
        }
      }
    }
    super.onClose();
  }
}
