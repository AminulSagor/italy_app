enum AiTutorSkillType { speaking, vocabulary, grammar }

enum AiTutorQuestionType { openText, singleChoice }

class AiTutorLevelQuestionModel {
  const AiTutorLevelQuestionModel({
    required this.id,
    required this.skill,
    required this.type,
    required this.prompt,
    required this.helperText,
    this.options = const <String>[],
  });

  final String id;
  final AiTutorSkillType skill;
  final AiTutorQuestionType type;
  final String prompt;
  final String helperText;
  final List<String> options;

  AiTutorLevelQuestionModel copyWith({
    String? id,
    AiTutorSkillType? skill,
    AiTutorQuestionType? type,
    String? prompt,
    String? helperText,
    List<String>? options,
  }) {
    return AiTutorLevelQuestionModel(
      id: id ?? this.id,
      skill: skill ?? this.skill,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      helperText: helperText ?? this.helperText,
      options: options ?? this.options,
    );
  }
}

class AiTutorLevelAnswerModel {
  const AiTutorLevelAnswerModel({
    required this.questionId,
    required this.skill,
    required this.question,
    required this.answer,
  });

  final String questionId;
  final AiTutorSkillType skill;
  final String question;
  final String answer;

  factory AiTutorLevelAnswerModel.fromJson(Map<String, dynamic> json) {
    return AiTutorLevelAnswerModel(
      questionId: json['questionId']?.toString() ?? '',
      skill: AiTutorSkillType.values.firstWhere(
        (AiTutorSkillType item) => item.name == json['skill']?.toString(),
        orElse: () => AiTutorSkillType.grammar,
      ),
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'questionId': questionId,
      'skill': skill.name,
      'question': question,
      'answer': answer,
    };
  }

