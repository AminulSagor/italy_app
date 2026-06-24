class JobPaginationMetaModel {
  const JobPaginationMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory JobPaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return JobPaginationMetaModel(
      page: _intValue(json['page'], fallback: 1),
      limit: _intValue(json['limit'], fallback: 20),
      total: _intValue(json['total']),
      totalPages: _intValue(json['totalPages'], fallback: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  JobPaginationMetaModel copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
  }) {
    return JobPaginationMetaModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class JobMediaFileModel {
  const JobMediaFileModel({
    required this.id,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String id;
  final String url;
  final String originalName;
  final String mimeType;
  final int sizeBytes;

  bool get isAvailable => url.trim().isNotEmpty;
  bool get isAudio => mimeType.toLowerCase().startsWith('audio/');
  bool get isVideo => mimeType.toLowerCase().startsWith('video/');
  bool get isPdf => mimeType.toLowerCase() == 'application/pdf';

  factory JobMediaFileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> file = _jsonMap(json['file']);
    return JobMediaFileModel(
      id: _stringValue(file['id'] ?? json['id']),
      url: _stringValue(
        json['signedReadUrl'] ?? json['publicUrl'] ?? file['publicUrl'],
      ),
      originalName: _stringValue(
        file['originalName'] ?? json['originalName'],
      ),
      mimeType: _stringValue(file['mimeType'] ?? json['mimeType']),
      sizeBytes: _intValue(file['sizeBytes'] ?? json['sizeBytes']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'url': url,
      'originalName': originalName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }

  JobMediaFileModel copyWith({
    String? id,
    String? url,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
  }) {
    return JobMediaFileModel(
      id: id ?? this.id,
      url: url ?? this.url,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}

class JobCareerTrackModel {
  const JobCareerTrackModel({
    required this.id,
    required this.title,
    required this.subtitleBn,
    required this.description,
    required this.iconKey,
    required this.cardColor,
    required this.sortOrder,
    required this.moduleCount,
    required this.sentenceCount,
    required this.learnedSentenceCount,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String subtitleBn;
  final String description;
  final String iconKey;
  final String cardColor;
  final int sortOrder;
  final int moduleCount;
  final int sentenceCount;
  final int learnedSentenceCount;
  final DateTime? updatedAt;

  double get completionProgress {
    if (sentenceCount <= 0) return 0;
    return (learnedSentenceCount / sentenceCount).clamp(0, 1).toDouble();
  }

  factory JobCareerTrackModel.fromJson(Map<String, dynamic> json) {
    return JobCareerTrackModel(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      subtitleBn: _stringValue(json['subtitleBn']),
      description: _stringValue(json['description']),
      iconKey: _stringValue(json['iconKey']),
      cardColor: _stringValue(json['cardColor']),
      sortOrder: _intValue(json['sortOrder']),
      moduleCount: _intValue(json['moduleCount']),
      sentenceCount: _intValue(json['sentenceCount']),
      learnedSentenceCount: _intValue(json['learnedSentenceCount']),
      updatedAt: DateTime.tryParse(_stringValue(json['updatedAt']))?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitleBn': subtitleBn,
      'description': description,
      'iconKey': iconKey,
      'cardColor': cardColor,
      'sortOrder': sortOrder,
      'moduleCount': moduleCount,
      'sentenceCount': sentenceCount,
      'learnedSentenceCount': learnedSentenceCount,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  JobCareerTrackModel copyWith({
    String? id,
    String? title,
    String? subtitleBn,
    String? description,
    String? iconKey,
    String? cardColor,
    int? sortOrder,
    int? moduleCount,
    int? sentenceCount,
    int? learnedSentenceCount,
    DateTime? updatedAt,
  }) {
    return JobCareerTrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      cardColor: cardColor ?? this.cardColor,
      sortOrder: sortOrder ?? this.sortOrder,
      moduleCount: moduleCount ?? this.moduleCount,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      learnedSentenceCount: learnedSentenceCount ?? this.learnedSentenceCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class JobCareerTrackListResponseModel {
  const JobCareerTrackListResponseModel({
    required this.items,
    required this.meta,
  });

  final List<JobCareerTrackModel> items;
  final JobPaginationMetaModel meta;

  factory JobCareerTrackListResponseModel.fromJson(Map<String, dynamic> json) {
    return JobCareerTrackListResponseModel(
      items: _jsonList(json['items'])
          .map(JobCareerTrackModel.fromJson)
          .toList(growable: false),
      meta: JobPaginationMetaModel.fromJson(_jsonMap(json['meta'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((JobCareerTrackModel item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }

  JobCareerTrackListResponseModel copyWith({
    List<JobCareerTrackModel>? items,
    JobPaginationMetaModel? meta,
  }) {
    return JobCareerTrackListResponseModel(
      items: items ?? this.items,
      meta: meta ?? this.meta,
    );
  }
}

class JobTrackProgressModel {
  const JobTrackProgressModel({
    required this.videoWatchPercent,
    required this.isTheoryOpened,
    this.theoryOpenedAt,
    this.lastActivityAt,
  });

  final int videoWatchPercent;
  final bool isTheoryOpened;
  final DateTime? theoryOpenedAt;
  final DateTime? lastActivityAt;

  factory JobTrackProgressModel.fromJson(Map<String, dynamic> json) {
    return JobTrackProgressModel(
      videoWatchPercent: _intValue(json['videoWatchPercent']),
      isTheoryOpened: json['isTheoryOpened'] == true,
      theoryOpenedAt: DateTime.tryParse(
        _stringValue(json['theoryOpenedAt']),
      )?.toLocal(),
      lastActivityAt: DateTime.tryParse(
        _stringValue(json['lastActivityAt']),
      )?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoWatchPercent': videoWatchPercent,
      'isTheoryOpened': isTheoryOpened,
      'theoryOpenedAt': theoryOpenedAt?.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
    };
  }

  JobTrackProgressModel copyWith({
    int? videoWatchPercent,
    bool? isTheoryOpened,
    DateTime? theoryOpenedAt,
    DateTime? lastActivityAt,
  }) {
    return JobTrackProgressModel(
      videoWatchPercent: videoWatchPercent ?? this.videoWatchPercent,
      isTheoryOpened: isTheoryOpened ?? this.isTheoryOpened,
      theoryOpenedAt: theoryOpenedAt ?? this.theoryOpenedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

class JobLearningSummaryModel {
  const JobLearningSummaryModel({
    required this.learnedSentences,
    required this.totalSentences,
    required this.completionPercent,
  });

  final int learnedSentences;
  final int totalSentences;
  final int completionPercent;

  factory JobLearningSummaryModel.fromJson(Map<String, dynamic> json) {
    return JobLearningSummaryModel(
      learnedSentences: _intValue(json['learnedSentences']),
      totalSentences: _intValue(json['totalSentences']),
      completionPercent: _intValue(json['completionPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'learnedSentences': learnedSentences,
      'totalSentences': totalSentences,
      'completionPercent': completionPercent,
    };
  }

  JobLearningSummaryModel copyWith({
    int? learnedSentences,
    int? totalSentences,
    int? completionPercent,
  }) {
    return JobLearningSummaryModel(
      learnedSentences: learnedSentences ?? this.learnedSentences,
      totalSentences: totalSentences ?? this.totalSentences,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }
}

class JobModuleModel {
  const JobModuleModel({
    required this.id,
    required this.name,
    required this.subtitleBn,
    required this.sortOrder,
    required this.sentenceCount,
    required this.learnedSentenceCount,
  });

  final String id;
  final String name;
  final String subtitleBn;
  final int sortOrder;
  final int sentenceCount;
  final int learnedSentenceCount;

  factory JobModuleModel.fromJson(Map<String, dynamic> json) {
    return JobModuleModel(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      subtitleBn: _stringValue(json['subtitleBn']),
      sortOrder: _intValue(json['sortOrder']),
      sentenceCount: _intValue(
        json['sentenceCount'] ?? json['totalSentences'],
      ),
      learnedSentenceCount: _intValue(
        json['learnedSentenceCount'] ?? json['learnedSentences'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'subtitleBn': subtitleBn,
      'sortOrder': sortOrder,
      'sentenceCount': sentenceCount,
      'learnedSentenceCount': learnedSentenceCount,
    };
  }

  JobModuleModel copyWith({
    String? id,
    String? name,
    String? subtitleBn,
    int? sortOrder,
    int? sentenceCount,
    int? learnedSentenceCount,
  }) {
    return JobModuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      sortOrder: sortOrder ?? this.sortOrder,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      learnedSentenceCount:
          learnedSentenceCount ?? this.learnedSentenceCount,
    );
  }
}

class JobCareerTrackDetailsModel {
  const JobCareerTrackDetailsModel({
    required this.id,
    required this.title,
    required this.subtitleBn,
    required this.description,
    required this.iconKey,
    required this.cardColor,
    required this.sortOrder,
    required this.trackProgress,
    required this.progress,
    required this.modules,
    this.introVideo,
    this.theoryResource,
  });

  final String id;
  final String title;
  final String subtitleBn;
  final String description;
  final String iconKey;
  final String cardColor;
  final int sortOrder;
  final JobMediaFileModel? introVideo;
  final JobMediaFileModel? theoryResource;
  final JobTrackProgressModel trackProgress;
  final JobLearningSummaryModel progress;
  final List<JobModuleModel> modules;

  factory JobCareerTrackDetailsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? introVideo = _jsonMapOrNull(json['introVideo']);
    final Map<String, dynamic>? theoryResource = _jsonMapOrNull(
      json['theoryResource'],
    );
    return JobCareerTrackDetailsModel(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      subtitleBn: _stringValue(json['subtitleBn']),
      description: _stringValue(json['description']),
      iconKey: _stringValue(json['iconKey']),
      cardColor: _stringValue(json['cardColor']),
      sortOrder: _intValue(json['sortOrder']),
      introVideo: introVideo == null
          ? null
          : JobMediaFileModel.fromJson(introVideo),
      theoryResource: theoryResource == null
          ? null
          : JobMediaFileModel.fromJson(theoryResource),
      trackProgress: JobTrackProgressModel.fromJson(
        _jsonMap(json['trackProgress']),
      ),
      progress: JobLearningSummaryModel.fromJson(_jsonMap(json['progress'])),
      modules: _jsonList(json['modules'])
          .map(JobModuleModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitleBn': subtitleBn,
      'description': description,
      'iconKey': iconKey,
      'cardColor': cardColor,
      'sortOrder': sortOrder,
      'introVideo': introVideo?.toJson(),
      'theoryResource': theoryResource?.toJson(),
      'trackProgress': trackProgress.toJson(),
      'progress': progress.toJson(),
      'modules': modules.map((JobModuleModel item) => item.toJson()).toList(),
    };
  }

  JobCareerTrackDetailsModel copyWith({
    String? id,
    String? title,
    String? subtitleBn,
    String? description,
    String? iconKey,
    String? cardColor,
    int? sortOrder,
    JobMediaFileModel? introVideo,
    JobMediaFileModel? theoryResource,
    JobTrackProgressModel? trackProgress,
    JobLearningSummaryModel? progress,
    List<JobModuleModel>? modules,
  }) {
    return JobCareerTrackDetailsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      cardColor: cardColor ?? this.cardColor,
      sortOrder: sortOrder ?? this.sortOrder,
      introVideo: introVideo ?? this.introVideo,
      theoryResource: theoryResource ?? this.theoryResource,
      trackProgress: trackProgress ?? this.trackProgress,
      progress: progress ?? this.progress,
      modules: modules ?? this.modules,
    );
  }
}


List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic>? _jsonMapOrNull(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _stringValue(dynamic value) => value?.toString().trim() ?? '';

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
