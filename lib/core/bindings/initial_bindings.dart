import 'package:get/get.dart';
import '../../features/courses/controllers/courses_controller.dart';
import '../../features/courses/services/courses_mock_service.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_mock_service.dart';
import '../../features/messages/controllers/messages_controller.dart';
import '../../features/messages/services/messages_mock_service.dart';
import '../../features/messages/services/chat_socket_service.dart';
import '../services/api_client.dart';
import '../services/token_service.dart';
import '../../features/notifications/services/notifications_mock_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/practice_hub/controllers/practice_hub_controller.dart';

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
      fenix: true,
    );
    if (!Get.isRegistered<ChatSocketService>()) {
      Get.lazyPut<ChatSocketService>(
        () => ChatSocketService(tokenService: Get.find<TokenService>()),
      );
    }

    Get.lazyPut<MessagesMockService>(
      () => MessagesMockService(
        apiClient: Get.find<ApiClient>(),
        tokenService: Get.find<TokenService>(),
        chatSocketService: Get.find<ChatSocketService>(),
      ),
    );
    Get.lazyPut<MessagesController>(
      () => MessagesController(
        messagesMockService: Get.find<MessagesMockService>(),
      ),
    );
    Get.lazyPut<NotificationsMockService>(() => NotificationsMockService());
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());
    Get.lazyPut<PracticeHubController>(
      () => PracticeHubController(),
      fenix: true,
    );
  }
}
