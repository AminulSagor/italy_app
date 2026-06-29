class LegalDocumentModel {
  const LegalDocumentModel({
    required this.title,
    required this.effectiveDate,
    required this.introduction,
    required this.sections,
  });

  final String title;
  final String effectiveDate;
  final String introduction;
  final List<LegalSectionModel> sections;
}

class LegalSectionModel {
  const LegalSectionModel({
    required this.title,
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}
