enum PracticeHubSkillBuilderType {
  importantVerbs,
  survivalItalian,
  jobSentences,
  dailyChallenges,
}

enum PracticeFinalExamAction {
  locked,
  startExam,
  resultPending,
  viewResult,
  viewCertificate,
  retakeExam,
}

class PracticeHubSkillBuilderModel {
  const PracticeHubSkillBuilderModel({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final PracticeHubSkillBuilderType type;
  final String title;
  final String subtitle;

  factory PracticeHubSkillBuilderModel.fromJson(Map<String, dynamic> json) {
    return PracticeHubSkillBuilderModel(
      type: PracticeHubSkillBuilderType.values.firstWhere(
        (PracticeHubSkillBuilderType value) => value.name == json['type'],
        orElse: () => PracticeHubSkillBuilderType.importantVerbs,
      ),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
    };
  }

  PracticeHubSkillBuilderModel copyWith({
    PracticeHubSkillBuilderType? type,
    String? title,
    String? subtitle,
  }) {
    return PracticeHubSkillBuilderModel(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}

class PracticeHubWebinarModel {
  const PracticeHubWebinarModel({
    required this.id,
    required this.title,
    required this.hostTeacherName,
    required this.status,
    this.dateTime,
    this.thumbnailImageUrl,
  });

  final String id;
  final String title;
  final String hostTeacherName;
  final String status;
  final DateTime? dateTime;
  final String? thumbnailImageUrl;

  bool get isLive => status.toLowerCase() == 'live';

  factory PracticeHubWebinarModel.fromJson(Map<String, dynamic> json) {
    return PracticeHubWebinarModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hostTeacherName: json['hostTeacherName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dateTime: DateTime.tryParse(json['dateTime']?.toString() ?? '')?.toLocal(),
      thumbnailImageUrl: _nullableString(json['thumbnailImageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'hostTeacherName': hostTeacherName,
      'status': status,
      'dateTime': dateTime?.toIso8601String(),
      'thumbnailImageUrl': thumbnailImageUrl,
    };
  }

  PracticeHubWebinarModel copyWith({
    String? id,
    String? title,
    String? hostTeacherName,
    String? status,
    DateTime? dateTime,
    String? thumbnailImageUrl,
  }) {
    return PracticeHubWebinarModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hostTeacherName: hostTeacherName ?? this.hostTeacherName,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
    );
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class PracticeHubOverviewModel {
  const PracticeHubOverviewModel({
    required this.skillBuilders,
    this.featuredWebinar,
  });

  final List<PracticeHubSkillBuilderModel> skillBuilders;
  final PracticeHubWebinarModel? featuredWebinar;

  factory PracticeHubOverviewModel.fromJson(Map<String, dynamic> json) {
    return PracticeHubOverviewModel(
      skillBuilders: _jsonList(json['skillBuilders'])
          .map(PracticeHubSkillBuilderModel.fromJson)
          .toList(growable: false),
      featuredWebinar: _jsonMapOrNull(json['featuredWebinar']) == null
          ? null
          : PracticeHubWebinarModel.fromJson(
              _jsonMapOrNull(json['featuredWebinar'])!,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'skillBuilders': skillBuilders
          .map((PracticeHubSkillBuilderModel item) => item.toJson())
          .toList(growable: false),
      'featuredWebinar': featuredWebinar?.toJson(),
    };
  }

  PracticeHubOverviewModel copyWith({
    List<PracticeHubSkillBuilderModel>? skillBuilders,
    PracticeHubWebinarModel? featuredWebinar,
    bool clearFeaturedWebinar = false,
  }) {
    return PracticeHubOverviewModel(
      skillBuilders: skillBuilders ?? this.skillBuilders,
      featuredWebinar: clearFeaturedWebinar
          ? null
          : featuredWebinar ?? this.featuredWebinar,
    );
  }
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic>? _jsonMapOrNull(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

class PracticeFinalExamCourseModel {
  const PracticeFinalExamCourseModel({
    required this.courseId,
    required this.courseName,
    required this.examTitle,
    required this.unlockCompletionPercent,
    required this.courseProgressPercent,
    required this.isUnlocked,
    required this.hasAttempted,
    required this.isEligible,
    required this.canRetake,
    required this.attemptId,
    required this.attemptStatus,
    required this.resultReady,
    required this.message,
  });

  final String courseId;
  final String courseName;
  final String examTitle;

  final int unlockCompletionPercent;
  final int courseProgressPercent;

  final bool isUnlocked;
  final bool hasAttempted;
  final bool isEligible;
  final bool canRetake;
  final bool resultReady;

  final String attemptId;
  final String attemptStatus;
  final String message;

  PracticeFinalExamAction get action {
    if (!isUnlocked) {
      return PracticeFinalExamAction.locked;
    }

    switch (attemptStatus) {
      case 'certificate_issued':
        return PracticeFinalExamAction.viewCertificate;

      case 'retake_requested':
        return PracticeFinalExamAction.retakeExam;

      case 'in_progress':
      case 'submitted':
      case 'under_review':
        return PracticeFinalExamAction.resultPending;

      case 'evaluated':
        return PracticeFinalExamAction.viewResult;

      case 'cancelled':
        return PracticeFinalExamAction.locked;
    }

    if (!hasAttempted && isEligible) {
      return PracticeFinalExamAction.startExam;
    }

    if (resultReady && attemptId.isNotEmpty) {
      return PracticeFinalExamAction.viewResult;
    }

    return PracticeFinalExamAction.locked;
  }

  String get actionLabelKey {
    switch (action) {
      case PracticeFinalExamAction.startExam:
        return 'start_final_exam';

      case PracticeFinalExamAction.resultPending:
        return 'final_exam_result_pending';

      case PracticeFinalExamAction.viewResult:
        return 'final_exam_view_result';

      case PracticeFinalExamAction.viewCertificate:
        return 'final_exam_view_certificate';

      case PracticeFinalExamAction.retakeExam:
        return 'final_exam_retake';

      case PracticeFinalExamAction.locked:
        return 'locked';
    }
  }

  String get statusLabelKey {
    switch (action) {
      case PracticeFinalExamAction.startExam:
        return 'ready_for_your_final_challenge';

      case PracticeFinalExamAction.resultPending:
        return 'final_exam_review_in_progress';

      case PracticeFinalExamAction.viewResult:
        return 'final_exam_result_available';

      case PracticeFinalExamAction.viewCertificate:
        return 'final_exam_certificate_available';

      case PracticeFinalExamAction.retakeExam:
        return 'final_exam_retake_available';

      case PracticeFinalExamAction.locked:
        return 'final_exam_locked_1';
    }
  }

  factory PracticeFinalExamCourseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final Map<String, dynamic> course =
        _jsonMapOrNull(json['course']) ??
            <String, dynamic>{};

    final Map<String, dynamic> exam =
        _jsonMapOrNull(json['exam']) ??
            <String, dynamic>{};

    int intValue(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();

      return double.tryParse(
        value?.toString() ?? '',
      )?.round() ??
          0;
    }

    return PracticeFinalExamCourseModel(
      courseId:
      course['id']?.toString().trim() ?? '',
      courseName:
      course['title']?.toString().trim() ??
          'Course',
      examTitle:
      exam['title']?.toString().trim() ??
          'Final Exam',
      unlockCompletionPercent:
      intValue(exam['unlockCompletionPercent']),
      courseProgressPercent:
      intValue(json['courseProgressPercent']),
      isUnlocked: json['isUnlocked'] == true,
      hasAttempted: json['hasAttempted'] == true,
      isEligible: json['isEligible'] == true,
      canRetake: json['canRetake'] == true,
      attemptId:
      json['attemptId']?.toString().trim() ?? '',
      attemptStatus:
      json['attemptStatus']?.toString().trim() ?? '',
      resultReady: json['resultReady'] == true,
      message:
      json['message']?.toString().trim() ?? '',
    );
  }
}
