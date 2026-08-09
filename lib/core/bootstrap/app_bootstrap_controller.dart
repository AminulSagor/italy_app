import 'dart:async';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        AppLogger.log(
          'Unable to load .env file',
          error: error,
          name: 'AppBootstrap',
        );
      }
    }

    await Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );

    if (!Get.isRegistered<TokenService>()) {
      await Get.putAsync<TokenService>(
        () => TokenService().init(),
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

    /*
     * Register DevicePushTokenService first.
     *
     * AuthService needs this service to get:
     * - deviceId
     * - platform
     * - FCM logout cleanup
     */
    if (!Get.isRegistered<DevicePushTokenService>()) {
      final DevicePushTokenService devicePushTokenService =
          DevicePushTokenService(
            apiClient: Get.find<ApiClient>(),
            storageService: Get.find<StorageService>(),
          );

      devicePushTokenService.listenForTokenRefresh();

      Get.put<DevicePushTokenService>(devicePushTokenService, permanent: true);
    }

    /*
     * Register AuthService after DevicePushTokenService.
     */
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(
          apiClient: Get.find<ApiClient>(),
          tokenService: Get.find<TokenService>(),
          storageService: Get.find<StorageService>(),
          devicePushTokenService: Get.find<DevicePushTokenService>(),
        ),
        permanent: true,
      );
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
          storageService: Get.find<StorageService>(),
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
          userSessionController:
          Get.find<UserSessionController>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CourseGooglePlayBillingService>()) {
      Get.put<CourseGooglePlayBillingService>(
        CourseGooglePlayBillingService(
          storageService: Get.find<StorageService>(),
          userSessionController:
          Get.find<UserSessionController>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CoursePurchaseRecoveryService>()) {
      await Get.putAsync<CoursePurchaseRecoveryService>(
        () => CoursePurchaseRecoveryService(
          billingService: Get.find<CourseGooglePlayBillingService>(),
          apiService: Get.find<ProCheckoutApiService>(),
        ).init(),
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

    /*
     * Presence and socket services stay global so messaging and calls keep
     * their existing persistent-connection behavior.
     */
    if (!Get.isRegistered<PresenceService>()) {
      Get.put<PresenceService>(PresenceService(), permanent: true);
    }

    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(
        ChatSocketService(tokenService: Get.find<TokenService>()),
        permanent: true,
      );
    }

    try {
      if (Get.isRegistered<ChatSocketService>() &&
          Get.isRegistered<PresenceService>()) {
        Get.find<ChatSocketService>().addPresenceListener(
          Get.find<PresenceService>().updatePresenceFromSocket,
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        AppLogger.log(
          'Could not attach the presence listener',
          error: error,
          stackTrace: stackTrace,
          name: 'AppBootstrap',
        );
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final StorageService storageService = Get.find<StorageService>();
      final TokenService tokenService = Get.find<TokenService>();

      /*
       * TokenService already loaded secure storage during application startup,
       * so this check reads the in-memory token and returns immediately.
       */
      final bool hasStoredToken = await tokenService.hasToken();

      final bool hasValidLocalSession =
          storageService.isLoggedIn && hasStoredToken;

      if (hasValidLocalSession) {
        /*
         * Preserve the existing terminated-app accepted-call behavior.
         *
         * In the normal no-call case this returns immediately. When a native
         * call was accepted, the call screen still receives priority.
         */
        if (Get.isRegistered<IncomingCallCoordinator>()) {
          await Get.find<IncomingCallCoordinator>()
              .restorePendingAcceptedCall();
        }

        /*
         * The cached user summary is restored synchronously when
         * UserSessionController is created. Therefore the wrapper, profile UI,
         * and user-specific Home cache can render without waiting for APIs.
         */
        Get.offAllNamed(AppRoutes.wrapper);

        /*
         * Validate the server session and refresh user information after the
         * first screen is visible. Invalid, expired, revoked, or suspended
         * sessions still follow the same redirect and cleanup behavior.
         */
        unawaited(
          _validateAndStartAuthenticatedSession(
            storageService: storageService,
            tokenService: tokenService,
          ),
        );

        return;
      }

      await _clearLocalUnauthenticatedState(
        storageService: storageService,
        tokenService: tokenService,
        hadStoredToken: hasStoredToken,
      );
    } catch (error, stackTrace) {
      AppLogger.log(
        'Bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );

      if (Get.currentRoute != AppRoutes.accountSuspended &&
          Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _validateAndStartAuthenticatedSession({
    required StorageService storageService,
    required TokenService tokenService,
  }) async {
    try {
      final bool hasValidServerSession = await Get.find<AuthService>()
          .validateStoredSession();

      /*
       * ApiClient performs the suspended-account navigation as soon as a
       * restriction response is received. Never override that route.
       */
      if (Get.currentRoute == AppRoutes.accountSuspended) {
        return;
      }

      if (!hasValidServerSession) {
        await _clearInvalidAuthenticatedSession(
          storageService: storageService,
          tokenService: tokenService,
        );
        return;
      }

      /*
       * Replace the locally cached summary with fresh settings and balances.
       * A temporary profile request failure leaves the cached summary visible.
       */
      await Get.find<UserSessionController>().loadUser(
        forceRefresh: true,
        showError: false,
      );

      if (Get.currentRoute == AppRoutes.accountSuspended) {
        return;
      }

      await _startAuthenticatedBackgroundTasks();
    } catch (error, stackTrace) {
      /*
       * An unexpected startup-task error must not hide the application or
       * destroy a locally valid session. Protected API requests and ApiClient
       * continue to enforce 401 and account-restriction handling.
       */
      AppLogger.log(
        'Authenticated startup validation failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }

  Future<void> _clearInvalidAuthenticatedSession({
    required StorageService storageService,
    required TokenService tokenService,
  }) async {
    await Get.find<LearningActivityTrackerService>().discardSession();

    try {
      await storageService.clearLoggedInData();
    } finally {
      await tokenService.clearTokens();
    }

    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().clear();
    }

    if (Get.currentRoute == AppRoutes.accountSuspended) {
      return;
    }

    if (storageService.isFirstTimeUser) {
      if (Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.splash);
      }
      return;
    }

    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _clearLocalUnauthenticatedState({
    required StorageService storageService,
    required TokenService tokenService,
    required bool hadStoredToken,
  }) async {
    await Get.find<LearningActivityTrackerService>().discardSession();

    if (storageService.isLoggedIn) {
      await storageService.clearLoggedInData();
    }

    if (hadStoredToken) {
      await tokenService.clearTokens();
    }

    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().clear();
    }

    if (storageService.isFirstTimeUser) {
      Get.offAllNamed(AppRoutes.splash);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _startAuthenticatedBackgroundTasks() async {
    await Future.wait<void>(<Future<void>>[
      _connectChatSocketSafely(),
      _registerFcmTokenSafely(),
      _recoverCoursePurchaseSafely(),
      _startLearningActivitySafely(),
    ]);
  }

  Future<void> _connectChatSocketSafely() async {
    try {
      if (!Get.isRegistered<ChatSocketService>()) {
        return;
      }

      final ChatSocketService socketService = Get.find<ChatSocketService>();

      String? deviceId;

      try {
        if (Get.isRegistered<PresenceService>()) {
          final PresenceService presenceService = Get.find<PresenceService>();

          /*
           * Preserve the existing short wait for device-ID initialization.
           */
          for (
            int attempt = 0;
            attempt < 10 && presenceService.deviceId.isEmpty;
            attempt++
          ) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }

          final String resolvedDeviceId = presenceService.deviceId.trim();

          if (resolvedDeviceId.isNotEmpty) {
            deviceId = resolvedDeviceId;
          }
        }
      } catch (error, stackTrace) {
        AppLogger.log(
          'Could not resolve presence device ID',
          error: error,
          stackTrace: stackTrace,
          name: 'AppBootstrap',
        );
      }

      await socketService.connect(deviceId: deviceId);
    } catch (error, stackTrace) {
      AppLogger.log(
        'Chat socket connection during bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }

  Future<void> _startLearningActivitySafely() async {
    try {
      if (!Get.isRegistered<LearningActivityTrackerService>()) {
        return;
      }

      await Get.find<LearningActivityTrackerService>().startSession();
    } catch (error, stackTrace) {
      AppLogger.log(
        'Learning activity startup failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }

  Future<void> _recoverCoursePurchaseSafely() async {
    try {
      if (!Get.isRegistered<CoursePurchaseRecoveryService>()) {
        return;
      }

      await Get.find<CoursePurchaseRecoveryService>().recoverPendingPurchase();
    } catch (error, stackTrace) {
      /*
       * Never send the user back to login merely because Google Play or the
       * backend is temporarily unavailable. The pending purchase remains
       * stored and can be retried on the next app resume.
       */
      AppLogger.log(
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

      await Get.find<DevicePushTokenService>().registerCurrentDevice();
    } catch (error, stackTrace) {
      AppLogger.log(
        'FCM token registration during bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AppBootstrap',
      );
    }
  }
}
