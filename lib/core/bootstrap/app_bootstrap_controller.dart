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
import '../../features/messages/services/chat_socket_service.dart';
import '../../features/messages/services/presence_service.dart';

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
    // Try to establish the global chat socket as early as possible so the
    // connection exists for presence and messaging across the app lifecycle.
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        final ChatSocketService socketSvc = Get.find<ChatSocketService>();
        String? deviceId;
        try {
          if (Get.isRegistered<PresenceService>()) {
            final PresenceService ps = Get.find<PresenceService>();
            // best-effort: wait a short time for the presence service to
            // initialize a device id (it's async). If not ready, connect
            // without a deviceId — the socket will rejoin/emit on successful init.
            for (int i = 0; i < 10 && ps.deviceId.isEmpty; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            }
            deviceId = ps.deviceId.isNotEmpty ? ps.deviceId : null;
          }
        } catch (_) {
          deviceId = null;
        }

        // Fire-and-forget connect; failures should not stop bootstrap.
        try {
          await socketSvc.connect(deviceId: deviceId);
        } catch (_) {}
      }
    } catch (_) {}
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
