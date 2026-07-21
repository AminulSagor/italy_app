enum FinalExamSectionType {
  coreQuiz,
  listeningLab,
  writingTask,
  speakingLab,
  unknown,
}

class FinalExamGatewayModel {
  final String courseId;
  final String courseTitle;
  final String courseSubtitle;

  final String examId;
  final String examTitle;
  final String examDescription;

  final String attemptId;
  final String attemptStatus;

  final int totalDurationMinutes;
  final int unlockCompletionPercent;
  final int courseProgressPercent;

  final String resultNotice;
  final String resultNoticeBn;
  final String message;

  final bool isUnlocked;
  final bool hasAttempted;
  final bool isEligible;
  final bool resultReady;

  const FinalExamGatewayModel({
    required this.courseId,
    required this.courseTitle,
    required this.courseSubtitle,
    required this.examId,
    required this.examTitle,
    required this.examDescription,
    required this.attemptId,
    required this.attemptStatus,
    required this.totalDurationMinutes,
    required this.unlockCompletionPercent,
    required this.courseProgressPercent,
    required this.resultNotice,
    required this.resultNoticeBn,
    required this.message,
    required this.isUnlocked,
    required this.hasAttempted,
    required this.isEligible,
    required this.resultReady,
  });

  bool get canViewResult {
    return resultReady && attemptId.trim().isNotEmpty;
  }

  bool get isResultPending {
    return hasAttempted && !resultReady;
  }

  factory FinalExamGatewayModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final Map<String, dynamic> course = _map(json['course']);
    final Map<String, dynamic> exam = _map(json['exam']);

    return FinalExamGatewayModel(
      courseId: _string(course['id']),
      courseTitle: _string(course['title']),
      courseSubtitle: _string(course['subtitle']),

      examId: _string(exam['id']),
      examTitle: _string(exam['title']),
      examDescription: _string(exam['description']),

      // New backend fields
      attemptId: _string(json['attemptId']),
      attemptStatus: _string(json['attemptStatus']),

      totalDurationMinutes: _int(
        exam['totalDurationMinutes'],
      ),
      unlockCompletionPercent: _int(
        exam['unlockCompletionPercent'],
      ),
      courseProgressPercent: _int(
        json['courseProgressPercent'],
      ),

      resultNotice: _string(exam['resultNotice']),
      resultNoticeBn: _string(exam['resultNoticeBn']),
      message: _string(json['message']),

      isUnlocked: _bool(json['isUnlocked']),
      hasAttempted: _bool(json['hasAttempted']),
      isEligible: _bool(json['isEligible']),
      resultReady: _bool(json['resultReady']),
    );
  }
}

class FinalExamAttemptModel {
  final String id;
  final String referenceCode;
  final String status;
  final DateTime? startedAt;
  final String examId;
  final String examTitle;
  final String courseTitle;
  final int totalDurationMinutes;
  final List<FinalExamSectionModel> sections;

  const FinalExamAttemptModel({
    required this.id,
    required this.referenceCode,
    required this.status,
    required this.startedAt,
    required this.examId,
    required this.examTitle,
    required this.courseTitle,
    required this.totalDurationMinutes,
    required this.sections,
  });

  factory FinalExamAttemptModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> attempt = _map(json['attempt']);
    final Map<String, dynamic> exam = _map(json['exam']);
    return FinalExamAttemptModel(
      id: _string(attempt['id']),
      referenceCode: _string(attempt['referenceCode']),
      status: _string(attempt['status']),
      startedAt: DateTime.tryParse(_string(attempt['startedAt'])),
      examId: _string(exam['id']),
      examTitle: _string(exam['title']),
      courseTitle: _string(exam['courseTitle']),
      totalDurationMinutes: _int(exam['totalDurationMinutes']),
      sections: _list(exam['sections'])
          .map(FinalExamSectionModel.fromJson)
          .toList(growable: false),
    );
  }

  FinalExamAttemptModel copyWith({
    List<FinalExamSectionModel>? sections,
  }) {
    return FinalExamAttemptModel(
      id: id,
      referenceCode: referenceCode,
      status: status,
      startedAt: startedAt,
      examId: examId,
      examTitle: examTitle,
      courseTitle: courseTitle,
      totalDurationMinutes: totalDurationMinutes,
      sections: sections ?? this.sections,
    );
  }
}

class FinalExamSectionModel {
  final String id;
  final FinalExamSectionType type;
  final String rawType;
  final String title;
  final String subtitle;
  final String reviewMode;
  final int questionCount;
  final int passingPercent;
  final int timeLimitSeconds;
  final int sortOrder;
  final FinalExamSectionRuleModel rule;
  final List<FinalExamQuestionModel> questions;

