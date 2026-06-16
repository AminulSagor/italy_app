class MessageThreadModel {
  final String id;
  final String learnerName;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool isOnline;
  final bool isHighlighted;
  final bool isDelivered;
  final String avatarUrl;

  const MessageThreadModel({
    required this.id,
    required this.learnerName,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.isOnline,
    required this.isHighlighted,
    required this.isDelivered,
    required this.avatarUrl,
  });

  factory MessageThreadModel.fromJson(Map<String, dynamic> json) {
    return MessageThreadModel(
      id: json['id'] as String,
      learnerName: json['learnerName'] as String,
      lastMessage: json['lastMessage'] as String,
      timeLabel: json['timeLabel'] as String,
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      isHighlighted: json['isHighlighted'] as bool,
      isDelivered: json['isDelivered'] as bool,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'learnerName': learnerName,
      'lastMessage': lastMessage,
      'timeLabel': timeLabel,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isHighlighted': isHighlighted,
      'isDelivered': isDelivered,
      'avatarUrl': avatarUrl,
    };
  }

  MessageThreadModel copyWith({
    String? id,
    String? learnerName,
    String? lastMessage,
    String? timeLabel,
    int? unreadCount,
    bool? isOnline,
    bool? isHighlighted,
    bool? isDelivered,
    String? avatarUrl,
  }) {
    return MessageThreadModel(
      id: id ?? this.id,
      learnerName: learnerName ?? this.learnerName,
      lastMessage: lastMessage ?? this.lastMessage,
      timeLabel: timeLabel ?? this.timeLabel,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isDelivered: isDelivered ?? this.isDelivered,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class MessageChatItemModel {
  final String id;
  final String text;
  final String timeLabel;
  final String statusLabel;
  final bool isMine;
  final bool isSystem;

  const MessageChatItemModel({
    required this.id,
    required this.text,
    required this.timeLabel,
    required this.statusLabel,
    required this.isMine,
    this.isSystem = false,
  });

  factory MessageChatItemModel.fromJson(Map<String, dynamic> json) {
    return MessageChatItemModel(
      id: json['id'] as String,
      text: json['text'] as String,
      timeLabel: json['timeLabel'] as String,
      statusLabel: json['statusLabel'] as String,
      isMine: json['isMine'] as bool,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'timeLabel': timeLabel,
      'statusLabel': statusLabel,
      'isMine': isMine,
      'isSystem': isSystem,
    };
  }

  MessageChatItemModel copyWith({
    String? id,
    String? text,
    String? timeLabel,
    String? statusLabel,
    bool? isMine,
    bool? isSystem,
  }) {
    return MessageChatItemModel(
      id: id ?? this.id,
      text: text ?? this.text,
      timeLabel: timeLabel ?? this.timeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      isMine: isMine ?? this.isMine,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}

class MessageChatModel {
  final String contactName;
  final String contactStatus;
  final String contactAvatarUrl;
  final bool isOnline;
  final List<MessageChatItemModel> messages;

  const MessageChatModel({
    required this.contactName,
    required this.contactStatus,
    required this.contactAvatarUrl,
    required this.isOnline,
    required this.messages,
  });

  factory MessageChatModel.fromJson(Map<String, dynamic> json) {
    return MessageChatModel(
      contactName: json['contactName'] as String,
      contactStatus: json['contactStatus'] as String,
      contactAvatarUrl: json['contactAvatarUrl'] as String,
      isOnline: json['isOnline'] as bool,
      messages: (json['messages'] as List<dynamic>)
          .map(
            (dynamic item) =>
                MessageChatItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contactName': contactName,
      'contactStatus': contactStatus,
      'contactAvatarUrl': contactAvatarUrl,
      'isOnline': isOnline,
      'messages': messages
          .map((MessageChatItemModel message) => message.toJson())
          .toList(),
    };
  }

  MessageChatModel copyWith({
    String? contactName,
    String? contactStatus,
    String? contactAvatarUrl,
    bool? isOnline,
    List<MessageChatItemModel>? messages,
  }) {
    return MessageChatModel(
      contactName: contactName ?? this.contactName,
      contactStatus: contactStatus ?? this.contactStatus,
      contactAvatarUrl: contactAvatarUrl ?? this.contactAvatarUrl,
      isOnline: isOnline ?? this.isOnline,
      messages: messages ?? this.messages,
    );
  }
}

class MessageUserProfileModel {
  final String name;
  final String statusLabel;
  final String avatarUrl;
  final String streakValue;
  final String xpValue;
  final bool isBlocked;

  const MessageUserProfileModel({
    required this.name,
    required this.statusLabel,
    required this.avatarUrl,
    required this.streakValue,
    required this.xpValue,
    required this.isBlocked,
  });

  factory MessageUserProfileModel.fromJson(Map<String, dynamic> json) {
    return MessageUserProfileModel(
      name: json['name'] as String,
      statusLabel: json['statusLabel'] as String,
      avatarUrl: json['avatarUrl'] as String,
      streakValue: json['streakValue'] as String,
      xpValue: json['xpValue'] as String,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'statusLabel': statusLabel,
      'avatarUrl': avatarUrl,
      'streakValue': streakValue,
      'xpValue': xpValue,
      'isBlocked': isBlocked,
    };
  }

  MessageUserProfileModel copyWith({
    String? name,
    String? statusLabel,
    String? avatarUrl,
    String? streakValue,
    String? xpValue,
    bool? isBlocked,
  }) {
    return MessageUserProfileModel(
      name: name ?? this.name,
      statusLabel: statusLabel ?? this.statusLabel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streakValue: streakValue ?? this.streakValue,
      xpValue: xpValue ?? this.xpValue,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

class MessageReportRequestModel {
  final String threadId;
  final String reason;
  final String description;
  final String? evidencePath;

  const MessageReportRequestModel({
    required this.threadId,
    required this.reason,
    required this.description,
    this.evidencePath,
  });

  factory MessageReportRequestModel.fromJson(Map<String, dynamic> json) {
    return MessageReportRequestModel(
      threadId: json['threadId'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String,
      evidencePath: json['evidencePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'threadId': threadId,
      'reason': reason,
      'description': description,
      'evidencePath': evidencePath,
    };
  }

  MessageReportRequestModel copyWith({
    String? threadId,
    String? reason,
    String? description,
    String? evidencePath,
  }) {
    return MessageReportRequestModel(
      threadId: threadId ?? this.threadId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      evidencePath: evidencePath ?? this.evidencePath,
    );
  }
}

class MessageReportResultModel {
  final String referenceId;
  final String statusLabel;
  final List<String> reviewSteps;

  const MessageReportResultModel({
    required this.referenceId,
    required this.statusLabel,
    required this.reviewSteps,
  });

  factory MessageReportResultModel.fromJson(Map<String, dynamic> json) {
    return MessageReportResultModel(
      referenceId: json['referenceId'] as String,
      statusLabel: json['statusLabel'] as String,
      reviewSteps: (json['reviewSteps'] as List<dynamic>)
          .map((dynamic item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'referenceId': referenceId,
      'statusLabel': statusLabel,
      'reviewSteps': reviewSteps,
    };
  }

  MessageReportResultModel copyWith({
    String? referenceId,
    String? statusLabel,
    List<String>? reviewSteps,
  }) {
    return MessageReportResultModel(
      referenceId: referenceId ?? this.referenceId,
      statusLabel: statusLabel ?? this.statusLabel,
      reviewSteps: reviewSteps ?? this.reviewSteps,
    );
  }
}

class MessagesResponseModel {
  final String currentUserName;
  final String currentUserAvatarUrl;
  final List<MessageThreadModel> threads;

  const MessagesResponseModel({
    required this.currentUserName,
    required this.currentUserAvatarUrl,
    required this.threads,
  });

  factory MessagesResponseModel.fromJson(Map<String, dynamic> json) {
    return MessagesResponseModel(
      currentUserName: json['currentUserName'] as String,
      currentUserAvatarUrl: json['currentUserAvatarUrl'] as String,
      threads: (json['threads'] as List<dynamic>)
          .map(
            (dynamic item) =>
                MessageThreadModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentUserName': currentUserName,
      'currentUserAvatarUrl': currentUserAvatarUrl,
      'threads': threads
          .map((MessageThreadModel thread) => thread.toJson())
          .toList(),
    };
  }

  MessagesResponseModel copyWith({
    String? currentUserName,
    String? currentUserAvatarUrl,
    List<MessageThreadModel>? threads,
  }) {
    return MessagesResponseModel(
      currentUserName: currentUserName ?? this.currentUserName,
      currentUserAvatarUrl: currentUserAvatarUrl ?? this.currentUserAvatarUrl,
      threads: threads ?? this.threads,
    );
  }
}
