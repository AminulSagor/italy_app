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

enum CvAssistantEditMode {
  factsOnly,
  designAndFacts;

  String get apiValue {
    switch (this) {
      case CvAssistantEditMode.factsOnly:
        return 'facts_only';

      case CvAssistantEditMode.designAndFacts:
        return 'design_and_facts';
    }
  }

  String get label {
    switch (this) {
      case CvAssistantEditMode.factsOnly:
        return 'Edit information';

      case CvAssistantEditMode.designAndFacts:
        return 'Edit information and design';
    }
  }

  static CvAssistantEditMode? fromValue(
      String? value,
      ) {
    switch (value?.trim().toLowerCase()) {
      case 'facts_only':
        return CvAssistantEditMode.factsOnly;

      case 'design_and_facts':
        return CvAssistantEditMode.designAndFacts;

      default:
        return null;
    }
  }
}

enum CvAssistantPhotoDecision {
  unresolved,
  uploaded,
  withoutPhoto,
  notApplicable;

  String get apiValue {
    switch (this) {
      case CvAssistantPhotoDecision.unresolved:
        return 'unresolved';

      case CvAssistantPhotoDecision.uploaded:
        return 'uploaded';

      case CvAssistantPhotoDecision.withoutPhoto:
        return 'without_photo';

      case CvAssistantPhotoDecision.notApplicable:
        return 'not_applicable';
    }
  }

