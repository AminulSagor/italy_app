enum LearningActivityKind {
  course,
  lesson,
  quiz,
  exam,
  pdf,
  vocabulary,
  practiceHub,
  jobSentences,
  survivalItalian,
  importantVerbs,
  aiTutor,
  webinar,
}

extension LearningActivityKindApiValue on LearningActivityKind {
  String get apiValue {
    switch (this) {
      case LearningActivityKind.practiceHub:
        return 'practice_hub';
      case LearningActivityKind.jobSentences:
        return 'job_sentences';
      case LearningActivityKind.survivalItalian:
        return 'survival_italian';
      case LearningActivityKind.importantVerbs:
        return 'important_verbs';
      case LearningActivityKind.aiTutor:
        return 'ai_tutor';
      case LearningActivityKind.course:
      case LearningActivityKind.lesson:
      case LearningActivityKind.quiz:
      case LearningActivityKind.exam:
      case LearningActivityKind.pdf:
      case LearningActivityKind.vocabulary:
      case LearningActivityKind.webinar:
        return name;
    }
  }
}

class LearningActivityTimeEntryModel {
  const LearningActivityTimeEntryModel({
    required this.eventId,
    required this.activityKind,
    required this.durationSeconds,
    required this.startedAt,
    required this.endedAt,
    required this.clientActivityDate,
    this.sourceId,
  });

  final String eventId;
  final LearningActivityKind activityKind;
  final String? sourceId;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime endedAt;
  final String clientActivityDate;

  factory LearningActivityTimeEntryModel.fromJson(Map<String, dynamic> json) {
    return LearningActivityTimeEntryModel(
      eventId: json['eventId']?.toString() ?? '',
      activityKind: LearningActivityKind.values.firstWhere(
        (LearningActivityKind item) =>
            item.apiValue == json['activityType']?.toString(),
        orElse: () => LearningActivityKind.course,
      ),
      sourceId: _nullableString(json['sourceId']),
      durationSeconds: _intValue(json['durationSeconds']),
      startedAt: DateTime.parse(json['startedAt'].toString()),
      endedAt: DateTime.parse(json['endedAt'].toString()),
      clientActivityDate: json['clientActivityDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eventId': eventId,
      'activityType': activityKind.apiValue,
      if (sourceId != null) 'sourceId': sourceId,
      'durationSeconds': durationSeconds,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'endedAt': endedAt.toUtc().toIso8601String(),
      'clientActivityDate': clientActivityDate,
    };
  }
}

class WeeklyLearningActivityModel {
  const WeeklyLearningActivityModel({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSeconds,
    required this.days,
  });

  final String weekStart;
  final String weekEnd;
  final int totalSeconds;
  final List<LearningActivityDayModel> days;

  factory WeeklyLearningActivityModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    return WeeklyLearningActivityModel(
      weekStart: json['weekStart']?.toString() ?? '',
      weekEnd: json['weekEnd']?.toString() ?? '',
      totalSeconds: _intValue(json['totalSeconds']),
      days: rawDays is List
          ? rawDays
                .whereType<Map>()
                .map(
                  (Map item) => LearningActivityDayModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : <LearningActivityDayModel>[],
    );
  }
}

class LearningActivityDayModel {
  const LearningActivityDayModel({
    required this.date,
    required this.dayLabel,
    required this.durationSeconds,
  });

  final String date;
  final String dayLabel;
  final int durationSeconds;

  factory LearningActivityDayModel.fromJson(Map<String, dynamic> json) {
    return LearningActivityDayModel(
      date: json['date']?.toString() ?? '',
      dayLabel: json['dayLabel']?.toString() ?? '',
      durationSeconds: _intValue(json['durationSeconds']),
    );
  }
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
