import 'important_verb_models.dart';

class ImportantVerbInformationModel {
  const ImportantVerbInformationModel({
    required this.title,
    required this.badges,
    required this.description,
  });

  final String title;
  final List<String> badges;
  final String description;

  factory ImportantVerbInformationModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbInformationModel(
      title: _stringValue(json['title'], fallback: 'Verb Information'),
      badges: _stringList(json['badges']),
      description: _stringValue(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'badges': badges,
      'description': description,
    };
  }

  ImportantVerbInformationModel copyWith({
    String? title,
    List<String>? badges,
    String? description,
  }) {
    return ImportantVerbInformationModel(
      title: title ?? this.title,
      badges: badges ?? this.badges,
      description: description ?? this.description,
    );
  }
}

class ImportantVerbExampleModel {
  const ImportantVerbExampleModel({
    required this.id,
    required this.italianText,
    required this.tts,
    required this.englishText,
    required this.banglaText,
    required this.displayText,
    required this.source,
    required this.sourceReference,
    required this.sourceLicense,
  });

  final String id;
  final String italianText;
  final ImportantVerbTtsModel tts;
  final String englishText;
  final String banglaText;
  final String displayText;
  final String source;
  final String sourceReference;
  final String sourceLicense;

  factory ImportantVerbExampleModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbExampleModel(
      id: _stringValue(json['id']),
      italianText: _stringValue(json['italianText']),
      tts: ImportantVerbTtsModel.fromJson(_jsonMap(json['tts'])),
      englishText: _stringValue(json['englishText']),
      banglaText: _stringValue(json['banglaText']),
      displayText: _stringValue(json['displayText']),
      source: _stringValue(json['source']),
      sourceReference: _stringValue(json['sourceReference']),
      sourceLicense: _stringValue(json['sourceLicense']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'italianText': italianText,
      'tts': tts.toJson(),
      'englishText': englishText,
      'banglaText': banglaText,
      'displayText': displayText,
      'source': source,
      'sourceReference': sourceReference,
      'sourceLicense': sourceLicense,
    };
  }

  ImportantVerbExampleModel copyWith({
    String? id,
    String? italianText,
    ImportantVerbTtsModel? tts,
    String? englishText,
    String? banglaText,
    String? displayText,
    String? source,
    String? sourceReference,
    String? sourceLicense,
  }) {
    return ImportantVerbExampleModel(
      id: id ?? this.id,
      italianText: italianText ?? this.italianText,
      tts: tts ?? this.tts,
      englishText: englishText ?? this.englishText,
      banglaText: banglaText ?? this.banglaText,
      displayText: displayText ?? this.displayText,
      source: source ?? this.source,
      sourceReference: sourceReference ?? this.sourceReference,
      sourceLicense: sourceLicense ?? this.sourceLicense,
    );
  }
}

class ImportantVerbConjugationModel {
  const ImportantVerbConjugationModel({
    required this.id,
    required this.personKey,
    required this.pronoun,
    required this.pronounIt,
    required this.pronounEn,
    required this.pronounBn,
    required this.conjugatedText,
    required this.tts,
    required this.meaning,
    required this.englishMeaning,
    required this.banglaMeaning,
    required this.sortOrder,
    required this.examples,
  });

  final String id;
  final String personKey;
  final String pronoun;
  final String pronounIt;
  final String pronounEn;
  final String pronounBn;
  final String conjugatedText;
  final ImportantVerbTtsModel tts;
  final String meaning;
  final String englishMeaning;
  final String banglaMeaning;
  final int sortOrder;
  final List<ImportantVerbExampleModel> examples;

  factory ImportantVerbConjugationModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbConjugationModel(
      id: _stringValue(json['id']),
      personKey: _stringValue(json['personKey']),
      pronoun: _stringValue(json['pronoun']),
      pronounIt: _stringValue(json['pronounIt']),
      pronounEn: _stringValue(json['pronounEn']),
      pronounBn: _stringValue(json['pronounBn']),
      conjugatedText: _stringValue(json['conjugatedText']),
      tts: ImportantVerbTtsModel.fromJson(_jsonMap(json['tts'])),
      meaning: _stringValue(json['meaning']),
      englishMeaning: _stringValue(json['englishMeaning']),
      banglaMeaning: _stringValue(json['banglaMeaning']),
      sortOrder: _intValue(json['sortOrder']),
      examples: _jsonList(json['examples'])
          .map(ImportantVerbExampleModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'personKey': personKey,
      'pronoun': pronoun,
      'pronounIt': pronounIt,
      'pronounEn': pronounEn,
      'pronounBn': pronounBn,
      'conjugatedText': conjugatedText,
      'tts': tts.toJson(),
      'meaning': meaning,
      'englishMeaning': englishMeaning,
      'banglaMeaning': banglaMeaning,
      'sortOrder': sortOrder,
      'examples': examples
          .map((ImportantVerbExampleModel item) => item.toJson())
          .toList(),
    };
  }

