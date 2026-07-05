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

enum CvGenerationMode {
  template,
  scratch;

  String get apiValue {
    switch (this) {
      case CvGenerationMode.template:
        return 'template';

      case CvGenerationMode.scratch:
        return 'scratch';
    }
  }

  static CvGenerationMode fromValue(
      String? value,
      ) {
    switch (value?.trim().toLowerCase()) {
      case 'template':
        return CvGenerationMode.template;

      case 'scratch':
      default:
        return CvGenerationMode.scratch;
    }
  }
}

class CvGenerationModel {
  const CvGenerationModel({
    required this.id,
    required this.assistantSessionId,
    required this.sourceGenerationId,
    required this.mode,
    required this.templateId,
    required this.status,
    required this.regenerationInstruction,
    required this.generatedImageUrl,
    required this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String? assistantSessionId;

  final String? sourceGenerationId;

  final CvGenerationMode mode;

  final String? templateId;

  final CvGenerationStatus status;

  final String? regenerationInstruction;

  final String? generatedImageUrl;

  final String? errorMessage;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  bool get isCompleted {
    return status == CvGenerationStatus.completed;
  }

  bool get isFailed {
    return status == CvGenerationStatus.failed;
  }

  bool get isProcessing {
    return status == CvGenerationStatus.processing;
  }

  bool get wasCreatedFromAssistant {
    return assistantSessionId != null;
  }

  bool get isEditedOrRegeneratedVersion {
    return sourceGenerationId != null;
  }

  bool get isTemplateMode {
    return mode == CvGenerationMode.template;
  }

  bool get isScratchMode {
    return mode == CvGenerationMode.scratch;
  }

  bool get hasDesignInstruction {
    return regenerationInstruction != null;
  }

  factory CvGenerationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvGenerationModel(
      id: json['id']?.toString() ?? '',

      assistantSessionId: _nullableValue(
        json['assistantSessionId'],
      ),

      sourceGenerationId: _nullableValue(
        json['sourceGenerationId'],
      ),

      mode: CvGenerationMode.fromValue(
        json['mode']?.toString(),
      ),

      templateId: _nullableValue(
        json['templateId'],
      ),

      status: CvGenerationStatus.fromValue(
        json['status']?.toString(),
      ),

      regenerationInstruction: _nullableValue(
        json['regenerationInstruction'],
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

      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ),
    );
  }

  CvGenerationModel copyWith({
    String? id,
    String? assistantSessionId,
    String? sourceGenerationId,
    CvGenerationMode? mode,
    String? templateId,
    CvGenerationStatus? status,
    String? regenerationInstruction,
    String? generatedImageUrl,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CvGenerationModel(
      id: id ?? this.id,

      assistantSessionId:
      assistantSessionId ?? this.assistantSessionId,

      sourceGenerationId:
      sourceGenerationId ?? this.sourceGenerationId,

      mode: mode ?? this.mode,

      templateId: templateId ?? this.templateId,

      status: status ?? this.status,

      regenerationInstruction:
      regenerationInstruction ??
          this.regenerationInstruction,

      generatedImageUrl:
      generatedImageUrl ?? this.generatedImageUrl,

      errorMessage:
      errorMessage ?? this.errorMessage,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String? _nullableValue(
    dynamic value,
    ) {
  final String normalized =
      value?.toString().trim() ?? '';

  return normalized.isEmpty
      ? null
      : normalized;
}