  const FinalExamSectionModel({
    required this.id,
    required this.type,
    required this.rawType,
    required this.title,
    required this.subtitle,
    required this.reviewMode,
    required this.questionCount,
    required this.passingPercent,
    required this.timeLimitSeconds,
    required this.sortOrder,
    required this.rule,
    required this.questions,
  });

  factory FinalExamSectionModel.fromJson(Map<String, dynamic> json) {
    final String rawType = _string(json['sectionType']);
    return FinalExamSectionModel(
      id: _string(json['id']),
      type: _sectionType(rawType),
      rawType: rawType,
      title: _string(json['title']),
      subtitle: _string(json['subtitle']),
      reviewMode: _string(json['reviewMode']),
      questionCount: _int(json['questionCount']),
      passingPercent: _int(json['passingPercent']),
      timeLimitSeconds: _int(json['timeLimitSeconds']),
      sortOrder: _int(json['sortOrder']),
      rule: FinalExamSectionRuleModel.fromJson(_map(json['rule'])),
      questions: _list(json['questions'])
          .map(FinalExamQuestionModel.fromJson)
          .toList(growable: false),
    );
  }

  FinalExamSectionModel copyWith({
    List<FinalExamQuestionModel>? questions,
  }) {
    return FinalExamSectionModel(
      id: id,
      type: type,
      rawType: rawType,
      title: title,
      subtitle: subtitle,
      reviewMode: reviewMode,
      questionCount: questionCount,
      passingPercent: passingPercent,
      timeLimitSeconds: timeLimitSeconds,
      sortOrder: sortOrder,
      rule: rule,
      questions: questions ?? this.questions,
    );
  }
}

class FinalExamSectionRuleModel {
  final bool playbackLocked;
  final int minWords;
  final int maxWords;
  final int maxDurationSeconds;
  final String rerecordPolicy;

  const FinalExamSectionRuleModel({
    required this.playbackLocked,
    required this.minWords,
    required this.maxWords,
    required this.maxDurationSeconds,
    required this.rerecordPolicy,
  });

  factory FinalExamSectionRuleModel.fromJson(Map<String, dynamic> json) {
    return FinalExamSectionRuleModel(
      playbackLocked: _bool(json['playbackLocked']),
      minWords: _int(json['minWords']),
      maxWords: _int(json['maxWords']),
      maxDurationSeconds: _int(json['maxDurationSeconds']),
      rerecordPolicy: _string(json['rerecordPolicy']),
    );
  }
}

class FinalExamQuestionModel {
  final String id;
  final String sectionId;
  final String format;
  final String title;
  final String subtitle;
  final String prompt;
  final String promptBn;
  final String audioFileId;
  final String imageFileId;
  final String audioUrl;
  final String imageUrl;
  final String audioMimeType;
  final String imageMimeType;
  final int sortOrder;
  final List<FinalExamOptionModel> options;
  final List<FinalExamPairItemModel> leftPairs;
  final List<FinalExamPairItemModel> rightPairs;
  final List<FinalExamSequenceItemModel> sequenceItems;

  const FinalExamQuestionModel({
    required this.id,
    required this.sectionId,
    required this.format,
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.promptBn,
    required this.audioFileId,
    required this.imageFileId,
    required this.audioUrl,
    required this.imageUrl,
    required this.audioMimeType,
    required this.imageMimeType,
    required this.sortOrder,
    required this.options,
    required this.leftPairs,
    required this.rightPairs,
    required this.sequenceItems,
  });

  factory FinalExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pairs = _map(json['pairs']);
    return FinalExamQuestionModel(
      id: _string(json['id']),
      sectionId: _string(json['sectionId']),
      format: _string(json['questionFormat']),
      title: _string(json['title']),
      subtitle: _string(json['subtitle']),
      prompt: _string(json['prompt']),
      promptBn: _string(json['promptBn']),
      audioFileId: _string(json['audioFileId']),
      imageFileId: _string(json['imageFileId']),
      audioUrl: _string(json['audioUrl']),
      imageUrl: _string(json['imageUrl']),
      audioMimeType: _string(json['audioMimeType']),
      imageMimeType: _string(json['imageMimeType']),
      sortOrder: _int(json['sortOrder']),
      options: _list(json['options'])
          .map(FinalExamOptionModel.fromJson)
          .toList(growable: false),
      leftPairs: _list(pairs['leftItems'])
          .map(FinalExamPairItemModel.fromJson)
          .toList(growable: false),
      rightPairs: _list(pairs['rightItems'])
          .map(FinalExamPairItemModel.fromJson)
          .toList(growable: false),
      sequenceItems: _list(json['sequenceItems'])
          .map(FinalExamSequenceItemModel.fromJson)
          .toList(growable: false),
    );
  }

  FinalExamQuestionModel copyWith({
    String? audioUrl,
    String? imageUrl,
    String? audioMimeType,
    String? imageMimeType,
  }) {
    return FinalExamQuestionModel(
      id: id,
      sectionId: sectionId,
      format: format,
      title: title,
      subtitle: subtitle,
      prompt: prompt,
      promptBn: promptBn,
      audioFileId: audioFileId,
      imageFileId: imageFileId,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      audioMimeType: audioMimeType ?? this.audioMimeType,
      imageMimeType: imageMimeType ?? this.imageMimeType,
      sortOrder: sortOrder,
      options: options,
      leftPairs: leftPairs,
      rightPairs: rightPairs,
      sequenceItems: sequenceItems,
    );
  }
}

