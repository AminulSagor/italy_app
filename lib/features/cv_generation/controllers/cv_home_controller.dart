import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_assistant_models.dart';
import '../models/cv_template_model.dart';
import '../services/cv_generation_api_service.dart';
import '../views/cv_chat_view.dart';
import 'cv_chat_controller.dart';

class CvHomeController extends GetxController {
  CvHomeController({
    required CvGenerationApiService apiService,
  }) : _apiService = apiService;

  static const int pageSize = 9;

  final CvGenerationApiService _apiService;

  final TextEditingController searchController =
  TextEditingController();

  final RxList<CvTemplateModel> templates =
      <CvTemplateModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString startingTemplateId = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isStartingScratch = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;

  Worker? _searchWorker;

  bool get canLoadMore =>
      currentPage.value < totalPages.value;

  bool get isStartingAnySession =>
      startingTemplateId.value.isNotEmpty ||
          isStartingScratch.value;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
          (_) {
        unawaited(loadTemplates(reset: true));
      },
      time: const Duration(milliseconds: 450),
    );

    unawaited(loadTemplates(reset: true));
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> refreshTemplates() {
    return loadTemplates(reset: true);
  }

  Future<void> loadTemplates({
    required bool reset,
  }) async {
    if (reset) {
      if (isLoading.value) {
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';
    } else {
      if (isLoadingMore.value || !canLoadMore) {
        return;
      }

      isLoadingMore.value = true;
    }

    try {
      final int requestedPage =
      reset ? 1 : currentPage.value + 1;

      final CvTemplateListResponseModel response =
      await _apiService.fetchTemplates(
        page: requestedPage,
        limit: pageSize,
        search: searchQuery.value,
      );

      if (reset) {
        templates.assignAll(response.templates);
      } else {
        templates.addAll(response.templates);
      }

      currentPage.value =
          response.pagination.page;

      totalPages.value =
          response.pagination.totalPages;

      totalItems.value =
          response.pagination.totalItems;
    } catch (error) {
      errorMessage.value =
          ApiErrorHandler.getErrorMessage(error);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> startTemplateChat(
      CvTemplateModel template,
      ) async {
    if (isStartingAnySession) {
      return;
    }

    startingTemplateId.value = template.id;

    try {
      final CvAssistantSessionModel session =
      await _apiService
          .createCvAssistantSession(
        templateId: template.id,
      );

      await _openChat(
        session: session,
        selectedTemplate: template,
      );
    } catch (error) {
      _showError(error);
    } finally {
      startingTemplateId.value = '';
    }
  }

  Future<void> startScratchChat() async {
    if (isStartingAnySession) {
      return;
    }

    isStartingScratch.value = true;

    try {
      final CvAssistantSessionModel session =
      await _apiService
          .createCvAssistantSession();

      await _openChat(
        session: session,
        selectedTemplate: null,
      );
    } catch (error) {
      _showError(error);
    } finally {
      isStartingScratch.value = false;
    }
  }

  Future<void> _openChat({
    required CvAssistantSessionModel session,
    required CvTemplateModel? selectedTemplate,
  }) async {
    if (Get.isRegistered<CvChatController>()) {
      await Get.delete<CvChatController>(
        force: true,
      );
    }

    await Get.to<void>(
          () => const CvChatView(),
      binding: BindingsBuilder(() {
        Get.put<CvChatController>(
          CvChatController(
            apiService: _apiService,
            initialSession: session,
            selectedTemplate: selectedTemplate,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    );
  }

  void _showError(Object error) {
    Get.snackbar(
      'Unable to start CV assistant',
      ApiErrorHandler.getErrorMessage(error),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    super.onClose();
  }
}