enum CourseCardState { active, locked }

enum SkillBuilderTone { green, yellow, blue, pink }

enum CourseChapterState { completed, current, free, available, locked }

class CoursesDashboardModel {
  final List<CourseCardModel> courses;
  final List<SkillBuilderModel> skillBuilders;
  final SpecializedLearningModel specializedLearning;

  const CoursesDashboardModel({
    required this.courses,
    required this.skillBuilders,
    required this.specializedLearning,
  });

  factory CoursesDashboardModel.fromJson(Map<String, dynamic> json) {
    return CoursesDashboardModel(
      courses: (json['courses'] as List<dynamic>)
          .map(
            (dynamic item) =>
                CourseCardModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      skillBuilders: (json['skillBuilders'] as List<dynamic>)
          .map(
            (dynamic item) =>
                SkillBuilderModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      specializedLearning: SpecializedLearningModel.fromJson(
        json['specializedLearning'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courses': courses.map((CourseCardModel item) => item.toJson()).toList(),
      'skillBuilders': skillBuilders
          .map((SkillBuilderModel item) => item.toJson())
          .toList(),
      'specializedLearning': specializedLearning.toJson(),
    };
  }

  CoursesDashboardModel copyWith({
    List<CourseCardModel>? courses,
    List<SkillBuilderModel>? skillBuilders,
    SpecializedLearningModel? specializedLearning,
  }) {
    return CoursesDashboardModel(
      courses: courses ?? this.courses,
      skillBuilders: skillBuilders ?? this.skillBuilders,
      specializedLearning: specializedLearning ?? this.specializedLearning,
    );
  }
}

class CourseCardModel {
  final String id;
  final String title;
  final String courseId;
  final String chapterId;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final String statusLabel;
  final CourseCardState state;

  const CourseCardModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.chapterId,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.statusLabel,
    required this.state,
  });

  factory CourseCardModel.fromJson(Map<String, dynamic> json) {
    return CourseCardModel(
      id: json['id'] as String,
      courseId: json['courseId']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      progressLabel: json['progressLabel'] as String,
      progress: (json['progress'] as num).toDouble(),
      statusLabel: json['statusLabel'] as String,
      state: CourseCardState.values.firstWhere(
        (CourseCardState item) => item.name == json['state'],
        orElse: () => CourseCardState.locked,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'subtitle': subtitle,
      'progressLabel': progressLabel,
      'progress': progress,
      'statusLabel': statusLabel,
      'state': state.name,
    };
  }

  CourseCardModel copyWith({
    String? id,
    String? courseId,
    String? chapterId,
    String? title,
    String? subtitle,
    String? progressLabel,
    double? progress,
    String? statusLabel,
    CourseCardState? state,
  }) {
    return CourseCardModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progressLabel: progressLabel ?? this.progressLabel,
      progress: progress ?? this.progress,
      statusLabel: statusLabel ?? this.statusLabel,
      state: state ?? this.state,
    );
  }
}

class SkillBuilderModel {
  final String id;
  final String title;
  final String courseId;
  final String chapterId;
  final String iconName;
  final SkillBuilderTone tone;

  const SkillBuilderModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.chapterId,
    required this.iconName,
    required this.tone,
  });

  factory SkillBuilderModel.fromJson(Map<String, dynamic> json) {
    return SkillBuilderModel(
      id: json['id'] as String,
      courseId: json['courseId']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      tone: SkillBuilderTone.values.firstWhere(
        (SkillBuilderTone item) => item.name == json['tone'],
        orElse: () => SkillBuilderTone.green,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'iconName': iconName,
      'tone': tone.name,
    };
  }

  SkillBuilderModel copyWith({
    String? id,
    String? courseId,
    String? chapterId,
    String? title,
    String? iconName,
    SkillBuilderTone? tone,
  }) {
    return SkillBuilderModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      tone: tone ?? this.tone,
    );
  }
}

class SpecializedLearningModel {
  final String title;
  final String subtitle;
  final String requirementLabel;
  final String lockedLabel;

  const SpecializedLearningModel({
    required this.title,
    required this.subtitle,
    required this.requirementLabel,
    required this.lockedLabel,
  });