class FinalExamOptionModel {
  final String id;
  final String text;
  final int sortOrder;

  const FinalExamOptionModel({
    required this.id,
    required this.text,
    required this.sortOrder,
  });

  factory FinalExamOptionModel.fromJson(Map<String, dynamic> json) {
    return FinalExamOptionModel(
      id: _string(json['id']),
      text: _string(json['optionText']),
      sortOrder: _int(json['sortOrder']),
    );
  }
}

class FinalExamPairItemModel {
  final String id;
  final String text;
  final int sortOrder;

  const FinalExamPairItemModel({
    required this.id,
    required this.text,
    required this.sortOrder,
  });

  factory FinalExamPairItemModel.fromJson(Map<String, dynamic> json) {
    return FinalExamPairItemModel(
      id: _string(json['id']),
      text: _string(json['text']),
      sortOrder: _int(json['sortOrder']),
    );
  }
}

class FinalExamSequenceItemModel {
  final String id;
  final String text;
  final int sortOrder;
  final bool isRequired;

  const FinalExamSequenceItemModel({
    required this.id,
    required this.text,
    required this.sortOrder,
    required this.isRequired,
  });

  factory FinalExamSequenceItemModel.fromJson(Map<String, dynamic> json) {
    return FinalExamSequenceItemModel(
      id: _string(json['id']),
      text: _string(json['text']),
      sortOrder: _int(json['sortOrder']),
      isRequired: json['isRequired'] != false,
    );
  }
}

class FinalExamAnswerResultModel {
  final bool isManualReview;
  final bool? isCorrect;
  final String correctAnswer;
  final double score;

  const FinalExamAnswerResultModel({
    required this.isManualReview,
    required this.isCorrect,
    required this.correctAnswer,
    required this.score,
  });

  factory FinalExamAnswerResultModel.fromJson(Map<String, dynamic> json) {
    return FinalExamAnswerResultModel(
      isManualReview: _bool(json['isManualReview']),
      isCorrect: json['isCorrect'] is bool ? json['isCorrect'] as bool : null,
      correctAnswer: _string(json['correctAnswer']),
      score: _double(json['score']),
    );
  }
}

class FinalExamSubmissionModel {
  final String message;
  final String referenceCode;
  final String status;
  final String estimatedResult;

  const FinalExamSubmissionModel({
    required this.message,
    required this.referenceCode,
    required this.status,
    required this.estimatedResult,
  });

  factory FinalExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    return FinalExamSubmissionModel(
      message: _string(json['message']),
      referenceCode: _string(json['referenceCode']),
      status: _string(json['status']),
      estimatedResult: _string(json['estimatedResult']),
    );
  }
}

class FinalExamResultResponseModel {
  final String courseId;
  final String status;
  final String referenceCode;
  final bool resultReady;
  final bool canRetake;
  final bool certificateAvailable;
  final String message;
  final Map<String, dynamic> review;

  const FinalExamResultResponseModel({
    required this.courseId,
    required this.status,
    required this.referenceCode,
    required this.resultReady,
    required this.canRetake,
    required this.certificateAvailable,
    required this.message,
    required this.review,
  });

  factory FinalExamResultResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return FinalExamResultResponseModel(
      courseId: _string(json['courseId']),
      status: _string(json['status']),
      referenceCode: _string(
        json['referenceCode'],
      ),
      resultReady: _bool(
        json['resultReady'],
      ),
      canRetake: _bool(
        json['canRetake'],
      ),
      certificateAvailable: _bool(
        json['certificateAvailable'],
      ),
      message: _string(json['message']),
      review: _map(json['review']),
    );
  }
}

FinalExamSectionType _sectionType(String value) {
  switch (value) {
    case 'core_quiz':
      return FinalExamSectionType.coreQuiz;
    case 'listening_lab':
      return FinalExamSectionType.listeningLab;
    case 'writing_task':
      return FinalExamSectionType.writingTask;
    case 'speaking_lab':
      return FinalExamSectionType.speakingLab;
    default:
      return FinalExamSectionType.unknown;
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

String _string(dynamic value) => value?.toString().trim() ?? '';
int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(_string(value)) ?? 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(_string(value)) ?? 0;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  return _string(value).toLowerCase() == 'true';
}
