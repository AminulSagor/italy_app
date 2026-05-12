enum ChapterQuizStatus { disabled, enabled, completed }

class ChapterDetailModel {
  final String id;
  final String title;
  final String videoProgressLabel;
  final String watchedTimeLabel;
  final String totalTimeLabel;
  final double videoProgress;
  final LessonContentModel lessonContent;
  final List<ChapterResourceModel> resources;
  final ChapterQuizModel quiz;

  const ChapterDetailModel({
    required this.id,
    required this.title,
    required this.videoProgressLabel,
    required this.watchedTimeLabel,
    required this.totalTimeLabel,
    required this.videoProgress,
    required this.lessonContent,
    required this.resources,
    required this.quiz,
  });

  factory ChapterDetailModel.fromJson(Map<String, dynamic> json) {
    return ChapterDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      videoProgressLabel: json['videoProgressLabel'] as String,
      watchedTimeLabel: json['watchedTimeLabel'] as String,
      totalTimeLabel: json['totalTimeLabel'] as String,
      videoProgress: (json['videoProgress'] as num).toDouble(),
      lessonContent: LessonContentModel.fromJson(
        json['lessonContent'] as Map<String, dynamic>,
      ),
      resources: (json['resources'] as List<dynamic>)
          .map((dynamic item) => ChapterResourceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      quiz: ChapterQuizModel.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'videoProgressLabel': videoProgressLabel,
      'watchedTimeLabel': watchedTimeLabel,
      'totalTimeLabel': totalTimeLabel,
      'videoProgress': videoProgress,
      'lessonContent': lessonContent.toJson(),
      'resources': resources.map((ChapterResourceModel item) => item.toJson()).toList(),
      'quiz': quiz.toJson(),
    };
  }

  ChapterDetailModel copyWith({
    String? id,
    String? title,
    String? videoProgressLabel,
    String? watchedTimeLabel,
    String? totalTimeLabel,
    double? videoProgress,
    LessonContentModel? lessonContent,
    List<ChapterResourceModel>? resources,
    ChapterQuizModel? quiz,
  }) {
    return ChapterDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      videoProgressLabel: videoProgressLabel ?? this.videoProgressLabel,
      watchedTimeLabel: watchedTimeLabel ?? this.watchedTimeLabel,
      totalTimeLabel: totalTimeLabel ?? this.totalTimeLabel,
      videoProgress: videoProgress ?? this.videoProgress,
      lessonContent: lessonContent ?? this.lessonContent,
      resources: resources ?? this.resources,
      quiz: quiz ?? this.quiz,
    );
  }
}

class LessonContentModel {
  final String title;
  final String italianText;
  final String italianHighlightText;
  final String italianMissingText;
  final String translationLabel;
  final String banglaText;
  final String banglaHighlightText;

  const LessonContentModel({
    required this.title,
    required this.italianText,
    required this.italianHighlightText,
    required this.italianMissingText,
    required this.translationLabel,
    required this.banglaText,
    required this.banglaHighlightText,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      title: json['title'] as String,
      italianText: json['italianText'] as String,
      italianHighlightText: json['italianHighlightText'] as String,
      italianMissingText: json['italianMissingText'] as String,
      translationLabel: json['translationLabel'] as String,
      banglaText: json['banglaText'] as String,
      banglaHighlightText: json['banglaHighlightText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'italianText': italianText,
      'italianHighlightText': italianHighlightText,
      'italianMissingText': italianMissingText,
      'translationLabel': translationLabel,
      'banglaText': banglaText,
      'banglaHighlightText': banglaHighlightText,
    };
  }
}

class ChapterResourceModel {
  final String title;
  final String subtitle;
  final String iconName;

  const ChapterResourceModel({
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  factory ChapterResourceModel.fromJson(Map<String, dynamic> json) {
    return ChapterResourceModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['iconName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
    };
  }
}

class ChapterQuizModel {
  final String title;
  final String subtitle;
  final ChapterQuizStatus status;
  final String actionLabel;
  final String scoreLabel;
  final String xpLabel;
  final String timeLabel;

  const ChapterQuizModel({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.actionLabel,
    required this.scoreLabel,
    required this.xpLabel,
    required this.timeLabel,
  });

  factory ChapterQuizModel.fromJson(Map<String, dynamic> json) {
    return ChapterQuizModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      status: ChapterQuizStatus.values.firstWhere(
        (ChapterQuizStatus item) => item.name == json['status'],
        orElse: () => ChapterQuizStatus.disabled,
      ),
      actionLabel: json['actionLabel'] as String,
      scoreLabel: json['scoreLabel'] as String,
      xpLabel: json['xpLabel'] as String,
      timeLabel: json['timeLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'status': status.name,
      'actionLabel': actionLabel,
      'scoreLabel': scoreLabel,
      'xpLabel': xpLabel,
      'timeLabel': timeLabel,
    };
  }

  ChapterQuizModel copyWith({
    ChapterQuizStatus? status,
    String? actionLabel,
    String? scoreLabel,
    String? xpLabel,
    String? timeLabel,
  }) {
    return ChapterQuizModel(
      title: title,
      subtitle: subtitle,
      status: status ?? this.status,
      actionLabel: actionLabel ?? this.actionLabel,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      xpLabel: xpLabel ?? this.xpLabel,
      timeLabel: timeLabel ?? this.timeLabel,
    );
  }
}
