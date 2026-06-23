enum MessageCallType {
  audio,
  video;

  bool get isVideo => this == MessageCallType.video;

  String get value {
    switch (this) {
      case MessageCallType.audio:
        return 'audio';
      case MessageCallType.video:
        return 'video';
    }
  }

  String get title {
    switch (this) {
      case MessageCallType.audio:
        return 'Voice Call';
      case MessageCallType.video:
        return 'Video Call';
    }
  }

  static MessageCallType fromValue(String? value) {
    switch (value) {
      case 'video':
        return MessageCallType.video;
      case 'audio':
      default:
        return MessageCallType.audio;
    }
  }
}

class MessageCallParticipantModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const MessageCallParticipantModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
  });

  factory MessageCallParticipantModel.fromJson(Map<String, dynamic> json) {
    return MessageCallParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    };
  }

  MessageCallParticipantModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return MessageCallParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class MessageCallSessionModel {
  final String id;
  final String conversationId;
  final MessageCallType type;
  final MessageCallParticipantModel participant;
  final DateTime startedAt;

  const MessageCallSessionModel({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.participant,
    required this.startedAt,
  });

  factory MessageCallSessionModel.fromJson(Map<String, dynamic> json) {
    return MessageCallSessionModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      type: MessageCallType.fromValue(json['type'] as String?),
      participant: MessageCallParticipantModel.fromJson(
        json['participant'] as Map<String, dynamic>,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'conversationId': conversationId,
      'type': type.value,
      'participant': participant.toJson(),
      'startedAt': startedAt.toIso8601String(),
    };
  }

  MessageCallSessionModel copyWith({
    String? id,
    String? conversationId,
    MessageCallType? type,
    MessageCallParticipantModel? participant,
    DateTime? startedAt,
  }) {
    return MessageCallSessionModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      participant: participant ?? this.participant,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}