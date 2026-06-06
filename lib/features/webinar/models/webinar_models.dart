Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

class WebinarPaginationModel {
  const WebinarPaginationModel({
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
  });

  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;

  factory WebinarPaginationModel.fromJson(Map<String, dynamic> json) {
    return WebinarPaginationModel(
      page: _asInt(json['page'], 1),
      limit: _asInt(json['limit'], 10),
      totalPages: _asInt(json['totalPages'], 0),
      totalItems: _asInt(json['totalItems'], 0),
    );
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class WebinarItemModel {
  const WebinarItemModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.hostTeacherName,
    required this.status,
    this.thumbnailImageUrl,
    this.agoraChannelName,
    this.liveStartedAt,
    this.liveEndedAt,
  });

  final String id;
  final String title;
  final DateTime? dateTime;
  final String hostTeacherName;
  final String status;
  final String? thumbnailImageUrl;
  final String? agoraChannelName;
  final DateTime? liveStartedAt;
  final DateTime? liveEndedAt;

  factory WebinarItemModel.fromJson(Map<String, dynamic> json) {
    return WebinarItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Not available',
      dateTime: _parseDate(json['dateTime']),
      hostTeacherName: json['hostTeacherName']?.toString() ?? 'Not available',
      status: json['status']?.toString() ?? '',
      thumbnailImageUrl: _nullableString(json['thumbnailImageUrl']),
      agoraChannelName: _nullableString(json['agoraChannelName']),
      liveStartedAt: _parseDate(json['liveStartedAt']),
      liveEndedAt: _parseDate(json['liveEndedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class WebinarListResponseModel {
  const WebinarListResponseModel({
    required this.webinars,
    required this.pagination,
  });

  final List<WebinarItemModel> webinars;
  final WebinarPaginationModel pagination;

  factory WebinarListResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawWebinars = json['webinars'];
    return WebinarListResponseModel(
      webinars: rawWebinars is List
          ? rawWebinars
              .whereType<Map>()
              .map((Map item) => WebinarItemModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : <WebinarItemModel>[],
      pagination: WebinarPaginationModel.fromJson(_jsonMap(json['pagination'])),
    );
  }
}

class WebinarParticipantModel {
  const WebinarParticipantModel({
    required this.userId,
    required this.fullName,
    required this.role,
    this.speakingPermission,
    this.profilePhoto,
    this.agoraUid,
    this.joinedAt,
    this.leftAt,
  });

  final String userId;
  final String fullName;
  final String role;
  final String? speakingPermission;
  final String? profilePhoto;
  final int? agoraUid;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  bool get canSpeak => speakingPermission == 'granted';
  bool get isSpeakRequested => speakingPermission == 'requested';

  factory WebinarParticipantModel.fromJson(Map<String, dynamic> json) {
    return WebinarParticipantModel(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Not available',
      role: json['role']?.toString() ?? '',
      speakingPermission: WebinarItemModel._nullableString(json['speakingPermission']),
      profilePhoto: WebinarItemModel._nullableString(json['profilePhoto']),
      agoraUid: _asNullableInt(json['agoraUid']),
      joinedAt: WebinarItemModel._parseDate(json['joinedAt']),
      leftAt: WebinarItemModel._parseDate(json['leftAt']),
    );
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class WebinarParticipantsResponseModel {
  const WebinarParticipantsResponseModel({
    required this.webinarId,
    required this.participants,
    required this.pagination,
  });

  final String webinarId;
  final List<WebinarParticipantModel> participants;
  final WebinarPaginationModel pagination;

  factory WebinarParticipantsResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawParticipants = json['participants'];
    return WebinarParticipantsResponseModel(
      webinarId: json['webinarId']?.toString() ?? '',
      participants: rawParticipants is List
          ? rawParticipants
              .whereType<Map>()
              .map((Map item) => WebinarParticipantModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : <WebinarParticipantModel>[],
      pagination: WebinarPaginationModel.fromJson(_jsonMap(json['pagination'])),
    );
  }
}

class AgoraTokenModel {
  const AgoraTokenModel({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.role,
    required this.rtcToken,
    required this.expiresIn,
  });

  final String appId;
  final String channelName;
  final int uid;
  final String role;
  final String rtcToken;
  final int expiresIn;

  factory AgoraTokenModel.fromJson(Map<String, dynamic> json) {
    return AgoraTokenModel(
      appId: json['appId']?.toString() ?? '',
      channelName: json['channelName']?.toString() ?? '',
      uid: WebinarPaginationModel._asInt(json['uid'], 0),
      role: json['role']?.toString() ?? 'subscriber',
      rtcToken: json['rtcToken']?.toString() ?? '',
      expiresIn: WebinarPaginationModel._asInt(json['expiresIn'], 0),
    );
  }
}

class WebinarJoinResultModel {
  const WebinarJoinResultModel({required this.token, required this.participant});

  final AgoraTokenModel token;
  final WebinarParticipantModel participant;

  factory WebinarJoinResultModel.fromJson(Map<String, dynamic> json) {
    return WebinarJoinResultModel(
      token: AgoraTokenModel.fromJson(_jsonMap(json['token'])),
      participant: WebinarParticipantModel.fromJson(_jsonMap(json['participant'])),
    );
  }
}

class WebinarLiveChatModel {
  final String id;
  final String webinarId;
  final String senderUserId;
  final String senderName;
  final String? senderProfilePhoto;
  final String senderRole;
  final String initials;
  final String message;
  final bool isHost;
  final DateTime? createdAt;
  final int colorIndex;

  const WebinarLiveChatModel({
    required this.id,
    required this.webinarId,
    required this.senderUserId,
    required this.senderName,
    required this.message,
    required this.initials,
    this.senderProfilePhoto,
    this.senderRole = '',
    this.isHost = false,
    this.createdAt,
    this.colorIndex = 0,
  });

  factory WebinarLiveChatModel.fromJson(Map<String, dynamic> json) {
    final String senderName =
        json['senderFullName']?.toString().trim().isNotEmpty == true
            ? json['senderFullName'].toString().trim()
            : 'Not available';

    return WebinarLiveChatModel(
      id: json['id']?.toString() ?? '',
      webinarId: json['webinarId']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      senderName: senderName,
      senderProfilePhoto: WebinarItemModel._nullableString(
        json['senderProfilePhoto'],
      ),
      senderRole: json['senderRole']?.toString() ?? '',
      initials: _buildInitials(senderName),
      message: json['message']?.toString() ?? '',
      isHost: json['isHost'] == true,
      createdAt: WebinarItemModel._parseDate(json['createdAt']),
      colorIndex: json['isHost'] == true ? 1 : 0,
    );
  }

  static String _buildInitials(String value) {
    final List<String> parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'NA';

    return parts
        .take(2)
        .map((String item) => item[0].toUpperCase())
        .join();
  }
}

class WebinarChatMessagesResponseModel {
  const WebinarChatMessagesResponseModel({
    required this.webinarId,
    required this.chatMessages,
    required this.pagination,
  });

  final String webinarId;
  final List<WebinarLiveChatModel> chatMessages;
  final WebinarPaginationModel pagination;

  factory WebinarChatMessagesResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawChatMessages = json['chatMessages'];
    return WebinarChatMessagesResponseModel(
      webinarId: json['webinarId']?.toString() ?? '',
      chatMessages: rawChatMessages is List
          ? rawChatMessages
              .whereType<Map>()
              .map((Map item) => WebinarLiveChatModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : <WebinarLiveChatModel>[],
      pagination: WebinarPaginationModel.fromJson(_jsonMap(json['pagination'])),
    );
  }
}
