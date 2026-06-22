import 'package:flutter/material.dart';

enum AiTutorMessageRole { user, assistant }

class AiTutorStarterModel {
  const AiTutorStarterModel({
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.isVoice,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String prompt;
  final bool isVoice;
  final IconData icon;

  AiTutorStarterModel copyWith({
    String? title,
    String? subtitle,
    String? prompt,
    bool? isVoice,
    IconData? icon,
  }) {
    return AiTutorStarterModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      prompt: prompt ?? this.prompt,
      isVoice: isVoice ?? this.isVoice,
      icon: icon ?? this.icon,
    );
  }
}

class AiTutorMessageModel {
  const AiTutorMessageModel({
    required this.id,
    required this.role,
    required this.primary,
    required this.createdAt,
    this.english,
    this.bangla,
    this.isPartial = false,
  });

  final String id;
  final AiTutorMessageRole role;
  final String primary;
  final String? english;
  final String? bangla;
  final DateTime createdAt;
  final bool isPartial;

  bool get isUser => role == AiTutorMessageRole.user;

  factory AiTutorMessageModel.fromJson(Map<String, dynamic> json) {
    final String roleValue = json['role']?.toString().trim().toLowerCase() ?? '';
    return AiTutorMessageModel(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      role: roleValue == 'user'
          ? AiTutorMessageRole.user
          : AiTutorMessageRole.assistant,
      primary: (json['primary'] ?? json['text'] ?? '').toString().trim(),
      english: _optionalText(json['english']),
      bangla: _optionalText(json['bangla']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isPartial: json['isPartial'] == true || json['final'] == false,
    );
  }

  factory AiTutorMessageModel.user(String text) {
    return AiTutorMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiTutorMessageRole.user,
      primary: text.trim(),
      createdAt: DateTime.now(),
    );
  }

  factory AiTutorMessageModel.fromTranscript(Map<String, dynamic> json) {
    final String role = json['role']?.toString().trim().toLowerCase() ?? '';
    return AiTutorMessageModel(
      id: json['messageId']?.toString().trim().isNotEmpty == true
          ? json['messageId'].toString().trim()
          : '${DateTime.now().microsecondsSinceEpoch}-$role',
      role: role == 'user'
          ? AiTutorMessageRole.user
          : AiTutorMessageRole.assistant,
      primary: json['text']?.toString().trim() ?? '',
      createdAt: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      isPartial: json['final'] == false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role.name,
      'primary': primary,
      'english': english,
      'bangla': bangla,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isPartial': isPartial,
    };
  }

  Map<String, dynamic> toHistoryJson() {
    return <String, dynamic>{
      'role': role.name,
      'content': primary,
    };
  }

  AiTutorMessageModel copyWith({
    String? id,
    AiTutorMessageRole? role,
    String? primary,
    String? english,
    String? bangla,
    DateTime? createdAt,
    bool? isPartial,
  }) {
    return AiTutorMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      primary: primary ?? this.primary,
      english: english ?? this.english,
      bangla: bangla ?? this.bangla,
      createdAt: createdAt ?? this.createdAt,
      isPartial: isPartial ?? this.isPartial,
    );
  }

  static String? _optionalText(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class AiTutorChatResponseModel {
  const AiTutorChatResponseModel({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AiTutorMessageModel message;

  factory AiTutorChatResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawMessage = json['message'];
    final Map<String, dynamic> messageJson = rawMessage is Map<String, dynamic>
        ? rawMessage
        : rawMessage is Map
            ? Map<String, dynamic>.from(rawMessage)
            : <String, dynamic>{};
    return AiTutorChatResponseModel(
      conversationId: json['conversationId']?.toString() ?? '',
      message: AiTutorMessageModel.fromJson(messageJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'conversationId': conversationId,
      'message': message.toJson(),
    };
  }

  AiTutorChatResponseModel copyWith({
    String? conversationId,
    AiTutorMessageModel? message,
  }) {
    return AiTutorChatResponseModel(
      conversationId: conversationId ?? this.conversationId,
      message: message ?? this.message,
    );
  }
}

class AiTutorVoiceSessionModel {
  const AiTutorVoiceSessionModel({
    required this.sessionId,
    required this.url,
    required this.room,
    required this.identity,
    required this.token,
    required this.ttlSeconds,
  });

  final String sessionId;
  final String url;
  final String room;
  final String identity;
  final String token;
  final int ttlSeconds;

  factory AiTutorVoiceSessionModel.fromJson(Map<String, dynamic> json) {
    return AiTutorVoiceSessionModel(
      sessionId: json['sessionId']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      identity: json['identity']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      ttlSeconds: int.tryParse(json['ttlSeconds']?.toString() ?? '') ?? 900,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'url': url,
      'room': room,
      'identity': identity,
      'token': token,
      'ttlSeconds': ttlSeconds,
    };
  }

  AiTutorVoiceSessionModel copyWith({
    String? sessionId,
    String? url,
    String? room,
    String? identity,
    String? token,
    int? ttlSeconds,
  }) {
    return AiTutorVoiceSessionModel(
      sessionId: sessionId ?? this.sessionId,
      url: url ?? this.url,
      room: room ?? this.room,
      identity: identity ?? this.identity,
      token: token ?? this.token,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
    );
  }
}
