import '../models/notification_models.dart';

/// Retained only for isolated widget previews. Runtime notifications use
/// [NotificationsApiService].
class NotificationsMockService {
  Future<NotificationsPageModel> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final DateTime now = DateTime.now();

    return NotificationsPageModel(
      items: <NotificationItemModel>[
        NotificationItemModel(
          id: 'preview-learning',
          category: NotificationCategory.learning,
          tone: NotificationTone.lesson,
          title: 'New lesson added',
          body: 'A new learning activity is available.',
          timeLabel: 'NOW',
          isRead: false,
          deepLink: '/courses',
          createdAt: now,
          eventType: 'admin_message',
        ),
      ],
      meta: const NotificationPageMetaModel(
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
      ),
    );
  }
}
