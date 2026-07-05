import 'package:get/get.dart';

import '../../features/ai_chat/controllers/ai_chat_controller.dart';
import '../../features/ai_chat/controllers/ai_tutor_level_test_controller.dart';
import '../../features/ai_chat/services/ai_tutor_api_service.dart';
import '../../features/ai_chat/services/ai_tutor_preferences_service.dart';
import '../../features/ai_chat/services/ai_tutor_tts_service.dart';
import '../../features/ai_chat/services/ai_tutor_voice_service.dart';
import '../../features/courses/controllers/courses_controller.dart';
import '../../features/courses/services/courses_api_service.dart';
import '../../features/courses/services/courses_mock_service.dart';
import '../../features/cv_generation/controllers/cv_home_controller.dart';
import '../../features/cv_generation/services/cv_generation_api_service.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_api_service.dart';
import '../../features/drawer_features/settings/services/user_settings_service.dart';
import '../../features/drawer_features/shop/controllers/google_play_purchase_controller.dart';
import '../../features/drawer_features/shop/services/google_play_billing_service.dart';
import '../../features/drawer_features/shop/services/shop_api_service.dart';
import '../../features/home/services/home_mock_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/messages/controllers/messages_controller.dart';
import '../../features/messages/services/messages_service.dart';
import '../../features/messages/services/chat_socket_service.dart';
import '../../features/messages/sub-feature/call/controllers/message_call_controller.dart';
import '../../features/messages/sub-feature/call/models/message_call_models.dart';
import '../../features/messages/sub-feature/call/service/call_agora_service.dart';
import '../../features/messages/sub-feature/call/service/call_socket_service.dart';
import '../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../features/notifications/services/notifications_api_service.dart';

