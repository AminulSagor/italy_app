import 'package:get/get.dart';

import '../../features/ai_chat/controllers/ai_chat_controller.dart';
import '../../features/ai_chat/services/ai_tutor_api_service.dart';
import '../../features/ai_chat/services/ai_tutor_tts_service.dart';
import '../../features/ai_chat/services/ai_tutor_voice_service.dart';
import '../../features/courses/controllers/courses_controller.dart';
import '../../features/courses/services/courses_api_service.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_mock_service.dart';
import '../../features/messages/controllers/messages_controller.dart';
import '../../features/messages/services/messages_mock_service.dart';
import '../../features/messages/services/chat_socket_service.dart';
import '../services/api_client.dart';
import '../services/token_service.dart';
import '../../features/notifications/services/notifications_mock_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/practice_hub/controllers/job_sentences_controller.dart';
import '../../features/practice_hub/controllers/important_verbs_controller.dart';
import '../../features/practice_hub/controllers/practice_hub_controller.dart';
import '../../features/practice_hub/services/job_sentences_api_service.dart';
import '../../features/practice_hub/services/important_verbs_api_service.dart';
import '../../features/practice_hub/services/italian_tts_service.dart';
import '../../features/practice_hub/services/practice_hub_api_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiTutorApiService>(
      () => AiTutorApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AiTutorVoiceService>(
      () => AiTutorVoiceService(),
      fenix: true,
    );
    Get.lazyPut<AiTutorTtsService>(
      () => AiTutorTtsService(),
      fenix: true,
    );
    Get.lazyPut<AiChatController>(
      () => AiChatController(
        apiService: Get.find<AiTutorApiService>(),
        voiceService: Get.find<AiTutorVoiceService>(),
        ttsService: Get.find<AiTutorTtsService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<HomeMockService>(() => HomeMockService());
    Get.lazyPut<CoursesApiService>(
      () => CoursesApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CoursesController>(
      () =>
          CoursesController(coursesApiService: Get.find<CoursesApiService>()),
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
    Get.lazyPut<PracticeHubApiService>(
      () => PracticeHubApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<JobSentencesApiService>(
      () => JobSentencesApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<JobSentencesController>(
      () => JobSentencesController(
        apiService: Get.find<JobSentencesApiService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ImportantVerbsApiService>(
      () => ImportantVerbsApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ItalianTtsService>(
      () => ItalianTtsService(),
      fenix: true,
    );
    Get.lazyPut<ImportantVerbsController>(
      () => ImportantVerbsController(
        apiService: Get.find<ImportantVerbsApiService>(),
        ttsService: Get.find<ItalianTtsService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PracticeHubController>(
      () => PracticeHubController(
        coursesApiService: Get.find<CoursesApiService>(),
        practiceHubApiService: Get.find<PracticeHubApiService>(),
      ),
      fenix: true,
    );
  }
}
