import 'package:get/get.dart';

enum ChapterQuizStatus { disabled, enabled, completed }

enum ChapterMediaType { video, audio, pdf }

class ChapterDetailModel {
  final String id;
  final String courseId;
  final String title;
  final String videoProgressLabel;
  final String watchedTimeLabel;
  final String totalTimeLabel;
  final double videoProgress;
  final LessonContentModel? lessonContent;
  final ChapterMediaModel? video;
  final ChapterMediaModel? audio;
  final ChapterResourceModel theoryBook;
  final ChapterResourceModel vocabulary;
  final ChapterQuizModel? quiz;
  final bool isQuizAvailabilityKnown;
  final LessonProgressModel progress;

  const ChapterDetailModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.videoProgressLabel,
    required this.watchedTimeLabel,
    required this.totalTimeLabel,
    required this.videoProgress,
    required this.theoryBook,
    required this.vocabulary,
    required this.progress,
    this.lessonContent,
    this.video,
    this.audio,
    this.quiz,
    this.isQuizAvailabilityKnown = true,
  });

  factory ChapterDetailModel.fromJson(Map<String, dynamic> json) {
    final List<ChapterResourceModel> resources = _jsonList(
      json['resources'],
    ).map(ChapterResourceModel.fromJson).toList(growable: false);

    return ChapterDetailModel(
      id: _stringValue(json['id']),
      courseId: _stringValue(json['courseId']),
      title: _fallbackString(json['title'], 'lesson_details'.tr),
      videoProgressLabel: _stringValue(json['videoProgressLabel']),
      watchedTimeLabel: _stringValue(json['watchedTimeLabel']),
      totalTimeLabel: _stringValue(json['totalTimeLabel']),
      videoProgress: _doubleValue(json['videoProgress']),
      lessonContent: json['lessonContent'] is Map
          ? LessonContentModel.fromJson(_jsonMap(json['lessonContent']))
          : null,
      video: json['video'] is Map
          ? ChapterMediaModel.fromJson(_jsonMap(json['video']))
          : null,
      audio: json['audio'] is Map
          ? ChapterMediaModel.fromJson(_jsonMap(json['audio']))
          : null,
      theoryBook: json['theoryBook'] is Map
          ? ChapterResourceModel.fromJson(_jsonMap(json['theoryBook']))
          : resources.isNotEmpty
          ? resources.first
          : ChapterResourceModel.notGiven(
              title: 'gen_theory_book'.tr,
              iconName: 'book',
            ),
      vocabulary: json['vocabulary'] is Map
          ? ChapterResourceModel.fromJson(_jsonMap(json['vocabulary']))
          : resources.length > 1
          ? resources.last
          : ChapterResourceModel.notGiven(
              title: 'gen_vocabulary'.tr,
              iconName: 'cards',
            ),
      quiz: json['quiz'] is Map
          ? ChapterQuizModel.fromJson(_jsonMap(json['quiz']))
          : null,
      isQuizAvailabilityKnown: _boolValue(
        json['isQuizAvailabilityKnown'],
        fallback: true,
      ),
      progress: json['progress'] is Map
          ? LessonProgressModel.fromJson(_jsonMap(json['progress']))
          : const LessonProgressModel.empty(),
    );
  }

  bool get hasVideo => video?.fileId.isNotEmpty == true;
  bool get hasAudio => audio?.fileId.isNotEmpty == true;
  bool get hasLessonContent => lessonContent != null;
  bool get hasQuiz => quiz != null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'title': title,
      'videoProgressLabel': videoProgressLabel,
      'watchedTimeLabel': watchedTimeLabel,
      'totalTimeLabel': totalTimeLabel,
      'videoProgress': videoProgress,
      'lessonContent': lessonContent?.toJson(),
      'video': video?.toJson(),
      'audio': audio?.toJson(),
      'theoryBook': theoryBook.toJson(),
      'vocabulary': vocabulary.toJson(),
      'quiz': quiz?.toJson(),
      'isQuizAvailabilityKnown': isQuizAvailabilityKnown,
      'progress': progress.toJson(),
    };
  }

  ChapterDetailModel copyWith({
    String? videoProgressLabel,
    String? watchedTimeLabel,
    String? totalTimeLabel,
    double? videoProgress,
    ChapterMediaModel? video,
    ChapterMediaModel? audio,
    ChapterResourceModel? theoryBook,
    ChapterQuizModel? quiz,
    LessonProgressModel? progress,
  }) {
    return ChapterDetailModel(
      id: id,
      courseId: courseId,
      title: title,
      videoProgressLabel: videoProgressLabel ?? this.videoProgressLabel,
      watchedTimeLabel: watchedTimeLabel ?? this.watchedTimeLabel,
      totalTimeLabel: totalTimeLabel ?? this.totalTimeLabel,
      videoProgress: videoProgress ?? this.videoProgress,
      lessonContent: lessonContent,
      video: video ?? this.video,
      audio: audio ?? this.audio,
      theoryBook: theoryBook ?? this.theoryBook,
      vocabulary: vocabulary,
      quiz: quiz ?? this.quiz,
      isQuizAvailabilityKnown: isQuizAvailabilityKnown,
      progress: progress ?? this.progress,
    );
  }
}

