import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_builder_api_service.dart';

class CreateCvThemeController extends GetxController {
  CreateCvThemeController({required CvBuilderApiService cvBuilderApiService})
      : _cvBuilderApiService = cvBuilderApiService;

  final CvBuilderApiService _cvBuilderApiService;

  late final CvTemplateModel template;
  late final String documentTitle;
  late final Map<String, dynamic> formData;
  late final Map<String, XFile> pendingPhotoFiles;

  final RxBool isSaving = false.obs;
  final RxString selectedPrimaryColor = '#006B3F'.obs;
  final RxString selectedAccentColor = '#E6F6F0'.obs;

  List<String> get colorOptions {
    final List<String> options = <String>[
      template.primaryColor,
      template.accentColor,
      ...template.schema.colorOptions,
      '#006B3F',
      '#183847',
      '#F3F4F6',
      '#0B4A7D',
      '#7B4A2F',
      '#111827',
    ];

    final Set<String> seen = <String>{};
    return options
        .map(_normalizeHex)
        .where((String item) => item.isNotEmpty)
        .where((String item) => seen.add(item.toUpperCase()))
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
  }

  void _readArguments() {
    final Object? rawArguments = Get.arguments;
    if (rawArguments is! CvThemeRouteArguments) {
      throw Exception('CV theme data is required.');
    }

    template = rawArguments.template;
    documentTitle = rawArguments.documentTitle;
    formData = rawArguments.formData;
    pendingPhotoFiles = rawArguments.pendingPhotoFiles;
    selectedPrimaryColor.value = _normalizeHex(rawArguments.primaryColor).isEmpty
        ? _normalizeHex(template.primaryColor)
        : _normalizeHex(rawArguments.primaryColor);
    selectedAccentColor.value = _normalizeHex(rawArguments.accentColor).isEmpty
        ? _normalizeHex(template.accentColor)
        : _normalizeHex(rawArguments.accentColor);
  }

  Color colorFromHex(String value) {
    final String normalizedHex = _normalizeHex(value).replaceAll('#', '');
    if (normalizedHex.length != 6) return const Color(0xFF006B3F);
    final int? parsed = int.tryParse(normalizedHex, radix: 16);
    return Color(0xFF000000 | (parsed ?? 0x006B3F));
  }


  String hexFromColor(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void selectPrimaryColor(String value) {
    selectedPrimaryColor.value = _normalizeHex(value);
  }

  void selectAccentColor(String value) {
    selectedAccentColor.value = _normalizeHex(value);
  }

  Future<void> saveCvDocument() async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final Map<String, dynamic> nextFormData =
          await _formDataWithUploadedPhotos();
      final ApiResult<CvDocumentModel> result = await ApiErrorHandler.call(
        () => _cvBuilderApiService.saveCvDocument(
          CvDocumentPayloadModel(
            templateId: template.id,
            title: documentTitle,
            themeColor: selectedPrimaryColor.value,
            accentColor: selectedAccentColor.value,
            formData: nextFormData,
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

  Future<Map<String, dynamic>> _formDataWithUploadedPhotos() async {
    final Map<String, dynamic> nextFormData = <String, dynamic>{
      for (final MapEntry<String, dynamic> entry in formData.entries)
        entry.key: entry.value is Map
            ? Map<String, dynamic>.from(entry.value as Map)
            : entry.value,
    };

    for (final MapEntry<String, XFile> entry in pendingPhotoFiles.entries) {
      final List<String> parts = entry.key.split('.');
      if (parts.length != 2) continue;

      final String sectionKey = parts.first;
      final String fieldKey = parts.last;
      final String uploadedUrl = await _cvBuilderApiService.uploadCvPhoto(
        entry.value,
      );

      final Map<String, dynamic> sectionData =
          nextFormData[sectionKey] is Map
              ? Map<String, dynamic>.from(nextFormData[sectionKey] as Map)
              : <String, dynamic>{};
      sectionData[fieldKey] = uploadedUrl;
      nextFormData[sectionKey] = sectionData;
    }

    return nextFormData;
  }

  String _normalizeHex(String value) {
    final String normalizedValue = value.trim();
    if (normalizedValue.isEmpty) return '';
    final String hex = normalizedValue.startsWith('#')
        ? normalizedValue
        : '#$normalizedValue';
    if (hex.length != 7) return '';
    return hex.toUpperCase();
  }
}
