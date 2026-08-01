import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/widgets/app_pdf_viewer.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../../models/course_models.dart';
import '../../quiz/controllers/quiz_controller.dart';
import '../../quiz/services/quiz_api_service.dart';
import '../../quiz/services/quiz_mock_service.dart';
import '../../vocabulary/controllers/vocabulary_controller.dart';
import '../../vocabulary/services/vocabulary_api_service.dart';
import '../models/chapter_detail_models.dart';
import '../services/chapter_detail_api_service.dart';


class ChapterDetailController extends GetxController {
  final CourseChapterModel chapter;
  final ChapterDetailApiService _chapterDetailApiService;

  ChapterDetailController({
    required this.chapter,
    required ChapterDetailApiService chapterDetailApiService,
  }) : _chapterDetailApiService = chapterDetailApiService;

  final RxBool isLoading = false.obs;
  final ScrollController scrollController = ScrollController();
  final RxBool isResumeSubmitting = false.obs;
  final RxBool isAudioProgressRecorded = false.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool shouldPlayVideo = false.obs;
  final RxInt videoPlaybackCommand = 0.obs;
  final Rx<ChapterQuizStatus> quizStatus = ChapterQuizStatus.disabled.obs;
  final Rxn<ChapterDetailModel> detail = Rxn<ChapterDetailModel>();

  int _lastRecordedVideoPercent = 0;
  bool _isLessonCompletionSubmitted = false;
  Future<ChapterVideoAccessModel?>? _videoAccessFuture;
  ChapterVideoAccessModel? _cachedVideoAccess;
  Future<String?>? _audioUrlFuture;
  Future<ChapterMediaModel?>? _pdfMediaFuture;
  Future<int>? _pdfPageCountFuture;

