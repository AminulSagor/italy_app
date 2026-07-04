enum MessageChatItemType { text, call }

enum MessageChatCallType { audio, video }

enum MessageChatCallStatus { completed, missed, rejected, failed }

class MessageThreadModel {
  final String id;
  final String learnerName;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool isOnline;
  final String blockStatus;
  final bool isHighlighted;
  final bool isDelivered;
  final String avatarUrl;
  final String? contactId;

  const MessageThreadModel({
    required this.id,
    required this.learnerName,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.isOnline,
    this.blockStatus = 'none',
    required this.isHighlighted,
    required this.isDelivered,
    required this.avatarUrl,
    this.contactId,
  });

  factory MessageThreadModel.fromJson(Map<String, dynamic> json) {
    return MessageThreadModel(
      id: json['id'] as String,
      learnerName: json['learnerName'] as String,
      lastMessage: json['lastMessage'] as String,
      timeLabel: json['timeLabel'] as String,
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      blockStatus: json['blockStatus']?.toString() ?? 'none',
      isHighlighted: json['isHighlighted'] as bool,
      isDelivered: json['isDelivered'] as bool,
      avatarUrl: json['avatarUrl'] as String,
      contactId: json['contactId'] as String?,
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
      'blockStatus': blockStatus,
      'isHighlighted': isHighlighted,
      'isDelivered': isDelivered,
      'avatarUrl': avatarUrl,
      'contactId': contactId,
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
    String? contactId,
    String? blockStatus,
  }) {
    return MessageThreadModel(
      id: id ?? this.id,
      learnerName: learnerName ?? this.learnerName,
      lastMessage: lastMessage ?? this.lastMessage,
      timeLabel: timeLabel ?? this.timeLabel,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      blockStatus: blockStatus ?? this.blockStatus,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isDelivered: isDelivered ?? this.isDelivered,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      contactId: contactId ?? this.contactId,
    );
  }
}

class MessageChatItemModel {
  final String id;
  final String text;
  final String timeLabel;
  final String statusLabel;
  final bool isMine;
  final String? createdAtIso;
  final bool isSystem;
  final MessageChatItemType itemType;
  final String? callId;
  final MessageChatCallType? callType;
  final MessageChatCallStatus? callStatus;
  final int callDurationSeconds;

  const MessageChatItemModel({
    required this.id,
    required this.text,
    required this.timeLabel,
    this.createdAtIso,
    required this.statusLabel,
    required this.isMine,
    this.isSystem = false,
    this.itemType = MessageChatItemType.text,
    this.callId,
    this.callType,
    this.callStatus,
    this.callDurationSeconds = 0,
  });

  bool get isCall => itemType == MessageChatItemType.call;

  bool get canCallBack =>
      isCall &&
      (callStatus == MessageChatCallStatus.missed ||
          callStatus == MessageChatCallStatus.rejected ||
          callStatus == MessageChatCallStatus.failed);

