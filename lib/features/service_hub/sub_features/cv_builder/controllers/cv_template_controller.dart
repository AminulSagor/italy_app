import 'dart:async';

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
  final RxBool isLoadingMore = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt selectedTemplateIndex = (-1).obs;
  final RxInt selectedColorIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxList<CvTemplateModel> templates = <CvTemplateModel>[].obs;
  final Rxn<CvTemplateModel> selectedTemplate = Rxn<CvTemplateModel>();

  final List<String> categories = <String>[
    'All',
    'Classic',
    'Modern Column',
  ];

  final List<Color> colors = <Color>[
    AppColors.primaryGreen,
    AppColors.legacyColorFF646C7A,
    AppColors.legacyColorFF0B4A7D,
    AppColors.adminBrown,
  ];

  Color get selectedColor => colors[selectedColorIndex.value];

  static const int _pageLimit = 10;
  int _currentPage = 1;
  int _totalPages = 1;
  Worker? _searchDebounce;

  bool get hasMoreTemplates => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    _searchDebounce = debounce<String>(
      searchQuery,
      (_) => loadTemplates(refresh: true),
      time: const Duration(milliseconds: 350),
    );
    loadTemplates(refresh: true);
  }

  Future<void> loadTemplates({bool refresh = true}) async {
    if (refresh) {
      if (isLoading.value) return;
      isLoading.value = true;
      _currentPage = 1;
    } else {
      if (isLoadingMore.value || !hasMoreTemplates) return;
      isLoadingMore.value = true;
      _currentPage += 1;
    }

    try {
      final ApiResult<CvTemplateListResponseModel> result =
          await ApiErrorHandler.call(
        () => _cvBuilderApiService.getTemplates(
          page: _currentPage,
          limit: _pageLimit,
          styleType: _selectedStyleTypeQuery(),
          search: searchQuery.value,
        ),
      );

      if (result.isSuccess && result.data != null) {
        final CvTemplateListResponseModel data = result.data!;
        _totalPages = data.pagination.totalPages <= 0
            ? 1
            : data.pagination.totalPages;

        if (refresh) {
          templates.assignAll(data.templates);
          selectedTemplateIndex.value = -1;
          selectedTemplate.value = null;
        } else {
          templates.addAll(data.templates);
        }
      }
    } finally {
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> refreshTemplates() => loadTemplates(refresh: true);

  Future<void> loadMoreTemplates() => loadTemplates(refresh: false);

  void selectCategory(int index) {
    if (index < 0 || index >= categories.length) return;
    if (selectedCategoryIndex.value == index) return;
    selectedCategoryIndex.value = index;
    loadTemplates(refresh: true);
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  void selectTemplate(int index) {
    if (index < 0 || index >= templates.length) return;
    selectedTemplateIndex.value = index;
    selectedTemplate.value = templates[index];
  }

  void selectColor(int index) {
    if (index < 0 || index >= colors.length) return;
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

  String? _selectedStyleTypeQuery() {
    switch (selectedCategoryIndex.value) {
      case 1:
        return 'classic';
      case 2:
        return 'modern_column';
      default:
        return 'all';
    }
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    super.onClose();
  }
}
