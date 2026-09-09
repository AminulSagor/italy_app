import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../core/widgets/app_pdf_viewer.dart';
import '../../../routes/app_routes.dart';
import '../../courses/sub_features/chapter_detail/models/chapter_detail_models.dart';
import '../models/job_sentence_models.dart';
import '../models/job_track_models.dart';

import '../services/italian_tts_service.dart';
import '../services/job_sentences_api_service.dart';

class JobSentencesController extends GetxController {
  JobSentencesController({
    required JobSentencesApiService apiService,
    required ItalianTtsService ttsService,
  }) : _apiService = apiService,
       _ttsService = ttsService;

  final JobSentencesApiService _apiService;
  final ItalianTtsService _ttsService;

  final TextEditingController searchController = TextEditingController();

  final RxString searchQuery = ''.obs;

  final RxBool isTracksLoading = false.obs;
  final RxString tracksError = ''.obs;

  final RxList<JobCareerTrackModel> careerTracks = <JobCareerTrackModel>[].obs;

  final Rxn<JobCareerTrackModel> selectedTrack = Rxn<JobCareerTrackModel>();

  final Rxn<JobCareerTrackDetailsModel> trackDetails =
      Rxn<JobCareerTrackDetailsModel>();

  final RxBool isTrackDetailsLoading = false.obs;
  final RxString trackDetailsError = ''.obs;

  final Rxn<JobModuleModel> selectedModule = Rxn<JobModuleModel>();

  final Rxn<JobModuleSentenceSummaryModel> moduleSummary =
      Rxn<JobModuleSentenceSummaryModel>();

  final RxList<JobSentenceModel> sentences = <JobSentenceModel>[].obs;

  final RxBool isSentencesLoading = false.obs;
  final RxString sentencesError = ''.obs;

  // TTS states.
  final RxString currentTtsSentenceId = ''.obs;
  final RxBool isTtsSpeaking = false.obs;

  Future<ChapterVideoAccessModel?>? _videoAccessFuture;
  ChapterVideoAccessModel? _cachedVideoAccess;
  String _videoAccessTrackId = '';

  Worker? _searchWorker;

  final Set<String> _reviewRequests = <String>{};

