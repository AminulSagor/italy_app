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
  final RxBool isTemplateOverlayVisible = false.obs;

  /*
   * The template currently selected by the user.
   *
   * This remains selected when analysis fails so the card
   * can show the error and Retry action.
   */
  final RxString selectedTemplateId = ''.obs;

  /*
   * The backend analyzes the template while creating the
   * assistant session. This ID controls the selected-card
   * "Analyzing template..." overlay.
   */
  final RxString analyzingTemplateId = ''.obs;

  /*
   * Stores the template whose analysis/session creation
   * failed.
   */
  final RxString analysisFailedTemplateId = ''.obs;

  /*
   * User-facing analysis failure message displayed by the
   * selected template card.
   */
  final RxString analysisErrorMessage = ''.obs;

  final RxBool isLoading = false.obs;

  final RxBool isLoadingMore = false.obs;

  final RxBool isStartingScratch = false.obs;

  final RxInt currentPage = 1.obs;

  final RxInt totalPages = 0.obs;

  final RxInt totalItems = 0.obs;

  Worker? _searchWorker;

  bool get canLoadMore {
    return currentPage.value < totalPages.value;
  }

  bool get isAnalyzingTemplate {
    return analyzingTemplateId.value.isNotEmpty;
  }

  bool get isStartingAnySession {
    return isAnalyzingTemplate ||
        isStartingScratch.value;
  }

  bool isTemplateSelected(
      String templateId,
      ) {
    return selectedTemplateId.value ==
        templateId.trim();
  }

  bool isTemplateAnalyzing(
      String templateId,
      ) {
    return analyzingTemplateId.value ==
        templateId.trim();
  }

  bool hasTemplateAnalysisFailed(
      String templateId,
      ) {
    return analysisFailedTemplateId.value ==
        templateId.trim();
  }

  /*
   * While one template is being analyzed, all template
   * cards and the scratch action should ignore new taps.
   */
  bool isTemplateInteractionDisabled(
      String templateId,
      ) {
    if (!isStartingAnySession) {
      return false;
    }

    /*
     * The active card is also disabled to prevent the user
     * from submitting the same analysis request repeatedly.
     */
    return true;
  }

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
          (_) {
        unawaited(
          loadTemplates(
            reset: true,
          ),
        );
      },
      time: const Duration(
        milliseconds: 450,
      ),
    );

    unawaited(
      loadTemplates(
        reset: true,
      ),
    );
  }

  void onSearchChanged(
      String value,
      ) {
    searchQuery.value = value.trim();
  }

  void clearSearch() {
    searchController.clear();

    searchQuery.value = '';
  }

  Future<void> refreshTemplates() {
    return loadTemplates(
      reset: true,
    );
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
      if (isLoadingMore.value ||
          !canLoadMore) {
        return;
      }

      isLoadingMore.value = true;
    }

    try {
      final int requestedPage =
      reset
          ? 1
          : currentPage.value + 1;

      final CvTemplateListResponseModel response =
      await _apiService.fetchTemplates(
        page: requestedPage,
        limit: pageSize,
        search: searchQuery.value,
      );

      if (reset) {
        templates.assignAll(
          response.templates,
        );
      } else {
        templates.addAll(
          response.templates,
        );
      }

      currentPage.value =
          response.pagination.page;

      totalPages.value =
          response.pagination.totalPages;

      totalItems.value =
          response.pagination.totalItems;
    } catch (error) {
      errorMessage.value =
          ApiErrorHandler.getErrorMessage(
            error,
          );
    } finally {
      isLoading.value = false;

      isLoadingMore.value = false;
    }
  }

  Future<void> startTemplateChat(
      CvTemplateModel template, {
        VoidCallback? onChatOpened,
      }) async {
    if (isStartingAnySession) {
      return;
    }

    final String templateId =
    template.id.trim();

    if (templateId.isEmpty) {
      analysisErrorMessage.value =
      'The selected template is invalid.';

      return;
    }

    selectedTemplateId.value =
        templateId;

    analyzingTemplateId.value =
        templateId;

    isTemplateOverlayVisible.value = true;

    analysisFailedTemplateId.value = '';

    analysisErrorMessage.value = '';

    try {
      /*
       * Template analysis happens inside this backend
       * request. Flutter therefore shows an indeterminate
       * "Analyzing template..." state rather than a fake
       * percentage.
       */
      final CvAssistantSessionModel session =
      await _apiService
          .createCvAssistantSession(
        templateId: templateId,
      );

      /*
       * Analysis has completed successfully. Remove the
       * loading state before navigating to the chat.
       *
       * The full-page overlay is removed separately through
       * onChatOpened after the navigation transition.
       */
      analyzingTemplateId.value = '';

      analysisFailedTemplateId.value = '';

      analysisErrorMessage.value = '';

      await _openChat(
        session: session,
        selectedTemplate: template,
        onChatOpened: () {
          isTemplateOverlayVisible.value = false;
          onChatOpened?.call();
        },
      );
    } catch (error) {
      isTemplateOverlayVisible.value = false;
      analyzingTemplateId.value = '';

      analysisFailedTemplateId.value =
          templateId;

      analysisErrorMessage.value =
          ApiErrorHandler.getErrorMessage(
            error,
          );
    } finally {
      /*
       * Do not clear another request's state if this method
       * ever becomes cancellable or concurrently replaced.
       */
      if (analyzingTemplateId.value ==
          templateId) {
        analyzingTemplateId.value = '';
      }
    }
  }

  Future<void> retryTemplateAnalysis(
      CvTemplateModel template, {
        VoidCallback? onChatOpened,
      }) async {
    if (isStartingAnySession) {
      return;
    }

    selectedTemplateId.value =
        template.id.trim();

    analysisFailedTemplateId.value = '';

    analysisErrorMessage.value = '';

    await startTemplateChat(
      template,
      onChatOpened: onChatOpened,
    );
  }

  void clearTemplateAnalysisFailure() {
    analysisFailedTemplateId.value = '';

    analysisErrorMessage.value = '';
  }

  Future<void> startScratchChat() async {
    if (isStartingAnySession) {
      return;
    }

    /*
     * Scratch mode does not use a selected template.
     */
    selectedTemplateId.value = '';

    analysisFailedTemplateId.value = '';

    analysisErrorMessage.value = '';

    isStartingScratch.value = true;

    try {
      final CvAssistantSessionModel session =
      await _apiService
          .createCvAssistantSession();

      /*
       * Remove the home-screen loading state before opening
       * the assistant screen.
       */
      isStartingScratch.value = false;

      await _openChat(
        session: session,
        selectedTemplate: null,
      );
    } catch (error) {
      _showScratchError(
        error,
      );
    } finally {
      isStartingScratch.value = false;
    }
  }

  Future<void> _openChat({
    required CvAssistantSessionModel session,
    required CvTemplateModel? selectedTemplate,
    VoidCallback? onChatOpened,
  }) async {
    const Duration transitionDuration =
    Duration(milliseconds: 300);

    final String controllerTag =
        'cv-chat-${session.id}';

    final navigationFuture = Get.to<void>(
          () => CvChatView(
        controllerTag: controllerTag,
      ),
      binding: BindingsBuilder(
            () {
          Get.put<CvChatController>(
            CvChatController(
              apiService: _apiService,
              initialSession: session,
              selectedTemplate: selectedTemplate,
            ),
            tag: controllerTag,
          );
        },
      ),
      transition: Transition.rightToLeft,
      duration: transitionDuration,
    );

    await Future<void>.delayed(
      transitionDuration +
          const Duration(milliseconds: 80),
    );

    onChatOpened?.call();

    if (navigationFuture != null) {
      await navigationFuture;
    }
  }

  void _showScratchError(
      Object error,
      ) {
    Get.snackbar(
      'Unable to start CV assistant',
      ApiErrorHandler.getErrorMessage(
        error,
      ),
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();

    searchController.dispose();

    super.onClose();
  }
}