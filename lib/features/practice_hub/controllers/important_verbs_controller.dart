import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';
import '../models/important_verb_detail_models.dart';
import '../models/important_verb_models.dart';
import '../services/important_verbs_api_service.dart';
import '../services/italian_tts_service.dart';
import '../views/important_verbs/saved_verbs_view.dart';

class ImportantVerbsController extends GetxController {
  ImportantVerbsController({
    required ImportantVerbsApiService apiService,
    required ItalianTtsService ttsService,
  }) : _apiService = apiService,
       _ttsService = ttsService;

  String get _language {
    final String languageCode = Get.locale?.languageCode.toLowerCase() ?? 'en';

    if (languageCode == 'bn') {
      return 'bn';
    }

    if (languageCode == 'it') {
      return 'it';
    }

    return 'en';
  }

  static const int _pageSize = 10;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 450);

  final ImportantVerbsApiService _apiService;
  final ItalianTtsService _ttsService;

  final TextEditingController importantVerbSearchController =
      TextEditingController();
  final TextEditingController savedVerbSearchController =
      TextEditingController();

  final RxList<ImportantVerbSummaryModel> verbItems =
      <ImportantVerbSummaryModel>[].obs;
  final RxList<ImportantVerbSummaryModel> savedVerbItems =
      <ImportantVerbSummaryModel>[].obs;
  final RxList<ImportantVerbSummaryModel> searchSuggestions =
      <ImportantVerbSummaryModel>[].obs;
  final RxSet<String> savedVerbIds = <String>{}.obs;
  final RxSet<String> savingVerbIds = <String>{}.obs;

  final RxBool isVerbsLoading = false.obs;
  final RxBool isLoadingMoreVerbs = false.obs;
  final RxBool isSavedVerbsLoading = false.obs;
  final RxBool isLoadingMoreSavedVerbs = false.obs;
  final RxBool isSearchLoading = false.obs;
  final RxBool isVerbDetailsLoading = false.obs;
  final RxBool isVerbInfoExpanded = true.obs;
  final RxBool showSavedVerbPreview = false.obs;
  final RxBool isSpeaking = false.obs;

  final RxString verbsError = ''.obs;
  final RxString savedVerbsError = ''.obs;
  final RxString verbDetailsError = ''.obs;
  final RxString importantVerbSearchQuery = ''.obs;
  final RxString savedVerbSearchQuery = ''.obs;
  final RxString selectedImportantVerbFilter = 'All Verbs'.obs;
  final RxString selectedSavedVerbFilter = 'All Verbs'.obs;
  final RxString expandedFormId = ''.obs;
  final RxString speakingText = ''.obs;

  final Rxn<ImportantVerbSummaryModel> selectedVerbSummary =
      Rxn<ImportantVerbSummaryModel>();
  final Rxn<ImportantVerbDetailModel> selectedVerbDetails =
      Rxn<ImportantVerbDetailModel>();

  final Set<String> _reviewedVerbIds = <String>{};
  Timer? _importantSearchDebounce;
  Timer? _savedSearchDebounce;
  int _verbsRequestId = 0;
  int _savedVerbsRequestId = 0;
  int _verbsPage = 0;
  int _verbsTotalPages = 1;
  int _savedVerbsPage = 0;
  int _savedVerbsTotalPages = 1;
  int _searchRequestId = 0;
  int _detailsRequestId = 0;

  final List<String> verbFilters = const <String>[
    'All Verbs',
    'Regular',
    'Irregular',
    '-ARE',
    '-ERE',
    '-IRE',
  ];

  ImportantVerbSummaryModel? get currentVerbSummary {
    return selectedVerbDetails.value?.summary ?? selectedVerbSummary.value;
  }

  List<ImportantVerbSummaryModel> get savedVerbPreviewItems {
    return savedVerbItems.take(6).toList(growable: false);
  }

  bool isVerbSavePending(String verbId) {
    return savingVerbIds.contains(verbId);
  }

  bool get hasMoreVerbs => _verbsPage < _verbsTotalPages;
  bool get hasMoreSavedVerbs => _savedVerbsPage < _savedVerbsTotalPages;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadInitialData());
  }

  Future<void> loadInitialData() async {
    await Future.wait<void>(<Future<void>>[
      loadVerbs(showError: false),
      loadSavedVerbs(showError: false),
    ]);
  }

  Future<void> refreshImportantVerbs() async {
    await Future.wait<void>(<Future<void>>[
      loadVerbs(showError: true),
      loadSavedVerbs(showError: true),
    ]);
  }

  Future<void> loadVerbs({bool showError = true}) async {
    final int requestId = ++_verbsRequestId;
    isVerbsLoading.value = true;
    isLoadingMoreVerbs.value = false;
    verbsError.value = '';
    _verbsPage = 0;
    _verbsTotalPages = 1;
    final _VerbFilterQuery filter = _filterFor(
      selectedImportantVerbFilter.value,
    );
    final String search = importantVerbSearchQuery.value;
    try {
      final ApiResult<ImportantVerbListResponseModel> result =
          await ApiErrorHandler.call<ImportantVerbListResponseModel>(
            () => _apiService.fetchVerbs(
              page: 1,
              limit: _pageSize,
              search: search,
              regularity: filter.regularity,
              endingType: filter.endingType,
              language: _language,
            ),
            showError: showError,
          );
      if (requestId != _verbsRequestId) return;
      if (!result.isSuccess || result.data == null) {
        verbsError.value = result.error ?? 'unable_to_load_important_verbs'.tr;
        return;
      }
      final ImportantVerbListResponseModel response = result.data!;
      _verbsPage = response.meta.page;
      _verbsTotalPages = response.meta.totalPages;
      verbItems.assignAll(response.items);
      _syncSavedIds(response.items);
    } finally {
      if (requestId == _verbsRequestId) {
        isVerbsLoading.value = false;
      }
    }
  }

  Future<void> loadMoreVerbs() async {
    if (isVerbsLoading.value || isLoadingMoreVerbs.value || !hasMoreVerbs) {
      return;
    }
    final int requestId = _verbsRequestId;
    final int nextPage = _verbsPage + 1;
    final _VerbFilterQuery filter = _filterFor(
      selectedImportantVerbFilter.value,
    );
    final String search = importantVerbSearchQuery.value;
    isLoadingMoreVerbs.value = true;
    try {
      final ApiResult<ImportantVerbListResponseModel> result =
          await ApiErrorHandler.call<ImportantVerbListResponseModel>(
            () => _apiService.fetchVerbs(
              page: nextPage,
              limit: _pageSize,
              search: search,
              regularity: filter.regularity,
              endingType: filter.endingType,
              language: _language,
            ),
            showError: false,
          );
      if (requestId != _verbsRequestId ||
          !result.isSuccess ||
          result.data == null) {
        return;
      }
      final ImportantVerbListResponseModel response = result.data!;
      _verbsPage = response.meta.page;
      _verbsTotalPages = response.meta.totalPages;
      _appendUnique(verbItems, response.items);
      _syncSavedIds(response.items);
    } finally {
      if (requestId == _verbsRequestId) {
        isLoadingMoreVerbs.value = false;
      }
    }
  }

  Future<void> loadSavedVerbs({bool showError = true}) async {
    final int requestId = ++_savedVerbsRequestId;
    isSavedVerbsLoading.value = true;
    isLoadingMoreSavedVerbs.value = false;
    savedVerbsError.value = '';
    _savedVerbsPage = 0;
    _savedVerbsTotalPages = 1;
    final _VerbFilterQuery filter = _filterFor(selectedSavedVerbFilter.value);
    final String search = savedVerbSearchQuery.value;
    try {
      final ApiResult<ImportantVerbListResponseModel> result =
          await ApiErrorHandler.call<ImportantVerbListResponseModel>(
            () => _apiService.fetchSavedVerbs(
              page: 1,
              limit: _pageSize,
              search: search,
              regularity: filter.regularity,
              endingType: filter.endingType,
              language: _language,
            ),
            showError: showError,
          );
      if (requestId != _savedVerbsRequestId) return;
      if (!result.isSuccess || result.data == null) {
        savedVerbsError.value = result.error ?? 'unable_to_load_saved_verbs'.tr;
        return;
      }
      final ImportantVerbListResponseModel response = result.data!;
      _savedVerbsPage = response.meta.page;
      _savedVerbsTotalPages = response.meta.totalPages;
      savedVerbItems.assignAll(response.items);
      _syncSavedIds(response.items);
      _applySavedStateToAllLists();
    } finally {
      if (requestId == _savedVerbsRequestId) {
        isSavedVerbsLoading.value = false;
      }
    }
  }

  Future<void> loadMoreSavedVerbs() async {
    if (isSavedVerbsLoading.value ||
        isLoadingMoreSavedVerbs.value ||
        !hasMoreSavedVerbs) {
      return;
    }
    final int requestId = _savedVerbsRequestId;
    final int nextPage = _savedVerbsPage + 1;
    final _VerbFilterQuery filter = _filterFor(selectedSavedVerbFilter.value);
    final String search = savedVerbSearchQuery.value;
    isLoadingMoreSavedVerbs.value = true;
    try {
      final ApiResult<ImportantVerbListResponseModel> result =
          await ApiErrorHandler.call<ImportantVerbListResponseModel>(
            () => _apiService.fetchSavedVerbs(
              page: nextPage,
              limit: _pageSize,
              search: search,
              regularity: filter.regularity,
              endingType: filter.endingType,
              language: _language,
            ),
            showError: false,
          );
      if (requestId != _savedVerbsRequestId ||
          !result.isSuccess ||
          result.data == null) {
        return;
      }
      final ImportantVerbListResponseModel response = result.data!;
      _savedVerbsPage = response.meta.page;
      _savedVerbsTotalPages = response.meta.totalPages;
      _appendUnique(savedVerbItems, response.items);
      _syncSavedIds(response.items);
      _applySavedStateToAllLists();
    } finally {
      if (requestId == _savedVerbsRequestId) {
        isLoadingMoreSavedVerbs.value = false;
      }
    }
  }

  void onImportantVerbSearchChanged(String value) {
    importantVerbSearchQuery.value = value;
    _verbsRequestId++;
    _verbsPage = 0;
    _verbsTotalPages = 1;
    isLoadingMoreVerbs.value = false;
    _importantSearchDebounce?.cancel();
    _importantSearchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(loadVerbs());
      unawaited(_loadSearchSuggestions(value));
    });
  }

  void onSavedVerbSearchChanged(String value) {
    savedVerbSearchQuery.value = value;
    _savedVerbsRequestId++;
    _savedVerbsPage = 0;
    _savedVerbsTotalPages = 1;
    isLoadingMoreSavedVerbs.value = false;
    _savedSearchDebounce?.cancel();
    _savedSearchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(loadSavedVerbs());
    });
  }

  Future<void> _loadSearchSuggestions(String value) async {
    final String query = value.trim();
    final int requestId = ++_searchRequestId;
    if (query.isEmpty) {
      searchSuggestions.clear();
      isSearchLoading.value = false;
      return;
    }
    isSearchLoading.value = true;
    try {
      final ApiResult<List<ImportantVerbSummaryModel>> result =
          await ApiErrorHandler.call<List<ImportantVerbSummaryModel>>(
            () => _apiService.searchVerbs(
              query: query,
              limit: 6,
              language: _language,
            ),
            showError: false,
          );
      if (requestId != _searchRequestId ||
          importantVerbSearchQuery.value.trim() != query) {
        return;
      }
      searchSuggestions.assignAll(result.dataOr(<ImportantVerbSummaryModel>[]));
      _syncSavedIds(searchSuggestions);
    } finally {
      if (requestId == _searchRequestId) {
        isSearchLoading.value = false;
      }
    }
  }

  void clearImportantVerbSearch() {
    _importantSearchDebounce?.cancel();
    _searchRequestId++;
    importantVerbSearchController.clear();
    importantVerbSearchQuery.value = '';
    searchSuggestions.clear();
    unawaited(loadVerbs());
  }

  void clearSavedVerbSearch() {
    _savedSearchDebounce?.cancel();
    savedVerbSearchController.clear();
    savedVerbSearchQuery.value = '';
    unawaited(loadSavedVerbs());
  }

  void selectImportantVerbFilter(String filter) {
    if (selectedImportantVerbFilter.value == filter) return;
    selectedImportantVerbFilter.value = filter;
    searchSuggestions.clear();
    unawaited(loadVerbs());
  }

  void selectSavedVerbFilter(String filter) {
    if (selectedSavedVerbFilter.value == filter) return;
    selectedSavedVerbFilter.value = filter;
    unawaited(loadSavedVerbs());
  }

  void toggleSavedVerbPreview() {
    showSavedVerbPreview.toggle();
    if (showSavedVerbPreview.value && savedVerbItems.isEmpty) {
      unawaited(loadSavedVerbs());
    }
  }

  void onViewAllSavedVerbsTap() {
    unawaited(loadSavedVerbs(showError: false));
    Get.to<void>(
      () => const SavedVerbsView(),
      transition: Transition.rightToLeft,
    );
  }

  void onVerbSuggestionTap(ImportantVerbSummaryModel verb) {
    importantVerbSearchController.text = verb.infinitive;
    importantVerbSearchQuery.value = verb.infinitive;
    searchSuggestions.clear();
    openVerbDetails(verb);
  }

  void onViewAllSearchResultsTap() {
    searchSuggestions.clear();
    unawaited(loadVerbs());
  }

  void openVerbDetails(ImportantVerbSummaryModel verb) {
    selectedVerbSummary.value = verb;
    selectedVerbDetails.value = null;
    verbDetailsError.value = '';
    isVerbInfoExpanded.value = true;
    expandedFormId.value = '';
    Get.toNamed(AppRoutes.verbDetails);
    unawaited(loadVerbDetails(verb.id));
  }

  Future<void> loadVerbDetails(String verbId, {bool showError = true}) async {
    final int requestId = ++_detailsRequestId;
    isVerbDetailsLoading.value = true;
    verbDetailsError.value = '';
    try {
      final ApiResult<ImportantVerbDetailModel> result =
          await ApiErrorHandler.call<ImportantVerbDetailModel>(
            () => _apiService.fetchVerbDetails(
              verbId: verbId,
              language: _language,
            ),
            showError: showError,
          );

      if (requestId != _detailsRequestId) return;
      if (!result.isSuccess || result.data == null) {
        verbDetailsError.value =
            result.error ?? 'unable_to_load_verb_details'.tr;
        return;
      }

      selectedVerbDetails.value = result.data;
      selectedVerbSummary.value = result.data!.summary;
      _syncSavedIds(<ImportantVerbSummaryModel>[result.data!.summary]);
      final List<ImportantVerbFormModel> forms = result.data!.forms;
      if (forms.isNotEmpty) {
        final ImportantVerbFormModel initialForm = forms.firstWhere(
          (ImportantVerbFormModel item) => item.formKey == 'present',
          orElse: () => forms.first,
        );
        expandedFormId.value = initialForm.id;
      }
      if (_reviewedVerbIds.add(verbId)) {
        unawaited(_markVerbReviewed(verbId));
      }
    } finally {
      if (requestId == _detailsRequestId) {
        isVerbDetailsLoading.value = false;
      }
    }
  }

  Future<void> _markVerbReviewed(String verbId) async {
    await ApiErrorHandler.call<void>(
      () => _apiService.markVerbReviewed(verbId: verbId),
      showError: false,
    );
  }

  bool isVerbSaved(String verbId) => savedVerbIds.contains(verbId);

  Future<void> toggleVerbSaved(ImportantVerbSummaryModel verb) async {
    if (isVerbSavePending(verb.id)) {
      return;
    }

    final bool wasSaved = isVerbSaved(verb.id);

    savingVerbIds.add(verb.id);
    savingVerbIds.refresh();

    // Keep the optimistic UI update.
    _setVerbSavedState(verb.id, !wasSaved);

    bool wasSuccessful = false;

    try {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
        () => wasSaved
            ? _apiService.removeSavedVerb(verbId: verb.id)
            : _apiService.saveVerb(verbId: verb.id),
      );

      if (!result.isSuccess) {
        // Restore the previous state when the API fails.
        _setVerbSavedState(verb.id, wasSaved);
        return;
      }

      wasSuccessful = true;
    } finally {
      savingVerbIds.remove(verb.id);
      savingVerbIds.refresh();
    }

    if (wasSuccessful) {
      unawaited(loadSavedVerbs(showError: false));
    }
  }

  Future<void> speak(ImportantVerbTtsModel tts) async {
    if (tts.text.trim().isEmpty || isSpeaking.value) return;

    isSpeaking.value = true;
    speakingText.value = tts.text;
    try {
      final bool started = await _ttsService.speak(tts);
      if (!started) {
        Get.snackbar(
          'pronunciation_unavailable'.tr,
          'Install or enable an Italian voice on this device and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSpeaking.value = false;
      speakingText.value = '';
    }
  }

  void toggleVerbInformation() => isVerbInfoExpanded.toggle();

  void toggleVerbForm(String formId) {
    expandedFormId.value = expandedFormId.value == formId ? '' : formId;
  }

  void onVerbDetailBackTap() => Get.back<void>();

  void _appendUnique(
    RxList<ImportantVerbSummaryModel> target,
    Iterable<ImportantVerbSummaryModel> incoming,
  ) {
    final Set<String> existingIds = target
        .map((ImportantVerbSummaryModel item) => item.id)
        .toSet();
    target.addAll(
      incoming.where(
        (ImportantVerbSummaryModel item) => existingIds.add(item.id),
      ),
    );
  }

  void _syncSavedIds(Iterable<ImportantVerbSummaryModel> items) {
    for (final ImportantVerbSummaryModel item in items) {
      if (item.isSaved) savedVerbIds.add(item.id);
    }
    savedVerbIds.refresh();
  }

  void _setVerbSavedState(String verbId, bool isSaved) {
    if (isSaved) {
      savedVerbIds.add(verbId);
    } else {
      savedVerbIds.remove(verbId);
    }
    savedVerbIds.refresh();
    _applySavedStateToAllLists();
  }

  void _applySavedStateToAllLists() {
    _replaceSavedState(verbItems);
    _replaceSavedState(savedVerbItems, removeUnsaved: true);
    _replaceSavedState(searchSuggestions);

    final ImportantVerbDetailModel? details = selectedVerbDetails.value;
    if (details != null) {
      selectedVerbDetails.value = details.copyWith(
        summary: details.summary.copyWith(
          isSaved: savedVerbIds.contains(details.summary.id),
        ),
      );
    }
    final ImportantVerbSummaryModel? summary = selectedVerbSummary.value;
    if (summary != null) {
      selectedVerbSummary.value = summary.copyWith(
        isSaved: savedVerbIds.contains(summary.id),
      );
    }
  }

  void _replaceSavedState(
    RxList<ImportantVerbSummaryModel> target, {
    bool removeUnsaved = false,
  }) {
    final List<ImportantVerbSummaryModel> updated = target
        .where(
          (ImportantVerbSummaryModel item) =>
              !removeUnsaved || savedVerbIds.contains(item.id),
        )
        .map(
          (ImportantVerbSummaryModel item) =>
              item.copyWith(isSaved: savedVerbIds.contains(item.id)),
        )
        .toList(growable: false);
    target.assignAll(updated);
  }

  _VerbFilterQuery _filterFor(String label) {
    switch (label.trim().toLowerCase()) {
      case 'regular':
        return const _VerbFilterQuery(regularity: 'regular');

      case 'irregular':
        return const _VerbFilterQuery(regularity: 'irregular');

      case '-are':
        return const _VerbFilterQuery(endingType: '-are');

      case '-ere':
        return const _VerbFilterQuery(endingType: '-ere');

      case '-ire':
        return const _VerbFilterQuery(endingType: '-ire');

      default:
        return const _VerbFilterQuery();
    }
  }

  @override
  void onClose() {
    _importantSearchDebounce?.cancel();
    _savedSearchDebounce?.cancel();
    importantVerbSearchController.dispose();
    savedVerbSearchController.dispose();
    unawaited(_ttsService.stop());
    super.onClose();
  }
}

class _VerbFilterQuery {
  const _VerbFilterQuery({this.regularity, this.endingType});

  final String? regularity;
  final String? endingType;
}
