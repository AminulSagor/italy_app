import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';
import '../models/job_sentence_models.dart';
import '../models/job_track_models.dart';
import '../models/practice_hub_pdf_model.dart';
import '../services/job_sentences_api_service.dart';

class JobSentencesController extends GetxController {
  JobSentencesController({required JobSentencesApiService apiService})
    : _apiService = apiService;

  final JobSentencesApiService _apiService;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  final RxString currentAudioSentenceId = ''.obs;
  final RxBool isAudioLoading = false.obs;
  final RxBool isAudioPlaying = false.obs;
  final Rx<Duration> audioPosition = Duration.zero.obs;
  final Rx<Duration> audioDuration = Duration.zero.obs;

  Worker? _searchWorker;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  final Set<String> _reviewRequests = <String>{};
  int _lastReportedVideoPercent = 0;
  int _sentenceRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadModuleSentences(showError: false),
      time: const Duration(milliseconds: 450),
    );
    _listenToAudioPlayer();
    unawaited(loadCareerTracks(showError: false));
  }

  Future<void> loadCareerTracks({bool showError = true}) async {
    if (isTracksLoading.value) return;

    isTracksLoading.value = true;
    tracksError.value = '';
    try {
      final ApiResult<JobCareerTrackListResponseModel> result =
          await ApiErrorHandler.call<JobCareerTrackListResponseModel>(
            () => _apiService.fetchCareerTracks(),
            showError: showError,
          );
      if (!result.isSuccess || result.data == null) {
        tracksError.value = result.error ?? 'Unable to load career tracks.';
        return;
      }
      careerTracks.assignAll(result.data!.items);
    } finally {
      isTracksLoading.value = false;
    }
  }

  Future<void> refreshCareerTracks() => loadCareerTracks(showError: false);

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
    if (id.isEmpty || isTrackDetailsLoading.value) return;

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
            result.error ?? 'Unable to load career track details.';
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
    unawaited(_stopAudio());
    Get.toNamed<void>(AppRoutes.jobPhraseDetails);
    unawaited(loadModuleSentences(moduleId: module.id));
  }

  Future<void> loadModuleSentences({
    String? moduleId,
    bool showError = true,
  }) async {
    final String id = moduleId ?? selectedModule.value?.id ?? '';
    if (id.isEmpty) return;

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
      if (requestId != _sentenceRequestId) return;
      if (!result.isSuccess || result.data == null) {
        sentencesError.value = result.error ?? 'Unable to load sentences.';
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

  Future<void> toggleSentenceAudio(JobSentenceModel sentence) async {
    final JobMediaFileModel? media = sentence.aiVoice;
    if (media == null || !media.isAvailable || isAudioLoading.value) return;

    if (currentAudioSentenceId.value == sentence.id) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      return;
    }

    isAudioLoading.value = true;
    currentAudioSentenceId.value = sentence.id;
    audioPosition.value = Duration.zero;
    audioDuration.value = Duration(
      seconds: sentence.voiceDurationSeconds,
    );
    try {
      await _audioPlayer.stop();
      final Duration? loadedDuration = await _audioPlayer.setUrl(media.url);
      if (loadedDuration != null) audioDuration.value = loadedDuration;
      await _audioPlayer.play();
    } catch (error) {
      currentAudioSentenceId.value = '';
      Get.snackbar('Audio', ApiErrorHandler.getErrorMessage(error));
    } finally {
      isAudioLoading.value = false;
    }
  }

  Future<void> seekAudio(double milliseconds) async {
    if (currentAudioSentenceId.value.isEmpty) return;
    await _audioPlayer.seek(Duration(milliseconds: milliseconds.round()));
  }

  Future<void> openTheoryBook() async {
    final JobCareerTrackDetailsModel? details = trackDetails.value;
    final JobMediaFileModel? resource = details?.theoryResource;
    if (details == null || resource == null || !resource.isAvailable) {
      Get.snackbar('Theory Book', 'Theory resource is not available.');
      return;
    }

    unawaited(_markTheoryOpened(details.id));
    Get.toNamed<void>(
      AppRoutes.practiceHubPdfViewer,
      arguments: PracticeHubPdfDocumentModel(
        title: resource.originalName.isEmpty
            ? '${details.title} Theory Book'
            : resource.originalName,
        source: resource.url,
        sourceType: PracticeHubPdfSourceType.network,
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
    if (details == null) return;

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

  void onBackTap() => Get.back<void>();


  Future<void> onPhraseBackTap() async {
    await _stopAudio();
    Get.back<void>();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    currentAudioSentenceId.value = '';
    isAudioLoading.value = false;
    isAudioPlaying.value = false;
    audioPosition.value = Duration.zero;
    audioDuration.value = Duration.zero;
  }

  void _listenToAudioPlayer() {
    _positionSubscription = _audioPlayer.positionStream.listen((Duration value) {
      audioPosition.value = value;
    });
    _durationSubscription = _audioPlayer.durationStream.listen((Duration? value) {
      if (value != null) audioDuration.value = value;
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (PlayerState state) {
        isAudioPlaying.value =
            state.playing && state.processingState != ProcessingState.completed;
        if (state.processingState == ProcessingState.completed) {
          unawaited(_handleAudioCompleted());
        }
      },
    );
  }

  Future<void> _handleAudioCompleted() async {
    final String sentenceId = currentAudioSentenceId.value;
    if (sentenceId.isEmpty) return;

    audioPosition.value = audioDuration.value;
    await _audioPlayer.pause();
    await _audioPlayer.seek(Duration.zero);
    await _reviewSentence(sentenceId);
  }

  Future<bool> markSentenceLearnedWhenVisible(
    JobSentenceModel sentence,
  ) async {
    if (sentence.hasAudio || sentence.isLearned) {
      return sentence.isLearned;
    }
    return _reviewSentence(sentence.id);
  }

  Future<bool> _reviewSentence(String sentenceId) async {
    if (_reviewRequests.contains(sentenceId)) return false;
    _reviewRequests.add(sentenceId);
    try {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
        () => _apiService.reviewSentence(sentenceId: sentenceId),
        showError: false,
      );
      if (!result.isSuccess) return false;
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
    if (index < 0) return;

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

    if (wasLearned) return;
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
    if (module == null || details == null) return;

    final int moduleIndex = details.modules.indexWhere(
      (JobModuleModel item) => item.id == module.id,
    );
    if (moduleIndex < 0) return;

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
    final int updatedLearnedTotal =
        (details.progress.learnedSentences + 1)
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
    _searchWorker?.dispose();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    searchController.dispose();
    unawaited(_audioPlayer.dispose());
    super.onClose();
  }
}
