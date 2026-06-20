import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../features/home/services/home_mock_service.dart';
import '../../routes/routes.dart';
import '../localization/translation_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/device_push_token_service.dart';
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

      Get.put<DevicePushTokenService>(
        devicePushTokenService,
        permanent: true,
      );
    }

    // Ensure HomeMockService is available early to avoid Get.find errors.
    if (!Get.isRegistered<HomeMockService>()) {
      Get.put<HomeMockService>(HomeMockService(), permanent: true);
    }

    if (!Get.isRegistered<TranslationService>()) {
      Get.put<TranslationService>(
        TranslationService(storageService: Get.find<StorageService>()),
        permanent: true,
      );
    }
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
      final AuthService authService = Get.find<AuthService>();

      if (await tokenService.hasToken()) {
        final bool isSessionValid = await authService.validateStoredSession();
        if (isSessionValid) {
          await _registerFcmTokenSafely();
          if (await tokenService.hasToken()) {
            Get.offAllNamed(AppRoutes.wrapper);
          } else {
            Get.offAllNamed(AppRoutes.login);
          }
          return;
        }

        await authService.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      } else if (storageService.isLoggedIn) {
        await storageService.clearLoggedInData();
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