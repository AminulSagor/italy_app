class CourseCertificateModel {
  final String id;
  final String certificateNumber;
  final String learnerName;
  final String courseTitle;
  final String proficiencyLevel;
  final String issueDate;
  final int finalScore;
  final String status;
  final String verificationUrl;
  final String pdfFileId;

  const CourseCertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.learnerName,
    required this.courseTitle,
    required this.proficiencyLevel,
    required this.issueDate,
    required this.finalScore,
    required this.status,
    required this.verificationUrl,
    required this.pdfFileId,
  });

  bool get isIssued => status.trim().toLowerCase() == 'issued';

  bool get hasPdf => pdfFileId.trim().isNotEmpty;

  factory CourseCertificateModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = _mapValue(json['user']);
    final Map<String, dynamic> course = _mapValue(json['course']);

    final DateTime? issuedAt = DateTime.tryParse(
      json['issuedAt']?.toString() ?? '',
    );

    final int score = _doubleValue(
      json['scorePercentSnapshot'],
    ).round().clamp(0, 100).toInt();

    return CourseCertificateModel(
      id: json['id']?.toString() ?? '',
      certificateNumber:
      json['certificateNumber']?.toString() ?? '',
      learnerName: _firstNonEmpty(<dynamic>[
        json['recipientNameSnapshot'],
        user['fullName'],
      ]),
      courseTitle: _firstNonEmpty(<dynamic>[
        json['courseTitleSnapshot'],
        course['title'],
      ]),
      proficiencyLevel:
      json['courseLevelSnapshot']?.toString() ?? '',
      issueDate: _formatDate(issuedAt),
      finalScore: score,
      status: json['status']?.toString() ?? '',
      verificationUrl:
      json['verificationUrl']?.toString() ?? '',
      pdfFileId: json['pdfFileId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'certificateNumber': certificateNumber,
      'learnerName': learnerName,
      'courseTitle': courseTitle,
      'proficiencyLevel': proficiencyLevel,
      'issueDate': issueDate,
      'finalScore': finalScore,
      'status': status,
      'verificationUrl': verificationUrl,
      'pdfFileId': pdfFileId,
    };
  }
}

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

double _doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _firstNonEmpty(List<dynamic> values) {
  for (final dynamic value in values) {
    final String text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }

  return '';
}

String _formatDate(DateTime? date) {
  if (date == null) return '';

  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final DateTime localDate = date.toLocal();

  return '${months[localDate.month - 1]} '
      '${localDate.day}, ${localDate.year}';
}
