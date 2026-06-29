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
        errorTitle: 'Course Details',
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
    if (currentDetail == null || !currentDetail.finalExam.canStart) {
      return;
    }

    final String tag = 'final_exam_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: course.id,
      ),
    );
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
