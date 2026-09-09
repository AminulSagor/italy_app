import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_template_model.dart';
import '../services/resume_studio_api_service.dart';
import '../views/cv_builder_view.dart';
import '../views/cv_library_view.dart';
import 'cv_builder_controller.dart';
import 'cv_library_controller.dart';

class CvHomeController extends GetxController {
  CvHomeController({required ResumeStudioApiService apiService})
    : _apiService = apiService;

  // Full-width A4 previews are visually useful but heavier than grid tiles.
  // Six gives a fast first paint without sacrificing the large-card UX.
  static const int pageSize = 6;

  final ResumeStudioApiService _apiService;
  final TextEditingController searchController = TextEditingController();

  final RxList<CvTemplateModel> templates = <CvTemplateModel>[].obs;
  final RxList<CvTemplateCategoryModel> categories =
      <CvTemplateCategoryModel>[].obs;

  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isInitialLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isFiltering = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isOpeningLibrary = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;

  final Rxn<CvBuilderContractModel> builderContract =
      Rxn<CvBuilderContractModel>();
  final Rxn<CvAccessModel> cvAccess = Rxn<CvAccessModel>();

  Worker? _searchWorker;
  int _requestSerial = 0;

  bool get canLoadMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
      (_) => unawaited(_reloadForFilterChange()),
      time: const Duration(milliseconds: 350),
    );

    unawaited(loadHomeBootstrap(showBlockingLoading: true));
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> selectCategory(String category) async {
    final String normalized = category.trim().toLowerCase();
    if (selectedCategory.value == normalized) return;
    selectedCategory.value = normalized;
    await _reloadForFilterChange();
  }

  Future<void> _reloadForFilterChange() async {
    await loadTemplates(
      reset: true,
      showBlockingLoading: false,
      showFilteringState: true,
    );
  }

  Future<void> refreshTemplates() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await loadHomeBootstrap(showBlockingLoading: false);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadHomeBootstrap({bool showBlockingLoading = false}) async {
    final int requestId = ++_requestSerial;

    if (showBlockingLoading) {
      isInitialLoading.value = true;
    } else if (templates.isNotEmpty) {
      isFiltering.value = true;
    }
    errorMessage.value = '';

    try {
      final CvHomeBootstrapModel bootstrap = await _apiService
          .fetchHomeBootstrap(
            page: 1,
            limit: pageSize,
            search: searchQuery.value,
            category: selectedCategory.value,
          );

      if (requestId != _requestSerial) return;

      final CvTemplateListResponseModel response = bootstrap.templateResponse;
      templates.assignAll(response.templates);
      categories.assignAll(bootstrap.categories);
      builderContract.value = bootstrap.builderContract;
      cvAccess.value = bootstrap.cvAccess;
      currentPage.value = response.page;
      totalPages.value = response.totalPages;
      totalItems.value = response.total;
    } catch (error) {
      if (requestId == _requestSerial) {
        errorMessage.value = ApiErrorHandler.getErrorMessage(error);
      }
    } finally {
      if (requestId == _requestSerial) {
        isInitialLoading.value = false;
        isFiltering.value = false;
      }
    }
  }

  Future<void> loadTemplates({
    required bool reset,
    bool showBlockingLoading = false,
    bool showFilteringState = false,
  }) async {
    if (!reset && (isLoadingMore.value || !canLoadMore)) return;

    final int requestId = ++_requestSerial;

    if (reset) {
      if (showBlockingLoading) isInitialLoading.value = true;
      if (showFilteringState && templates.isNotEmpty) {
        isFiltering.value = true;
      }
      errorMessage.value = '';
    } else {
      isLoadingMore.value = true;
    }

    try {
      final int requestedPage = reset ? 1 : currentPage.value + 1;
      final CvTemplateListResponseModel response = await _apiService
          .fetchTemplates(
            page: requestedPage,
            limit: pageSize,
            search: searchQuery.value,
            category: selectedCategory.value,
          );

      if (requestId != _requestSerial) return;

      if (reset) {
        templates.assignAll(response.templates);
      } else {
        final Set<String> existingIds = templates.map((e) => e.id).toSet();
        templates.addAll(
          response.templates.where(
            (CvTemplateModel item) => !existingIds.contains(item.id),
          ),
        );
      }

      currentPage.value = response.page;
      totalPages.value = response.totalPages;
      totalItems.value = response.total;
    } catch (error) {
      if (requestId == _requestSerial) {
        errorMessage.value = ApiErrorHandler.getErrorMessage(error);
      }
    } finally {
      if (requestId == _requestSerial) {
        isInitialLoading.value = false;
        isFiltering.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<CvBuilderContractModel?> loadBuilderContract({
    bool force = false,
  }) async {
    if (!force && builderContract.value != null) return builderContract.value;

    try {
      final CvBuilderContractModel contract = await _apiService
          .fetchBuilderContract();
      builderContract.value = contract;
      return contract;
    } catch (_) {
      return null;
    }
  }

  Future<void> openTemplate(CvTemplateModel template) async {
    final CvBuilderContractModel? contract =
        builderContract.value ?? await loadBuilderContract();

    if (contract == null) {
      Get.snackbar(
        'cvb_unavailable_title'.tr,
        'cvb_unavailable_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Opening a template is free. The backend either creates its one workspace
    // or resumes the existing one. Access is consumed only on first PDF render.
    await _openBuilder(contract: contract, template: template);
  }

  Future<void> openMyCvs() async {
    if (isOpeningLibrary.value) return;
    isOpeningLibrary.value = true;

    try {
      final String controllerTag =
          'resume-library-${DateTime.now().microsecondsSinceEpoch}';

      await Get.to<void>(
        () => CvLibraryView(controllerTag: controllerTag),
        binding: BindingsBuilder(() {
          Get.put<CvLibraryController>(
            CvLibraryController(
              apiService: _apiService,
              initialContract: builderContract.value,
              initialAccess: cvAccess.value,
            ),
            tag: controllerTag,
          );
        }),
        transition: Transition.rightToLeft,
      );

      unawaited(loadHomeBootstrap(showBlockingLoading: false));
    } finally {
      isOpeningLibrary.value = false;
    }
  }

  Future<void> _openBuilder({
    required CvBuilderContractModel contract,
    required CvTemplateModel template,
  }) async {
    final String controllerTag =
        'resume-builder-${DateTime.now().microsecondsSinceEpoch}';

    await Get.to<void>(
      () => CvBuilderView(controllerTag: controllerTag),
      binding: BindingsBuilder(() {
        Get.put<CvBuilderController>(
          CvBuilderController(
            apiService: _apiService,
            contract: contract,
            initialSchema: template.fieldSchema,
            initialTemplate: template,
            accessAtOpen: cvAccess.value,
          ),
          tag: controllerTag,
        );
      }),
      transition: Transition.rightToLeft,
    );

    // A render can change free/paid access, so refresh once when returning.
    unawaited(loadHomeBootstrap(showBlockingLoading: false));
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    super.onClose();
  }
}
