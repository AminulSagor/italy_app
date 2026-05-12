import 'package:get/get.dart';

import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/course_models.dart';
import '../services/courses_mock_service.dart';

class CoursesController extends GetxController {
  final CoursesMockService _coursesMockService;

  CoursesController({required CoursesMockService coursesMockService})
    : _coursesMockService = coursesMockService;

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
      dashboard.value = await _coursesMockService.fetchDashboard();
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