class ChapterMediaModel {
  final String fileId;
  final String url;
  final String title;
  final String mimeType;
  final int durationSeconds;
  final int pageCount;
  final ChapterMediaType type;

  const ChapterMediaModel({
    required this.fileId,
    required this.url,
    required this.title,
    required this.mimeType,
    required this.durationSeconds,
    required this.pageCount,
    required this.type,
  });

  factory ChapterMediaModel.fromJson(Map<String, dynamic> json) {
    return ChapterMediaModel(
      fileId: _stringValue(json['fileId']),
      url: _stringValue(json['url']),
      title: _stringValue(json['title']),
      mimeType: _stringValue(json['mimeType']),
      durationSeconds: _intValue(json['durationSeconds']),
      pageCount: _intValue(json['pageCount']),
      type: ChapterMediaType.values.firstWhere(
        (ChapterMediaType item) => item.name == _stringValue(json['type']),
        orElse: () => ChapterMediaType.video,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fileId': fileId,
      'url': url,
      'title': title,
      'mimeType': mimeType,
      'durationSeconds': durationSeconds,
      'pageCount': pageCount,
      'type': type.name,
    };
  }
}

enum ChapterVideoTranscodeStatus {
  notRequired,
  pending,
  processing,
  ready,
  failed,
  unknown,
}

class ChapterVideoQualityOption {
  final String label;
  final String streamUrl;

  const ChapterVideoQualityOption({
    required this.label,
    required this.streamUrl,
  });

  factory ChapterVideoQualityOption.fromJson(Map<String, dynamic> json) {
    return ChapterVideoQualityOption(
      label: _stringValue(json['label']),
      streamUrl: _stringValue(json['streamUrl']),
    );
  }

  bool get isValid {
    return label.isNotEmpty && streamUrl.isNotEmpty;
  }
}

class ChapterVideoAccessModel {
  final String fileId;
  final String mediaAssetId;
  final ChapterVideoTranscodeStatus status;
  final String streamUrl;
  final int durationSeconds;
  final int width;
  final int height;
  final bool retryable;
  final bool requiresSignedCookies;
  final Map<String, String> cookies;
  final DateTime? expiresAt;
  final List<ChapterVideoQualityOption> qualities;

  const ChapterVideoAccessModel({
    required this.fileId,
    required this.mediaAssetId,
    required this.status,
    required this.streamUrl,
    required this.durationSeconds,
    required this.width,
    required this.height,
    required this.retryable,
    required this.requiresSignedCookies,
    required this.cookies,
    required this.expiresAt,
    required this.qualities,
  });

  factory ChapterVideoAccessModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> cloudFrontAccess =
        json['cloudFrontAccess'] is Map
        ? Map<String, dynamic>.from(json['cloudFrontAccess'] as Map)
        : <String, dynamic>{};

    return ChapterVideoAccessModel(
      fileId: json['fileId']?.toString().trim() ?? '',
      mediaAssetId: json['mediaAssetId']?.toString().trim() ?? '',
      status: _parseStatus(json['status']),
      streamUrl: json['streamUrl']?.toString().trim() ?? '',
      qualities: List<ChapterVideoQualityOption>.unmodifiable(
        _jsonList(json['qualities'])
            .map(ChapterVideoQualityOption.fromJson)
            .where((ChapterVideoQualityOption quality) => quality.isValid),
      ),
      durationSeconds: _parseInt(json['durationSeconds']),
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      retryable: _parseBool(json['retryable']),
      requiresSignedCookies: _parseBool(json['requiresSignedCookies']),
      cookies: _parseCookies(cloudFrontAccess['cookies']),
      expiresAt: DateTime.tryParse(
        cloudFrontAccess['expiresAt']?.toString() ?? '',
      ),
    );
  }

  bool get hasCloudFrontCookies {
    return cookies['CloudFront-Policy']?.isNotEmpty == true &&
        cookies['CloudFront-Signature']?.isNotEmpty == true &&
        cookies['CloudFront-Key-Pair-Id']?.isNotEmpty == true;
  }

