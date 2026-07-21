import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/routes.dart';
import '../../drawer_features/shop/models/shop_models.dart';
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

  final RxBool isTemplateOverlayVisible =
      false.obs;

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

  /*
   * CV free-generation and purchased-credit information.
   */
  final Rxn<StoreBalancesModel> cvAccess =
  Rxn<StoreBalancesModel>();

  final RxBool isLoadingCvAccess = false.obs;

  Worker? _searchWorker;

  bool get canLoadMore {
    return currentPage.value <
        totalPages.value;
  }

  bool get isAnalyzingTemplate {
    return analyzingTemplateId
        .value.isNotEmpty;
  }

  bool get isStartingAnySession {
    return isAnalyzingTemplate ||
        isStartingScratch.value;
  }

  /*
   * Total free CV creation limit configured by admin.
   */
  int get freeCvGenerationsLimit {
    return cvAccess.value
        ?.freeCvGenerationsLimit ??
        3;
  }

  /*
   * Free CV creations still remaining.
   *
   * Before the balance request finishes, use the configured
   * default optimistically so a temporary network issue does
   * not incorrectly tell the user that the free limit ended.
   */
  int get freeCvGenerationsRemaining {
    return cvAccess.value
        ?.freeCvGenerationsRemaining ??
        freeCvGenerationsLimit;
  }

  /*
   * Purchased CV credits only.
   */
  int get paidCvCredits {
    return cvAccess.value?.cvCredits ?? 0;
  }

  bool get hasFreeCvGeneration {
    return freeCvGenerationsRemaining > 0;
  }

  bool get freeCvLimitEnded {
    return cvAccess.value
        ?.freeCvLimitExhausted ??
        false;
  }

  int get totalCvGenerationsAvailable {
    return cvAccess.value
        ?.totalCvGenerationsAvailable ??
        freeCvGenerationsRemaining +
            paidCvCredits;
  }

  /*
   * Keep this optimistic when the balance request fails.
   * The backend remains authoritative and will return HTTP
   * 402 when the user has no free generation or paid credit.
   */
  bool get canCreateCv {
    return cvAccess.value?.canCreateCv ??
        true;
  }

  /*
   * Possible values:
   * free, credit, none.
   */
  String get nextCvGenerationUses {
    return cvAccess.value
        ?.nextCvGenerationUses ??
        (freeCvGenerationsRemaining > 0
            ? 'free'
            : paidCvCredits > 0
            ? 'credit'
            : 'none');
  }

  bool get nextCvUsesFreeAllowance {
    return nextCvGenerationUses ==
        'free';
  }

  bool get nextCvUsesPaidCredit {
    return nextCvGenerationUses ==
        'credit';
  }

  bool get allowCvEditingWithoutCredit {
    return cvAccess.value
        ?.allowCvEditingWithoutCredit ??
        true;
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

    unawaited(
      loadCvAccess(),
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

  /*
   * Refresh both template data and CV access information.
   */
  Future<void> refreshTemplates() async {
    await Future.wait<void>(
      <Future<void>>[
        loadTemplates(
          reset: true,
        ),
        loadCvAccess(),
      ],
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

      final CvTemplateListResponseModel
      response =
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

  /*
   * Loads:
   * - remaining free CV creations
   * - purchased CV credits
   * - whether another CV can be created
   *
   * A temporary balance-loading failure must not block the
   * existing CV assistant functionality. The backend still
   * validates access during final generation.
   */
  Future<void> loadCvAccess() async {
    if (isLoadingCvAccess.value) {
      return;
    }

    isLoadingCvAccess.value = true;

    try {
      cvAccess.value =
      await _apiService.fetchCvAccess();
    } catch (_) {
      /*
       * Do not replace the template error or prevent the
       * user from opening the assistant due to a temporary
       * balance request failure.
       */
    } finally {
      isLoadingCvAccess.value = false;
    }
  }

  /*
   * Checks the current free/paid CV access before opening a
   * new assistant session.
   *
   * This is an early UX check only. The backend performs the
   * final atomic access validation when generation begins.
   */
  Future<bool>
  ensureNewCvAccessAvailable() async {
    await loadCvAccess();

    if (canCreateCv) {
      return true;
    }

    await Get.dialog<void>(
      AlertDialog(
        title: Text(
          'cv_credit_required_title'.tr,
        ),
        content: Text(
          'cv_credit_required_message'.tr,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back<void>();
            },
            child: Text(
              'cancel'.tr,
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Get.back<void>();

              unawaited(
                Future<void>.delayed(
                  Duration.zero,
                  openCvCreditStore,
                ),
              );
            },
            icon: const Icon(
              Icons.add_card_rounded,
            ),
            label: Text(
              'buy_cv_credits'.tr,
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return false;
  }

  /*
   * Opens the CV Credit Store and refreshes the balance when
   * the user returns.
   */
  Future<void> openCvCreditStore() async {
    await Get.toNamed(
      AppRoutes.cvCreditStore,
    );

    await loadCvAccess();
  }

  Future<void> startTemplateChat(
      CvTemplateModel template, {
        VoidCallback? onChatOpened,
      }) async {
    if (isStartingAnySession) {
      return;
    }

    /*
     * Prevent opening a new CV assistant when all three free
     * creations are used and no purchased credit remains.
     */
    final bool accessAvailable =
    await ensureNewCvAccessAvailable();

    if (!accessAvailable) {
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

    isTemplateOverlayVisible.value =
    true;

    analysisFailedTemplateId.value =
    '';

    analysisErrorMessage.value = '';

    try {
      /*
       * Template analysis happens inside this backend
       * request. Flutter therefore shows an indeterminate
       * "Analyzing template..." state rather than a fake
       * percentage.
       */
      final CvAssistantSessionModel
      session =
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

      analysisFailedTemplateId.value =
      '';

      analysisErrorMessage.value = '';

      await _openChat(
        session: session,
        selectedTemplate: template,
        onChatOpened: () {
          isTemplateOverlayVisible.value =
          false;

          onChatOpened?.call();
        },
      );
    } catch (error) {
      isTemplateOverlayVisible.value =
      false;

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

    analysisFailedTemplateId.value =
    '';

    analysisErrorMessage.value = '';

    await startTemplateChat(
      template,
      onChatOpened: onChatOpened,
    );
  }

  void clearTemplateAnalysisFailure() {
    analysisFailedTemplateId.value =
    '';

    analysisErrorMessage.value = '';
  }

  Future<void> startScratchChat() async {
    if (isStartingAnySession) {
      return;
    }

    /*
     * Prevent opening a new scratch CV assistant when the
     * free allowance and purchased balance are both zero.
     */
    final bool accessAvailable =
    await ensureNewCvAccessAvailable();

    if (!accessAvailable) {
      return;
    }

    /*
     * Scratch mode does not use a selected template.
     */
    selectedTemplateId.value = '';

    analysisFailedTemplateId.value =
    '';

    analysisErrorMessage.value = '';

    isStartingScratch.value = true;

    try {
      final CvAssistantSessionModel
      session =
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
              selectedTemplate:
              selectedTemplate,
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
          const Duration(
            milliseconds: 80,
          ),
    );

    onChatOpened?.call();

    if (navigationFuture != null) {
      await navigationFuture;
    }

    /*
   * The user may have generated a CV while inside the
   * assistant. Refresh the free allowance and purchased
   * CV-credit balance after returning.
   */
    await loadCvAccess();
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