  ImportantVerbConjugationModel copyWith({
    String? id,
    String? personKey,
    String? pronoun,
    String? pronounIt,
    String? pronounEn,
    String? pronounBn,
    String? conjugatedText,
    ImportantVerbTtsModel? tts,
    String? meaning,
    String? englishMeaning,
    String? banglaMeaning,
    int? sortOrder,
    List<ImportantVerbExampleModel>? examples,
  }) {
    return ImportantVerbConjugationModel(
      id: id ?? this.id,
      personKey: personKey ?? this.personKey,
      pronoun: pronoun ?? this.pronoun,
      pronounIt: pronounIt ?? this.pronounIt,
      pronounEn: pronounEn ?? this.pronounEn,
      pronounBn: pronounBn ?? this.pronounBn,
      conjugatedText: conjugatedText ?? this.conjugatedText,
      tts: tts ?? this.tts,
      meaning: meaning ?? this.meaning,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      banglaMeaning: banglaMeaning ?? this.banglaMeaning,
      sortOrder: sortOrder ?? this.sortOrder,
      examples: examples ?? this.examples,
    );
  }
}

class ImportantVerbFormModel {
  const ImportantVerbFormModel({
    required this.id,
    required this.formKey,
    required this.title,
    required this.titleEn,
    required this.titleBn,
    required this.titleIt,
    required this.description,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.descriptionIt,
    required this.isCompound,
    required this.sortOrder,
    required this.conjugations,
  });

  final String id;
  final String formKey;
  final String title;
  final String titleEn;
  final String titleBn;
  final String titleIt;
  final String description;
  final String descriptionEn;
  final String descriptionBn;
  final String descriptionIt;
  final bool isCompound;
  final int sortOrder;
  final List<ImportantVerbConjugationModel> conjugations;

  factory ImportantVerbFormModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbFormModel(
      id: _stringValue(json['id']),
      formKey: _stringValue(json['formKey']),
      title: _stringValue(json['title']),
      titleEn: _stringValue(json['titleEn']),
      titleBn: _stringValue(json['titleBn']),
      titleIt: _stringValue(json['titleIt']),
      description: _stringValue(json['description']),
      descriptionEn: _stringValue(json['descriptionEn']),
      descriptionBn: _stringValue(json['descriptionBn']),
      descriptionIt: _stringValue(json['descriptionIt']),
      isCompound: _boolValue(json['isCompound']),
      sortOrder: _intValue(json['sortOrder']),
      conjugations: _jsonList(json['conjugations'])
          .map(ImportantVerbConjugationModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'formKey': formKey,
      'title': title,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'titleIt': titleIt,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'descriptionIt': descriptionIt,
      'isCompound': isCompound,
      'sortOrder': sortOrder,
      'conjugations': conjugations
          .map((ImportantVerbConjugationModel item) => item.toJson())
          .toList(),
    };
  }

  ImportantVerbFormModel copyWith({
    String? id,
    String? formKey,
    String? title,
    String? titleEn,
    String? titleBn,
    String? titleIt,
    String? description,
    String? descriptionEn,
    String? descriptionBn,
    String? descriptionIt,
    bool? isCompound,
    int? sortOrder,
    List<ImportantVerbConjugationModel>? conjugations,
  }) {
    return ImportantVerbFormModel(
      id: id ?? this.id,
      formKey: formKey ?? this.formKey,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      titleIt: titleIt ?? this.titleIt,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      descriptionIt: descriptionIt ?? this.descriptionIt,
      isCompound: isCompound ?? this.isCompound,
      sortOrder: sortOrder ?? this.sortOrder,
      conjugations: conjugations ?? this.conjugations,
    );
  }
}

class ImportantVerbDetailModel {
  const ImportantVerbDetailModel({
    required this.summary,
    required this.title,
    required this.tts,
    required this.information,
    required this.forms,
  });

  final ImportantVerbSummaryModel summary;
  final String title;
  final ImportantVerbTtsModel tts;
  final ImportantVerbInformationModel information;
  final List<ImportantVerbFormModel> forms;

  factory ImportantVerbDetailModel.fromJson(Map<String, dynamic> json) {
    return ImportantVerbDetailModel(
      summary: ImportantVerbSummaryModel.fromJson(json),
      title: _stringValue(json['title']),
      tts: ImportantVerbTtsModel.fromJson(_jsonMap(json['tts'])),
      information: ImportantVerbInformationModel.fromJson(
        _jsonMap(json['information']),
      ),
      forms: _jsonList(json['forms'])
          .map(ImportantVerbFormModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...summary.toJson(),
      'title': title,
      'tts': tts.toJson(),
      'information': information.toJson(),
      'forms': forms
          .map((ImportantVerbFormModel item) => item.toJson())
          .toList(),
    };
  }

  ImportantVerbDetailModel copyWith({
    ImportantVerbSummaryModel? summary,
    String? title,
    ImportantVerbTtsModel? tts,
    ImportantVerbInformationModel? information,
    List<ImportantVerbFormModel>? forms,
  }) {
    return ImportantVerbDetailModel(
      summary: summary ?? this.summary,
      title: title ?? this.title,
      tts: tts ?? this.tts,
      information: information ?? this.information,
      forms: forms ?? this.forms,
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
