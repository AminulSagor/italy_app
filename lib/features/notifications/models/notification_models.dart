enum NotificationCategory { all, learning, system, social }

enum NotificationTone { lesson, webinar, message, streak }

class NotificationFilterModel {
  final NotificationCategory category;
  final String label;

  const NotificationFilterModel({required this.category, required this.label});

  factory NotificationFilterModel.fromJson(Map<String, dynamic> json) {
    return NotificationFilterModel(
      category: NotificationCategory.values.firstWhere(
        (NotificationCategory category) => category.name == json['category'],
        orElse: () => NotificationCategory.all,
      ),
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'category': category.name, 'label': label};
  }

  NotificationFilterModel copyWith({
    NotificationCategory? category,
    String? label,
  }) {
    return NotificationFilterModel(
      category: category ?? this.category,
      label: label ?? this.label,
    );
  }
}

class NotificationItemModel {
  final String id;
  final NotificationCategory category;
  final NotificationTone tone;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String avatarUrl;

  const NotificationItemModel({
    required this.id,
    required this.category,
    required this.tone,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    this.avatarUrl = '',
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String,
      category: NotificationCategory.values.firstWhere(
        (NotificationCategory category) => category.name == json['category'],
        orElse: () => NotificationCategory.learning,
      ),
      tone: NotificationTone.values.firstWhere(
        (NotificationTone tone) => tone.name == json['tone'],
        orElse: () => NotificationTone.lesson,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      timeLabel: json['timeLabel'] as String,
      isRead: json['isRead'] as bool,
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': category.name,
      'tone': tone.name,
      'title': title,
      'body': body,
      'timeLabel': timeLabel,
      'isRead': isRead,
      'avatarUrl': avatarUrl,
    };
  }

  NotificationItemModel copyWith({
    String? id,
    NotificationCategory? category,
    NotificationTone? tone,
    String? title,
    String? body,
    String? timeLabel,
    bool? isRead,
    String? avatarUrl,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      tone: tone ?? this.tone,
      title: title ?? this.title,
      body: body ?? this.body,
      timeLabel: timeLabel ?? this.timeLabel,
      isRead: isRead ?? this.isRead,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class NotificationsResponseModel {
  final List<NotificationFilterModel> filters;
  final List<NotificationItemModel> notifications;

  const NotificationsResponseModel({
    required this.filters,
    required this.notifications,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      filters: (json['filters'] as List<dynamic>)
          .map(
            (dynamic item) => NotificationFilterModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map(
            (dynamic item) => NotificationItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filters': filters
          .map((NotificationFilterModel item) => item.toJson())
          .toList(),
      'notifications': notifications
          .map((NotificationItemModel item) => item.toJson())
          .toList(),
    };
  }

  NotificationsResponseModel copyWith({
    List<NotificationFilterModel>? filters,
    List<NotificationItemModel>? notifications,
  }) {
    return NotificationsResponseModel(
      filters: filters ?? this.filters,
      notifications: notifications ?? this.notifications,
    );
  }
}
