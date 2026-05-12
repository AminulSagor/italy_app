import 'package:get/get.dart';

import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/course_models.dart';
import '../services/courses_mock_service.dart';

class CourseDetailController extends GetxController {
  final String controllerTag;
  final CourseCardModel course;
  final CoursesMockService _coursesMockService;

  CourseDetailController({
    required this.controllerTag,
    required this.course,
    required CoursesMockService coursesMockService,
  }) : _coursesMockService = coursesMockService;

  final RxBool isLoading = false.obs;
  final RxBool isProSubmitting = false.obs;
  final RxBool isProEnabled = false.obs;
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
      detail.value = await _coursesMockService.fetchCourseDetail(
        courseId: course.id,
        isProEnabled: isProEnabled.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enablePro() async {
    if (isProSubmitting.value || isProEnabled.value) {
      return;
    }

    isProSubmitting.value = true;
    try {
      await _coursesMockService.enableProAccess();
      isProEnabled.value = true;
      await loadDetail();
    } finally {
      isProSubmitting.value = false;
    }
  }

  Future<void> openProOrderSummary() async {
    final String tag = 'pro_checkout_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.proOrderSummary,
      arguments: ProOrderSummaryRouteArguments(
        controllerTag: tag,
        courseDetailControllerTag: controllerTag,
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
  }
}