  AiTutorLevelAnswerModel copyWith({
    String? questionId,
    AiTutorSkillType? skill,
    String? question,
    String? answer,
  }) {
    return AiTutorLevelAnswerModel(
      questionId: questionId ?? this.questionId,
      skill: skill ?? this.skill,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}

class AiTutorLearnerProfileModel {
  const AiTutorLearnerProfileModel({
    required this.speakingLevel,
    required this.vocabularyLevel,
    required this.grammarLevel,
    required this.finalLevel,
    required this.summary,
    required this.strengths,
    required this.focusAreas,
    required this.completedAt,
  });

  final String speakingLevel;
  final String vocabularyLevel;
  final String grammarLevel;
  final String finalLevel;
  final String summary;
  final List<String> strengths;
  final List<String> focusAreas;
  final DateTime completedAt;

  bool get isBeginner => _levelRank(finalLevel) <= _levelRank('A2');

  bool get isAdvanced => _levelRank(finalLevel) >= _levelRank('B2');

  String get adaptiveLabel {
    if (isBeginner) {
      return 'Slow + simple practice';
    }
    if (isAdvanced) {
      return 'Natural + challenging practice';
    }
    return 'Clear + progressive practice';
  }

  factory AiTutorLearnerProfileModel.fromJson(Map<String, dynamic> json) {
    return AiTutorLearnerProfileModel(
      speakingLevel: _normalizeLevel(json['speakingLevel']),
      vocabularyLevel: _normalizeLevel(json['vocabularyLevel']),
      grammarLevel: _normalizeLevel(json['grammarLevel']),
      finalLevel: _normalizeLevel(json['finalLevel']),
      summary: json['summary']?.toString().trim().isNotEmpty == true
          ? json['summary'].toString().trim()
          : 'Your AI tutor will adapt lessons to this result.',
      strengths: _stringList(json['strengths']),
      focusAreas: _stringList(json['focusAreas']),
      completedAt:
          DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'speakingLevel': speakingLevel,
      'vocabularyLevel': vocabularyLevel,
      'grammarLevel': grammarLevel,
      'finalLevel': finalLevel,
      'summary': summary,
      'strengths': strengths,
      'focusAreas': focusAreas,
      'completedAt': completedAt.toUtc().toIso8601String(),
    };
  }

  AiTutorLearnerProfileModel copyWith({
    String? speakingLevel,
    String? vocabularyLevel,
    String? grammarLevel,
    String? finalLevel,
    String? summary,
    List<String>? strengths,
    List<String>? focusAreas,
    DateTime? completedAt,
  }) {
    return AiTutorLearnerProfileModel(
      speakingLevel: speakingLevel ?? this.speakingLevel,
      vocabularyLevel: vocabularyLevel ?? this.vocabularyLevel,
      grammarLevel: grammarLevel ?? this.grammarLevel,
      finalLevel: finalLevel ?? this.finalLevel,
      summary: summary ?? this.summary,
      strengths: strengths ?? this.strengths,
      focusAreas: focusAreas ?? this.focusAreas,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static const List<String> _levels = <String>[
    'A1',
    'A1+',
    'A2',
    'A2+',
    'B1',
    'B1+',
    'B2',
    'B2+',
    'C1',
    'C2',
  ];

  static int _levelRank(String value) {
    final int index = _levels.indexOf(value.toUpperCase());
    return index == -1 ? 0 : index;
  }

  static String _normalizeLevel(dynamic value) {
    final String level = value?.toString().trim().toUpperCase() ?? '';
    return _levels.contains(level) ? level : 'A1';
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }
    return value
        .map((dynamic item) => item?.toString().trim() ?? '')
        .where((String item) => item.isNotEmpty)
        .take(6)
        .toList(growable: false);
  }
}

class AiTutorLevelTestResponseModel {
  const AiTutorLevelTestResponseModel({required this.profile});

  final AiTutorLearnerProfileModel profile;

  factory AiTutorLevelTestResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawProfile = json['profile'];
    final Map<String, dynamic> profileJson = rawProfile is Map<String, dynamic>
        ? rawProfile
        : rawProfile is Map
        ? Map<String, dynamic>.from(rawProfile)
        : <String, dynamic>{};
    return AiTutorLevelTestResponseModel(
      profile: AiTutorLearnerProfileModel.fromJson(profileJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'profile': profile.toJson()};
  }
}

class AiTutorLevelProfileResponseModel {
  const AiTutorLevelProfileResponseModel({
    required this.profile,
    required this.attemptsUsed,
    required this.maxAttempts,
    required this.attemptsRemaining,
    required this.canAttempt,
    required this.hasPaidAccess,
  });

  final AiTutorLearnerProfileModel? profile;
  final int attemptsUsed;
  final int maxAttempts;
  final int attemptsRemaining;
  final bool canAttempt;
  final bool hasPaidAccess;

  factory AiTutorLevelProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawProfile = json['profile'];
    if (rawProfile is Map<String, dynamic>) {
      return AiTutorLevelProfileResponseModel(
        profile: AiTutorLearnerProfileModel.fromJson(rawProfile),
        attemptsUsed: _intValue(json['attemptsUsed']),
        maxAttempts: _intValue(json['maxAttempts']),
        attemptsRemaining: _intValue(json['attemptsRemaining']),
        canAttempt: json['canAttempt'] != false,
        hasPaidAccess: json['hasPaidAccess'] == true,
      );
    }
    if (rawProfile is Map) {
      return AiTutorLevelProfileResponseModel(
        profile: AiTutorLearnerProfileModel.fromJson(
          Map<String, dynamic>.from(rawProfile),
        ),
        attemptsUsed: _intValue(json['attemptsUsed']),
        maxAttempts: _intValue(json['maxAttempts']),
        attemptsRemaining: _intValue(json['attemptsRemaining']),
        canAttempt: json['canAttempt'] != false,
        hasPaidAccess: json['hasPaidAccess'] == true,
      );
    }
    return AiTutorLevelProfileResponseModel(
      profile: null,
      attemptsUsed: _intValue(json['attemptsUsed']),
      maxAttempts: _intValue(json['maxAttempts']),
      attemptsRemaining: _intValue(json['attemptsRemaining']),
      canAttempt: json['canAttempt'] != false,
      hasPaidAccess: json['hasPaidAccess'] == true,
    );
  }
}

class AiTutorLevelTranscriptionResponseModel {
  const AiTutorLevelTranscriptionResponseModel({required this.transcript});

  final String transcript;

  factory AiTutorLevelTranscriptionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiTutorLevelTranscriptionResponseModel(
      transcript: json['transcript']?.toString().trim() ?? '',
    );
  }
}

class AiTutorLevelTestRequestModel {
  const AiTutorLevelTestRequestModel({required this.answers});

  final List<AiTutorLevelAnswerModel> answers;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'answers': answers
          .map((AiTutorLevelAnswerModel item) => item.toJson())
          .toList(growable: false),
    };
  }
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