  factory MessageChatItemModel.fromJson(Map<String, dynamic> json) {
    return MessageChatItemModel(
      id: json['id'] as String,
      text: json['text'] as String,
      timeLabel: json['timeLabel'] as String,
      createdAtIso: json['createdAtIso'] as String?,
      statusLabel: json['statusLabel'] as String,
      isMine: json['isMine'] as bool,
      isSystem: json['isSystem'] as bool? ?? false,
      itemType: MessageChatItemType.values.firstWhere(
        (MessageChatItemType value) => value.name == json['itemType'],
        orElse: () => MessageChatItemType.text,
      ),
      callId: json['callId'] as String?,
      callType: _callTypeFrom(json['callType']),
      callStatus: _callStatusFrom(json['callStatus']),
      callDurationSeconds: _intFrom(json['callDurationSeconds']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'timeLabel': timeLabel,
      'createdAtIso': createdAtIso,
      'statusLabel': statusLabel,
      'isMine': isMine,
      'isSystem': isSystem,
      'itemType': itemType.name,
      'callId': callId,
      'callType': callType?.name,
      'callStatus': callStatus?.name,
      'callDurationSeconds': callDurationSeconds,
    };
  }

  MessageChatItemModel copyWith({
    String? id,
    String? text,
    String? timeLabel,
    String? statusLabel,
    bool? isMine,
    String? createdAtIso,
    bool? isSystem,
    MessageChatItemType? itemType,
    String? callId,
    MessageChatCallType? callType,
    MessageChatCallStatus? callStatus,
    int? callDurationSeconds,
  }) {
    return MessageChatItemModel(
      id: id ?? this.id,
      text: text ?? this.text,
      timeLabel: timeLabel ?? this.timeLabel,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      statusLabel: statusLabel ?? this.statusLabel,
      isMine: isMine ?? this.isMine,
      isSystem: isSystem ?? this.isSystem,
      itemType: itemType ?? this.itemType,
      callId: callId ?? this.callId,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
    );
  }
}

MessageChatCallType? _callTypeFrom(dynamic value) {
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized == MessageChatCallType.audio.name) {
    return MessageChatCallType.audio;
  }
  if (normalized == MessageChatCallType.video.name) {
    return MessageChatCallType.video;
  }
  return null;
}

MessageChatCallStatus? _callStatusFrom(dynamic value) {
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  for (final MessageChatCallStatus status in MessageChatCallStatus.values) {
    if (status.name == normalized) return status;
  }
  return null;
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class MessageChatModel {
  final String contactName;
  final String contactStatus;
  final String contactAvatarUrl;
  final bool isOnline;
  final String? contactId;
  final List<MessageChatItemModel> messages;

  const MessageChatModel({
    required this.contactName,
    required this.contactStatus,
    required this.contactAvatarUrl,
    required this.isOnline,
    this.contactId,
    required this.messages,
  });

  factory MessageChatModel.fromJson(Map<String, dynamic> json) {
    return MessageChatModel(
      contactName: json['contactName'] as String,
      contactStatus: json['contactStatus'] as String,
      contactAvatarUrl: json['contactAvatarUrl'] as String,
      contactId: json['contactId'] as String?,
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
      'contactId': contactId,
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
    String? contactId,
    bool? isOnline,
    List<MessageChatItemModel>? messages,
  }) {
    return MessageChatModel(
      contactName: contactName ?? this.contactName,
      contactStatus: contactStatus ?? this.contactStatus,
      contactAvatarUrl: contactAvatarUrl ?? this.contactAvatarUrl,
      contactId: contactId ?? this.contactId,
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
  final String reportedUserId;
  final String reasonId;
  final String description;
  final String? evidencePath;
  final String? evidenceFileId;
  final String? clientReportId;

  const MessageReportRequestModel({
    required this.reportedUserId,
    required this.reasonId,
    required this.description,
    this.evidencePath,
    this.evidenceFileId,
    this.clientReportId,
  });

  factory MessageReportRequestModel.fromJson(Map<String, dynamic> json) {
    return MessageReportRequestModel(
      reportedUserId: json['reportedUserId'] as String,
      reasonId: json['reasonId'] as String,
      description: json['description'] as String,
      evidencePath: json['evidencePath'] as String?,
      evidenceFileId: json['evidenceFileId'] as String?,
      clientReportId: json['clientReportId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reportedUserId': reportedUserId,
      'reasonId': reasonId,
      'description': description,
      'evidencePath': evidencePath,
      'evidenceFileId': evidenceFileId,
      'clientReportId': clientReportId,
    };
  }

  MessageReportRequestModel copyWith({
    String? reportedUserId,
    String? reasonId,
    String? description,
    String? evidencePath,
    String? evidenceFileId,
    String? clientReportId,
  }) {
    return MessageReportRequestModel(
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reasonId: reasonId ?? this.reasonId,
      description: description ?? this.description,
      evidencePath: evidencePath ?? this.evidencePath,
      evidenceFileId: evidenceFileId ?? this.evidenceFileId,
      clientReportId: clientReportId ?? this.clientReportId,
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
