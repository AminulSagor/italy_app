import 'dart:convert';

import 'package:flutter/material.dart';

enum AiTutorMessageRole { user, assistant }

enum AiTutorChatMode { general, writingHelp }

enum AiTutorWritingSourceLanguage { english, bangla }

extension AiTutorChatModeX on AiTutorChatMode {
  String get apiValue {
    switch (this) {
      case AiTutorChatMode.general:
        return 'general';
      case AiTutorChatMode.writingHelp:
        return 'writing_help';
    }
  }
}

extension AiTutorWritingSourceLanguageX on AiTutorWritingSourceLanguage {
  String get apiValue {
    switch (this) {
      case AiTutorWritingSourceLanguage.english:
        return 'english';
      case AiTutorWritingSourceLanguage.bangla:
        return 'bangla';
    }
  }

  String get displayName {
    switch (this) {
      case AiTutorWritingSourceLanguage.english:
        return 'English → Italian';
      case AiTutorWritingSourceLanguage.bangla:
        return 'Bangla → Italian';
    }
  }
}

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
    final Map<String, dynamic> normalizedJson = _normalizeMessageJson(json);
    final String roleValue =
        normalizedJson['role']?.toString().trim().toLowerCase() ?? '';
    final AiTutorCorrectionModel? correction = _correctionFromJson(
      normalizedJson['correction'],
    );
    return AiTutorMessageModel(
      id:
          normalizedJson['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      role: roleValue == 'user'
          ? AiTutorMessageRole.user
          : AiTutorMessageRole.assistant,
      primary:
          _optionalText(normalizedJson['primary'] ?? normalizedJson['text']) ??
          '',
      english: _optionalText(normalizedJson['english']),
      bangla: _optionalText(normalizedJson['bangla']),
      italianSpeechText: _optionalText(
        normalizedJson['italianSpeechText'] ??
            normalizedJson['italian_speech_text'],
      ),
      correction: correction,
      createdAt:
          DateTime.tryParse(normalizedJson['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isPartial:
          normalizedJson['isPartial'] == true ||
          normalizedJson['final'] == false,
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

  factory AiTutorMessageModel.assistant(String text) {
    return AiTutorMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiTutorMessageRole.assistant,
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
      createdAt:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
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
    return <String, dynamic>{'role': role.name, 'content': primary};
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

class AiTutorBalanceModel {
  const AiTutorBalanceModel({
    required this.voiceSeconds,
    required this.textTokens,
  });

  final int voiceSeconds;
  final int textTokens;

  factory AiTutorBalanceModel.fromEnvelope(Map<String, dynamic> json) {
    final Map<String, dynamic> balances = _asJsonMap(json['balances']);
    final Map<String, dynamic> ai = _asJsonMap(balances['ai']);
    return AiTutorBalanceModel(
      voiceSeconds: _intValue(ai['voiceSeconds']),
      textTokens: _intValue(ai['textTokens']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'voiceSeconds': voiceSeconds,
    'textTokens': textTokens,
  };
}

class AiTutorTokenUsageModel {
  const AiTutorTokenUsageModel({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  factory AiTutorTokenUsageModel.fromJson(Map<String, dynamic> json) {
    return AiTutorTokenUsageModel(
      promptTokens: _intValue(json['promptTokens']),
      completionTokens: _intValue(json['completionTokens']),
      totalTokens: _intValue(json['totalTokens']),
    );
  }
}

class AiTutorChatResponseModel {
  const AiTutorChatResponseModel({
    required this.conversationId,
    required this.message,
    required this.memoryFacts,
    required this.recentMistakeTags,
    required this.balances,
    required this.usage,
  });

  final String conversationId;
  final AiTutorMessageModel message;
  final List<String> memoryFacts;
  final List<String> recentMistakeTags;
  final AiTutorBalanceModel balances;
  final AiTutorTokenUsageModel usage;

  factory AiTutorChatResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> messageJson = _asJsonMap(json['message']);
    return AiTutorChatResponseModel(
      conversationId: json['conversationId']?.toString() ?? '',
      message: AiTutorMessageModel.fromJson(messageJson),
      memoryFacts: _stringList(json['memoryFacts'], maxItems: 10),
      recentMistakeTags: _stringList(json['recentMistakeTags'], maxItems: 6),
      balances: AiTutorBalanceModel.fromEnvelope(json),
      usage: AiTutorTokenUsageModel.fromJson(_asJsonMap(json['usage'])),
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
    required this.allocatedSeconds,
    required this.balances,
    this.model,
    this.setup = const <String, dynamic>{},
    this.credentialExpiresAt,
    this.sessionPurpose = 'tutoring',
    this.isFree = false,
  });

  final String sessionId;
  final String url;
  final String room;
  final String identity;
  final String token;
  final int ttlSeconds;
  final int allocatedSeconds;
  final AiTutorBalanceModel balances;
  final String? model;
  final Map<String, dynamic> setup;
  final DateTime? credentialExpiresAt;
  final String sessionPurpose;
  final bool isFree;

  bool get isLevelTest => sessionPurpose == 'level_test';

  factory AiTutorVoiceSessionModel.fromJson(Map<String, dynamic> json) {
    final int ttl = _intValue(json['ttlSeconds']);
    return AiTutorVoiceSessionModel(
      sessionId: json['sessionId']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      identity: json['identity']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      ttlSeconds: ttl > 0 ? ttl : 900,
      allocatedSeconds: _intValue(json['allocatedSeconds']) > 0
          ? _intValue(json['allocatedSeconds'])
          : (ttl > 0 ? ttl : 900),
      balances: AiTutorBalanceModel.fromEnvelope(json),
      model: _optionalText(json['model']),
      setup: _asJsonMap(json['setup']),
      credentialExpiresAt: DateTime.tryParse(
        json['credentialExpiresAt']?.toString() ?? '',
      ),
      sessionPurpose: json['sessionPurpose']?.toString() ?? 'tutoring',
      isFree: json['isFree'] == true,
    );
  }
}

class AiTutorLiveEventModel {
  const AiTutorLiveEventModel({
    required this.eventId,
    required this.type,
    this.text,
    this.handle,
    required this.occurredAt,
  });

  final String eventId;
  final String type;
  final String? text;
  final String? handle;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'eventId': eventId,
    'type': type,
    if (text?.trim().isNotEmpty == true) 'text': text!.trim(),
    if (handle?.trim().isNotEmpty == true) 'handle': handle!.trim(),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
  };
}

class AiTutorVoiceHeartbeatModel {
  const AiTutorVoiceHeartbeatModel({
    required this.active,
    required this.shouldEnd,
    required this.chargedSeconds,
    required this.usedSeconds,
    required this.sessionRemainingSeconds,
    required this.balances,
  });

  final bool active;
  final bool shouldEnd;
  final int chargedSeconds;
  final int usedSeconds;
  final int sessionRemainingSeconds;
  final AiTutorBalanceModel balances;

  factory AiTutorVoiceHeartbeatModel.fromJson(Map<String, dynamic> json) {
    return AiTutorVoiceHeartbeatModel(
      active: json['active'] == true,
      shouldEnd: json['shouldEnd'] == true,
      chargedSeconds: _intValue(json['chargedSeconds']),
      usedSeconds: _intValue(json['usedSeconds']),
      sessionRemainingSeconds: _intValue(json['sessionRemainingSeconds']),
      balances: AiTutorBalanceModel.fromEnvelope(json),
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
      'voiceTransport': 'gemini_live',
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
    this.chatMode = AiTutorChatMode.general,
    this.writingSourceLanguage,
  });

  final String message;
  final List<AiTutorMessageModel> history;
  final String? conversationId;
  final List<String> memoryFacts;
  final List<String> recentMistakeTags;
  final AiTutorChatMode chatMode;
  final AiTutorWritingSourceLanguage? writingSourceLanguage;

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
      'chatMode': chatMode.apiValue,
      if (chatMode == AiTutorChatMode.writingHelp &&
          writingSourceLanguage != null)
        'sourceLanguage': writingSourceLanguage!.apiValue,
    };
  }
}

Map<String, dynamic> _normalizeMessageJson(Map<String, dynamic> json) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
  final Map<String, dynamic> nested = _asJsonMap(normalized['primary']);
  if (nested.isEmpty ||
      (!nested.containsKey('primary') && !nested.containsKey('text'))) {
    return normalized;
  }

  return <String, dynamic>{
    ...normalized,
    ...nested,
    if (normalized.containsKey('id')) 'id': normalized['id'],
    if (normalized.containsKey('role')) 'role': normalized['role'],
    if (normalized.containsKey('createdAt'))
      'createdAt': normalized['createdAt'],
  };
}

Map<String, dynamic> _asJsonMap(dynamic value) {
  dynamic candidate = value;
  for (int attempt = 0; attempt < 2; attempt++) {
    if (candidate is Map<String, dynamic>) {
      return Map<String, dynamic>.from(candidate);
    }
    if (candidate is Map) {
      return Map<String, dynamic>.from(candidate);
    }
    if (candidate is! String) {
      return <String, dynamic>{};
    }

    String encoded = candidate.trim();
    if (encoded.startsWith('```') && encoded.endsWith('```')) {
      final List<String> lines = encoded.split('\n');
      if (lines.length >= 3) {
        encoded = lines.sublist(1, lines.length - 1).join('\n').trim();
      }
    }

    try {
      candidate = jsonDecode(encoded);
    } on FormatException {
      return <String, dynamic>{};
    }
  }
  return <String, dynamic>{};
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

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
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
