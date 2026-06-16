import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/cv_builder_models.dart';
import '../services/cv_builder_api_service.dart';

class CvTemplateController extends GetxController {
  CvTemplateController({required CvBuilderApiService cvBuilderApiService})
      : _cvBuilderApiService = cvBuilderApiService;

  final CvBuilderApiService _cvBuilderApiService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt selectedTemplateIndex = 0.obs;
  final RxInt selectedColorIndex = 0.obs;
  final RxList<CvTemplateModel> templates = <CvTemplateModel>[].obs;
  final Rxn<CvTemplateModel> selectedTemplate = Rxn<CvTemplateModel>();

  final List<String> categories = <String>[
    'All',
    'ATS',
    'Modern',
    'Classic',
  ];

  final List<Color> colors = <Color>[
    AppColors.primaryGreen,
    AppColors.legacyColorFF646C7A,
    AppColors.legacyColorFF0B4A7D,
    AppColors.adminBrown,
  ];

  Color get selectedColor => colors[selectedColorIndex.value];

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<CvTemplateListResponseModel> result =
          await ApiErrorHandler.call(
        () => _cvBuilderApiService.getTemplates(),
      );
      if (result.isSuccess && result.data != null) {
        templates.assignAll(result.data!.templates);
        if (templates.isNotEmpty) {
          selectedTemplateIndex.value = 0;
          selectedTemplate.value = templates.first;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  void selectTemplate(int index) {
    if (index < 0 || index >= templates.length) return;
    selectedTemplateIndex.value = index;
    selectedTemplate.value = templates[index];
  }

  void startWithTemplate(int index) {
    selectTemplate(index);
    useSelectedTemplate();
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  void useSelectedTemplate() {
    final CvTemplateModel? template = selectedTemplate.value;
    if (template == null) {
      Get.snackbar('Template', 'Please select a CV template first.');
      return;
    }

    Get.toNamed(
      AppRoutes.createCvDynamicForm,
      arguments: CvTemplateFormRouteArguments(
        template: template,
        themeColor: template.primaryColor,
      ),
    );
  }

  String _colorToHex(Color color) {
    final int value = color.value;
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
