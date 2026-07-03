enum CvGenerationStatus {
  processing,
  completed,
  failed;

  static CvGenerationStatus fromValue(
      String? value,
      ) {
    return CvGenerationStatus.values.firstWhere(
          (CvGenerationStatus status) =>
      status.name == value?.trim().toLowerCase(),
      orElse: () => CvGenerationStatus.processing,
    );
  }
}

class CvGenerationModel {
  const CvGenerationModel({
    required this.id,
    required this.status,
    required this.generatedImageUrl,
    required this.errorMessage,
    required this.createdAt,
  });

  final String id;
  final CvGenerationStatus status;
  final String? generatedImageUrl;
  final String? errorMessage;
  final DateTime? createdAt;

  bool get isCompleted =>
      status == CvGenerationStatus.completed;

  bool get isFailed =>
      status == CvGenerationStatus.failed;

  bool get isProcessing =>
      status == CvGenerationStatus.processing;

  factory CvGenerationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvGenerationModel(
      id: json['id']?.toString() ?? '',
      status: CvGenerationStatus.fromValue(
        json['status']?.toString(),
      ),
      generatedImageUrl: _nullableValue(
        json['generatedImageUrl'],
      ),
      errorMessage: _nullableValue(
        json['errorMessage'],
      ),
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
    );
  }
}

String? _nullableValue(dynamic value) {
  final String normalized =
      value?.toString().trim() ?? '';

  return normalized.isEmpty ? null : normalized;
}