import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/course_models.dart';
import '../services/courses_api_service.dart';

class CoursesController extends GetxController {
  final CoursesApiService _coursesApiService;

  CoursesController({required CoursesApiService coursesApiService})
    : _coursesApiService = coursesApiService;

  final RxBool isLoading = false.obs;
  final Rxn<CoursesDashboardModel> dashboard = Rxn<CoursesDashboardModel>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final ApiResult<CoursesDashboardModel> result =
          await ApiErrorHandler.call<CoursesDashboardModel>(
        () => _coursesApiService.fetchDashboard(),
        errorTitle: 'Courses',
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      dashboard.value = result.data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openCourse(CourseCardModel course) async {
    final String tag = 'course_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.courseDetail,
      arguments: CourseDetailRouteArguments(
        course: course,
        controllerTag: tag,
      ),
    );
  }
}
