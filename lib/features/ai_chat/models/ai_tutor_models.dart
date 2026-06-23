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

class AiTutorCorrectionModel {
  const AiTutorCorrectionModel({
    required this.original,
    required this.corrected,
    required this.explanation,
    this.rule,
  });

  final String original;
  final String corrected;
  final String explanation;
  final String? rule;

  factory AiTutorCorrectionModel.fromJson(Map<String, dynamic> json) {
    return AiTutorCorrectionModel(
      original: json['original']?.toString().trim() ?? '',
      corrected: json['corrected']?.toString().trim() ?? '',
      explanation: json['explanation']?.toString().trim() ?? '',
      rule: _optionalText(json['rule']),
    );
  }

  bool get isValid =>
      original.isNotEmpty && corrected.isNotEmpty && explanation.isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'original': original,
      'corrected': corrected,
      'explanation': explanation,
      'rule': rule,
    };
  }

  AiTutorCorrectionModel copyWith({
    String? original,
    String? corrected,
    String? explanation,
    String? rule,
  }) {
    return AiTutorCorrectionModel(
      original: original ?? this.original,
      corrected: corrected ?? this.corrected,
      explanation: explanation ?? this.explanation,
      rule: rule ?? this.rule,
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
    this.italianSpeechText,
    this.correction,
    this.isPartial = false,
  });

  final String id;
  final AiTutorMessageRole role;
  final String primary;
  final String? english;
  final String? bangla;
  final String? italianSpeechText;
  final AiTutorCorrectionModel? correction;
  final DateTime createdAt;
  final bool isPartial;

  bool get isUser => role == AiTutorMessageRole.user;

  factory AiTutorMessageModel.fromJson(Map<String, dynamic> json) {
    final String roleValue = json['role']?.toString().trim().toLowerCase() ?? '';
    final AiTutorCorrectionModel? correction = _correctionFromJson(
      json['correction'],
    );
    return AiTutorMessageModel(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      role: roleValue == 'user'
          ? AiTutorMessageRole.user
          : AiTutorMessageRole.assistant,
      primary: (json['primary'] ?? json['text'] ?? '').toString().trim(),
      english: _optionalText(json['english']),
      bangla: _optionalText(json['bangla']),
      italianSpeechText: _optionalText(json['italianSpeechText']),
      correction: correction,
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
      'italianSpeechText': italianSpeechText,
      'correction': correction?.toJson(),
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
    String? italianSpeechText,
    AiTutorCorrectionModel? correction,
    DateTime? createdAt,
    bool? isPartial,
  }) {
    return AiTutorMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      primary: primary ?? this.primary,
      english: english ?? this.english,
      bangla: bangla ?? this.bangla,
      italianSpeechText: italianSpeechText ?? this.italianSpeechText,
      correction: correction ?? this.correction,
      createdAt: createdAt ?? this.createdAt,
      isPartial: isPartial ?? this.isPartial,
    );
  }
}

class AiTutorChatResponseModel {
  const AiTutorChatResponseModel({
    required this.conversationId,
    required this.message,
    required this.memoryFacts,
    required this.recentMistakeTags,
  });

  final String conversationId;
  final AiTutorMessageModel message;
  final List<String> memoryFacts;
  final List<String> recentMistakeTags;

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
      memoryFacts: _stringList(json['memoryFacts'], maxItems: 10),
      recentMistakeTags: _stringList(
        json['recentMistakeTags'],
        maxItems: 6,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'conversationId': conversationId,
      'message': message.toJson(),
      'memoryFacts': memoryFacts,
      'recentMistakeTags': recentMistakeTags,
    };
  }

  AiTutorChatResponseModel copyWith({
    String? conversationId,
    AiTutorMessageModel? message,
    List<String>? memoryFacts,
    List<String>? recentMistakeTags,
  }) {
    return AiTutorChatResponseModel(
      conversationId: conversationId ?? this.conversationId,
      message: message ?? this.message,
      memoryFacts: memoryFacts ?? this.memoryFacts,
      recentMistakeTags: recentMistakeTags ?? this.recentMistakeTags,
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

class AiTutorVoiceSessionRequestModel {
  const AiTutorVoiceSessionRequestModel({
    this.topic,
    this.ttlSeconds = 900,
    this.memoryFacts = const <String>[],
    this.recentMistakeTags = const <String>[],
    this.guidedMode,
    this.guidedLevel,
  });

  final String? topic;
  final int ttlSeconds;
  final List<String> memoryFacts;
  final List<String> recentMistakeTags;
  final String? guidedMode;
  final String? guidedLevel;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (topic?.trim().isNotEmpty == true) 'topic': topic!.trim(),
      'ttlSeconds': ttlSeconds,
      'memoryFacts': memoryFacts,
      'recentMistakeTags': recentMistakeTags,
      if (guidedMode?.trim().isNotEmpty == true)
        'guidedMode': guidedMode!.trim(),
      if (guidedLevel?.trim().isNotEmpty == true)
        'guidedLevel': guidedLevel!.trim().toUpperCase(),
    };
  }
}

class AiTutorChatRequestModel {
  const AiTutorChatRequestModel({
    required this.message,
    required this.history,
    this.conversationId,
    this.memoryFacts = const <String>[],
    this.recentMistakeTags = const <String>[],
  });

  final String message;
  final List<AiTutorMessageModel> history;
  final String? conversationId;
  final List<String> memoryFacts;
  final List<String> recentMistakeTags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message.trim(),
      if (conversationId?.trim().isNotEmpty == true)
        'conversationId': conversationId!.trim(),
      'history': history
          .takeLast(20)
          .map((AiTutorMessageModel item) => item.toHistoryJson())
          .toList(growable: false),
      'memoryFacts': memoryFacts,
      'recentMistakeTags': recentMistakeTags,
    };
  }
}

AiTutorCorrectionModel? _correctionFromJson(dynamic value) {
  if (value is! Map) {
    return null;
  }
  final AiTutorCorrectionModel correction = AiTutorCorrectionModel.fromJson(
    Map<String, dynamic>.from(value),
  );
  return correction.isValid ? correction : null;
}

String? _optionalText(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

List<String> _stringList(dynamic value, {required int maxItems}) {
  if (value is! List) {
    return <String>[];
  }
  return value
      .map((dynamic item) => item?.toString().trim() ?? '')
      .where((String item) => item.isNotEmpty)
      .take(maxItems)
      .toList(growable: false);
}

extension IterableTakeLast<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final List<T> values = toList(growable: false);
    if (values.length <= count) {
      return values;
    }
    return values.skip(values.length - count);
  }
}
