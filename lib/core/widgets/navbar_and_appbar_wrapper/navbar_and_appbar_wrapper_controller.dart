import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/drawer_features/language/language_switch_dialogue.dart';
import '../../../features/messages/controllers/messages_controller.dart';
import '../../../features/messages/services/messages_mock_service.dart';
import '../../../features/messages/services/chat_socket_service.dart';
import '../../services/api_client.dart';
import '../../services/token_service.dart';
import '../../../features/notifications/controllers/notifications_controller.dart';
import '../../../features/notifications/services/notifications_mock_service.dart';
import '../../../features/notifications/views/notifications_bottom_sheet.dart';
import '../../localization/translation_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';
import '../../../routes/routes.dart';

class NavbarAndAppbarWrapperController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();
  final AuthService _authService = Get.find<AuthService>();
  final RxInt currentIndex = 0.obs;
  final RxBool isMessagesPageOpen = false.obs;
  final RxSet<int> visitedTabs = <int>{0}.obs;

  void onBottomNavTap(int index) {
    isMessagesPageOpen.value = false;

    if (index == currentIndex.value) {
      return;
    }

    currentIndex.value = index;
    visitedTabs.add(index);
  }

  void openNotifications() {
    if (!Get.isRegistered<NotificationsMockService>()) {
      Get.lazyPut<NotificationsMockService>(() => NotificationsMockService());
    }

    if (Get.isRegistered<NotificationsController>()) {
      Get.delete<NotificationsController>();
    }

    Get.put<NotificationsController>(
      NotificationsController(
        notificationsMockService: Get.find<NotificationsMockService>(),
      ),
    );

    Get.bottomSheet<void>(
      const NotificationsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      isDismissible: true,
      enableDrag: true,
    ).whenComplete(() {
      if (Get.isRegistered<NotificationsController>()) {
        Get.delete<NotificationsController>();
      }
    });
  }

  void openMessages() {
    if (!Get.isRegistered<MessagesMockService>()) {
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
    }

    if (!Get.isRegistered<MessagesController>()) {
      Get.put<MessagesController>(
        MessagesController(
          messagesMockService: Get.find<MessagesMockService>(),
        ),
      );
    }

    isMessagesPageOpen.value = true;
  }

  void closeMessages() {
    isMessagesPageOpen.value = false;
  }

  void backToHome() {
    isMessagesPageOpen.value = false;
    onBottomNavTap(0);
  }

  Future<bool> onWillPop() async {
    if (isMessagesPageOpen.value) {
      isMessagesPageOpen.value = false;
      return false;
    }

    if (currentIndex.value != 0) {
      onBottomNavTap(0);
      return false;
    }

    return true;
  }

  // drawer callbacks
  Future<void> onLanguageTap(BuildContext context) async {
    final BuildContext dialogContext = Get.context ?? context;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final AppLanguage? selectedLanguage = await showLanguageDialog(
      context: dialogContext,
      initialLanguage: _translationService.currentLanguage,
    );

    if (selectedLanguage == null) {
      return;
    }

    _translationService.setLanguage(selectedLanguage);
  }

  void onShopTap() {
    Get.toNamed(AppRoutes.shop);
  }

  Future<void> onLogoutTap() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
