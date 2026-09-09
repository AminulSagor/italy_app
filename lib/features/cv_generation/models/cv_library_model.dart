import 'package:get/get.dart';

class CvLibraryResponseModel {
  const CvLibraryResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<CvLibraryItemModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory CvLibraryResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];
    return CvLibraryResponseModel(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (Map item) => CvLibraryItemModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((CvLibraryItemModel item) => item.documentId.isNotEmpty)
                .toList()
          : const <CvLibraryItemModel>[],
      total: _toInt(json['total']),
      page: _toInt(json['page'], fallback: 1),
      limit: _toInt(json['limit'], fallback: 20),
      totalPages: _toInt(json['totalPages'], fallback: 1),
    );
  }
}

class CvLibraryItemModel {
  const CvLibraryItemModel({
    required this.documentId,
    required this.title,
    required this.templateId,
    required this.templateName,
    required this.templateCategory,
    required this.templateAvailable,
    required this.previewImageUrl,
    required this.revision,
    required this.status,
    required this.updatedAt,
    required this.creationChargedAt,
    required this.editingIsFree,
    required this.hasDraftChanges,
    required this.latestGeneration,
  });

  final String documentId;
  final String title;
  final String? templateId;
  final String templateName;
  final String? templateCategory;
  final bool templateAvailable;
  final String? previewImageUrl;
  final int revision;
  final String status;
  final DateTime? updatedAt;
  final DateTime? creationChargedAt;
  final bool editingIsFree;
  final bool hasDraftChanges;
  final CvLibraryGenerationModel? latestGeneration;

  bool get hasPdf => latestGeneration?.hasPdf == true;
  bool get isDraftOnly => !hasPdf;

  factory CvLibraryItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawGeneration = json['latestGeneration'];
    return CvLibraryItemModel(
      documentId: json['documentId']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? 'cvb_my_cv'.tr,
      templateId: _nullableString(json['templateId']),
      templateName: json['templateName']?.toString().trim().isNotEmpty == true
          ? json['templateName'].toString().trim()
          : 'cvb_template_fallback'.tr,
      templateCategory: _nullableString(json['templateCategory']),
      templateAvailable: json['templateAvailable'] != false,
      previewImageUrl: _nullableString(json['previewImageUrl']),
      revision: _toInt(json['revision'], fallback: 1),
      status: json['status']?.toString().trim() ?? 'draft',
      updatedAt: _dateTime(json['updatedAt']),
      creationChargedAt: _dateTime(json['creationChargedAt']),
      editingIsFree: json['editingIsFree'] == true,
      hasDraftChanges: json['hasDraftChanges'] != false,
      latestGeneration: rawGeneration is Map
          ? CvLibraryGenerationModel.fromJson(
              Map<String, dynamic>.from(rawGeneration),
            )
          : null,
    );
  }
}

class CvLibraryGenerationModel {
  const CvLibraryGenerationModel({
    required this.id,
    required this.documentRevision,
    required this.pageCount,
    required this.warnings,
    required this.createdAt,
    required this.hasPdf,
  });

  final String id;
  final int? documentRevision;
  final int pageCount;
  final List<String> warnings;
  final DateTime? createdAt;
  final bool hasPdf;

  factory CvLibraryGenerationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawWarnings = json['warnings'];
    return CvLibraryGenerationModel(
      id: json['id']?.toString().trim() ?? '',
      documentRevision: _nullableInt(json['documentRevision']),
      pageCount: _toInt(json['pageCount'], fallback: 1),
      warnings: rawWarnings is List
          ? rawWarnings
                .map((dynamic item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .toList()
          : const <String>[],
      createdAt: _dateTime(json['createdAt']),
      hasPdf: json['hasPdf'] == true,
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _dateTime(dynamic value) {
  final String raw = value?.toString().trim() ?? '';
  return raw.isEmpty ? null : DateTime.tryParse(raw);
}

String? _nullableString(dynamic value) {
  final String normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}
