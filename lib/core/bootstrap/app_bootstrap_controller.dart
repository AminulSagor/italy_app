import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../localization/translation_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';
import '../../features/home/services/home_mock_service.dart';

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
        ApiClient(tokenService: Get.find<TokenService>()),
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

    // Ensure HomeMockService is available early to avoid Get.find errors
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
      final bool hasValidLocalSession =
          storageService.isLoggedIn && await tokenService.hasToken();

      if (hasValidLocalSession) {
        Get.offAllNamed(AppRoutes.wrapper);
        return;
      }

      if (storageService.isLoggedIn) {
        await storageService.clearLoggedInData();
        await tokenService.clearTokens();
      }

      if (storageService.isFirstTimeUser) {
        Get.offAllNamed(AppRoutes.splash);
        return;
      }

      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      dev.log('Bootstrap failed', error: error, name: 'AppBootstrap');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
