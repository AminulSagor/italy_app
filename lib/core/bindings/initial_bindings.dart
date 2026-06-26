import 'package:get/get.dart';

import '../../features/ai_chat/controllers/ai_chat_controller.dart';
import '../../features/ai_chat/controllers/ai_tutor_level_test_controller.dart';
import '../../features/ai_chat/services/ai_tutor_api_service.dart';
import '../../features/ai_chat/services/ai_tutor_preferences_service.dart';
import '../../features/ai_chat/services/ai_tutor_tts_service.dart';
import '../../features/ai_chat/services/ai_tutor_voice_service.dart';
import '../../features/courses/controllers/courses_controller.dart';
import '../../features/courses/services/courses_api_service.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_mock_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/messages/controllers/messages_controller.dart';
import '../../features/messages/services/messages_service.dart';
import '../../features/messages/services/chat_socket_service.dart';
import '../../features/messages/services/messages_mock_service.dart';
import '../../features/messages/sub-feature/call/controllers/message_call_controller.dart';
import '../../features/messages/sub-feature/call/models/message_call_models.dart';
import '../../features/messages/sub-feature/call/service/call_agora_service.dart';
import '../../features/messages/sub-feature/call/service/call_socket_service.dart';
import '../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../features/messages/sub-feature/call/views/message_call_view.dart';
import '../../features/notifications/services/notifications_mock_service.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../features/leaderboard/services/leaderboard_service.dart';
import '../../features/practice_hub/controllers/practice_hub_controller.dart';
import '../services/api_client.dart';
import '../services/token_service.dart';
import '../../features/practice_hub/controllers/job_sentences_controller.dart';
import '../../features/practice_hub/controllers/important_verbs_controller.dart';
import '../../features/practice_hub/services/job_sentences_api_service.dart';
import '../../features/practice_hub/services/important_verbs_api_service.dart';
import '../../features/practice_hub/services/italian_tts_service.dart';
import '../../features/practice_hub/services/practice_hub_api_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeMockService>()) {
      Get.lazyPut<HomeMockService>(
        HomeMockService.new,
      );
    }

    if (!Get.isRegistered<CoursesMockService>()) {
      Get.lazyPut<CoursesMockService>(
        CoursesMockService.new,
        fenix: true,
      );
    }

    if (!Get.isRegistered<CoursesController>()) {
      Get.lazyPut<CoursesController>(
            () => CoursesController(
          coursesMockService: Get.find<CoursesMockService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
            () => HomeController(
          homeMockService: Get.find<HomeMockService>(),
        ),
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
      Get.put<CallAgoraService>(
        CallAgoraService(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<IncomingCallCoordinator>()) {
      Get.put<IncomingCallCoordinator>(
        IncomingCallCoordinator(
          callSocketService: Get.find<CallSocketService>(),
          acceptedCallHandler: ({
            required String callId,
            required Map<String, dynamic> callData,
            required Map<String, dynamic> answerResponse,
          }) async {
            final MessageCallParticipantModel participant =
            MessageCallParticipantModel(
              id: callData['callerId']?.toString() ?? '',
              name: callData['callerName']?.toString() ?? 'Caller',
              avatarUrl:
              callData['callerAvatarUrl']?.toString() ?? '',
              isOnline: true,
            );

            final MessageCallSessionModel session =
            MessageCallSessionModel.fromAnswerResponse(
              response: answerResponse,
              callId: callId,
              participant: participant,
            );

            final MessageCallType callType =
            MessageCallType.fromValue(
              callData['callType']?.toString(),
            );

            final String conversationId =
            callData['conversationId']?.toString().trim().isNotEmpty ==
                true
                ? callData['conversationId'].toString()
                : session.conversationId;

            if (Get.isRegistered<MessageCallController>()) {
              await Get.delete<MessageCallController>(
                force: true,
              );
            }

            await Get.to<void>(
                  () => const MessageCallView(),
              binding: BindingsBuilder(() {
                Get.put<MessageCallController>(
                  MessageCallController(
                    conversationId: conversationId,
                    callType: callType,
                    participant: participant,
                    callSocketService:
                    Get.find<CallSocketService>(),
                    callAgoraService:
                    Get.find<CallAgoraService>(),
                    initialSession: session,
                  ),
                );
              }),
              transition: Transition.rightToLeft,
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

    if (!Get.isRegistered<NotificationsMockService>()) {
      Get.lazyPut<NotificationsMockService>(
        NotificationsMockService.new,
      );
    }

    if (!Get.isRegistered<LeaderboardController>()) {
      Get.lazyPut<LeaderboardController>(
        LeaderboardController.new,
      );
    }

    if (!Get.isRegistered<PracticeHubController>()) {
      Get.lazyPut<PracticeHubController>(
        PracticeHubController.new,
        fenix: true,
      );
    }
  }
}
