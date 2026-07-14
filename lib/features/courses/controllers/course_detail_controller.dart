import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/course_models.dart';
import '../services/courses_api_service.dart';

class CourseDetailController extends GetxController {
  final String controllerTag;
  final CourseCardModel course;
  final CoursesApiService _coursesApiService;

  CourseDetailController({
    required this.controllerTag,
    required this.course,
    required CoursesApiService coursesApiService,
  }) : _coursesApiService = coursesApiService;

  final RxBool isLoading = false.obs;
  final RxBool isProSubmitting = false.obs;
  final Rxn<CourseDetailModel> detail = Rxn<CourseDetailModel>();

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final ApiResult<CourseDetailModel> result =
          await ApiErrorHandler.call<CourseDetailModel>(
        () => _coursesApiService.fetchCourseDetail(
          courseId: course.id,
        ),
        errorTitle: 'course_details'.tr,
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      detail.value = result.data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAfterPurchase() async {
    await loadDetail();
  }

  Future<void> openProOrderSummary() async {
    final String tag = 'pro_checkout_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.proOrderSummary,
      arguments: ProOrderSummaryRouteArguments(
        controllerTag: tag,
        courseDetailControllerTag: controllerTag,
        courseId: course.id,
        courseName: detail.value?.title ?? course.title,
        lessonCount: detail.value?.lessonCount ?? 0,
      ),
    );
  }

  Future<void> openFinalExam() async {
    final CourseDetailModel? currentDetail = detail.value;
    if (currentDetail == null) return;

    final CourseFinalExamModel finalExam = currentDetail.finalExam;

    // Result is available: open result page directly.
    if (finalExam.canViewResult) {
      final String attemptId = finalExam.attemptId.trim();

      if (attemptId.isEmpty) {
        Get.snackbar(
          'gen_final_exam_result'.tr,
          'Result attempt was not found.',
        );
        return;
      }

      final String tag =
          'final_exam_result_${attemptId}_'
          '${DateTime.now().millisecondsSinceEpoch}';

      await Get.toNamed(
        AppRoutes.finalExamResult,
        arguments: FinalExamResultRouteArguments(
          controllerTag: tag,
          courseId: course.id,
          attemptId: attemptId,
        ),
      );

      await loadDetail();
      return;
    }

    // Exam submitted, but teacher review is incomplete.
    if (finalExam.hasAttempted && !finalExam.resultReady) {
      Get.snackbar(
        'gen_final_exam_result'.tr,
        finalExam.helperLabel.isNotEmpty
            ? finalExam.helperLabel
            : 'Your final examination result is being processed.',
      );
      return;
    }

    // User cannot start the exam.
    if (!finalExam.canStart) {
      Get.snackbar(
        'gen_final_exam'.tr,
        finalExam.helperLabel,
      );
      return;
    }

    // User is eligible: open the exam overview.
    final String tag =
        'final_exam_${course.id}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: course.id,
      ),
    );

    await loadDetail();
  }

  Future<void> handleFinalExamTap() async {
    final CourseFinalExamModel? finalExam =
        detail.value?.finalExam;

    if (finalExam == null) return;

    // View Result
    if (finalExam.canViewResult) {
      await openFinalExam();
      return;
    }

    // Preserve existing certificate navigation
    if (finalExam.hasCertificate) {
      final String resolvedAttemptId =
      finalExam.attemptId.trim();

      if (resolvedAttemptId.isEmpty) {
        Get.snackbar(
          'Certificate unavailable',
          'Final exam attempt was not found.',
        );
        return;
      }

      final String tag =
          'course_certificate_'
          '${DateTime.now().millisecondsSinceEpoch}';

      await Get.toNamed(
        AppRoutes.courseCertificate,
        arguments: CourseCertificateRouteArguments(
          controllerTag: tag,
          attemptId: resolvedAttemptId,
        ),
      );
      return;
    }

    // Start Exam
    if (finalExam.canStart) {
      await openFinalExam();
    }
  }

  Future<void> openChapter(CourseChapterModel chapter) async {
    if (chapter.state == CourseChapterState.locked) {
      return;
    }

    final String tag = 'chapter_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.chapterDetail,
      arguments: ChapterDetailRouteArguments(
        chapter: chapter,
        controllerTag: tag,
      ),
    );

    await loadDetail();
  }
}
