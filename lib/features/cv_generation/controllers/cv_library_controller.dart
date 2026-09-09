import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_library_model.dart';
import '../models/cv_template_model.dart';
import '../models/resume_studio_models.dart';
import '../services/resume_studio_api_service.dart';
import '../views/cv_builder_view.dart';
import '../views/cv_preview_view.dart';
import 'cv_builder_controller.dart';
import 'cv_preview_controller.dart';

class CvLibraryController extends GetxController {
  CvLibraryController({
    required ResumeStudioApiService apiService,
    CvBuilderContractModel? initialContract,
    CvAccessModel? initialAccess,
  }) : _apiService = apiService,
       _builderContract = initialContract,
       _access = initialAccess;

  static const int pageSize = 20;

  final ResumeStudioApiService _apiService;

  final RxList<CvLibraryItemModel> items = <CvLibraryItemModel>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString openingDocumentId = ''.obs;
  final RxString viewingDocumentId = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;

  CvBuilderContractModel? _builderContract;
  CvAccessModel? _access;

  bool get canLoadMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadLibrary(reset: true, blocking: true));
  }

  Future<void> refreshLibrary() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await loadLibrary(reset: true, blocking: false);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadLibrary({required bool reset, bool blocking = false}) async {
    if (!reset && (isLoadingMore.value || !canLoadMore)) return;

    if (reset) {
      errorMessage.value = '';
      if (blocking) isInitialLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final CvLibraryResponseModel response = await _apiService.fetchCvLibrary(
        page: reset ? 1 : currentPage.value + 1,
        limit: pageSize,
      );

      if (reset) {
        items.assignAll(response.items);
      } else {
        final Set<String> existingIds = items
            .map((CvLibraryItemModel item) => item.documentId)
            .toSet();
        items.addAll(
          response.items.where(
            (CvLibraryItemModel item) => !existingIds.contains(item.documentId),
          ),
        );
      }

      currentPage.value = response.page;
      totalPages.value = response.totalPages;
      totalItems.value = response.total;
    } catch (error) {
      errorMessage.value = ApiErrorHandler.getErrorMessage(error);
    } finally {
      isInitialLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> edit(CvLibraryItemModel item) async {
    if (openingDocumentId.value.isNotEmpty || !item.templateAvailable) return;
    openingDocumentId.value = item.documentId;

    try {
      final ResumeDocumentModel document = await _apiService.fetchDocument(
        item.documentId,
      );
      final String templateId = document.templateId ?? item.templateId ?? '';
      if (templateId.isEmpty) {
        throw StateError('cvb_template_link_missing'.tr);
      }

      final CvTemplateModel template = await _apiService.fetchTemplate(
        templateId,
      );
      final CvBuilderContractModel contract =
          _builderContract ?? await _apiService.fetchBuilderContract();
      _builderContract = contract;

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
              initialDocument: document,
              accessAtOpen: _access,
            ),
            tag: controllerTag,
          );
        }),
        transition: Transition.rightToLeft,
      );

      await Future.wait<void>(<Future<void>>[
        loadLibrary(reset: true, blocking: false),
        _refreshBuilderContext(),
      ]);
    } catch (error) {
      Get.snackbar(
        'cvb_open_cv_failed'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      openingDocumentId.value = '';
    }
  }

  Future<void> view(CvLibraryItemModel item) async {
    final CvLibraryGenerationModel? latest = item.latestGeneration;
    if (latest == null ||
        !latest.hasPdf ||
        viewingDocumentId.value.isNotEmpty) {
      return;
    }

    viewingDocumentId.value = item.documentId;
    try {
      final ResumeGenerationModel generation = await _apiService
          .fetchGeneration(latest.id);
      final String controllerTag = 'resume-preview-${generation.id}';

      await Get.to<void>(
        () => CvPreviewView(controllerTag: controllerTag),
        binding: BindingsBuilder(() {
          Get.put<CvPreviewController>(
            CvPreviewController(
              apiService: _apiService,
              generation: generation,
              documentTitle: item.title,
            ),
            tag: controllerTag,
          );
        }),
        transition: Transition.rightToLeft,
      );
    } catch (error) {
      Get.snackbar(
        'cvb_open_pdf_failed'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      viewingDocumentId.value = '';
    }
  }

  Future<void> _refreshBuilderContext() async {
    try {
      final CvHomeBootstrapModel bootstrap = await _apiService
          .fetchHomeBootstrap(page: 1, limit: 1);
      _builderContract = bootstrap.builderContract;
      _access = bootstrap.cvAccess;
    } catch (_) {
      // Library remains usable. The next builder can retry its contract fetch.
    }
  }
}