  int _lastReportedVideoPercent = 0;
  int _sentenceRequestId = 0;
  int _ttsRequestId = 0;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadModuleSentences(showError: false),
      time: const Duration(milliseconds: 450),
    );

    unawaited(loadCareerTracks(showError: false));
  }

  Future<ChapterVideoAccessModel?> loadCareerTrackVideoAccess() {
    final String trackId =
        trackDetails.value?.id ?? selectedTrack.value?.id ?? '';

    if (trackId.isEmpty) {
      return Future<ChapterVideoAccessModel?>.value(null);
    }

    if (_videoAccessTrackId != trackId) {
      _videoAccessTrackId = trackId;
      _cachedVideoAccess = null;
      _videoAccessFuture = null;
    }

    final ChapterVideoAccessModel? cachedAccess = _cachedVideoAccess;

    if (cachedAccess != null &&
        cachedAccess.canPlay &&
        !cachedAccess.isExpiredOrNearExpiry) {
      return Future<ChapterVideoAccessModel?>.value(cachedAccess);
    }

    final Future<ChapterVideoAccessModel?>? activeFuture = _videoAccessFuture;

    if (activeFuture != null) {
      return activeFuture;
    }

    final Future<ChapterVideoAccessModel?> future =
        _requestCareerTrackVideoAccess(trackId);

    _videoAccessFuture = future;

    return future.whenComplete(() {
      if (identical(_videoAccessFuture, future)) {
        _videoAccessFuture = null;
      }
    });
  }

  Future<ChapterVideoAccessModel?> _requestCareerTrackVideoAccess(
    String trackId,
  ) async {
    final ApiResult<ChapterVideoAccessModel> result =
        await ApiErrorHandler.call<ChapterVideoAccessModel>(
          () => _apiService.fetchCareerTrackVideoAccess(trackId: trackId),
          showError: false,
          errorTitle: 'video'.tr,
        );

    final String currentTrackId =
        trackDetails.value?.id ?? selectedTrack.value?.id ?? '';

    if (currentTrackId != trackId) {
      return null;
    }

    final ChapterVideoAccessModel? access = result.data;

    if (!result.isSuccess || access == null) {
      _cachedVideoAccess = null;
      return null;
    }

    if (access.canPlay && !access.isExpiredOrNearExpiry) {
      _cachedVideoAccess = access;
    } else {
      _cachedVideoAccess = null;
    }

    return access;
  }

  Future<void> loadCareerTracks({bool showError = true}) async {
    if (isTracksLoading.value) {
      return;
    }

    isTracksLoading.value = true;
    tracksError.value = '';

    try {
      final ApiResult<JobCareerTrackListResponseModel> result =
          await ApiErrorHandler.call<JobCareerTrackListResponseModel>(
            () => _apiService.fetchCareerTracks(),
            showError: showError,
          );

      if (!result.isSuccess || result.data == null) {
        tracksError.value = result.error ?? 'unable_to_load_career_tracks'.tr;
        return;
      }

      careerTracks.assignAll(result.data!.items);
    } finally {
      isTracksLoading.value = false;
    }
  }

  Future<void> refreshCareerTracks() {
    return loadCareerTracks(showError: false);
  }

  void prepareCareerTrack(JobCareerTrackModel track) {
    selectedTrack.value = track;
    trackDetails.value = null;
    trackDetailsError.value = '';
    _lastReportedVideoPercent = 0;

    unawaited(loadCareerTrackDetails(trackId: track.id, showError: false));
  }

  void openCareerTrack(JobCareerTrackModel track) {
    selectedTrack.value = track;
    trackDetails.value = null;
    trackDetailsError.value = '';
    _lastReportedVideoPercent = 0;

    Get.toNamed<void>(AppRoutes.jobDetails);

    unawaited(loadCareerTrackDetails(trackId: track.id));
  }

  Future<void> loadCareerTrackDetails({
    String? trackId,
    bool showError = true,
  }) async {
    final String id = trackId ?? selectedTrack.value?.id ?? '';

    if (id.isEmpty || isTrackDetailsLoading.value) {
      return;
    }

    isTrackDetailsLoading.value = true;
    trackDetailsError.value = '';

    try {
      final ApiResult<JobCareerTrackDetailsModel> result =
          await ApiErrorHandler.call<JobCareerTrackDetailsModel>(
            () => _apiService.fetchCareerTrackDetails(trackId: id),
            showError: showError,
          );

      if (!result.isSuccess || result.data == null) {
        trackDetailsError.value =
            result.error ?? 'unable_to_load_career_track_details'.tr;
        return;
      }

      trackDetails.value = result.data;

      _lastReportedVideoPercent = result.data!.trackProgress.videoWatchPercent;
    } finally {
      isTrackDetailsLoading.value = false;
    }
  }

  void openModule(JobModuleModel module) {
    selectedModule.value = module;
    moduleSummary.value = null;
    sentences.clear();
    sentencesError.value = '';

    clearSearch();

    unawaited(_stopTts());

    Get.toNamed<void>(AppRoutes.jobPhraseDetails);

    unawaited(loadModuleSentences(moduleId: module.id));
  }

  Future<void> loadModuleSentences({
    String? moduleId,
    bool showError = true,
  }) async {
    final String id = moduleId ?? selectedModule.value?.id ?? '';

    if (id.isEmpty) {
      return;
    }

    final int requestId = ++_sentenceRequestId;

    isSentencesLoading.value = true;
    sentencesError.value = '';

    try {
      final ApiResult<JobModuleSentencesResponseModel> result =
          await ApiErrorHandler.call<JobModuleSentencesResponseModel>(
            () => _apiService.fetchModuleSentences(
              moduleId: id,
              search: searchQuery.value,
            ),
            showError: showError,
          );

      if (requestId != _sentenceRequestId) {
        return;
      }

      if (!result.isSuccess || result.data == null) {
        sentencesError.value = result.error ?? 'unable_to_load_sentences'.tr;
        return;
      }

      moduleSummary.value = result.data!.module;

      sentences.assignAll(result.data!.items);
    } finally {
      if (requestId == _sentenceRequestId) {
        isSentencesLoading.value = false;
      }
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> toggleSentenceTts(JobSentenceModel sentence) async {
    final String text = sentence.italianSentence.trim();

    if (text.isEmpty) {
      return;
    }

    final bool isCurrentSentence = currentTtsSentenceId.value == sentence.id;

    if (isCurrentSentence && isTtsSpeaking.value) {
      await _stopTts();
      return;
    }

    // Stop any previously speaking sentence.
    await _stopTts();

    final int requestId = ++_ttsRequestId;

    currentTtsSentenceId.value = sentence.id;

    isTtsSpeaking.value = true;

    try {
      final bool started = await _ttsService.speakText(text, locale: 'it-IT');

      if (!started) {
        Get.snackbar(
          'pronunciation_unavailable'.tr,
          'Install or enable an Italian voice on this device and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Speech was stopped or replaced.
      if (requestId != _ttsRequestId) {
        return;
      }

      // Mark the sentence completed only
      // after TTS has finished speaking.
      if (!sentence.isLearned) {
        await _reviewSentence(sentence.id);
      }
    } finally {
      if (requestId == _ttsRequestId) {
        currentTtsSentenceId.value = '';
        isTtsSpeaking.value = false;
      }
    }
  }

  Future<void> _stopTts() async {
    // Invalidates any active TTS request.
    _ttsRequestId++;

    await _ttsService.stop();

    currentTtsSentenceId.value = '';
    isTtsSpeaking.value = false;
  }

  Future<void> openTheoryBook() async {
    final JobCareerTrackDetailsModel? details = trackDetails.value;

    final JobMediaFileModel? resource = details?.theoryResource;

    if (details == null || resource == null || !resource.isAvailable) {
      Get.snackbar('gen_theory_book'.tr, 'theory_resource_is_not_available'.tr);
      return;
    }

    unawaited(_markTheoryOpened(details.id));

    Get.to<void>(
      () => AppPdfViewer(
        title: resource.originalName.isEmpty
            ? '${details.title} '
                  '${'gen_theory_book'.tr}'
            : resource.originalName,
        source: resource.url,
        sourceType: AppPdfSourceType.network,
        sourceId: 'job_sentences_theory_pdf_viewer',
        initialPageCount: resource.pageCount,
      ),
    );
  }

  Future<void> _markTheoryOpened(String trackId) async {
    await ApiErrorHandler.call<void>(
      () => _apiService.markTheoryOpened(trackId: trackId),
      showError: false,
    );
  }

  Future<void> recordVideoProgress({
    required int watchedPercent,
    required int timeSpentSeconds,
  }) async {
    final JobCareerTrackDetailsModel? details = trackDetails.value;

    if (details == null) {
      return;
    }

    final int normalizedPercent = watchedPercent.clamp(0, 100).toInt();

    final bool importantMilestone =
        normalizedPercent >= 80 && _lastReportedVideoPercent < 80;

    if (!importantMilestone &&
        normalizedPercent < _lastReportedVideoPercent + 10 &&
        normalizedPercent < 100) {
      return;
    }

    _lastReportedVideoPercent = normalizedPercent;

    await ApiErrorHandler.call<void>(
      () => _apiService.recordVideoProgress(
        trackId: details.id,
        watchedPercent: normalizedPercent,
        timeSpentSeconds: timeSpentSeconds,
      ),
      showError: false,
    );
  }

  void onBackTap() {
    Get.back<void>();
  }

  Future<void> onPhraseBackTap() async {
    await _stopTts();
    Get.back<void>();
  }

  // Kept temporarily because the current view
  // still calls this method.
  //
  // It no longer marks a sentence completed
  // simply because it became visible.
  Future<bool> markSentenceLearnedWhenVisible(JobSentenceModel sentence) async {
    return sentence.isLearned;
  }

  Future<bool> _reviewSentence(String sentenceId) async {
    if (_reviewRequests.contains(sentenceId)) {
      return false;
    }

    _reviewRequests.add(sentenceId);

    try {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
        () => _apiService.reviewSentence(sentenceId: sentenceId),
        showError: false,
      );

      if (!result.isSuccess) {
        return false;
      }

      _markSentenceLearnedLocally(sentenceId);

      return true;
    } finally {
      _reviewRequests.remove(sentenceId);
    }
  }

  void _markSentenceLearnedLocally(String sentenceId) {
    final int index = sentences.indexWhere(
      (JobSentenceModel item) => item.id == sentenceId,
    );

    if (index < 0) {
      return;
    }

    final JobSentenceModel current = sentences[index];

    final bool wasLearned = current.isLearned;

    final JobSentenceProgressModel oldProgress =
        current.progress ??
        const JobSentenceProgressModel(reviewCount: 0, isLearned: false);

    final DateTime now = DateTime.now();

    sentences[index] = current.copyWith(
      progress: oldProgress.copyWith(
        reviewCount: oldProgress.reviewCount + 1,
        isLearned: true,
        learnedAt: oldProgress.learnedAt ?? now,
        lastReviewedAt: now,
      ),
    );

    sentences.refresh();

    if (wasLearned) {
      return;
    }

    final JobModuleSentenceSummaryModel? summary = moduleSummary.value;

    if (summary != null) {
      moduleSummary.value = summary.copyWith(
        learnedSentences: (summary.learnedSentences + 1)
            .clamp(0, summary.totalSentences)
            .toInt(),
      );
    }

    _updateSelectedModuleProgress();
  }

  void _updateSelectedModuleProgress() {
    final JobModuleModel? module = selectedModule.value;

    final JobCareerTrackDetailsModel? details = trackDetails.value;

    if (module == null || details == null) {
      return;
    }

    final int moduleIndex = details.modules.indexWhere(
      (JobModuleModel item) => item.id == module.id,
    );

    if (moduleIndex < 0) {
      return;
    }

    final List<JobModuleModel> updatedModules = List<JobModuleModel>.from(
      details.modules,
    );

    final JobModuleModel currentModule = updatedModules[moduleIndex];

    final JobModuleModel updatedModule = currentModule.copyWith(
      learnedSentenceCount: (currentModule.learnedSentenceCount + 1)
          .clamp(0, currentModule.sentenceCount)
          .toInt(),
    );

    updatedModules[moduleIndex] = updatedModule;

    selectedModule.value = updatedModule;

    final int updatedLearnedTotal = (details.progress.learnedSentences + 1)
        .clamp(0, details.progress.totalSentences)
        .toInt();

    trackDetails.value = details.copyWith(
      modules: updatedModules,
      progress: details.progress.copyWith(
        learnedSentences: updatedLearnedTotal,
        completionPercent: details.progress.totalSentences == 0
            ? 0
            : ((updatedLearnedTotal / details.progress.totalSentences) * 100)
                  .round()
                  .clamp(0, 100)
                  .toInt(),
      ),
    );

    final int trackIndex = careerTracks.indexWhere(
      (JobCareerTrackModel item) => item.id == details.id,
    );

    if (trackIndex >= 0) {
      final JobCareerTrackModel currentTrack = careerTracks[trackIndex];

      careerTracks[trackIndex] = currentTrack.copyWith(
        learnedSentenceCount: (currentTrack.learnedSentenceCount + 1)
            .clamp(0, currentTrack.sentenceCount)
            .toInt(),
      );

      careerTracks.refresh();
    }
  }

  @override
  void onClose() {
    _ttsRequestId++;

    _searchWorker?.dispose();
    searchController.dispose();

    // Do not dispose the shared service.
    unawaited(_ttsService.stop());

    super.onClose();
  }
}
