import '../models/notification_models.dart';

class NotificationsMockService {
  Future<NotificationsResponseModel> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const NotificationsResponseModel(
      filters: <NotificationFilterModel>[
        NotificationFilterModel(category: NotificationCategory.all, label: 'All'),
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
      ],
      notifications: <NotificationItemModel>[
        NotificationItemModel(
          id: 'lesson-1',
          category: NotificationCategory.learning,
          tone: NotificationTone.lesson,
          title: 'New Lesson Added!',
          body: 'Capitolo 5 is now available. Start mastering past tense today!',
          timeLabel: '10MAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'webinar-1',
          category: NotificationCategory.learning,
          tone: NotificationTone.webinar,
          title: 'Live Webinar starting soon!',
          body: 'Join our Kitchen Job live class with Chef Marco in 15 minutes.',
          timeLabel: '15M\nAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'message-1',
          category: NotificationCategory.social,
          tone: NotificationTone.message,
          title: 'Message from\nGiacomo',
          body: '"Hey, do you want to practice together for the exam?"',
          timeLabel: '1H\nAGO',
          isRead: true,
          avatarUrl: 'https://i.pravatar.cc/120?img=12',
        ),
        NotificationItemModel(
          id: 'streak-1',
          category: NotificationCategory.system,
          tone: NotificationTone.streak,
          title: 'Streak at Risk!',
          body: 'Finish one quiz before midnight to keep your 12-day streak alive!',
          timeLabel: '3HAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'streak-2',
          category: NotificationCategory.system,
          tone: NotificationTone.streak,
          title: 'Streak at Risk!',
          body: 'Finish one quiz before midnight to keep your 12-day streak alive!',
          timeLabel: '3HAGO',
          isRead: false,
        ),
      ],
    );
  }
}
