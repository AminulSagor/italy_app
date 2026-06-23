enum MessageCallType {
  audio,
  video;

  bool get isVideo =>
      this == MessageCallType.video;

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

  static MessageCallType fromValue(
      String? value,
      ) {
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

  factory MessageCallParticipantModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MessageCallParticipantModel(
      id: json['id']?.toString() ?? '',
      name:
      json['name']?.toString() ??
          json['fullName']?.toString() ??
          'Unknown user',
      avatarUrl:
      json['avatarUrl']?.toString() ?? '',
      isOnline:
      json['isOnline'] as bool? ?? false,
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

class MessageCallMediaModel {
  final String appId;
  final String channelName;
  final int uid;
  final String token;
  final int expiresAt;

  const MessageCallMediaModel({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.token,
    required this.expiresAt,
  });

  factory MessageCallMediaModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MessageCallMediaModel(
      appId: json['appId']?.toString() ?? '',
      channelName:
      json['channelName']?.toString() ??
          '',
      uid: _parseInt(json['uid']),
      token: json['token']?.toString() ?? '',
      expiresAt:
      _parseInt(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appId': appId,
      'channelName': channelName,
      'uid': uid,
      'token': token,
      'expiresAt': expiresAt,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}

class MessageCallSessionModel {
  final String id;
  final String conversationId;
  final MessageCallType type;
  final MessageCallParticipantModel participant;
  final String status;
  final DateTime startedAt;
  final MessageCallMediaModel media;
  final bool created;

  const MessageCallSessionModel({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.participant,
    required this.status,
    required this.startedAt,
    required this.media,
    required this.created,
  });

  factory MessageCallSessionModel.fromInitiateResponse({
    required Map<String, dynamic> response,
    required MessageCallParticipantModel participant,
  }) {
    final Map<String, dynamic> call =
    _mapFrom(response['call']);

    final Map<String, dynamic> media =
    _mapFrom(response['media']);

    final String createdAt =
        call['createdAt']?.toString() ?? '';

    return MessageCallSessionModel(
      id: call['id']?.toString() ?? '',
      conversationId:
      call['directConversationId']
          ?.toString() ??
          '',
      type: MessageCallType.fromValue(
        call['callType']?.toString(),
      ),
      participant: participant,
      status:
      call['status']?.toString() ??
          'ringing',
      startedAt:
      DateTime.tryParse(createdAt)
          ?.toLocal() ??
          DateTime.now(),
      media:
      MessageCallMediaModel.fromJson(
        media,
      ),
      created:
      response['created'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'conversationId': conversationId,
      'type': type.value,
      'participant': participant.toJson(),
      'status': status,
      'startedAt':
      startedAt.toIso8601String(),
      'media': media.toJson(),
      'created': created,
    };
  }

  MessageCallSessionModel copyWith({
    String? id,
    String? conversationId,
    MessageCallType? type,
    MessageCallParticipantModel?
    participant,
    String? status,
    DateTime? startedAt,
    MessageCallMediaModel? media,
    bool? created,
  }) {
    return MessageCallSessionModel(
      id: id ?? this.id,
      conversationId:
      conversationId ??
          this.conversationId,
      type: type ?? this.type,
      participant:
      participant ?? this.participant,
      status: status ?? this.status,
      startedAt:
      startedAt ?? this.startedAt,
      media: media ?? this.media,
      created: created ?? this.created,
    );
  }

  static Map<String, dynamic> _mapFrom(
      dynamic value,
      ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }
}