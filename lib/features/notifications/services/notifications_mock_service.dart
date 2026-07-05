import 'package:get/get.dart';
import '../models/notification_models.dart';

class NotificationsMockService {
  Future<NotificationsResponseModel> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return NotificationsResponseModel(
      filters: <NotificationFilterModel>[
        NotificationFilterModel(category: NotificationCategory.all, label: 'gen_all'.tr),
        NotificationFilterModel(
          category: NotificationCategory.learning,
          label: 'gen_learning'.tr,
        ),
        NotificationFilterModel(
          category: NotificationCategory.system,
          label: 'gen_system'.tr,
        ),
        NotificationFilterModel(
          category: NotificationCategory.social,
          label: 'gen_social'.tr,
        ),
      ],
      notifications: <NotificationItemModel>[
        NotificationItemModel(
          id: 'lesson-1',
          category: NotificationCategory.learning,
          tone: NotificationTone.lesson,
          title: 'gen_new_lesson_added'.tr,
          body: 'Capitolo 5 is now available. Start mastering past tense today!',
          timeLabel: '10MAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'webinar-1',
          category: NotificationCategory.learning,
          tone: NotificationTone.webinar,
          title: 'gen_live_webinar_starting_soon'.tr,
          body: 'Join our Kitchen Job live class with Chef Marco in 15 minutes.',
          timeLabel: '15M\nAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'message-1',
          category: NotificationCategory.social,
          tone: NotificationTone.message,
          title: 'gen_message_from_ngiacomo'.tr,
          body: '"Hey, do you want to practice together for the exam?"',
          timeLabel: '1H\nAGO',
          isRead: true,
          avatarUrl: 'https://i.pravatar.cc/120?img=12',
        ),
        NotificationItemModel(
          id: 'streak-1',
          category: NotificationCategory.system,
          tone: NotificationTone.streak,
          title: 'gen_streak_at_risk'.tr,
          body: 'Finish one quiz before midnight to keep your 12-day streak alive!',
          timeLabel: '3HAGO',
          isRead: false,
        ),
        NotificationItemModel(
          id: 'streak-2',
          category: NotificationCategory.system,
          tone: NotificationTone.streak,
          title: 'gen_streak_at_risk'.tr,
          body: 'Finish one quiz before midnight to keep your 12-day streak alive!',
          timeLabel: '3HAGO',
          isRead: false,
        ),
      ],
    );
  }
}
