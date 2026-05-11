import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/messages/controllers/messages_controller.dart';
import '../../../features/messages/services/messages_mock_service.dart';
import '../../../features/notifications/controllers/notifications_controller.dart';
import '../../../features/notifications/services/notifications_mock_service.dart';
import '../../../features/notifications/views/notifications_bottom_sheet.dart';
import '../../themes/app_colors.dart';

class NavbarAndAppbarWrapperController extends GetxController {
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
      Get.lazyPut<MessagesMockService>(() => MessagesMockService());
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
}
