class ImportantVerbTtsModel {
  const ImportantVerbTtsModel({required this.locale, required this.text});

  final String locale;
  final String text;

  factory ImportantVerbTtsModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbTtsModel(
      locale: _stringValue(json['locale'], fallback: 'it-IT'),
      text: _stringValue(json['text']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'locale': locale, 'text': text};
  }

  ImportantVerbTtsModel copyWith({String? locale, String? text}) {
    return ImportantVerbTtsModel(
      locale: locale ?? this.locale,
      text: text ?? this.text,
    );
  }
}

class ImportantVerbSummaryModel {
  const ImportantVerbSummaryModel({
    required this.id,
    required this.infinitive,
    required this.slug,
    required this.englishMeaning,
    required this.banglaMeaning,
    required this.italianMeaning,
    required this.displayMeaning,
    required this.regularity,
    required this.endingType,
    required this.auxiliary,
    required this.badges,
    required this.localizedBadges,
    required this.combinedMeaning,
    required this.tts,
    required this.isSaved,
  });

  final String id;
  final String infinitive;
  final String slug;
  final String englishMeaning;
  final String banglaMeaning;
  final String italianMeaning;
  final String displayMeaning;
  final String regularity;
  final String endingType;
  final String auxiliary;
  final List<String> badges;
  final List<String> localizedBadges;
  final String combinedMeaning;
  final ImportantVerbTtsModel tts;
  final bool isSaved;

  bool get isIrregular => regularity.toLowerCase() == 'irregular';
  String get endingLabel => endingType.toUpperCase();

  factory ImportantVerbSummaryModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbSummaryModel(
      id: _stringValue(json['id']),
      infinitive: _stringValue(json['infinitive']),
      slug: _stringValue(json['slug']),
      englishMeaning: _stringValue(json['englishMeaning']),
      banglaMeaning: _stringValue(json['banglaMeaning']),
      italianMeaning: _stringValue(json['italianMeaning']),
      displayMeaning: _stringValue(json['displayMeaning']),
      regularity: _stringValue(json['regularity'], fallback: 'regular'),
      endingType: _stringValue(json['endingType'], fallback: 'other'),
      auxiliary: _stringValue(json['auxiliary'], fallback: 'unknown'),
      badges: _stringList(json['badges']),
      localizedBadges: _stringList(json['localizedBadges']),
      combinedMeaning: _stringValue(json['combinedMeaning']),
      tts: ImportantVerbTtsModel.fromJson(_jsonMap(json['tts'])),
      isSaved: _boolValue(json['isSaved']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'infinitive': infinitive,
      'slug': slug,
      'englishMeaning': englishMeaning,
      'banglaMeaning': banglaMeaning,
      'italianMeaning': italianMeaning,
      'displayMeaning': displayMeaning,
      'regularity': regularity,
      'endingType': endingType,
      'auxiliary': auxiliary,
      'badges': badges,
      'localizedBadges': localizedBadges,
      'combinedMeaning': combinedMeaning,
      'tts': tts.toJson(),
      'isSaved': isSaved,
    };
  }

  ImportantVerbSummaryModel copyWith({
    String? id,
    String? infinitive,
    String? slug,
    String? englishMeaning,
    String? banglaMeaning,
    String? italianMeaning,
    String? displayMeaning,
    String? regularity,
    String? endingType,
    String? auxiliary,
    List<String>? badges,
    List<String>? localizedBadges,
    String? combinedMeaning,
    ImportantVerbTtsModel? tts,
    bool? isSaved,
  }) {
    return ImportantVerbSummaryModel(
      id: id ?? this.id,
      infinitive: infinitive ?? this.infinitive,
      slug: slug ?? this.slug,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      banglaMeaning: banglaMeaning ?? this.banglaMeaning,
      italianMeaning: italianMeaning ?? this.italianMeaning,
      displayMeaning: displayMeaning ?? this.displayMeaning,
      regularity: regularity ?? this.regularity,
      endingType: endingType ?? this.endingType,
      auxiliary: auxiliary ?? this.auxiliary,
      badges: badges ?? this.badges,
      localizedBadges: localizedBadges ?? this.localizedBadges,
      combinedMeaning: combinedMeaning ?? this.combinedMeaning,
      tts: tts ?? this.tts,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class ImportantVerbPaginationModel {
  const ImportantVerbPaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ImportantVerbPaginationModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbPaginationModel(
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

  ImportantVerbPaginationModel copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
  }) {
    return ImportantVerbPaginationModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class ImportantVerbListResponseModel {
  const ImportantVerbListResponseModel({
    required this.items,
    required this.meta,
  });

  final List<ImportantVerbSummaryModel> items;
  final ImportantVerbPaginationModel meta;

  factory ImportantVerbListResponseModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbListResponseModel(
      items: _jsonList(json['items'])
          .map(ImportantVerbSummaryModel.fromJson)
          .toList(growable: false),
      meta: ImportantVerbPaginationModel.fromJson(_jsonMap(json['meta'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items
          .map((ImportantVerbSummaryModel item) => item.toJson())
          .toList(),
      'meta': meta.toJson(),
    };
  }

  ImportantVerbListResponseModel copyWith({
    List<ImportantVerbSummaryModel>? items,
    ImportantVerbPaginationModel? meta,
  }) {
    return ImportantVerbListResponseModel(
      items: items ?? this.items,
      meta: meta ?? this.meta,
    );
  }
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final String parsed = value?.toString().trim() ?? '';
  return parsed.isEmpty ? fallback : parsed;
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic item) => item?.toString().trim() ?? '')
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