  factory SpecializedLearningModel.fromJson(Map<String, dynamic> json) {
    return SpecializedLearningModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      requirementLabel: json['requirementLabel'] as String,
      lockedLabel: json['lockedLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'requirementLabel': requirementLabel,
      'lockedLabel': lockedLabel,
    };
  }

  SpecializedLearningModel copyWith({
    String? title,
    String? subtitle,
    String? requirementLabel,
    String? lockedLabel,
  }) {
    return SpecializedLearningModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      requirementLabel: requirementLabel ?? this.requirementLabel,
      lockedLabel: lockedLabel ?? this.lockedLabel,
    );
  }
}

class CourseDetailModel {
  final String id;
  final String title;
  final String courseId;
  final String chapterId;
  final String progressLabel;
  final bool isProEnabled;
  final bool isFree;
  final int lessonCount;
  final bool isExamFinished;
  final List<CourseChapterModel> chapters;
  final CourseFinalExamModel finalExam;

  const CourseDetailModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.chapterId,
    required this.progressLabel,
    required this.isProEnabled,
    this.isFree = false,
    this.lessonCount = 0,
    required this.isExamFinished,
    required this.chapters,
    required this.finalExam,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: json['id'] as String,
      courseId: json['courseId']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      title: json['title'] as String,
      progressLabel: json['progressLabel'] as String,
      isProEnabled: json['isProEnabled'] as bool,
      isFree: json['isFree'] as bool? ?? false,
      lessonCount: (json['lessonCount'] as num?)?.toInt() ?? 0,
      isExamFinished: json['isExamFinished'] as bool,
      chapters: (json['chapters'] as List<dynamic>)
          .map(
            (dynamic item) =>
                CourseChapterModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      finalExam: CourseFinalExamModel.fromJson(
        json['finalExam'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'progressLabel': progressLabel,
      'isProEnabled': isProEnabled,
      'isFree': isFree,
      'lessonCount': lessonCount,
      'isExamFinished': isExamFinished,
      'chapters': chapters
          .map((CourseChapterModel item) => item.toJson())
          .toList(),
      'finalExam': finalExam.toJson(),
    };
  }

  CourseDetailModel copyWith({
    String? id,
    String? courseId,
    String? chapterId,
    String? title,
    String? progressLabel,
    bool? isProEnabled,
    bool? isFree,
    int? lessonCount,
    bool? isExamFinished,
    List<CourseChapterModel>? chapters,
    CourseFinalExamModel? finalExam,
  }) {
    return CourseDetailModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      progressLabel: progressLabel ?? this.progressLabel,
      isProEnabled: isProEnabled ?? this.isProEnabled,
      isFree: isFree ?? this.isFree,
      lessonCount: lessonCount ?? this.lessonCount,
      isExamFinished: isExamFinished ?? this.isExamFinished,
      chapters: chapters ?? this.chapters,
      finalExam: finalExam ?? this.finalExam,
    );
  }
}

class CourseChapterModel {
  final String id;
  final String courseId;
  final String chapterId;
  final String title;
  final String subtitle;
  final String? statusLabel;
  final String? tagLabel;
  final double progress;
  final CourseChapterState state;

  const CourseChapterModel({
    required this.id,
    required this.courseId,
    required this.chapterId,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.state,
    this.statusLabel,
    this.tagLabel,
  });

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    return CourseChapterModel(
      id: json['id'] as String,
      courseId: json['courseId']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      statusLabel: json['statusLabel'] as String?,
      tagLabel: json['tagLabel'] as String?,
      progress: (json['progress'] as num).toDouble(),
      state: CourseChapterState.values.firstWhere(
        (CourseChapterState item) => item.name == json['state'],
        orElse: () => CourseChapterState.locked,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'subtitle': subtitle,
      'statusLabel': statusLabel,
      'tagLabel': tagLabel,
      'progress': progress,
      'state': state.name,
    };
  }

  CourseChapterModel copyWith({
    String? id,
    String? courseId,
    String? chapterId,
    String? title,
    String? subtitle,
    String? statusLabel,
    String? tagLabel,
    double? progress,
    CourseChapterState? state,
  }) {
    return CourseChapterModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      statusLabel: statusLabel ?? this.statusLabel,
      tagLabel: tagLabel ?? this.tagLabel,
      progress: progress ?? this.progress,
      state: state ?? this.state,
    );
  }
}