  @override
  void onInit() {
    super.onInit();
    if (chapter.progress >= 0.8) {
      quizStatus.value = ChapterQuizStatus.enabled;
      _lastRecordedVideoPercent = 80;
    }
    loadDetail();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> refreshChapter() async {
    _videoAccessFuture = null;
    _cachedVideoAccess = null;
    _audioUrlFuture = null;
    _pdfMediaFuture = null;
    _pdfPageCountFuture = null;

    await loadDetail();
  }

  Future<void> loadDetail() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final ApiResult<ChapterDetailModel> result =
          await ApiErrorHandler.call<ChapterDetailModel>(
            () => _chapterDetailApiService.fetchChapterDetail(
              lessonId: chapter.id,
              fallbackCourseId: chapter.courseId,
              fallbackTitle: chapter.title,
              initialVideoProgress: chapter.progress,
            ),
            errorTitle: 'lesson_details'.tr,
          );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      detail.value = result.data;
      quizStatus.value =
          result.data!.quiz?.status ?? ChapterQuizStatus.disabled;
      _preloadChapterResources();
      _lastRecordedVideoPercent = result.data!.progress.videoWatchPercent;
      _isLessonCompletionSubmitted = result.data!.progress.isCompleted;

      if (result.data!.isQuizAvailabilityKnown &&
          result.data!.quiz == null &&
          result.data!.hasVideo &&
          result.data!.progress.videoWatchPercent >= 100) {
        await _markLessonCompletedIfNeeded();
      } else if (result.data!.isQuizAvailabilityKnown &&
          result.data!.quiz == null &&
          !result.data!.hasVideo &&
          !result.data!.hasAudio) {
        await _markLessonCompletedIfNeeded();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<ChapterVideoAccessModel?> loadVideoAccess() {
    final ChapterVideoAccessModel? cachedAccess = _cachedVideoAccess;

    if (cachedAccess != null &&
        cachedAccess.canPlay &&
        !cachedAccess.isExpiredOrNearExpiry) {
      return Future<ChapterVideoAccessModel?>.value(cachedAccess);
    }

    final Future<ChapterVideoAccessModel?>? activeFuture =
        _videoAccessFuture;

    if (activeFuture != null) {
      return activeFuture;
    }

    final Future<ChapterVideoAccessModel?> future =
    _requestVideoAccess();

    _videoAccessFuture = future;

    return future.whenComplete(() {
      if (identical(_videoAccessFuture, future)) {
        _videoAccessFuture = null;
      }
    });
  }

  Future<ChapterVideoAccessModel?> _requestVideoAccess() async {
    final ChapterDetailModel? current = detail.value;

    if (current == null || !current.hasVideo) {
      return null;
    }

    final ApiResult<ChapterVideoAccessModel> result =
    await ApiErrorHandler.call<ChapterVideoAccessModel>(
          () => _chapterDetailApiService.fetchVideoAccess(
        lessonId: current.id,
      ),
      showError: false,
      errorTitle: 'video'.tr,
    );

    final ChapterVideoAccessModel? access = result.data;

    if (!result.isSuccess || access == null) {
      _cachedVideoAccess = null;
      return null;
    }

    if (access.canPlay && !access.isExpiredOrNearExpiry) {
      _cachedVideoAccess = access;
    } else {
      // Do not cache pending, processing, failed, or invalid access.
      // The next retry will check the backend again.
      _cachedVideoAccess = null;
    }

    return access;
  }

  Future<String?> loadAudioUrl() {
    final Future<String?>? cachedFuture = _audioUrlFuture;
    if (cachedFuture != null) {
      return cachedFuture;
    }

    final Future<String?> future = _loadMediaUrl(
      media: detail.value?.audio,
      type: ChapterMediaType.audio,
      errorTitle: 'audio'.tr,
    );
    _audioUrlFuture = future;
    return future.then((String? url) {
      if (url == null || url.isEmpty) {
        _audioUrlFuture = null;
      }
      return url;
    });
  }

  Future<String?> _loadMediaUrl({
    required ChapterMediaModel? media,
    required ChapterMediaType type,
    required String errorTitle,
  }) async {
    if (media == null || media.fileId.isEmpty) {
      return null;
    }
    if (media.url.isNotEmpty) {
      return media.url;
    }

    final ApiResult<ChapterMediaModel?> result =
        await ApiErrorHandler.call<ChapterMediaModel?>(
          () => _chapterDetailApiService.fetchMedia(
            fileId: media.fileId,
            type: type,
          ),
          showError: false,
          errorTitle: errorTitle,
        );

    return result.isSuccess ? result.data?.url : null;
  }

  void _preloadChapterResources() {
    final ChapterDetailModel? current = detail.value;
    if (current == null) {
      return;
    }

    if (current.hasVideo) {
      unawaited(loadVideoAccess());
    }
    if (current.hasAudio) {
      unawaited(loadAudioUrl());
    }
    if (current.theoryBook.isAvailable) {
      unawaited(_preloadTheoryBookDetails());
    }
  }

  Future<ChapterMediaModel?> _loadPdfMedia() {
    final Future<ChapterMediaModel?>? cachedFuture = _pdfMediaFuture;
    if (cachedFuture != null) {
      return cachedFuture;
    }

    final String fileId = detail.value?.theoryBook.fileId ?? '';
    if (fileId.isEmpty) {
      return Future<ChapterMediaModel?>.value(null);
    }

    final Future<ChapterMediaModel?> future = _chapterDetailApiService
        .fetchMedia(fileId: fileId, type: ChapterMediaType.pdf);
    _pdfMediaFuture = future;
    return future.then((ChapterMediaModel? media) {
      if (media == null || media.url.isEmpty) {
        _pdfMediaFuture = null;
      }
      return media;
    });
  }

  Future<void> _preloadTheoryBookDetails() async {
    final ChapterDetailModel? current = detail.value;
    final ChapterResourceModel? theoryBook = current?.theoryBook;
    if (current == null ||
        theoryBook == null ||
        !theoryBook.isAvailable ||
        theoryBook.fileId?.isNotEmpty != true) {
      return;
    }

    final ChapterMediaModel? media = await _loadPdfMedia();
    final ChapterDetailModel? afterMedia = detail.value;
    if (media == null ||
        afterMedia == null ||
        afterMedia.id != current.id ||
        afterMedia.theoryBook.fileId != theoryBook.fileId) {
      if (afterMedia != null && afterMedia.id == current.id) {
        detail.value = afterMedia.copyWith(
          theoryBook: afterMedia.theoryBook.copyWith(
            subtitle: 'gen_pages_unavailable'.tr,
          ),
        );
      }
      return;
    }

    detail.value = afterMedia.copyWith(
      theoryBook: afterMedia.theoryBook.copyWith(
        fileUrl: media.url,
        subtitle: 'loading'.tr,
      ),
    );

    final Future<int> pageCountFuture = _pdfPageCountFuture ??=
        _chapterDetailApiService.fetchPdfPageCount(pdfUrl: media.url);
    final int pageCount = await pageCountFuture;

    final ChapterDetailModel? latest = detail.value;
    if (latest == null ||
        latest.id != current.id ||
        latest.theoryBook.fileId != theoryBook.fileId) {
      return;
    }

    detail.value = latest.copyWith(
      theoryBook: latest.theoryBook.copyWith(
        fileUrl: media.url,
        count: pageCount,
        subtitle: pageCount > 0
            ? '$pageCount ${pageCount == 1 ? 'page'.tr : 'pages'.tr}'
            : 'gen_pages_unavailable'.tr,
      ),
    );
  }

  Future<void> toggleVideoPlayback() async {
    final ChapterDetailModel? current = detail.value;
    if (current == null || !current.hasVideo || isResumeSubmitting.value) {
      return;
    }

    if (isVideoPlaying.value) {
      shouldPlayVideo.value = false;
      videoPlaybackCommand.value++;
      return;
    }

    isResumeSubmitting.value = true;
    try {
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
      shouldPlayVideo.value = true;
      videoPlaybackCommand.value++;
    } finally {
      isResumeSubmitting.value = false;
    }
  }

  void onVideoPlaybackChanged(bool isPlaying) {
    isVideoPlaying.value = isPlaying;
  }

  Future<void> recordVideoProgress({
    required Duration position,
    required Duration duration,
  }) async {
    final ChapterDetailModel? current = detail.value;
    if (current == null || duration.inSeconds <= 0) {
      return;
    }

    final int percent =
        ((position.inMilliseconds / duration.inMilliseconds) * 100)
            .floor()
            .clamp(0, 100)
            .toInt();

    final bool reachedQuizThreshold =
        _lastRecordedVideoPercent < 80 && percent >= 80;
    if (percent < 5 ||
        percent <= _lastRecordedVideoPercent ||
        (!reachedQuizThreshold &&
            percent < 100 &&
            percent < _lastRecordedVideoPercent + 5)) {
      return;
    }

    _lastRecordedVideoPercent = percent;
    _updateLocalVideoProgress(percent: percent, duration: duration);

    final ApiResult<Object?> result = await ApiErrorHandler.call<Object?>(
      () async {
        await _chapterDetailApiService.recordVideoProgress(
          courseId: current.courseId,
          lessonId: current.id,
          watchedPercent: percent,
          timeSpentSeconds: position.inSeconds,
        );
        return null;
      },
      showError: false,
      errorTitle: 'video_progress'.tr,
    );

    if (result.isSuccess &&
        percent >= 100 &&
        current.isQuizAvailabilityKnown &&
        current.quiz == null) {
      await _markLessonCompletedIfNeeded();
    }
  }

  Future<void> recordAudioCompleted() async {
    if (isAudioProgressRecorded.value) {
      return;
    }

    final ChapterDetailModel? current = detail.value;
    final ChapterMediaModel? audio = current?.audio;
    if (current == null || audio == null) {
      return;
    }

    isAudioProgressRecorded.value = true;
    final ApiResult<Object?> result = await ApiErrorHandler.call<Object?>(
      () async {
        await _chapterDetailApiService.recordAudioListened(
          courseId: current.courseId,
          lessonId: current.id,
          audioFileId: audio.fileId,
        );
        return null;
      },
      showError: false,
      errorTitle: 'audio_progress'.tr,
    );

    if (!result.isSuccess) {
      isAudioProgressRecorded.value = false;
      return;
    }

    if (current.isQuizAvailabilityKnown &&
        current.quiz == null &&
        !current.hasVideo) {
      await _markLessonCompletedIfNeeded();
    }
  }

  Future<void> openTheoryBook() async {
    final ChapterDetailModel? current = detail.value;
    final ChapterResourceModel? theoryBook = current?.theoryBook;

    if (current == null || theoryBook == null || !theoryBook.isAvailable) {
      Get.snackbar(
        'gen_theory_book'.tr,
        'theory_book_not_given_for_this_lesson'.tr,
      );
      return;
    }

    String pdfUrl = theoryBook.fileUrl ?? '';
    if (pdfUrl.isEmpty && theoryBook.fileId?.isNotEmpty == true) {
      final ChapterMediaModel? media = await _loadPdfMedia();
      pdfUrl = media?.url ?? '';
    }

    if (pdfUrl.isEmpty) {
      Get.snackbar('gen_theory_book'.tr, 'theory_book_could_not_be_loaded'.tr);
      return;
    }

    await ApiErrorHandler.call<Object?>(
      () async {
        await _chapterDetailApiService.markTheoryRead(
          courseId: current.courseId,
          lessonId: current.id,
        );
        return null;
      },
      showError: false,
      errorTitle: 'gen_theory_book'.tr,
    );

    Get.to<void>(
          () => AppPdfViewer(
        title: theoryBook.title,
        source: pdfUrl,
        sourceType:
        AppPdfSourceType.network,
        sourceId:
        'chapter_theory_pdf_viewer',
      ),
    );
  }

  Future<void> openQuiz() async {
    final ChapterDetailModel? current = detail.value;
    final ChapterQuizModel? quiz = current?.quiz;
    final ChapterQuizStatus status = quiz?.status ?? quizStatus.value;

    if (current == null ||
        quiz == null ||
        status == ChapterQuizStatus.disabled) {
      return;
    }

    final String tag =
        'quiz_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    final Object? routeResult = await Get.toNamed(
      AppRoutes.quiz,
      arguments: QuizRouteArguments(
        controllerTag: tag,
        lessonId: current.id,
        courseId: current.courseId,
        chapterTitle: current.title,
        questionCount: quiz.totalQuestions > 0 ? quiz.totalQuestions : 15,
      ),
    );

    if (routeResult == true) {
      quizStatus.value = ChapterQuizStatus.completed;
      await _markLessonCompletedIfNeeded();
      await loadDetail();
    }

    if (Get.isRegistered<QuizController>(tag: tag)) {
      Get.delete<QuizController>(tag: tag, force: true);
    }
    if (Get.isRegistered<QuizApiService>(tag: tag)) {
      Get.delete<QuizApiService>(tag: tag, force: true);
    }
    if (Get.isRegistered<QuizMockService>(tag: tag)) {
      Get.delete<QuizMockService>(tag: tag, force: true);
    }
  }

  Future<void> openVocabulary() async {
    final ChapterDetailModel? current = detail.value;

    if (current == null || !current.vocabulary.isAvailable) {
      Get.snackbar(
        'gen_vocabulary'.tr,
        'vocabulary_not_given_for_this_lesson'.tr,
      );
      return;
    }

    final String tag =
        'vocabulary_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.vocabulary,
      arguments: VocabularyRouteArguments(
        controllerTag: tag,
        lessonId: current.id,
      ),
    );

    if (Get.isRegistered<VocabularyController>(tag: tag)) {
      Get.delete<VocabularyController>(
        tag: tag,
        force: true,
      );
    }

    if (Get.isRegistered<VocabularyApiService>(tag: tag)) {
      Get.delete<VocabularyApiService>(
        tag: tag,
        force: true,
      );
    }
  }