  bool get canPlay {
    if (status != ChapterVideoTranscodeStatus.ready) {
      return false;
    }

    if (streamUrl.isEmpty) {
      return false;
    }

    if (requiresSignedCookies && !hasCloudFrontCookies) {
      return false;
    }

    return true;
  }

  String get cookieHeader {
    final List<String> values = <String>[];

    const List<String> allowedCookieNames = <String>[
      'CloudFront-Policy',
      'CloudFront-Signature',
      'CloudFront-Key-Pair-Id',
      'CloudFront-Hash-Algorithm',
    ];

    for (final String name in allowedCookieNames) {
      final String value = cookies[name]?.trim() ?? '';

      if (value.isNotEmpty) {
        values.add('$name=$value');
      }
    }

    return values.join('; ');
  }

  Map<String, String> get videoHttpHeaders {
    final String cookie = cookieHeader;

    if (cookie.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{'Cookie': cookie};
  }

  bool get isExpiredOrNearExpiry {
    if (!requiresSignedCookies) {
      return false;
    }

    final DateTime? expiry = expiresAt;

    if (expiry == null) {
      return true;
    }

    return !DateTime.now().isBefore(
      expiry.subtract(const Duration(minutes: 1)),
    );
  }

  static ChapterVideoTranscodeStatus _parseStatus(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'not_required':
        return ChapterVideoTranscodeStatus.notRequired;
      case 'pending':
        return ChapterVideoTranscodeStatus.pending;
      case 'processing':
        return ChapterVideoTranscodeStatus.processing;
      case 'ready':
        return ChapterVideoTranscodeStatus.ready;
      case 'failed':
        return ChapterVideoTranscodeStatus.failed;
      default:
        return ChapterVideoTranscodeStatus.unknown;
    }
  }

