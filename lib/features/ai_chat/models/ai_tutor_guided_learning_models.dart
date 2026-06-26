enum AiTutorGuidedMode {
  guided(
    apiValue: 'guided',
    title: 'Guided Mode',
    levelLabel: 'Beginner',
  ),
  assisted(
    apiValue: 'assisted',
    title: 'Assisted Mode',
    levelLabel: 'Intermediate',
  ),
  free(
    apiValue: 'free',
    title: 'Free Mode',
    levelLabel: 'Advanced',
  );

  const AiTutorGuidedMode({
    required this.apiValue,
    required this.title,
    required this.levelLabel,
  });

  final String apiValue;
  final String title;
  final String levelLabel;

  static AiTutorGuidedMode fromApiValue(String? value) {
    return AiTutorGuidedMode.values.firstWhere(
      (AiTutorGuidedMode item) => item.apiValue == value?.trim().toLowerCase(),
      orElse: () => AiTutorGuidedMode.guided,
    );
  }
}

class AiTutorGuidedSessionContext {
  const AiTutorGuidedSessionContext({
    required this.level,
    required this.mode,
    required this.topic,
  });

  final String level;
  final AiTutorGuidedMode mode;
  final String topic;

  String get displayLabel => '$level · ${mode.title}';

  factory AiTutorGuidedSessionContext.fromJson(Map<String, dynamic> json) {
    return AiTutorGuidedSessionContext(
      level: json['level']?.toString().trim().toUpperCase() ?? 'A1',
      mode: AiTutorGuidedMode.fromApiValue(json['mode']?.toString()),
      topic: json['topic']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'mode': mode.apiValue,
      'topic': topic,
    };
  }

  AiTutorGuidedSessionContext copyWith({
    String? level,
    AiTutorGuidedMode? mode,
    String? topic,
  }) {
    return AiTutorGuidedSessionContext(
      level: level ?? this.level,
      mode: mode ?? this.mode,
      topic: topic ?? this.topic,
    );
  }
}
