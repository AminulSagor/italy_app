import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../features/courses/sub_features/pro_checkout/services/course_google_play_billing_service.dart';
import '../../features/courses/sub_features/pro_checkout/services/pro_checkout_api_service.dart';
import '../../features/messages/services/chat_socket_service.dart';
import '../../features/messages/services/presence_service.dart';
import '../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../routes/routes.dart';
import '../controllers/user_session_controller.dart';
import '../localization/translation_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/course_purchase_recovery_service.dart';
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
      dev.log(
        'Unable to load .env file',
        error: error,
        name: 'AppBootstrap',
      );
    }

    await Get.putAsync<StorageService>(
          () => StorageService().init(),
      permanent: true,
    );

    if (!Get.isRegistered<TokenService>()) {
      Get.put<TokenService>(
        TokenService(),
        permanent: true,
      );
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

      Get.put<DevicePushTokenService>(
        devicePushTokenService,
        permanent: true,
      );
    }

    if (!Get.isRegistered<CurrentUserSummaryService>()) {
      Get.put<CurrentUserSummaryService>(
        CurrentUserSummaryService(
          apiClient: Get.find<ApiClient>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<UserSessionController>()) {
      Get.put<UserSessionController>(
        UserSessionController(
          currentUserSummaryService:
          Get.find<CurrentUserSummaryService>(),
        ),
        permanent: true,
      );
    }

    /*
     * Google Play course-purchase services must be global.
     *
     * They must not be created only when the checkout route is opened,
     * because a purchase may complete while the app is closed or while
     * another page is visible.
     */
    if (!Get.isRegistered<ProCheckoutApiService>()) {
      Get.put<ProCheckoutApiService>(
        ProCheckoutApiService(
          apiClient: Get.find<ApiClient>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CourseGooglePlayBillingService>()) {
      Get.put<CourseGooglePlayBillingService>(
        CourseGooglePlayBillingService(
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CoursePurchaseRecoveryService>()) {
      await Get.putAsync<CoursePurchaseRecoveryService>(
            () => CoursePurchaseRecoveryService(
          billingService:
          Get.find<CourseGooglePlayBillingService>(),
          apiService: Get.find<ProCheckoutApiService>(),
        ).init(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LearningActivityApiService>()) {
      Get.put<LearningActivityApiService>(
        LearningActivityApiService(
          apiClient: Get.find<ApiClient>(),
        ),
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
        NotificationSummaryService(
          apiClient: Get.find<ApiClient>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<TranslationService>()) {
      Get.put<TranslationService>(
        TranslationService(
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    // Ensure presence and socket services are registered early so we can
    // establish a single persistent socket connection when the user logs in.
    if (!Get.isRegistered<PresenceService>()) {
      Get.put<PresenceService>(
        PresenceService(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(
        ChatSocketService(
          tokenService: Get.find<TokenService>(),
        ),
        permanent: true,
      );
    }

    // Ensure presence listener is attached if both services are available.
    // This avoids a short startup race where presence updates may arrive
    // before PresenceService had a chance to register.
    try {
      if (Get.isRegistered<ChatSocketService>() &&
          Get.isRegistered<PresenceService>()) {
        Get.find<ChatSocketService>().addPresenceListener(
          Get.find<PresenceService>().updatePresenceFromSocket,
        );
      }
    } catch (error, stackTrace) {
      dev.log(
        'Could not attach the presence listener',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }

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
      final StorageService storageService =
      Get.find<StorageService>();

      final TokenService tokenService =
      Get.find<TokenService>();

      final bool hasValidLocalSession =
          storageService.isLoggedIn &&
              await tokenService.hasToken();

      if (hasValidLocalSession) {
        final bool hasValidServerSession =
            await Get.find<AuthService>().validateStoredSession();

        if (Get.currentRoute == AppRoutes.accountSuspended) {
          return;
        }

        if (!hasValidServerSession) {
          await Get.find<LearningActivityTrackerService>().discardSession();
          await storageService.clearLoggedInData();
          await tokenService.clearTokens();

          if (storageService.isFirstTimeUser) {
            Get.offAllNamed(AppRoutes.splash);
          } else {
            Get.offAllNamed(AppRoutes.login);
          }
          return;
        }

        if (Get.isRegistered<IncomingCallCoordinator>()) {
          // Handle a native accepted call before user/profile/home requests.
          // The accepted call route is awaited, so the bootstrap screen stays
          // as a touch blocker behind the call instead of flashing home.
          await Get.find<IncomingCallCoordinator>()
              .restorePendingAcceptedCall();
        }

        // Connect the global chat socket once.
        try {
          final ChatSocketService socketService =
          Get.find<ChatSocketService>();

          String? deviceId;

          try {
            final PresenceService presenceService =
            Get.find<PresenceService>();

            // Wait briefly for device ID initialization.
            for (
            int attempt = 0;
            attempt < 10 && presenceService.deviceId.isEmpty;
            attempt++
            ) {
              await Future<void>.delayed(
                const Duration(milliseconds: 50),
              );
            }

            deviceId = presenceService.deviceId;
          } catch (error, stackTrace) {
            deviceId = null;

            dev.log(
              'Could not resolve presence device ID',
              error: error,
              stackTrace: stackTrace,
              name: 'AppBootstrap',
            );
          }

          await socketService.connect(
            deviceId: deviceId,
          );
        } catch (error, stackTrace) {
          dev.log(
            'Chat socket connection during bootstrap failed',
            error: error,
            stackTrace: stackTrace,
            name: 'AppBootstrap',
          );
        }

        await _registerFcmTokenSafely();

        /*
         * Load the authenticated user first. Purchase recovery uses an
         * authenticated backend endpoint and must belong to the current user.
         */
        await Get.find<UserSessionController>().loadUser();

        /*
         * Recover a Google Play course purchase that completed while:
         *
         * - the app was closed;
         * - the network was unavailable;
         * - backend verification temporarily failed;
         * - the payment completed outside the checkout page.
         *
         * Recovery failure must not stop the user from opening the app.
         */
        await _recoverCoursePurchaseSafely();

        await Get.find<LearningActivityTrackerService>()
            .startSession();

        Get.offAllNamed(AppRoutes.wrapper);
        return;
      }

      await Get.find<LearningActivityTrackerService>()
          .discardSession();

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

  Future<void> _recoverCoursePurchaseSafely() async {
    try {
      if (!Get.isRegistered<CoursePurchaseRecoveryService>()) {
        return;
      }

      await Get.find<CoursePurchaseRecoveryService>()
          .recoverPendingPurchase();
    } catch (error, stackTrace) {
      /*
       * Never send the user back to login merely because Google Play or the
       * backend is temporarily unavailable. The pending purchase remains
       * stored and can be retried on the next app resume.
       */
      dev.log(
        'Google Play course purchase recovery failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }

  Future<void> _registerFcmTokenSafely() async {
    try {
      if (!Get.isRegistered<DevicePushTokenService>()) {
        return;
      }

      await Get.find<DevicePushTokenService>()
          .registerCurrentDevice();
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