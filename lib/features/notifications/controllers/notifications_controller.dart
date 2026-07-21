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
    required void Function(bool hasUnread) onUnreadStateChanged,
  })  : _notificationsApiService = notificationsApiService,
        _onNotificationOpen = onNotificationOpen,
        _onUnreadStateChanged = onUnreadStateChanged;

  static const int _pageSize = 10;

  final NotificationsApiService _notificationsApiService;
  final Future<void> Function(NotificationItemModel notification)
      _onNotificationOpen;
  final void Function(bool hasUnread) _onUnreadStateChanged;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final Rx<NotificationCategory> selectedCategory =
      NotificationCategory.all.obs;
  final RxList<NotificationItemModel> notifications =
      <NotificationItemModel>[].obs;

  List<NotificationFilterModel> get filters =>
      <NotificationFilterModel>[
        NotificationFilterModel(
          category: NotificationCategory.all,
          label: 'notification_filter_all'.tr,
        ),
        NotificationFilterModel(
          category: NotificationCategory.learning,
          label: 'notification_filter_learning'.tr,
        ),
        NotificationFilterModel(
          category: NotificationCategory.system,
          label: 'notification_filter_system'.tr,
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

  Future<void> loadNotifications({
    required bool reset,
  }) async {
    if (!reset &&
        (isLoadingMore.value ||
            isLoading.value ||
            !hasMore)) {
      return;
    }



    final int requestVersion =
    reset ? ++_requestVersion : _requestVersion;

    final NotificationCategory category =
        selectedCategory.value;

    if (reset) {
      isLoadingMore.value = false;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      int page = reset ? 1 : _currentPage + 1;
      bool shouldContinueLoading = true;
      bool isFirstFetchedPage = true;

      while (shouldContinueLoading) {
        final ApiResult<NotificationsPageModel>
        result =
        await ApiErrorHandler.call<
            NotificationsPageModel>(
              () => _notificationsApiService
              .fetchNotifications(
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

        final NotificationsPageModel pageData =
        result.data!;

        /*
       * Message notifications already appear
       * inside the Messages feature.
       */
        final List<NotificationItemModel>
        visibleItems =
        pageData.items
            .where(
              (NotificationItemModel item) =>
          item.tone !=
              NotificationTone.message,
        )
            .toList(growable: false);

        final int previousItemCount =
            notifications.length;

        if (reset && isFirstFetchedPage) {
          notifications.assignAll(visibleItems);
        } else {
          final Set<String> existingIds =
          notifications
              .map(
                (NotificationItemModel item) =>
            item.id,
          )
              .toSet();

          notifications.addAll(
            visibleItems.where(
                  (NotificationItemModel item) =>
              !existingIds.contains(item.id),
            ),
          );
        }

        _currentPage = pageData.meta.page;
        _totalPages = pageData.meta.totalPages;
        _notifyUnreadStateChanged();

        final int addedItemCount =
            notifications.length -
                previousItemCount;

        /*
       * Keep the main loading indicator visible
       * while searching later pages for visible
       * non-message notifications.
       */
        shouldContinueLoading =
            hasMore &&
                (notifications.length < _pageSize ||
                    addedItemCount == 0);

        if (shouldContinueLoading) {
          final int nextPage = _currentPage + 1;

          if (nextPage <= page) {
            shouldContinueLoading = false;
          } else {
            page = nextPage;
            isFirstFetchedPage = false;
          }
        }
      }
    } finally {
      if (requestVersion == _requestVersion) {
        isLoading.value = false;
        isLoadingMore.value = false;
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
        _replaceReadState(
          notification.id,
          isRead: true,
        );

        _notifyUnreadStateChanged();
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

      _notifyUnreadStateChanged();
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

  void _notifyUnreadStateChanged() {
    _onUnreadStateChanged(hasUnread);
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