class CourseFinalExamModel {
  final String examId;
  final String title;
  final String description;
  final String actionLabel;
  final String helperLabel;
  final bool isConfigured;
  final bool canStart;

  // Add these three fields.
  final bool hasAttempted;
  final bool isEligible;
  final String attemptStatus;
  bool get hasCertificate =>
      attemptStatus == 'certificate_issued';
  final int courseProgressPercent;
  final int unlockCompletionPercent;

  const CourseFinalExamModel({
    required this.examId,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.helperLabel,
    required this.isConfigured,
    required this.canStart,
    required this.hasAttempted,
    required this.isEligible,
    required this.attemptStatus,
    required this.courseProgressPercent,
    required this.unlockCompletionPercent,
  });

  factory CourseFinalExamModel.fromJson(Map<String, dynamic> json) {
    return CourseFinalExamModel(
      examId: json['examId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Final Exam',
      description: json['description']?.toString() ?? '',
      actionLabel: json['actionLabel']?.toString() ?? '',
      helperLabel: json['helperLabel']?.toString() ?? '',
      isConfigured: json['isConfigured'] as bool? ?? false,
      canStart: json['canStart'] as bool? ?? false,
      hasAttempted: json['hasAttempted'] as bool? ?? false,
      isEligible: json['isEligible'] as bool? ?? false,
      attemptStatus: json['attemptStatus']?.toString() ?? '',
      courseProgressPercent: _intValue(json['courseProgressPercent']),
      unlockCompletionPercent: _intValue(
        json['unlockCompletionPercent'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'examId': examId,
      'title': title,
      'description': description,
      'actionLabel': actionLabel,
      'helperLabel': helperLabel,
      'isConfigured': isConfigured,
      'canStart': canStart,
      'hasAttempted': hasAttempted,
      'isEligible': isEligible,
      'attemptStatus': attemptStatus,
      'courseProgressPercent': courseProgressPercent,
      'unlockCompletionPercent': unlockCompletionPercent,
    };
  }
}

class CourseProgressModel {
  final String courseId;
  final int completedLessons;
  final int totalLessons;
  final double completionPercent;

  const CourseProgressModel({
    required this.courseId,
    required this.completedLessons,
    required this.totalLessons,
    required this.completionPercent,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      courseId: json['courseId']?.toString() ?? '',
      completedLessons: _intValue(json['completedLessons']),
      totalLessons: _intValue(json['totalLessons']),
      completionPercent: _doubleValue(json['completionPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'completionPercent': completionPercent,
    };
  }

  CourseProgressModel copyWith({
    String? courseId,
    int? completedLessons,
    int? totalLessons,
    double? completionPercent,
  }) {
    return CourseProgressModel(
      courseId: courseId ?? this.courseId,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }
}

class CourseLessonProgressModel {
  final String lessonId;
  final int videoWatchPercent;
  final bool isTheoryRead;
  final bool isCompleted;

  const CourseLessonProgressModel({
    required this.lessonId,
    required this.videoWatchPercent,
    required this.isTheoryRead,
    required this.isCompleted,
  });

  const CourseLessonProgressModel.empty({required this.lessonId})
      : videoWatchPercent = 0,
        isTheoryRead = false,
        isCompleted = false;

  factory CourseLessonProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseLessonProgressModel(
      lessonId: json['lessonId']?.toString() ?? '',
      videoWatchPercent: _intValue(json['videoWatchPercent'])
          .clamp(0, 100)
          .toInt(),
      isTheoryRead: _boolValue(json['isTheoryRead']),
      isCompleted: _boolValue(json['isCompleted']),
    );
  }

  double get progress {
    if (isCompleted) return 1;
    return (videoWatchPercent / 100).clamp(0.0, 1.0).toDouble();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lessonId': lessonId,
      'videoWatchPercent': videoWatchPercent,
      'isTheoryRead': isTheoryRead,
      'isCompleted': isCompleted,
    };
  }

  CourseLessonProgressModel copyWith({
    String? lessonId,
    int? videoWatchPercent,
    bool? isTheoryRead,
    bool? isCompleted,
  }) {
    return CourseLessonProgressModel(
      lessonId: lessonId ?? this.lessonId,
      videoWatchPercent: videoWatchPercent ?? this.videoWatchPercent,
      isTheoryRead: isTheoryRead ?? this.isTheoryRead,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}
