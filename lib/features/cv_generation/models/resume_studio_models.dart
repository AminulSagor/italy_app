import 'dart:convert';

import 'package:get/get.dart';

class ResumeDocumentModel {
  const ResumeDocumentModel({
    required this.id,
    required this.title,
    required this.templateId,
    required this.data,
    required this.revision,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.creationChargedAt,
    required this.creationChargeSource,
  });

  final String id;
  final String title;
  final String? templateId;
  final Map<String, dynamic> data;
  final int revision;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? creationChargedAt;
  final String? creationChargeSource;

  bool get hasConsumedCreationAccess => creationChargedAt != null;
  bool get isFreeToEdit => hasConsumedCreationAccess;

  factory ResumeDocumentModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];

    return ResumeDocumentModel(
      id: json['id']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? 'cvb_my_cv'.tr,
      templateId: _nullableString(json['templateId']),
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
      revision: _toInt(json['revision'], fallback: 1),
      status: json['status']?.toString().trim() ?? 'draft',
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTime(json['updatedAt']),
      creationChargedAt: _dateTime(json['creationChargedAt']),
      creationChargeSource: _nullableString(json['creationChargeSource']),
    );
  }
}

class ResumeGenerationModel {
  const ResumeGenerationModel({
    required this.id,
    required this.documentId,
    required this.templateId,
    required this.pageCount,
    required this.warnings,
    required this.cached,
    required this.pdfUrl,
    required this.createdAt,
    required this.creationChargedNow,
    required this.creationSource,
    required this.editingIsFree,
  });

  final String id;
  final String documentId;
  final String templateId;
  final int pageCount;
  final List<String> warnings;
  final bool cached;
  final String pdfUrl;
  final DateTime? createdAt;
  final bool creationChargedNow;
  final String? creationSource;
  final bool editingIsFree;

  factory ResumeGenerationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawWarnings = json['warnings'];
    final dynamic rawCreation = json['creation'];
    final Map<String, dynamic> creation = rawCreation is Map
        ? Map<String, dynamic>.from(rawCreation)
        : const <String, dynamic>{};

    return ResumeGenerationModel(
      id: json['id']?.toString().trim() ?? '',
      documentId: json['documentId']?.toString().trim() ?? '',
      templateId: json['templateId']?.toString().trim() ?? '',
      pageCount: _toInt(json['pageCount'], fallback: 1),
      warnings: rawWarnings is List
          ? rawWarnings
                .map((dynamic item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .toList()
          : const <String>[],
      cached: json['cached'] == true,
      pdfUrl: json['pdfUrl']?.toString().trim() ?? '',
      createdAt: _dateTime(json['createdAt']),
      creationChargedNow: creation['chargedNow'] == true,
      creationSource: _nullableString(creation['source']),
      editingIsFree: creation['editingIsFree'] != false,
    );
  }
}

class ResumeAiSuggestionsModel {
  const ResumeAiSuggestionsModel({required this.suggestions});

  final List<String> suggestions;

  factory ResumeAiSuggestionsModel.fromJson(Map<String, dynamic> json) {
    return ResumeAiSuggestionsModel(suggestions: _suggestionStrings(json));
  }
}

typedef ResumeSummarySuggestionsModel = ResumeAiSuggestionsModel;

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _dateTime(dynamic value) {
  final String raw = value?.toString().trim() ?? '';
  return raw.isEmpty ? null : DateTime.tryParse(raw);
}

String? _nullableString(dynamic value) {
  final String normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

List<String> _suggestionStrings(dynamic value, {int depth = 0}) {
  if (depth > 5 || value == null) return const <String>[];

  if (value is Map) {
    final dynamic direct = value['suggestions'];
    if (direct is List) {
      final List<String> suggestions = direct
          .expand((dynamic item) {
            final List<String> nested = _suggestionStrings(
              item,
              depth: depth + 1,
            );
            if (nested.isNotEmpty) return nested;
            final String text = item?.toString().trim() ?? '';
            return text.isEmpty || _looksLikeRawAiPayload(text)
                ? const <String>[]
                : <String>[text];
          })
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      if (suggestions.isNotEmpty) return suggestions;
    }

    for (final String key in <String>[
      'message',
      'primary',
      'text',
      'content',
      'reply',
      'response',
      'assistantMessage',
      'data',
    ]) {
      final List<String> nested = _suggestionStrings(
        value[key],
        depth: depth + 1,
      );
      if (nested.isNotEmpty) return nested;
    }
    return const <String>[];
  }

  if (value is String) {
    String encoded = value.trim();
    if (encoded.startsWith('```') && encoded.endsWith('```')) {
      final List<String> lines = encoded.split('\n');
      if (lines.length >= 3) {
        encoded = lines.sublist(1, lines.length - 1).join('\n').trim();
      }
    }
    final List<String> candidates = <String>[encoded];
    final int objectStart = encoded.indexOf('{');
    final int objectEnd = encoded.lastIndexOf('}');
    if (objectStart >= 0 && objectEnd > objectStart) {
      final String embedded = encoded.substring(objectStart, objectEnd + 1);
      if (embedded != encoded) candidates.add(embedded);
    }
    for (final String candidate in candidates) {
      if (!(candidate.startsWith('{') || candidate.startsWith('['))) continue;
      try {
        final List<String> nested = _suggestionStrings(
          jsonDecode(candidate),
          depth: depth + 1,
        );
        if (nested.isNotEmpty) return nested;
      } catch (_) {
        // Try any embedded JSON object before giving up.
      }
    }
    return const <String>[];
  }

  return const <String>[];
}

bool _looksLikeRawAiPayload(String value) {
  final String normalized = value.trim();
  return normalized.startsWith('{') ||
      normalized.startsWith('[') ||
      normalized.startsWith('```') ||
      normalized.contains('"suggestions"') ||
      normalized.contains('"primary"');
}
