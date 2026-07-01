import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../features/messages/services/chat_socket_service.dart';
import '../../features/messages/services/presence_service.dart';
import '../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../routes/routes.dart';
import '../controllers/user_session_controller.dart';
import '../localization/translation_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/current_user_summary_service.dart';
import '../services/device_push_token_service.dart';
import '../services/learning_activity_api_service.dart';
import '../services/learning_activity_tracker_service.dart';
import '../services/notification_summary_service.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';

class AppBootstrapController extends GetxController {
  AppBootstrapController();

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (error) {
      dev.log('Unable to load .env file', error: error, name: 'AppBootstrap');
    }

    await Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );

    if (!Get.isRegistered<TokenService>()) {
      Get.put<TokenService>(TokenService(), permanent: true);
    }

    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(
        ApiClient(
          tokenService: Get.find<TokenService>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(
          apiClient: Get.find<ApiClient>(),
          tokenService: Get.find<TokenService>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<DevicePushTokenService>()) {
      final DevicePushTokenService devicePushTokenService =
          DevicePushTokenService(
            apiClient: Get.find<ApiClient>(),
            storageService: Get.find<StorageService>(),
          );

      devicePushTokenService.listenForTokenRefresh();

      Get.put<DevicePushTokenService>(devicePushTokenService, permanent: true);
    }

    if (!Get.isRegistered<CurrentUserSummaryService>()) {
      Get.put<CurrentUserSummaryService>(
        CurrentUserSummaryService(apiClient: Get.find<ApiClient>()),
        permanent: true,
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

    if (!Get.isRegistered<LearningActivityApiService>()) {
      Get.put<LearningActivityApiService>(
        LearningActivityApiService(apiClient: Get.find<ApiClient>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LearningActivityTrackerService>()) {
      await Get.putAsync<LearningActivityTrackerService>(
        () => LearningActivityTrackerService(
          apiService: Get.find<LearningActivityApiService>(),
          storageService: Get.find<StorageService>(),
        ).init(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationSummaryService>()) {
      Get.put<NotificationSummaryService>(
        NotificationSummaryService(apiClient: Get.find<ApiClient>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<TranslationService>()) {
      Get.put<TranslationService>(
        TranslationService(storageService: Get.find<StorageService>()),
        permanent: true,
      );
    }

    // Ensure presence and socket services are registered early so we can
    // establish a single persistent socket connection when the user logs in.
    if (!Get.isRegistered<PresenceService>()) {
      Get.put<PresenceService>(PresenceService(), permanent: true);
    }
    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(
        ChatSocketService(tokenService: Get.find<TokenService>()),
        permanent: true,
      );
    }
    // Ensure presence listener is attached if both services are available
    // This avoids a short startup race where presence updates may arrive
    // before the PresenceService had a chance to register.
    try {
      if (Get.isRegistered<ChatSocketService>() &&
          Get.isRegistered<PresenceService>()) {
        Get.find<ChatSocketService>().addPresenceListener(
          Get.find<PresenceService>().updatePresenceFromSocket,
        );
      }
    } catch (_) {}
    // Network connections are deferred to _bootstrap so a terminated-app
    // CallKit accept can open the call screen before normal home loading.
  }

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final StorageService storageService = Get.find<StorageService>();
      final TokenService tokenService = Get.find<TokenService>();

      final bool hasValidLocalSession =
          storageService.isLoggedIn && await tokenService.hasToken();

      if (hasValidLocalSession) {
        if (Get.isRegistered<IncomingCallCoordinator>()) {
          // Handle a native accepted call before user/profile/home requests.
          // The accepted call route is awaited, so the bootstrap screen stays
          // as a touch blocker behind the call instead of flashing the home UI.
          await Get.find<IncomingCallCoordinator>()
              .restorePendingAcceptedCall();
        }

        // If there's a valid session, connect the global chat socket once
        try {
          final ChatSocketService socketSvc = Get.find<ChatSocketService>();
          String? deviceId;
          try {
            final PresenceService ps = Get.find<PresenceService>();
            // wait briefly for deviceId initialization (best-effort)
            for (int i = 0; i < 10 && ps.deviceId.isEmpty; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            }
            deviceId = ps.deviceId;
          } catch (_) {
            deviceId = null;
          }

          await socketSvc.connect(deviceId: deviceId);
        } catch (_) {}

        await _registerFcmTokenSafely();
        await Get.find<UserSessionController>().loadUser();
        await Get.find<LearningActivityTrackerService>().startSession();
        Get.offAllNamed(AppRoutes.wrapper);

        return;
      }

      await Get.find<LearningActivityTrackerService>().discardSession();

      if (storageService.isLoggedIn) {
        await storageService.clearLoggedInData();
        await tokenService.clearTokens();
      }

      if (storageService.isFirstTimeUser) {
        Get.offAllNamed(AppRoutes.splash);
        return;
      }

      Get.offAllNamed(AppRoutes.login);
    } catch (error, stackTrace) {
      dev.log(
        'Bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _registerFcmTokenSafely() async {
    try {
      if (!Get.isRegistered<DevicePushTokenService>()) {
        return;
      }

      await Get.find<DevicePushTokenService>().registerCurrentDevice();
    } catch (error, stackTrace) {
      dev.log(
        'FCM token registration during bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }
}
