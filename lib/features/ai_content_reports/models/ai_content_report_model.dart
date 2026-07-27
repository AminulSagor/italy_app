enum AiReportFeatureType {
  writing('writing'),
  talking('talking'),
  cvBuilder('cv_builder');

  const AiReportFeatureType(this.apiValue);

  final String apiValue;
}

enum AiReportIssue {
  offensiveOrHateful(
    apiValue: 'offensive_or_hateful',
    translationKey: 'ai_report_offensive_or_hateful',
  ),
  sexualOrInappropriate(
    apiValue: 'sexual_or_inappropriate',
    translationKey: 'ai_report_sexual_or_inappropriate',
  ),
  dangerousOrHarmful(
    apiValue: 'dangerous_or_harmful',
    translationKey: 'ai_report_dangerous_or_harmful',
  ),
  harassment(
    apiValue: 'harassment',
    translationKey: 'ai_report_harassment',
  ),
  falseOrMisleading(
    apiValue: 'false_or_misleading',
    translationKey: 'ai_report_false_or_misleading',
  ),
  privacyConcern(
    apiValue: 'privacy_concern',
    translationKey: 'ai_report_privacy_concern',
  ),
  other(
    apiValue: 'other',
    translationKey: 'ai_report_other',
  );

  const AiReportIssue({
    required this.apiValue,
    required this.translationKey,
  });

  final String apiValue;
  final String translationKey;
}

class AiContentReportSource {
  const AiContentReportSource({
    required this.featureType,
    this.aiContentText,
    this.aiContentFileId,
    this.aiContentUrl,
    this.sourceReference,
    this.messageReference,
  });

  final AiReportFeatureType featureType;

  /// Automatically attached AI message or transcript.
  final String? aiContentText;

  /// For a generated CV stored by your backend.
  final String? aiContentFileId;

  /// For a generated CV preview or generated file URL.
  final String? aiContentUrl;

  /// Conversation, session or generation ID.
  final String? sourceReference;

  /// Individual AI message ID.
  final String? messageReference;

  bool get hasAutomaticAttachment {
    return (aiContentText?.trim().isNotEmpty ?? false) ||
        (aiContentFileId?.trim().isNotEmpty ?? false) ||
        (aiContentUrl?.trim().isNotEmpty ?? false);
  }
}