class CurrentUserSummary {
  const CurrentUserSummary({
    required this.id,
    required this.fullName,
    required this.learnerLevel,
    required this.currentStreakDays,
    this.aiVoiceSeconds = 0,
    this.aiTextTokens = 0,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String learnerLevel;
  final int currentStreakDays;
  final int aiVoiceSeconds;
  final int aiTextTokens;
  final String? avatarUrl;

  factory CurrentUserSummary.fromJson(Map<String, dynamic> json) {
    return CurrentUserSummary(
      id: json['id']?.toString().trim() ?? '',
      fullName: json['fullName']?.toString().trim() ?? '',
      learnerLevel: json['learnerLevel']?.toString().trim() ?? 'A1',
      currentStreakDays: _intValue(json['currentStreakDays']),
      aiVoiceSeconds: _intValue(json['aiVoiceSeconds']),
      aiTextTokens: _intValue(json['aiTextTokens']),
      avatarUrl: _nullableString(json['avatarUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'learnerLevel': learnerLevel,
      'currentStreakDays': currentStreakDays,
      'aiVoiceSeconds': aiVoiceSeconds,
      'aiTextTokens': aiTextTokens,
      'avatarUrl': avatarUrl,
    };
  }

  CurrentUserSummary copyWith({
    String? id,
    String? fullName,
    String? learnerLevel,
    int? currentStreakDays,
    int? aiVoiceSeconds,
    int? aiTextTokens,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return CurrentUserSummary(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      learnerLevel: learnerLevel ?? this.learnerLevel,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      aiVoiceSeconds: aiVoiceSeconds ?? this.aiVoiceSeconds,
      aiTextTokens: aiTextTokens ?? this.aiTextTokens,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
