import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/notification_models.dart';
import '../services/notifications_api_service.dart';

class NotificationsController extends GetxController {
  NotificationsController({
    required NotificationsApiService notificationsApiService,
    required Future<void> Function(NotificationItemModel notification)
        onNotificationOpen,
  })  : _notificationsApiService = notificationsApiService,
        _onNotificationOpen = onNotificationOpen;

  static const int _pageSize = 10;

  final NotificationsApiService _notificationsApiService;
  final Future<void> Function(NotificationItemModel notification)
      _onNotificationOpen;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final Rx<NotificationCategory> selectedCategory =
      NotificationCategory.all.obs;
  final RxList<NotificationItemModel> notifications =
      <NotificationItemModel>[].obs;

  final List<NotificationFilterModel> filters =
      const <NotificationFilterModel>[
    NotificationFilterModel(
      category: NotificationCategory.all,
      label: 'All',
    ),
    NotificationFilterModel(
      category: NotificationCategory.learning,
      label: 'Learning',
    ),
    NotificationFilterModel(
      category: NotificationCategory.system,
      label: 'System',
    ),
    NotificationFilterModel(
      category: NotificationCategory.social,
      label: 'Social',
    ),
  ];

  int _currentPage = 0;
  int _totalPages = 1;
  int _requestVersion = 0;

  bool get hasMore => _currentPage < _totalPages;
  bool get hasUnread => notifications.any(
        (NotificationItemModel item) => !item.isRead,
      );

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    loadNotifications(reset: true);
  }

  Future<void> loadNotifications({required bool reset}) async {
    if (!reset && (isLoadingMore.value || isLoading.value || !hasMore)) {
      return;
    }

    final int requestVersion = reset ? ++_requestVersion : _requestVersion;
    final NotificationCategory category = selectedCategory.value;
    final int page = reset ? 1 : _currentPage + 1;

    if (reset) {
      isLoadingMore.value = false;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final ApiResult<NotificationsPageModel> result =
          await ApiErrorHandler.call<NotificationsPageModel>(
        () => _notificationsApiService.fetchNotifications(
          category: category,
          page: page,
          limit: _pageSize,
        ),
        errorTitle: 'Notifications',
      );
      if (requestVersion != _requestVersion ||
          category != selectedCategory.value ||
          !result.isSuccess ||
          result.data == null) {
        return;
      }

      final NotificationsPageModel pageData = result.data!;
      if (reset) {
        notifications.assignAll(pageData.items);
      } else {
        final Set<String> existingIds = notifications
            .map((NotificationItemModel item) => item.id)
            .toSet();
        notifications.addAll(
          pageData.items.where(
            (NotificationItemModel item) => !existingIds.contains(item.id),
          ),
        );
      }
      _currentPage = pageData.meta.page;
      _totalPages = pageData.meta.totalPages;
    } finally {
      if (requestVersion == _requestVersion) {
        if (reset) {
          isLoading.value = false;
        } else {
          isLoadingMore.value = false;
        }
      }
    }
  }

  Future<void> refreshNotifications() {
    return loadNotifications(reset: true);
  }

  Future<void> selectCategory(NotificationCategory category) async {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    _currentPage = 0;
    _totalPages = 1;
    notifications.clear();
    await loadNotifications(reset: true);
  }

  Future<void> openNotification(NotificationItemModel notification) async {
    if (!notification.isRead) {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
        () => _notificationsApiService.markRead(notification.id),
        showError: false,
      );
      if (result.isSuccess) {
        _replaceReadState(notification.id, isRead: true);
      }
    }
    await _onNotificationOpen(notification.copyWith(isRead: true));
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAllRead.value || !hasUnread) return;
    isMarkingAllRead.value = true;
    try {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
        _notificationsApiService.markAllRead,
        errorTitle: 'Notifications',
      );
      if (!result.isSuccess) return;
      notifications.assignAll(
        notifications
            .map(
              (NotificationItemModel item) => item.copyWith(isRead: true),
            )
            .toList(growable: false),
      );
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  void _replaceReadState(String notificationId, {required bool isRead}) {
    final int index = notifications.indexWhere(
      (NotificationItemModel item) => item.id == notificationId,
    );
    if (index < 0) return;
    notifications[index] = notifications[index].copyWith(isRead: isRead);
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 220) {
      loadNotifications(reset: false);
    }
  }

  @override
  void onClose() {
    _requestVersion++;
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.onClose();
  }
}
