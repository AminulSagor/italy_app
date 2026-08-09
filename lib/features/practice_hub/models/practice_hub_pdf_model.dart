enum PracticeHubPdfSourceType { asset, network }

class PracticeHubPdfDocumentModel {
  const PracticeHubPdfDocumentModel({
    required this.title,
    required this.source,
    required this.sourceType,
    this.pageCount = 0,
    this.situationId,
    this.isSituationCompleted = false,
  });

  final String title;
  final String source;
  final PracticeHubPdfSourceType sourceType;
  final int pageCount;
  final String? situationId;
  final bool isSituationCompleted;

  bool get isNetwork => sourceType == PracticeHubPdfSourceType.network;

  factory PracticeHubPdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PracticeHubPdfDocumentModel(
      title: json['title']?.toString() ?? 'Lesson',
      source: json['source']?.toString() ?? '',
      sourceType: PracticeHubPdfSourceType.values.firstWhere(
            (PracticeHubPdfSourceType value) => value.name == json['sourceType'],
        orElse: () => PracticeHubPdfSourceType.asset,
      ),
      pageCount: _intValue(json['pageCount']),
      situationId: _nullableString(json['situationId']),
      isSituationCompleted: json['isSituationCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'source': source,
      'sourceType': sourceType.name,
      'pageCount': pageCount,
      'situationId': situationId,
      'isSituationCompleted': isSituationCompleted,
    };
  }

  PracticeHubPdfDocumentModel copyWith({
    String? title,
    String? source,
    PracticeHubPdfSourceType? sourceType,
    int? pageCount,
    String? situationId,
    bool? isSituationCompleted,
  }) {
    return PracticeHubPdfDocumentModel(
      title: title ?? this.title,
      source: source ?? this.source,
      sourceType: sourceType ?? this.sourceType,
      pageCount: pageCount ?? this.pageCount,
      situationId: situationId ?? this.situationId,
      isSituationCompleted:
      isSituationCompleted ?? this.isSituationCompleted,
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