  static CvAssistantPhotoDecision fromValue(
      String? value,
      ) {
    switch (value?.trim().toLowerCase()) {
      case 'uploaded':
        return CvAssistantPhotoDecision.uploaded;

      case 'without_photo':
        return CvAssistantPhotoDecision.withoutPhoto;

      case 'not_applicable':
        return CvAssistantPhotoDecision.notApplicable;

      case 'unresolved':
      default:
        return CvAssistantPhotoDecision.unresolved;
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

  bool get isBatchQuestion {
    return key == 'batchCvDetails';
  }

  bool get isChoiceQuestion {
    return type == 'choice';
  }

  bool get isLongTextQuestion {
    return type == 'long_text';
  }

  bool get isEmailQuestion {
    return type == 'email';
  }

  bool get isPhoneQuestion {
    return type == 'phone';
  }

  bool get isUrlQuestion {
    return type == 'url';
  }

  bool get isListQuestion {
    return type == 'list';
  }

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

class CvPendingSuggestionModel {
  const CvPendingSuggestionModel({
    required this.key,
    required this.targetField,
    required this.text,
  });

  final String key;
  final String? targetField;
  final String text;

  factory CvPendingSuggestionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvPendingSuggestionModel(
      key: json['key']?.toString().trim() ?? '',
      targetField: _nullableString(
        json['targetField'],
      ),
      text: json['text']?.toString().trim() ?? '',
    );
  }
}

class CvAssistantPlanningStateModel {
  const CvAssistantPlanningStateModel({
    required this.pendingSuggestions,
    required this.confirmedSuggestions,
    required this.rejectedSuggestions,
    required this.declinedOptionalSections,
    required this.missingRequiredFields,
    required this.missingTemplateSections,
    required this.unresolvedOptionalSections,
    required this.photoDecision,
    required this.qualityIssues,
    required this.canGenerate,
  });

  final List<CvPendingSuggestionModel> pendingSuggestions;

  final List<String> confirmedSuggestions;

  final List<String> rejectedSuggestions;

  final List<String> declinedOptionalSections;

  final List<String> missingRequiredFields;

  final List<String> missingTemplateSections;

  final List<String> unresolvedOptionalSections;

  final CvAssistantPhotoDecision photoDecision;

  final List<String> qualityIssues;

  final bool canGenerate;

  bool get hasPendingSuggestions {
    return pendingSuggestions.isNotEmpty;
  }

  bool get hasMissingRequiredFields {
    return missingRequiredFields.isNotEmpty;
  }

  bool get hasMissingTemplateSections {
    return missingTemplateSections.isNotEmpty;
  }

  bool get hasUnresolvedOptionalSections {
    return unresolvedOptionalSections.isNotEmpty;
  }

  bool get hasQualityIssues {
    return qualityIssues.isNotEmpty;
  }

  bool get isPhotoDecisionUnresolved {
    return photoDecision ==
        CvAssistantPhotoDecision.unresolved;
  }

  bool get hasBlockers {
    return hasPendingSuggestions ||
        hasMissingRequiredFields ||
        hasMissingTemplateSections ||
        hasUnresolvedOptionalSections ||
        hasQualityIssues ||
        isPhotoDecisionUnresolved ||
        !canGenerate;
  }

  factory CvAssistantPlanningStateModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic rawPendingSuggestions =
    json['pendingSuggestions'];

    return CvAssistantPlanningStateModel(
      pendingSuggestions:
      rawPendingSuggestions is List
          ? rawPendingSuggestions
          .whereType<Map>()
          .map(
            (Map item) =>
            CvPendingSuggestionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
      )
          .where(
            (CvPendingSuggestionModel item) =>
        item.key.isNotEmpty ||
            item.text.isNotEmpty,
      )
          .toList()
          : <CvPendingSuggestionModel>[],

      confirmedSuggestions: _toStringList(
        json['confirmedSuggestions'],
      ),

      rejectedSuggestions: _toStringList(
        json['rejectedSuggestions'],
      ),

      declinedOptionalSections: _toStringList(
        json['declinedOptionalSections'],
      ),

      missingRequiredFields: _toStringList(
        json['missingRequiredFields'],
      ),

      missingTemplateSections: _toStringList(
        json['missingTemplateSections'],
      ),

      unresolvedOptionalSections: _toStringList(
        json['unresolvedOptionalSections'],
      ),

      photoDecision:
      CvAssistantPhotoDecision.fromValue(
        json['photoDecision']?.toString(),
      ),

      qualityIssues: _toStringList(
        json['qualityIssues'],
      ),

      canGenerate: json['canGenerate'] == true,
    );
  }

  factory CvAssistantPlanningStateModel.empty() {
    return const CvAssistantPlanningStateModel(
      pendingSuggestions:
      <CvPendingSuggestionModel>[],
      confirmedSuggestions: <String>[],
      rejectedSuggestions: <String>[],
      declinedOptionalSections: <String>[],
      missingRequiredFields: <String>[],
      missingTemplateSections: <String>[],
      unresolvedOptionalSections: <String>[],
      photoDecision:
      CvAssistantPhotoDecision.unresolved,
      qualityIssues: <String>[],
      canGenerate: false,
    );
  }
}

class CvAssistantSessionModel {
  const CvAssistantSessionModel({
    required this.id,
    required this.templateId,
    required this.status,
    required this.conversationMode,
    required this.editMode,
    required this.sourceGenerationId,
    required this.pendingDesignInstruction,
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
    required this.validationComplete,
    required this.qualityCheckPassed,
    required this.qualityCheckedAt,
    required this.generationBlockers,
    required this.planningState,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String? templateId;

  final CvAssistantSessionStatus status;

  final CvAssistantConversationMode conversationMode;

  final CvAssistantEditMode? editMode;

  final String? sourceGenerationId;

  final String? pendingDesignInstruction;

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

  /// This value comes directly from the backend.
  final bool canGenerate;

  /// This value comes directly from the backend.
  final bool validationComplete;

  /// This value comes directly from the backend.
  final bool qualityCheckPassed;

  final DateTime? qualityCheckedAt;

  final List<String> generationBlockers;

  final CvAssistantPlanningStateModel planningState;

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

  bool get isEditSession {
    return editMode != null;
  }

  bool get isFactsOnlyEdit {
    return editMode ==
        CvAssistantEditMode.factsOnly;
  }

  bool get isDesignAndFactsEdit {
    return editMode ==
        CvAssistantEditMode.designAndFacts;
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

  /// Generation readiness must come from the complete
  /// backend validation state.
  bool get isReadyToGenerate {
    return status ==
        CvAssistantSessionStatus.readyToGenerate &&
        canGenerate &&
        validationComplete &&
        qualityCheckPassed &&
        currentQuestion == null &&
        generationBlockers.isEmpty;
  }

  bool get hasGenerationBlockers {
    return generationBlockers.isNotEmpty;
  }

  List<String> get missingRequiredFields {
    return planningState.missingRequiredFields;
  }

  List<String> get missingTemplateSections {
    return planningState.missingTemplateSections;
  }

  List<String> get unresolvedOptionalSections {
    return planningState.unresolvedOptionalSections;
  }

  List<CvPendingSuggestionModel>
  get pendingSuggestions {
    return planningState.pendingSuggestions;
  }

  CvAssistantPhotoDecision get photoDecision {
    return planningState.photoDecision;
  }

  List<String> get qualityIssues {
    return planningState.qualityIssues;
  }

  bool get hasPendingSuggestions {
    return pendingSuggestions.isNotEmpty;
  }

  bool get hasUnresolvedPhotoDecision {
    return photoDecision ==
        CvAssistantPhotoDecision.unresolved;
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

    final dynamic rawPlanningState =
    json['planningState'];

    return CvAssistantSessionModel(
      id: json['id']?.toString() ?? '',

      templateId: _nullableString(
        json['templateId'],
      ),

      status:
      CvAssistantSessionStatus.fromValue(
        json['status']?.toString(),
      ),

      conversationMode:
      CvAssistantConversationMode.fromValue(
        json['conversationMode']?.toString(),
      ),

      editMode:
      CvAssistantEditMode.fromValue(
        json['editMode']?.toString(),
      ),

      sourceGenerationId: _nullableString(
        json['sourceGenerationId'],
      ),

      pendingDesignInstruction:
      _nullableString(
        json['pendingDesignInstruction'],
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

      skippedQuestionKeys: _toStringList(
        rawSkippedKeys,
      ),

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

      referenceImageFileIds: _toStringList(
        rawReferenceIds,
      ),

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
      json['canGenerate'] == true,

      validationComplete:
      json['validationComplete'] == true,

      qualityCheckPassed:
      json['qualityCheckPassed'] == true,

      qualityCheckedAt: DateTime.tryParse(
        json['qualityCheckedAt']?.toString() ??
            '',
      ),

      generationBlockers: _toStringList(
        json['generationBlockers'],
      ),

      planningState:
      rawPlanningState is Map
          ? CvAssistantPlanningStateModel
          .fromJson(
        Map<String, dynamic>.from(
          rawPlanningState,
        ),
      )
          : CvAssistantPlanningStateModel
          .empty(),

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
    CvAssistantConversationMode?
    conversationMode,
    CvAssistantEditMode? editMode,
    String? sourceGenerationId,
    String? pendingDesignInstruction,
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
    bool? validationComplete,
    bool? qualityCheckPassed,
    DateTime? qualityCheckedAt,
    List<String>? generationBlockers,
    CvAssistantPlanningStateModel?
    planningState,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CvAssistantSessionModel(
      id: id ?? this.id,

      templateId:
      templateId ?? this.templateId,

      status: status ?? this.status,

      conversationMode:
      conversationMode ??
          this.conversationMode,

      editMode: editMode ?? this.editMode,

      sourceGenerationId:
      sourceGenerationId ??
          this.sourceGenerationId,

      pendingDesignInstruction:
      pendingDesignInstruction ??
          this.pendingDesignInstruction,

      currentQuestionKey:
      currentQuestionKey ??
          this.currentQuestionKey,

      currentQuestion:
      currentQuestion ??
          this.currentQuestion,

      assistantMessage:
      assistantMessage ??
          this.assistantMessage,

      collectedCvData:
      collectedCvData ??
          this.collectedCvData,

      skippedQuestionKeys:
      skippedQuestionKeys ??
          this.skippedQuestionKeys,

      messages:
      messages ?? this.messages,

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
      generationId ??
          this.generationId,

      canGenerate:
      canGenerate ?? this.canGenerate,

      validationComplete:
      validationComplete ??
          this.validationComplete,

      qualityCheckPassed:
      qualityCheckPassed ??
          this.qualityCheckPassed,

      qualityCheckedAt:
      qualityCheckedAt ??
          this.qualityCheckedAt,

      generationBlockers:
      generationBlockers ??
          this.generationBlockers,

      planningState:
      planningState ??
          this.planningState,

      progress:
      progress ?? this.progress,

      createdAt:
      createdAt ?? this.createdAt,

      updatedAt:
      updatedAt ?? this.updatedAt,
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

List<String> _toStringList(
    dynamic value,
    ) {
  if (value is! List) {
    return <String>[];
  }

  return value
      .map(
        (dynamic item) =>
        item.toString().trim(),
  )
      .where(
        (String item) => item.isNotEmpty,
  )
      .toList();
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