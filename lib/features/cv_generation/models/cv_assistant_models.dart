enum CvAssistantConversationMode {
  oneByOne,
  allAtOnce;

  String get apiValue {
    switch (this) {
      case CvAssistantConversationMode.oneByOne:
        return 'one_by_one';
      case CvAssistantConversationMode.allAtOnce:
        return 'all_at_once';
    }
  }

  String get label {
    switch (this) {
      case CvAssistantConversationMode.oneByOne:
        return 'One by One';
      case CvAssistantConversationMode.allAtOnce:
        return 'All at Once';
    }
  }

  static CvAssistantConversationMode fromValue(
      String? value,
      ) {
    switch (value?.trim().toLowerCase()) {
      case 'all_at_once':
        return CvAssistantConversationMode.allAtOnce;
      case 'one_by_one':
      default:
        return CvAssistantConversationMode.oneByOne;
    }
  }
}

enum CvAssistantMessageRole {
  user,
  assistant,
  system;

  static CvAssistantMessageRole fromValue(
      String? value,
      ) {
    return CvAssistantMessageRole.values.firstWhere(
          (CvAssistantMessageRole role) =>
      role.name == value?.trim().toLowerCase(),
      orElse: () => CvAssistantMessageRole.assistant,
    );
  }
}

enum CvAssistantSessionStatus {
  active,
  readyToGenerate,
  generating,
  completed,
  cancelled;

  static CvAssistantSessionStatus fromValue(
      String? value,
      ) {
    switch (value?.trim().toLowerCase()) {
      case 'ready_to_generate':
        return CvAssistantSessionStatus.readyToGenerate;

      case 'generating':
        return CvAssistantSessionStatus.generating;

      case 'completed':
        return CvAssistantSessionStatus.completed;

      case 'cancelled':
        return CvAssistantSessionStatus.cancelled;

      case 'active':
      default:
        return CvAssistantSessionStatus.active;
    }
  }
}

class CvAssistantQuestionModel {
  const CvAssistantQuestionModel({
    required this.key,
    required this.text,
    required this.type,
    required this.optional,
  });

  final String key;
  final String text;
  final String type;
  final bool optional;

  bool get isBatchQuestion => key == 'batchCvDetails';

  factory CvAssistantQuestionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvAssistantQuestionModel(
      key: json['key']?.toString().trim() ?? '',
      text: json['text']?.toString().trim() ?? '',
      type: json['type']?.toString().trim() ?? 'text',
      optional: json['optional'] == true,
    );
  }
}

class CvAssistantMessageModel {
  const CvAssistantMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.questionKey,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final CvAssistantMessageRole role;
  final String text;
  final String? questionKey;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  bool get isUser {
    return role == CvAssistantMessageRole.user;
  }

  bool get isAssistant {
    return role == CvAssistantMessageRole.assistant;
  }

  bool get isSystem {
    return role == CvAssistantMessageRole.system;
  }

  factory CvAssistantMessageModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic rawMetadata = json['metadata'];

    return CvAssistantMessageModel(
      id: json['id']?.toString() ?? '',
      role: CvAssistantMessageRole.fromValue(
        json['role']?.toString(),
      ),
      text: json['text']?.toString() ?? '',
      questionKey: _nullableString(
        json['questionKey'],
      ),
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
    );
  }
}

