enum NotificationCategory { all, learning, system, social }

enum NotificationTone { lesson, webinar, message, streak }

class NotificationFilterModel {
  const NotificationFilterModel({
    required this.category,
    required this.label,
  });

  final NotificationCategory category;
  final String label;
}

class NotificationPageMetaModel {
  const NotificationPageMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory NotificationPageMetaModel.fromJson(Map<String, dynamic> json) {
    return NotificationPageMetaModel(
      page: _intValue(json['page'], fallback: 1),
      limit: _intValue(json['limit'], fallback: 10),
      total: _intValue(json['total']),
      totalPages: _intValue(json['totalPages']),
    );
  }
}

class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.category,
    required this.tone,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    required this.deepLink,
    required this.createdAt,
    required this.eventType,
    this.avatarUrl = '',
  });

  final String id;
  final NotificationCategory category;
  final NotificationTone tone;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String deepLink;
  final DateTime createdAt;
  final String eventType;
  final String avatarUrl;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> event = _jsonMap(json['event']);
    final DateTime createdAt = DateTime.tryParse(
          _stringValue(json['createdAt'] ?? event['createdAt']),
        )?.toLocal() ??
        DateTime.now();
    final String deepLink = _stringValue(event['deepLink']);
    final String eventType = _stringValue(event['type']);

    return NotificationItemModel(
      id: _stringValue(json['id']),
      category: _categoryFrom(
        _stringValue(json['category']),
        eventType,
        deepLink,
      ),
      tone: _toneFrom(
        _stringValue(json['tone']),
        eventType,
        deepLink,
      ),
      title: _stringValue(event['title'], fallback: 'Notification'),
      body: _stringValue(event['body']),
      timeLabel: _timeLabel(createdAt),
      isRead: _boolValue(json['isRead']),
      deepLink: deepLink,
      createdAt: createdAt,
      eventType: eventType,
      avatarUrl: _stringValue(event['avatarUrl']),
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      category: category,
      tone: tone,
      title: title,
      body: body,
      timeLabel: timeLabel,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink,
      createdAt: createdAt,
      eventType: eventType,
      avatarUrl: avatarUrl,
    );
  }
}

class NotificationsPageModel {
  const NotificationsPageModel({
    required this.items,
    required this.meta,
  });

  final List<NotificationItemModel> items;
  final NotificationPageMetaModel meta;

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] is List
        ? json['items'] as List<dynamic>
        : const <dynamic>[];
    return NotificationsPageModel(
      items: rawItems
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) => NotificationItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      meta: NotificationPageMetaModel.fromJson(_jsonMap(json['meta'])),
    );
  }
}

NotificationCategory _categoryFrom(
  String explicit,
  String eventType,
  String deepLink,
) {
  final NotificationCategory? parsed = NotificationCategory.values
      .where((NotificationCategory item) => item.name == explicit)
      .firstOrNull;
  if (parsed != null) return parsed;

  final String link = deepLink.toLowerCase();
  if (eventType == 'chat_message' || link.startsWith('/messages')) {
    return NotificationCategory.social;
  }
  if (
      eventType == 'webinar' ||
      link.startsWith('/webinar') ||
      link.startsWith('/courses') ||
      link.startsWith('italirpothe://final-exams') ||
      link.startsWith('italirpothe://certificates')) {
    return NotificationCategory.learning;
  }
  return NotificationCategory.system;
}

NotificationTone _toneFrom(
  String explicit,
  String eventType,
  String deepLink,
) {
  final NotificationTone? parsed = NotificationTone.values
      .where((NotificationTone item) => item.name == explicit)
      .firstOrNull;
  if (parsed != null) return parsed;

  final String link = deepLink.toLowerCase();
  if (
      eventType == 'chat_message' ||
      link.startsWith('/messages') ||
      link.startsWith('italirpothe://messages')) {
    return NotificationTone.message;
  }
  if (eventType == 'streak_reminder') return NotificationTone.streak;
  if (eventType == 'webinar' || link.startsWith('/webinar')) {
    return NotificationTone.webinar;
  }
  return NotificationTone.lesson;
}

String _timeLabel(DateTime createdAt) {
  final Duration elapsed = DateTime.now().difference(createdAt);
  if (elapsed.inMinutes < 1) return 'NOW';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}M AGO';
  if (elapsed.inDays < 1) return '${elapsed.inHours}H AGO';
  return '${elapsed.inDays}D AGO';
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
