
class MessagePresenceModel {
  final String userId;
  final bool isOnline;
  final String? lastSeen;
  final String? connectionType;

  MessagePresenceModel({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
    this.connectionType,
  });

  factory MessagePresenceModel.fromJson(Map<String, dynamic> json) {
    return MessagePresenceModel(
      userId: json['userId']?.toString() ?? '',
      isOnline: json['isOnline'] == true,
      lastSeen: json['lastSeen']?.toString(),
      connectionType: json['connectionType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'connectionType': connectionType,
    };
  }

  MessagePresenceModel copyWith({
    String? userId,
    bool? isOnline,
    String? lastSeen,
    String? connectionType,
  }) {
    return MessagePresenceModel(
      userId: userId ?? this.userId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}