class CvAssistantSessionModel {
  const CvAssistantSessionModel({
    required this.id,
    required this.templateId,
    required this.status,
    required this.conversationMode,
    required this.currentQuestionKey,
    required this.currentQuestion,
    required this.assistantMessage,
    required this.collectedCvData,
    required this.skippedQuestionKeys,
    required this.messages,
    required this.profilePhotoFileId,
    required this.referenceImageFileIds,
    required this.templateAnalysis,
    required this.generationId,
    required this.canGenerate,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String? templateId;

  final CvAssistantSessionStatus status;

  final CvAssistantConversationMode conversationMode;

  final String? currentQuestionKey;

  final CvAssistantQuestionModel? currentQuestion;

  final String? assistantMessage;

  final Map<String, dynamic> collectedCvData;

  final List<String> skippedQuestionKeys;

  final List<CvAssistantMessageModel> messages;

  final String? profilePhotoFileId;

  final List<String> referenceImageFileIds;

  final Map<String, dynamic>? templateAnalysis;

  final String? generationId;

  final bool canGenerate;

  final int progress;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  bool get isOneByOneMode {
    return conversationMode ==
        CvAssistantConversationMode.oneByOne;
  }

  bool get isAllAtOnceMode {
    return conversationMode ==
        CvAssistantConversationMode.allAtOnce;
  }

  bool get isGenerating {
    return status ==
        CvAssistantSessionStatus.generating;
  }

  bool get isCompleted {
    return status ==
        CvAssistantSessionStatus.completed;
  }

  bool get isCancelled {
    return status ==
        CvAssistantSessionStatus.cancelled;
  }

  bool get isReadyToGenerate {
    return status ==
        CvAssistantSessionStatus.readyToGenerate ||
        canGenerate;
  }

  factory CvAssistantSessionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic rawQuestion =
    json['currentQuestion'];

    final dynamic rawMessages =
    json['messages'];

    final dynamic rawReferenceIds =
    json['referenceImageFileIds'];

    final dynamic rawSkippedKeys =
    json['skippedQuestionKeys'];

    final dynamic rawCollectedData =
    json['collectedCvData'];

    final dynamic rawTemplateAnalysis =
    json['templateAnalysis'];

    return CvAssistantSessionModel(
      id: json['id']?.toString() ?? '',

      templateId: _nullableString(
        json['templateId'],
      ),

      status: CvAssistantSessionStatus.fromValue(
        json['status']?.toString(),
      ),

      conversationMode:
      CvAssistantConversationMode.fromValue(
        json['conversationMode']?.toString(),
      ),

      currentQuestionKey: _nullableString(
        json['currentQuestionKey'],
      ),

      currentQuestion: rawQuestion is Map
          ? CvAssistantQuestionModel.fromJson(
        Map<String, dynamic>.from(
          rawQuestion,
        ),
      )
          : null,

      assistantMessage: _nullableString(
        json['assistantMessage'],
      ),

      collectedCvData: rawCollectedData is Map
          ? Map<String, dynamic>.from(
        rawCollectedData,
      )
          : <String, dynamic>{},

      skippedQuestionKeys:
      rawSkippedKeys is List
          ? rawSkippedKeys
          .map(
            (dynamic item) =>
            item.toString().trim(),
      )
          .where(
            (String item) =>
        item.isNotEmpty,
      )
          .toList()
          : <String>[],

      messages: rawMessages is List
          ? rawMessages
          .whereType<Map>()
          .map(
            (Map item) =>
            CvAssistantMessageModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
      )
          .toList()
          : <CvAssistantMessageModel>[],

      profilePhotoFileId: _nullableString(
        json['profilePhotoFileId'],
      ),

      referenceImageFileIds:
      rawReferenceIds is List
          ? rawReferenceIds
          .map(
            (dynamic item) =>
            item.toString().trim(),
      )
          .where(
            (String item) =>
        item.isNotEmpty,
      )
          .toList()
          : <String>[],

      templateAnalysis:
      rawTemplateAnalysis is Map
          ? Map<String, dynamic>.from(
        rawTemplateAnalysis,
      )
          : null,

      generationId: _nullableString(
        json['generationId'],
      ),

      canGenerate:
      json['canGenerate'] != false,

      progress: _toProgress(
        json['progress'],
      ),

      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),

      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ),
    );
  }

  CvAssistantSessionModel copyWith({
    String? id,
    String? templateId,
    CvAssistantSessionStatus? status,
    CvAssistantConversationMode? conversationMode,
    String? currentQuestionKey,
    CvAssistantQuestionModel? currentQuestion,
    String? assistantMessage,
    Map<String, dynamic>? collectedCvData,
    List<String>? skippedQuestionKeys,
    List<CvAssistantMessageModel>? messages,
    String? profilePhotoFileId,
    List<String>? referenceImageFileIds,
    Map<String, dynamic>? templateAnalysis,
    String? generationId,
    bool? canGenerate,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CvAssistantSessionModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      status: status ?? this.status,
      conversationMode:
      conversationMode ?? this.conversationMode,
      currentQuestionKey:
      currentQuestionKey ??
          this.currentQuestionKey,
      currentQuestion:
      currentQuestion ?? this.currentQuestion,
      assistantMessage:
      assistantMessage ?? this.assistantMessage,
      collectedCvData:
      collectedCvData ?? this.collectedCvData,
      skippedQuestionKeys:
      skippedQuestionKeys ??
          this.skippedQuestionKeys,
      messages: messages ?? this.messages,
      profilePhotoFileId:
      profilePhotoFileId ??
          this.profilePhotoFileId,
      referenceImageFileIds:
      referenceImageFileIds ??
          this.referenceImageFileIds,
      templateAnalysis:
      templateAnalysis ??
          this.templateAnalysis,
      generationId:
      generationId ?? this.generationId,
      canGenerate:
      canGenerate ?? this.canGenerate,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String? _nullableString(
    dynamic value,
    ) {
  final String normalized =
      value?.toString().trim() ?? '';

  return normalized.isEmpty
      ? null
      : normalized;
}

int _toProgress(
    dynamic value,
    ) {
  final int progress = value is num
      ? value.toInt()
      : int.tryParse(
    value?.toString() ?? '',
  ) ??
      0;

  return progress.clamp(0, 100);
}