  static Map<String, String> _parseCookies(dynamic value) {
    if (value is! Map) {
      return const <String, String>{};
    }

    final Map<String, String> parsed = <String, String>{};

    value.forEach((dynamic key, dynamic item) {
      final String cookieName = key?.toString().trim() ?? '';
      final String cookieValue = item?.toString().trim() ?? '';

      if (cookieName.isNotEmpty && cookieValue.isNotEmpty) {
        parsed[cookieName] = cookieValue;
      }
    });

    return Map<String, String>.unmodifiable(parsed);
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    return value?.toString().trim().toLowerCase() == 'true';
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
      title: _fallbackString(json['title'], 'lesson_theory'.tr),
      italianText: _stringValue(json['italianText']),
      italianHighlightText: _stringValue(json['italianHighlightText']),
      italianMissingText: _stringValue(json['italianMissingText']),
      translationLabel: _fallbackString(
        json['translationLabel'],
        'translation_label'.tr,
      ),
      banglaText: _stringValue(json['banglaText']),
      banglaHighlightText: _stringValue(json['banglaHighlightText']),
    );
  }

  bool get hasContent {
    return italianText.isNotEmpty ||
        italianHighlightText.isNotEmpty ||
        italianMissingText.isNotEmpty ||
        banglaText.isNotEmpty ||
        banglaHighlightText.isNotEmpty;
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
  final String? fileId;
  final String? fileUrl;
  final bool isAvailable;
  final int count;

  const ChapterResourceModel({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.isAvailable,
    this.fileId,
    this.fileUrl,
    this.count = 0,
  });

  factory ChapterResourceModel.notGiven({
    required String title,
    required String iconName,
  }) {
    return ChapterResourceModel(
      title: title,
      subtitle: 'gen_not_given'.tr,
      iconName: iconName,
      isAvailable: false,
    );
  }

  factory ChapterResourceModel.fromJson(Map<String, dynamic> json) {
    return ChapterResourceModel(
      title: _stringValue(json['title']),
      subtitle: _fallbackString(json['subtitle'], 'gen_not_given'.tr),
      iconName: _stringValue(json['iconName']),
      fileId: _emptyToNull(json['fileId']),
      fileUrl: _emptyToNull(json['fileUrl']),
      isAvailable: _boolValue(json['isAvailable'], fallback: true),
      count: _intValue(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'fileId': fileId,
      'fileUrl': fileUrl,
      'isAvailable': isAvailable,
      'count': count,
    };
  }

  ChapterResourceModel copyWith({
    String? title,
    String? subtitle,
    String? iconName,
    String? fileId,
    String? fileUrl,
    bool? isAvailable,
    int? count,
  }) {
    return ChapterResourceModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconName: iconName ?? this.iconName,
      fileId: fileId ?? this.fileId,
      fileUrl: fileUrl ?? this.fileUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      count: count ?? this.count,
    );
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
  final String quizId;
  final int totalQuestions;
  final bool unlockRequirementEnabled;
  final int unlockVideoWatchPercent;
  final bool hasInProgressSession;
  final int answeredQuestions;

  const ChapterQuizModel({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.actionLabel,
    required this.scoreLabel,
    required this.xpLabel,
    required this.timeLabel,
    required this.quizId,
    required this.totalQuestions,
    required this.unlockRequirementEnabled,
    required this.unlockVideoWatchPercent,
    this.hasInProgressSession = false,
    this.answeredQuestions = 0,
  });

  factory ChapterQuizModel.fromJson(Map<String, dynamic> json) {
    return ChapterQuizModel(
      title: _fallbackString(json['title'], 'chapter_quiz'.tr),
      subtitle: _fallbackString(
        json['subtitle'],
        'chapter_quiz_description'.tr,
      ),
      status: ChapterQuizStatus.values.firstWhere(
        (ChapterQuizStatus item) => item.name == _stringValue(json['status']),
        orElse: () => ChapterQuizStatus.disabled,
      ),
      actionLabel: _stringValue(json['actionLabel']),
      scoreLabel: _stringValue(json['scoreLabel']),
      xpLabel: _stringValue(json['xpLabel']),
      timeLabel: _stringValue(json['timeLabel']),
      quizId: _stringValue(json['quizId']),
      totalQuestions: _intValue(json['totalQuestions']),

      unlockRequirementEnabled: _boolValue(
        json['unlockRequirementEnabled'],
        fallback: false,
      ),

      unlockVideoWatchPercent: _intValue(json['unlockVideoWatchPercent']) > 0
          ? _intValue(json['unlockVideoWatchPercent'])
          : 80,
      hasInProgressSession: _boolValue(
        json['hasInProgressSession'],
        fallback: false,
      ),
      answeredQuestions: _intValue(json['answeredQuestions']),
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
      'quizId': quizId,
      'totalQuestions': totalQuestions,
      'unlockRequirementEnabled': unlockRequirementEnabled,

      'unlockVideoWatchPercent': unlockVideoWatchPercent,
      'hasInProgressSession': hasInProgressSession,
      'answeredQuestions': answeredQuestions,
    };
  }

  ChapterQuizModel copyWith({
    ChapterQuizStatus? status,
    String? actionLabel,
    String? scoreLabel,
    String? xpLabel,
    String? timeLabel,
    bool? unlockRequirementEnabled,
    int? unlockVideoWatchPercent,
    bool? hasInProgressSession,
    int? answeredQuestions,
  }) {
    return ChapterQuizModel(
      title: title,
      subtitle: subtitle,
      status: status ?? this.status,
      actionLabel: actionLabel ?? this.actionLabel,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      xpLabel: xpLabel ?? this.xpLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      quizId: quizId,
      totalQuestions: totalQuestions,
      unlockRequirementEnabled:
          unlockRequirementEnabled ?? this.unlockRequirementEnabled,

      unlockVideoWatchPercent:
          unlockVideoWatchPercent ?? this.unlockVideoWatchPercent,
      hasInProgressSession:
          hasInProgressSession ?? this.hasInProgressSession,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
    );
  }
}

class LessonProgressModel {
  final int videoWatchPercent;
  final bool isTheoryRead;
  final bool isCompleted;

  const LessonProgressModel({
    required this.videoWatchPercent,
    required this.isTheoryRead,
    required this.isCompleted,
  });

  const LessonProgressModel.empty()
    : videoWatchPercent = 0,
      isTheoryRead = false,
      isCompleted = false;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      videoWatchPercent: _intValue(json['videoWatchPercent']),
      isTheoryRead: _boolValue(json['isTheoryRead'], fallback: false),
      isCompleted: _boolValue(json['isCompleted'], fallback: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoWatchPercent': videoWatchPercent,
      'isTheoryRead': isTheoryRead,
      'isCompleted': isCompleted,
    };
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  return <Map<String, dynamic>>[];
}

String _fallbackString(dynamic value, String fallback) {
  final String text = _stringValue(value);
  return text.isEmpty ? fallback : text;
}

String _stringValue(dynamic value) => value?.toString().trim() ?? '';

String? _emptyToNull(dynamic value) {
  final String text = _stringValue(value);
  return text.isEmpty ? null : text;
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

bool _boolValue(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}