  Future<void> _markLessonCompletedIfNeeded() async {
    final ChapterDetailModel? current = detail.value;
    if (current == null ||
        current.progress.isCompleted ||
        _isLessonCompletionSubmitted) {
      return;
    }

    _isLessonCompletionSubmitted = true;
    final ApiResult<Object?> result = await ApiErrorHandler.call<Object?>(
      () async {
        await _chapterDetailApiService.markLessonCompleted(
          courseId: current.courseId,
          lessonId: current.id,
        );
        return null;
      },
      showError: false,
      errorTitle: 'lesson_progress'.tr,
    );

    if (!result.isSuccess) {
      _isLessonCompletionSubmitted = false;
      return;
    }

    final ChapterDetailModel? latest = detail.value;
    if (latest == null) {
      return;
    }

    detail.value = latest.copyWith(
      progress: LessonProgressModel(
        videoWatchPercent: latest.progress.videoWatchPercent,
        isTheoryRead: latest.progress.isTheoryRead,
        isCompleted: true,
      ),
    );
  }

  void _updateLocalVideoProgress({
    required int percent,
    required Duration duration,
  }) {
    final ChapterDetailModel? current = detail.value;
    final ChapterQuizModel? quiz = current?.quiz;
    if (current == null) {
      return;
    }

    final ChapterQuizModel? updatedQuiz = quiz == null
        ? null
        : quiz.copyWith(
            status: percent >= 80 ? ChapterQuizStatus.enabled : quiz.status,
            actionLabel: percent >= 80 ? 'start_quiz'.tr : quiz.actionLabel,
          );

    if (percent >= 80 && quizStatus.value == ChapterQuizStatus.disabled) {
      quizStatus.value = ChapterQuizStatus.enabled;
    }

    detail.value = current.copyWith(
      videoProgress: (percent / 100).clamp(0.0, 1.0).toDouble(),
      videoProgressLabel: percent >= 80
          ? '$percent% ${'watched'.tr} – ${'quiz_unlocked'.tr}'
          : '$percent% ${'watched'.tr} – ${'keep_going_1'.tr}',
      watchedTimeLabel: _durationLabel(
        Duration(
          milliseconds: (duration.inMilliseconds * (percent / 100)).round(),
        ),
      ),
      totalTimeLabel: _durationLabel(duration),
      quiz: updatedQuiz,
      progress: LessonProgressModel(
        videoWatchPercent: percent,
        isTheoryRead: current.progress.isTheoryRead,
        isCompleted: current.progress.isCompleted,
      ),
    );
  }

  String _durationLabel(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = totalSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
