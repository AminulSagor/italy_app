import 'job_track_models.dart';

class JobSentenceProgressModel {
  const JobSentenceProgressModel({
    required this.reviewCount,
    required this.isLearned,
    this.learnedAt,
    this.lastReviewedAt,
  });

  final int reviewCount;
  final bool isLearned;
  final DateTime? learnedAt;
  final DateTime? lastReviewedAt;

  factory JobSentenceProgressModel.fromJson(Map<String, dynamic> json) {
    return JobSentenceProgressModel(
      reviewCount: _intValue(json['reviewCount']),
      isLearned: json['isLearned'] == true,
      learnedAt: DateTime.tryParse(_stringValue(json['learnedAt']))?.toLocal(),
      lastReviewedAt: DateTime.tryParse(
        _stringValue(json['lastReviewedAt']),
      )?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reviewCount': reviewCount,
      'isLearned': isLearned,
      'learnedAt': learnedAt?.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }

  JobSentenceProgressModel copyWith({
    int? reviewCount,
    bool? isLearned,
    DateTime? learnedAt,
    DateTime? lastReviewedAt,
  }) {
    return JobSentenceProgressModel(
      reviewCount: reviewCount ?? this.reviewCount,
      isLearned: isLearned ?? this.isLearned,
      learnedAt: learnedAt ?? this.learnedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }
}

class JobSentenceModel {
  const JobSentenceModel({
    required this.id,
    required this.italianSentence,
    required this.bengaliTranslation,
    required this.sortOrder,
    required this.voiceDurationSeconds,
    this.aiVoice,
    this.progress,
  });

  final String id;
  final String italianSentence;
  final String bengaliTranslation;
  final int sortOrder;
  final JobMediaFileModel? aiVoice;
  final int voiceDurationSeconds;
  final JobSentenceProgressModel? progress;

  bool get isLearned => progress?.isLearned ?? false;
  bool get hasAudio => aiVoice?.isAvailable ?? false;

  factory JobSentenceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? aiVoice = _jsonMapOrNull(json['aiVoice']);
    final Map<String, dynamic>? progress = _jsonMapOrNull(json['progress']);
    return JobSentenceModel(
      id: _stringValue(json['id']),
      italianSentence: _stringValue(json['italianSentence']),
      bengaliTranslation: _stringValue(json['bengaliTranslation']),
      sortOrder: _intValue(json['sortOrder']),
      aiVoice: aiVoice == null ? null : JobMediaFileModel.fromJson(aiVoice),
      voiceDurationSeconds: _intValue(json['voiceDurationSeconds']),
      progress: progress == null
          ? null
          : JobSentenceProgressModel.fromJson(progress),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'italianSentence': italianSentence,
      'bengaliTranslation': bengaliTranslation,
      'sortOrder': sortOrder,
      'aiVoice': aiVoice?.toJson(),
      'voiceDurationSeconds': voiceDurationSeconds,
      'progress': progress?.toJson(),
    };
  }

  JobSentenceModel copyWith({
    String? id,
    String? italianSentence,
    String? bengaliTranslation,
    int? sortOrder,
    JobMediaFileModel? aiVoice,
    int? voiceDurationSeconds,
    JobSentenceProgressModel? progress,
  }) {
    return JobSentenceModel(
      id: id ?? this.id,
      italianSentence: italianSentence ?? this.italianSentence,
      bengaliTranslation: bengaliTranslation ?? this.bengaliTranslation,
      sortOrder: sortOrder ?? this.sortOrder,
      aiVoice: aiVoice ?? this.aiVoice,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      progress: progress ?? this.progress,
    );
  }
}

class JobModuleSentenceSummaryModel {
  const JobModuleSentenceSummaryModel({
    required this.id,
    required this.name,
    required this.subtitleBn,
    required this.learnedSentences,
    required this.totalSentences,
  });

  final String id;
  final String name;
  final String subtitleBn;
  final int learnedSentences;
  final int totalSentences;

  factory JobModuleSentenceSummaryModel.fromJson(Map<String, dynamic> json) {
    return JobModuleSentenceSummaryModel(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      subtitleBn: _stringValue(json['subtitleBn']),
      learnedSentences: _intValue(json['learnedSentences']),
      totalSentences: _intValue(json['totalSentences']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'subtitleBn': subtitleBn,
      'learnedSentences': learnedSentences,
      'totalSentences': totalSentences,
    };
  }

  JobModuleSentenceSummaryModel copyWith({
    String? id,
    String? name,
    String? subtitleBn,
    int? learnedSentences,
    int? totalSentences,
  }) {
    return JobModuleSentenceSummaryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      learnedSentences: learnedSentences ?? this.learnedSentences,
      totalSentences: totalSentences ?? this.totalSentences,
    );
  }
}

class JobModuleSentencesResponseModel {
  const JobModuleSentencesResponseModel({
    required this.module,
    required this.items,
    required this.meta,
  });

  final JobModuleSentenceSummaryModel module;
  final List<JobSentenceModel> items;
  final JobPaginationMetaModel meta;

  factory JobModuleSentencesResponseModel.fromJson(Map<String, dynamic> json) {
    return JobModuleSentencesResponseModel(
      module: JobModuleSentenceSummaryModel.fromJson(_jsonMap(json['module'])),
      items: _jsonList(json['items'])
          .map(JobSentenceModel.fromJson)
          .toList(growable: false),
      meta: JobPaginationMetaModel.fromJson(_jsonMap(json['meta'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'module': module.toJson(),
      'items': items.map((JobSentenceModel item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }

  JobModuleSentencesResponseModel copyWith({
    JobModuleSentenceSummaryModel? module,
    List<JobSentenceModel>? items,
    JobPaginationMetaModel? meta,
  }) {
    return JobModuleSentencesResponseModel(
      module: module ?? this.module,
      items: items ?? this.items,
      meta: meta ?? this.meta,
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
