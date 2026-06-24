enum SurvivalCardVariant { hero, normal, wide }

class SurvivalProgressSummaryModel {
  const SurvivalProgressSummaryModel({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  double get completionRate {
    if (totalCount <= 0) return 0;
    return (completedCount / totalCount).clamp(0, 1).toDouble();
  }

  factory SurvivalProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    return SurvivalProgressSummaryModel(
      completedCount: _intValue(json['completedCount']),
      totalCount: _intValue(json['totalCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'completedCount': completedCount,
      'totalCount': totalCount,
    };
  }

  SurvivalProgressSummaryModel copyWith({
    int? completedCount,
    int? totalCount,
  }) {
    return SurvivalProgressSummaryModel(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class SurvivalSituationModel {
  const SurvivalSituationModel({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.cardColor,
    required this.cardVariant,
    required this.sortOrder,
    required this.isCompleted,
    this.subtitleBn,
  });

  final String id;
  final String title;
  final String? subtitleBn;
  final String iconKey;
  final String cardColor;
  final SurvivalCardVariant cardVariant;
  final int sortOrder;
  final bool isCompleted;

  factory SurvivalSituationModel.fromJson(Map<String, dynamic> json) {
    return SurvivalSituationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitleBn: _nullableString(json['subtitleBn']),
      iconKey: json['iconKey']?.toString() ?? 'document',
      cardColor: json['cardColor']?.toString() ?? '#E8F7EA',
      cardVariant: SurvivalCardVariant.values.firstWhere(
        (SurvivalCardVariant value) => value.name == json['cardVariant'],
        orElse: () => SurvivalCardVariant.normal,
      ),
      sortOrder: _intValue(json['sortOrder']),
      isCompleted: json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitleBn': subtitleBn,
      'iconKey': iconKey,
      'cardColor': cardColor,
      'cardVariant': cardVariant.name,
      'sortOrder': sortOrder,
      'isCompleted': isCompleted,
    };
  }

  SurvivalSituationModel copyWith({
    String? id,
    String? title,
    String? subtitleBn,
    String? iconKey,
    String? cardColor,
    SurvivalCardVariant? cardVariant,
    int? sortOrder,
    bool? isCompleted,
  }) {
    return SurvivalSituationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      iconKey: iconKey ?? this.iconKey,
      cardColor: cardColor ?? this.cardColor,
      cardVariant: cardVariant ?? this.cardVariant,
      sortOrder: sortOrder ?? this.sortOrder,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SurvivalSituationsResponseModel {
  const SurvivalSituationsResponseModel({
    required this.items,
    required this.progress,
  });

  final List<SurvivalSituationModel> items;
  final SurvivalProgressSummaryModel progress;

  factory SurvivalSituationsResponseModel.fromJson(Map<String, dynamic> json) {
    return SurvivalSituationsResponseModel(
      items: _jsonList(json['items'])
          .map(SurvivalSituationModel.fromJson)
          .toList(growable: false),
      progress: SurvivalProgressSummaryModel.fromJson(
        _jsonMap(json['progress']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items
          .map((SurvivalSituationModel item) => item.toJson())
          .toList(growable: false),
      'progress': progress.toJson(),
    };
  }

  SurvivalSituationsResponseModel copyWith({
    List<SurvivalSituationModel>? items,
    SurvivalProgressSummaryModel? progress,
  }) {
    return SurvivalSituationsResponseModel(
      items: items ?? this.items,
      progress: progress ?? this.progress,
    );
  }
}

class SurvivalResourceModel {
  const SurvivalResourceModel({
    required this.signedReadUrl,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String signedReadUrl;
  final String originalName;
  final String mimeType;
  final int sizeBytes;

  factory SurvivalResourceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> file = _jsonMap(json['file']);
    return SurvivalResourceModel(
      signedReadUrl: json['signedReadUrl']?.toString() ?? '',
      originalName: file['originalName']?.toString() ?? '',
      mimeType: file['mimeType']?.toString() ?? '',
      sizeBytes: _intValue(file['sizeBytes']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'signedReadUrl': signedReadUrl,
      'file': <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      },
    };
  }

  SurvivalResourceModel copyWith({
    String? signedReadUrl,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
  }) {
    return SurvivalResourceModel(
      signedReadUrl: signedReadUrl ?? this.signedReadUrl,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}

class SurvivalSituationDetailModel {
  const SurvivalSituationDetailModel({
    required this.situation,
    this.resource,
  });

  final SurvivalSituationModel situation;
  final SurvivalResourceModel? resource;

  factory SurvivalSituationDetailModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? resourceJson = _jsonMapOrNull(json['resource']);
    return SurvivalSituationDetailModel(
      situation: SurvivalSituationModel.fromJson(json),
      resource: resourceJson == null
          ? null
          : SurvivalResourceModel.fromJson(resourceJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...situation.toJson(),
      'resource': resource?.toJson(),
    };
  }

  SurvivalSituationDetailModel copyWith({
    SurvivalSituationModel? situation,
    SurvivalResourceModel? resource,
    bool clearResource = false,
  }) {
    return SurvivalSituationDetailModel(
      situation: situation ?? this.situation,
      resource: clearResource ? null : resource ?? this.resource,
    );
  }
}

String? _nullableString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
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