import '../../features/leaderboard/services/leaderboard_service.dart';
import '../../features/practice_hub/controllers/practice_hub_controller.dart';
import '../services/api_client.dart';
import '../controllers/user_session_controller.dart';
import '../services/learning_activity_api_service.dart';
import '../services/current_user_summary_service.dart';
import '../widgets/app_drawer_controller.dart';
import '../services/token_service.dart';
import '../services/storage_service.dart';
import '../../features/practice_hub/controllers/job_sentences_controller.dart';
import '../../features/practice_hub/controllers/important_verbs_controller.dart';
import '../../features/practice_hub/services/job_sentences_api_service.dart';
import '../../features/practice_hub/services/important_verbs_api_service.dart';
import '../../features/practice_hub/services/italian_tts_service.dart';
import '../../features/practice_hub/services/practice_hub_api_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CurrentUserSummaryService>()) {
      Get.lazyPut<CurrentUserSummaryService>(
        () => CurrentUserSummaryService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<UserSessionController>()) {
      Get.put<UserSessionController>(
        UserSessionController(
          currentUserSummaryService: Get.find<CurrentUserSummaryService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ShopApiService>()) {
      Get.put<ShopApiService>(
        ShopApiService(apiClient: Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<GooglePlayBillingService>()) {
      Get.put<GooglePlayBillingService>(
        GooglePlayBillingService(storageService: Get.find<StorageService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<GooglePlayPurchaseController>()) {
      Get.put<GooglePlayPurchaseController>(
        GooglePlayPurchaseController(
          apiService: Get.find<ShopApiService>(),
          billingService: Get.find<GooglePlayBillingService>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<AppDrawerController>(
      () => AppDrawerController(
        userSessionController: Get.find<UserSessionController>(),
        leaderboardService: Get.find<LeaderboardService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<UserSettingsService>(
      () => UserSettingsService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AiTutorApiService>(
      () => AiTutorApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AiTutorPreferencesService>(
      () => AiTutorPreferencesService(),
      fenix: true,
    );
    Get.lazyPut<AiTutorVoiceService>(() => AiTutorVoiceService(), fenix: true);
    Get.lazyPut<AiTutorTtsService>(() => AiTutorTtsService(), fenix: true);
    Get.lazyPut<AiChatController>(
      () => AiChatController(
        apiService: Get.find<AiTutorApiService>(),
        voiceService: Get.find<AiTutorVoiceService>(),
        ttsService: Get.find<AiTutorTtsService>(),
        preferencesService: Get.find<AiTutorPreferencesService>(),
        userSessionController: Get.find<UserSessionController>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AiTutorLevelTestController>(
      () => AiTutorLevelTestController(
        apiService: Get.find<AiTutorApiService>(),
        preferencesService: Get.find<AiTutorPreferencesService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CoursesApiService>(
      () => CoursesApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CoursesController>(
      () => CoursesController(coursesApiService: Get.find<CoursesApiService>()),
      fenix: true,
    );

    Get.lazyPut<HomeApiService>(
      () => HomeApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(homeApiService: Get.find<HomeApiService>()),
      fenix: true,
    );
    if (!Get.isRegistered<HomeMockService>()) {
      Get.lazyPut<HomeMockService>(HomeMockService.new);
    }

    if (!Get.isRegistered<CoursesMockService>()) {
      Get.lazyPut<CoursesMockService>(CoursesMockService.new, fenix: true);
    }

    if (!Get.isRegistered<CoursesController>()) {
      Get.lazyPut<CoursesController>(
        () =>
            CoursesController(coursesApiService: Get.find<CoursesApiService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ChatSocketService>()) {
      Get.lazyPut<ChatSocketService>(
        () => ChatSocketService(tokenService: Get.find<TokenService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CallSocketService>()) {
      Get.put<CallSocketService>(
        CallSocketService(tokenService: Get.find<TokenService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CallAgoraService>()) {
      Get.put<CallAgoraService>(CallAgoraService(), permanent: true);
    }

    if (!Get.isRegistered<IncomingCallCoordinator>()) {
      Get.put<IncomingCallCoordinator>(
        IncomingCallCoordinator(
          callSocketService: Get.find<CallSocketService>(),
          acceptedCallHandler:
              ({
                required String callId,
                required Map<String, dynamic> callData,
                required Map<String, dynamic> answerResponse,
              }) async {
                final MessageCallParticipantModel participant =
                    MessageCallParticipantModel(
                      id: callData['callerId']?.toString() ?? '',
                      name: callData['callerName']?.toString() ?? 'caller'.tr,
                      avatarUrl: callData['callerAvatarUrl']?.toString() ?? '',
                      isOnline: true,
                    );

                final MessageCallSessionModel session =
                    MessageCallSessionModel.fromAnswerResponse(
                      response: answerResponse,
                      callId: callId,
                      participant: participant,
                    );

                final MessageCallType callType = MessageCallType.fromValue(
                  callData['callType']?.toString(),
                );

                final String conversationId =
                    callData['conversationId']?.toString().trim().isNotEmpty ==
                        true
                    ? callData['conversationId'].toString()
                    : session.conversationId;

                if (Get.isRegistered<MessageCallController>()) {
                  await Get.delete<MessageCallController>(force: true);
                }

                final MessageCallController controller = MessageCallController(
                  conversationId: conversationId,
                  callType: callType,
                  participant: participant,
                  callSocketService: Get.find<CallSocketService>(),
                  callAgoraService: Get.find<CallAgoraService>(),
                  initialSession: session,
                );
                Get.put<MessageCallController>(controller, permanent: true);
                await controller.openCallScreen(
                  replaceCurrent:
                      callData['_replaceCurrentCallRoute'] == true,
                );
              },
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<MessagesMockService>()) {
      Get.lazyPut<MessagesMockService>(
        () => MessagesMockService(
          apiClient: Get.find<ApiClient>(),
          tokenService: Get.find<TokenService>(),
          chatSocketService: Get.find<ChatSocketService>(),
        ),
      );
    }

    if (!Get.isRegistered<MessagesController>()) {
      Get.lazyPut<MessagesController>(
        () => MessagesController(
          messagesMockService: Get.find<MessagesMockService>(),
        ),
      );
    }

    if (!Get.isRegistered<NotificationsApiService>()) {
      Get.lazyPut<NotificationsApiService>(
        () => NotificationsApiService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<LeaderboardService>()) {
      Get.lazyPut<LeaderboardService>(
        () => LeaderboardService(
          apiClient: Get.find<ApiClient>(),
          tokenService: Get.find<TokenService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<LeaderboardController>()) {
      Get.lazyPut<LeaderboardController>(
        () => LeaderboardController(
          leaderboardService: Get.find<LeaderboardService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PracticeHubController>()) {
      Get.lazyPut<PracticeHubController>(
        () => PracticeHubController(
          coursesApiService: Get.find<CoursesApiService>(),
          practiceHubApiService: Get.find<PracticeHubApiService>(),
        ),
      );
    }

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
    Get.lazyPut<ItalianTtsService>(() => ItalianTtsService(), fenix: true);
    Get.lazyPut<ImportantVerbsController>(
      () => ImportantVerbsController(
        apiService: Get.find<ImportantVerbsApiService>(),
        ttsService: Get.find<ItalianTtsService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AiTutorApiService>(
      () => AiTutorApiService(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AiTutorPreferencesService>(
      () => AiTutorPreferencesService(),
      fenix: true,
    );
    Get.lazyPut<AiTutorVoiceService>(() => AiTutorVoiceService(), fenix: true);
    Get.lazyPut<AiTutorTtsService>(() => AiTutorTtsService(), fenix: true);
    Get.lazyPut<AiChatController>(
      () => AiChatController(
        apiService: Get.find<AiTutorApiService>(),
        voiceService: Get.find<AiTutorVoiceService>(),
        ttsService: Get.find<AiTutorTtsService>(),
        preferencesService: Get.find<AiTutorPreferencesService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AiTutorLevelTestController>(
      () => AiTutorLevelTestController(
        apiService: Get.find<AiTutorApiService>(),
        preferencesService: Get.find<AiTutorPreferencesService>(),
      ),
      fenix: true,
    );

    if (!Get.isRegistered<CvGenerationApiService>()) {
      Get.lazyPut<CvGenerationApiService>(
            () => CvGenerationApiService(
          apiClient: Get.find<ApiClient>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CvHomeController>()) {
      Get.lazyPut<CvHomeController>(
            () => CvHomeController(
          apiService:
          Get.find<CvGenerationApiService>(),
        ),
        fenix: true,
      );
    }
  }
}
