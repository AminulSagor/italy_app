import 'package:get/get.dart';

import '../models/notification_models.dart';
import '../services/notifications_mock_service.dart';

class NotificationsController extends GetxController {
  final NotificationsMockService _notificationsMockService;

  NotificationsController({required NotificationsMockService notificationsMockService})
    : _notificationsMockService = notificationsMockService;

  final RxBool isLoading = false.obs;
  final Rx<NotificationCategory> selectedCategory = NotificationCategory.all.obs;
  final RxList<NotificationFilterModel> filters = <NotificationFilterModel>[].obs;
  final RxList<NotificationItemModel> notifications = <NotificationItemModel>[].obs;

  List<NotificationItemModel> get filteredNotifications {
    if (selectedCategory.value == NotificationCategory.all) {
      return notifications;
    }

    return notifications
        .where(
          (NotificationItemModel item) => item.category == selectedCategory.value,
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final NotificationsResponseModel response = await _notificationsMockService
          .fetchNotifications();
      filters.assignAll(response.filters);
      notifications.assignAll(response.notifications);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(NotificationCategory category) {
    selectedCategory.value = category;
  }

  void markAllAsRead() {
    notifications.assignAll(
      notifications
          .map((NotificationItemModel item) => item.copyWith(isRead: true))
          .toList(),
    );
  }
}
