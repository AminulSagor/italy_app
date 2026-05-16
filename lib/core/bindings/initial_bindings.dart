import 'package:get/get.dart';
import '../../features/courses/controllers/courses_controller.dart';
import '../../features/courses/services/courses_mock_service.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_mock_service.dart';
import '../../features/messages/controllers/messages_controller.dart';
import '../../features/messages/services/messages_mock_service.dart';
import '../../features/notifications/services/notifications_mock_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeMockService>(() => HomeMockService());
    Get.lazyPut<CoursesMockService>(() => CoursesMockService(), fenix: true);
    Get.lazyPut<CoursesController>(
      () =>
          CoursesController(coursesMockService: Get.find<CoursesMockService>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(homeMockService: Get.find<HomeMockService>()),
    );
    Get.lazyPut<MessagesMockService>(() => MessagesMockService());
    Get.lazyPut<MessagesController>(
      () => MessagesController(
        messagesMockService: Get.find<MessagesMockService>(),
      ),
    );
    Get.lazyPut<NotificationsMockService>(() => NotificationsMockService());
  }
}
