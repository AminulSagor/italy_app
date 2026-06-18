import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../../models/course_models.dart';
import '../../quiz/controllers/quiz_controller.dart';
import '../../quiz/services/quiz_api_service.dart';
import '../../quiz/services/quiz_mock_service.dart';
import '../../vocabulary/controllers/vocabulary_controller.dart';
import '../../vocabulary/services/vocabulary_api_service.dart';
import '../../vocabulary/services/vocabulary_mock_service.dart';
import '../models/chapter_detail_models.dart';
import '../services/chapter_detail_api_service.dart';
import '../widgets/chapter_pdf_viewer.dart';

class ChapterDetailController extends GetxController {
  final CourseChapterModel chapter;
  final ChapterDetailApiService _chapterDetailApiService;

  ChapterDetailController({
    required this.chapter,
    required ChapterDetailApiService chapterDetailApiService,
  }) : _chapterDetailApiService = chapterDetailApiService;

  final RxBool isLoading = false.obs;
  final RxBool isResumeSubmitting = false.obs;
  final RxBool isAudioProgressRecorded = false.obs;
  final RxInt videoPlayCommand = 0.obs;
  final Rx<ChapterQuizStatus> quizStatus = ChapterQuizStatus.disabled.obs;
  final Rxn<ChapterDetailModel> detail = Rxn<ChapterDetailModel>();

  int _lastRecordedVideoPercent = 0;

  @override
  void onInit() {
    super.onInit();
    if (chapter.progress >= 0.8) {
      quizStatus.value = ChapterQuizStatus.enabled;
      _lastRecordedVideoPercent = 80;
    }
    loadDetail();
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
        errorTitle: 'Lesson Details',
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      detail.value = result.data;
      quizStatus.value = result.data!.quiz?.status ?? ChapterQuizStatus.disabled;
      _lastRecordedVideoPercent = result.data!.progress.videoWatchPercent;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resumeVideo() async {
    final ChapterDetailModel? current = detail.value;
    if (current == null || !current.hasVideo || isResumeSubmitting.value) {
      return;
    }

    isResumeSubmitting.value = true;
    videoPlayCommand.value++;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    isResumeSubmitting.value = false;
  }

  Future<void> recordVideoProgress({
    required Duration position,
    required Duration duration,
  }) async {
    final ChapterDetailModel? current = detail.value;
    if (current == null || duration.inSeconds <= 0) {
      return;
    }

    final int percent = ((position.inMilliseconds / duration.inMilliseconds) * 100)
        .floor()
        .clamp(0, 100)
        .toInt();

    if (percent < 5 || percent < _lastRecordedVideoPercent + 5) {
      return;
    }

    _lastRecordedVideoPercent = percent;
    _updateLocalVideoProgress(percent: percent, duration: duration);

    await ApiErrorHandler.call<Object?>(
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
      errorTitle: 'Video Progress',
    );
  }

  Future<void> recordAudioListened() async {
    if (isAudioProgressRecorded.value) {
      return;
    }

    final ChapterDetailModel? current = detail.value;
    final ChapterMediaModel? audio = current?.audio;
    if (current == null || audio == null) {
      return;
    }

    isAudioProgressRecorded.value = true;
    await ApiErrorHandler.call<Object?>(
      () async {
        await _chapterDetailApiService.recordAudioListened(
          courseId: current.courseId,
          lessonId: current.id,
          audioFileId: audio.fileId,
        );
        return null;
      },
      showError: false,
      errorTitle: 'Audio Progress',
    );
  }

  Future<void> openTheoryBook() async {
    final ChapterDetailModel? current = detail.value;
    final ChapterResourceModel? theoryBook = current?.theoryBook;

    if (current == null || theoryBook == null || !theoryBook.isAvailable) {
      Get.snackbar('Theory Book', 'Theory book not given for this lesson.');
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
      errorTitle: 'Theory Book',
    );

    Get.to<void>(
      () => ChapterPdfViewer(
        title: theoryBook.title,
        pdfUrl: theoryBook.fileUrl ?? '',
      ),
    );
  }

  Future<void> openQuiz() async {
    final ChapterDetailModel? current = detail.value;
    final ChapterQuizModel? quiz = current?.quiz;
    final ChapterQuizStatus status = quiz?.status ?? quizStatus.value;

    if (current == null || quiz == null || status == ChapterQuizStatus.disabled) {
      return;
    }

    final String tag = 'quiz_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

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
      await ApiErrorHandler.call<Object?>(
        () async {
          await _chapterDetailApiService.markLessonCompleted(
            courseId: current.courseId,
            lessonId: current.id,
          );
          return null;
        },
        showError: false,
        errorTitle: 'Lesson Progress',
      );
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
      Get.snackbar('Vocabulary', 'Vocabulary not given for this lesson.');
      return;
    }

    final String tag = 'vocabulary_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.vocabulary,
      arguments: VocabularyRouteArguments(
        controllerTag: tag,
        lessonId: current.id,
      ),
    );

    if (Get.isRegistered<VocabularyController>(tag: tag)) {
      Get.delete<VocabularyController>(tag: tag, force: true);
    }
    if (Get.isRegistered<VocabularyApiService>(tag: tag)) {
      Get.delete<VocabularyApiService>(tag: tag, force: true);
    }
    if (Get.isRegistered<VocabularyMockService>(tag: tag)) {
      Get.delete<VocabularyMockService>(tag: tag, force: true);
    }
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
            actionLabel: percent >= 80 ? 'Start Quiz →' : quiz.actionLabel,
          );

    if (percent >= 80 && quizStatus.value == ChapterQuizStatus.disabled) {
      quizStatus.value = ChapterQuizStatus.enabled;
    }

    detail.value = current.copyWith(
      videoProgress: (percent / 100).clamp(0.0, 1.0).toDouble(),
      videoProgressLabel: percent >= 80
          ? '$percent% Watched – Quiz Unlocked!'
          : '$percent% Watched – Keep Going!',
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
