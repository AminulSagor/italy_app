import 'package:get/get.dart';

import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../../models/course_models.dart';
import '../../quiz/controllers/quiz_controller.dart';
import '../../quiz/services/quiz_mock_service.dart';
import '../../vocabulary/controllers/vocabulary_controller.dart';
import '../../vocabulary/services/vocabulary_mock_service.dart';
import '../models/chapter_detail_models.dart';
import '../services/chapter_detail_mock_service.dart';

class ChapterDetailController extends GetxController {
  final CourseChapterModel chapter;
  final ChapterDetailMockService _chapterDetailMockService;

  ChapterDetailController({
    required this.chapter,
    required ChapterDetailMockService chapterDetailMockService,
  }) : _chapterDetailMockService = chapterDetailMockService;

  final RxBool isLoading = false.obs;
  final RxBool isResumeSubmitting = false.obs;
  final Rx<ChapterQuizStatus> quizStatus = ChapterQuizStatus.disabled.obs;
  final Rxn<ChapterDetailModel> detail = Rxn<ChapterDetailModel>();

  @override
  void onInit() {
    super.onInit();
    if (chapter.progress >= 0.8) {
      quizStatus.value = ChapterQuizStatus.enabled;
    }
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      detail.value = await _chapterDetailMockService.fetchChapterDetail(
        chapterId: chapter.id,
        chapterTitle: chapter.title,
        quizStatus: quizStatus.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resumeVideo() async {
    if (isResumeSubmitting.value) {
      return;
    }

    isResumeSubmitting.value = true;
    try {
      await _chapterDetailMockService.resumeVideoUntilQuizUnlocked();
      if (quizStatus.value == ChapterQuizStatus.disabled) {
        quizStatus.value = ChapterQuizStatus.enabled;
      }
      await loadDetail();
    } finally {
      isResumeSubmitting.value = false;
    }
  }

  Future<void> openQuiz() async {
    if (quizStatus.value == ChapterQuizStatus.disabled) {
      return;
    }

    final String tag = 'quiz_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    final Object? routeResult = await Get.toNamed(
      AppRoutes.quiz,
      arguments: ControllerTagRouteArguments(controllerTag: tag),
    );

    if (routeResult == true) {
      quizStatus.value = ChapterQuizStatus.completed;
      await loadDetail();
    }

    if (Get.isRegistered<QuizController>(tag: tag)) {
      Get.delete<QuizController>(tag: tag, force: true);
    }
    if (Get.isRegistered<QuizMockService>(tag: tag)) {
      Get.delete<QuizMockService>(tag: tag, force: true);
    }
  }

  Future<void> openVocabulary() async {
    final String tag = 'vocabulary_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.vocabulary,
      arguments: ControllerTagRouteArguments(controllerTag: tag),
    );

    if (Get.isRegistered<VocabularyController>(tag: tag)) {
      Get.delete<VocabularyController>(tag: tag, force: true);
    }
    if (Get.isRegistered<VocabularyMockService>(tag: tag)) {
      Get.delete<VocabularyMockService>(tag: tag, force: true);
    }
  }
}
