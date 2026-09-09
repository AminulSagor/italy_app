import 'package:get/get.dart';

enum CvFieldType {
  text,
  textarea,
  email,
  phone,
  url,
  date,
  image,
  repeatable,
  select,
  tags,
  boolean;

  static CvFieldType fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'textarea':
        return CvFieldType.textarea;
      case 'email':
        return CvFieldType.email;
      case 'phone':
        return CvFieldType.phone;
      case 'url':
        return CvFieldType.url;
      case 'date':
        return CvFieldType.date;
      case 'image':
        return CvFieldType.image;
      case 'repeatable':
        return CvFieldType.repeatable;
      case 'select':
        return CvFieldType.select;
      case 'tags':
        return CvFieldType.tags;
      case 'boolean':
        return CvFieldType.boolean;
      case 'text':
      default:
        return CvFieldType.text;
    }
  }
}

class CvFieldDefinition {
  const CvFieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.enabled,
    required this.required,
    required this.hidden,
    required this.maxLength,
    required this.maxItems,
    required this.options,
    required this.aiAssist,
  });

  final String key;
  final String label;
  final CvFieldType type;
  final bool enabled;
  final bool required;
  final bool hidden;
  final int? maxLength;
  final int? maxItems;
  final List<String> options;
  final String? aiAssist;

  bool get isVisible => enabled && !hidden;
  bool get supportsAi => aiAssist?.trim().isNotEmpty == true;
  bool get supportsAiSummary => aiAssist == 'summary-suggestions';
  bool get supportsAiDescription => aiAssist == 'description-suggestions';
  bool get supportsAiHighlights => aiAssist == 'highlight-suggestions';
  bool get supportsAiTechnicalSkills =>
      aiAssist == 'technical-skill-suggestions';

  String get leafKey {
    final int index = key.lastIndexOf('.');
    return index < 0 ? key : key.substring(index + 1);
  }

  factory CvFieldDefinition.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];

    return CvFieldDefinition(
      key: json['key']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? '',
      type: CvFieldType.fromValue(json['type']?.toString()),
      enabled: json['enabled'] != false,
      required: json['required'] == true,
      hidden: json['hidden'] == true,
      maxLength: _nullableInt(json['maxLength']),
      maxItems: _nullableInt(json['maxItems']),
      options: rawOptions is List
          ? rawOptions
                .map((dynamic item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .toList()
          : const <String>[],
      aiAssist: _nullableString(json['aiAssist']),
    );
  }
}

class CvSectionDefinition {
  const CvSectionDefinition({
    required this.key,
    required this.label,
    required this.enabled,
    required this.required,
    required this.hidden,
    required this.order,
    required this.zone,
    required this.maxItems,
    required this.fields,
  });

  final String key;
  final String label;
  final bool enabled;
  final bool required;
  final bool hidden;
  final int order;
  final String? zone;
  final int? maxItems;
  final List<CvFieldDefinition> fields;

  bool get isVisible => enabled && !hidden;

  List<CvFieldDefinition> get visibleFields =>
      fields.where((CvFieldDefinition field) => field.isVisible).toList();

  bool get isCollectionSection {
    return <String>{
      'experience',
      'education',
      'projects',
      'languages',
      'certifications',
      'references',
    }.contains(key);
  }

  factory CvSectionDefinition.fromJson(Map<String, dynamic> json) {
    final dynamic rawFields = json['fields'];

    return CvSectionDefinition(
      key: json['key']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? '',
      enabled: json['enabled'] != false,
      required: json['required'] == true,
      hidden: json['hidden'] == true,
      order: _toInt(json['order']),
      zone: _nullableString(json['zone']),
      maxItems: _nullableInt(json['maxItems']),
      fields: rawFields is List
          ? rawFields
                .whereType<Map>()
                .map(
                  (Map item) => CvFieldDefinition.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((CvFieldDefinition field) => field.key.isNotEmpty)
                .toList()
          : const <CvFieldDefinition>[],
    );
  }
}

class CvFieldSchema {
  const CvFieldSchema({required this.sections});

  final List<CvSectionDefinition> sections;

  List<CvSectionDefinition> get visibleSections {
    final List<CvSectionDefinition> result = sections
        .where((CvSectionDefinition section) => section.isVisible)
        .toList();
    result.sort(
      (CvSectionDefinition a, CvSectionDefinition b) =>
          a.order.compareTo(b.order),
    );
    return result;
  }

  factory CvFieldSchema.fromJson(Map<String, dynamic> json) {
    final dynamic rawSections = json['sections'];

    return CvFieldSchema(
      sections: rawSections is List
          ? rawSections
                .whereType<Map>()
                .map(
                  (Map item) => CvSectionDefinition.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((CvSectionDefinition section) => section.key.isNotEmpty)
                .toList()
          : const <CvSectionDefinition>[],
    );
  }
}

class CvTemplateModel {
  const CvTemplateModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.isPremium,
    required this.publishedAt,
    required this.fieldSchema,
    required this.previewImageUrl,
    this.locale,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final String category;
  final bool isPremium;
  final DateTime? publishedAt;
  final CvFieldSchema fieldSchema;
  final String? previewImageUrl;
  final String? locale;

  bool get hasPreviewImage => previewImageUrl?.trim().isNotEmpty == true;

  bool get isNew {
    final DateTime? value = publishedAt;
    if (value == null) return false;
    final int ageInDays = DateTime.now().difference(value.toLocal()).inDays;
    return ageInDays >= 0 && ageInDays <= 14;
  }

  factory CvTemplateModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSchema = json['fieldSchema'];

    return CvTemplateModel(
      id: json['id']?.toString().trim() ?? '',
      slug: json['slug']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? '',
      description: _nullableString(json['description']),
      category: json['category']?.toString().trim() ?? '',
      isPremium: json['isPremium'] == true,
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
      fieldSchema: CvFieldSchema.fromJson(
        rawSchema is Map
            ? Map<String, dynamic>.from(rawSchema)
            : const <String, dynamic>{},
      ),
      previewImageUrl: _nullableString(json['previewImageUrl']),
      locale: _nullableString(json['locale']),
    );
  }
}

class CvTemplatePreviewModel {
  const CvTemplatePreviewModel({
    required this.templateId,
    required this.slug,
    required this.previewImageUrl,
    required this.previewPdfUrl,
  });

  final String templateId;
  final String slug;
  final String? previewImageUrl;
  final String? previewPdfUrl;

  bool get hasPreviewPdf => previewPdfUrl?.trim().isNotEmpty == true;
  bool get hasPreviewImage => previewImageUrl?.trim().isNotEmpty == true;

  factory CvTemplatePreviewModel.fromJson(Map<String, dynamic> json) {
    return CvTemplatePreviewModel(
      templateId: json['templateId']?.toString().trim() ?? '',
      slug: json['slug']?.toString().trim() ?? '',
      previewImageUrl: _nullableString(json['previewImageUrl']),
      previewPdfUrl: _nullableString(json['previewPdfUrl']),
    );
  }
}

class CvTemplateListResponseModel {
  const CvTemplateListResponseModel({
    required this.templates,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<CvTemplateModel> templates;
  final int page;
  final int limit;
  final int total;

  int get totalPages {
    if (limit <= 0 || total <= 0) return 0;
    return (total / limit).ceil();
  }

  factory CvTemplateListResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems = json['items'];

    return CvTemplateListResponseModel(
      templates: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (Map item) =>
                      CvTemplateModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((CvTemplateModel item) => item.id.isNotEmpty)
                .toList()
          : const <CvTemplateModel>[],
      page: _toInt(json['page'], fallback: 1),
      limit: _toInt(json['limit'], fallback: 6),
      total: _toInt(json['total']),
    );
  }
}

class CvAccessModel {
  const CvAccessModel({
    required this.freeCreationLimit,
    required this.freeCreationsUsed,
    required this.freeCreationsRemaining,
    required this.paidCredits,
    required this.totalCreationsAvailable,
    required this.canCreate,
    required this.nextCreationUses,
    required this.editingIsFree,
  });

  final int freeCreationLimit;
  final int freeCreationsUsed;
  final int freeCreationsRemaining;
  final int paidCredits;
  final int totalCreationsAvailable;
  final bool canCreate;
  final String nextCreationUses;
  final bool editingIsFree;

  bool get nextIsFree => nextCreationUses == 'free';
  bool get nextUsesPaidCredit => nextCreationUses == 'credit';

  factory CvAccessModel.fromJson(Map<String, dynamic> json) {
    return CvAccessModel(
      freeCreationLimit: _toInt(json['freeCreationLimit']),
      freeCreationsUsed: _toInt(json['freeCreationsUsed']),
      freeCreationsRemaining: _toInt(json['freeCreationsRemaining']),
      paidCredits: _toInt(json['paidCredits']),
      totalCreationsAvailable: _toInt(json['totalCreationsAvailable']),
      canCreate: json['canCreate'] == true,
      nextCreationUses: json['nextCreationUses']?.toString().trim() ?? 'none',
      editingIsFree: json['editingIsFree'] != false,
    );
  }
}

class CvRecentGenerationModel {
  const CvRecentGenerationModel({
    required this.id,
    required this.templateId,
    required this.pageCount,
    required this.warnings,
    required this.createdAt,
    required this.hasPdf,
  });

  final String id;
  final String templateId;
  final int pageCount;
  final List<String> warnings;
  final DateTime? createdAt;
  final bool hasPdf;

  factory CvRecentGenerationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawWarnings = json['warnings'];
    return CvRecentGenerationModel(
      id: json['id']?.toString().trim() ?? '',
      templateId: json['templateId']?.toString().trim() ?? '',
      pageCount: _toInt(json['pageCount'], fallback: 1),
      warnings: rawWarnings is List
          ? rawWarnings
                .map((dynamic item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .toList()
          : const <String>[],
      createdAt: _dateTime(json['createdAt']),
      hasPdf:
          json['hasPdf'] == true ||
          (json['pdfUrl']?.toString().trim().isNotEmpty == true),
    );
  }
}

class CvRecentDocumentModel {
  const CvRecentDocumentModel({
    required this.id,
    required this.title,
    required this.templateId,
    required this.revision,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.creationChargedAt,
    required this.creationChargeSource,
    required this.editingIsFree,
    required this.latestGeneration,
  });

  final String id;
  final String title;
  final String? templateId;
  final int revision;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? creationChargedAt;
  final String? creationChargeSource;
  final bool editingIsFree;
  final CvRecentGenerationModel? latestGeneration;

  bool get hasConsumedCreationAccess => creationChargedAt != null;
  bool get hasPdf => latestGeneration?.hasPdf == true;
  bool get isDraft => !hasConsumedCreationAccess;

  factory CvRecentDocumentModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawGeneration = json['latestGeneration'];
    return CvRecentDocumentModel(
      id: json['id']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? 'cvb_my_cv'.tr,
      templateId: _nullableString(json['templateId']),
      revision: _toInt(json['revision'], fallback: 1),
      status: json['status']?.toString().trim() ?? 'draft',
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTime(json['updatedAt']),
      creationChargedAt: _dateTime(json['creationChargedAt']),
      creationChargeSource: _nullableString(json['creationChargeSource']),
      editingIsFree: json['editingIsFree'] == true,
      latestGeneration: rawGeneration is Map
          ? CvRecentGenerationModel.fromJson(
              Map<String, dynamic>.from(rawGeneration),
            )
          : null,
    );
  }
}

class CvHomeBootstrapModel {
  const CvHomeBootstrapModel({
    required this.templateResponse,
    required this.categories,
    required this.builderContract,
    required this.cvAccess,
  });

  final CvTemplateListResponseModel templateResponse;
  final List<CvTemplateCategoryModel> categories;
  final CvBuilderContractModel builderContract;
  final CvAccessModel cvAccess;

  factory CvHomeBootstrapModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawTemplates = json['templates'];
    final dynamic rawCategories = json['categories'];
    final dynamic rawContract = json['builderContract'];
    final dynamic rawAccess = json['cvAccess'];

    return CvHomeBootstrapModel(
      templateResponse: CvTemplateListResponseModel.fromJson(
        rawTemplates is Map
            ? Map<String, dynamic>.from(rawTemplates)
            : const <String, dynamic>{},
      ),
      categories: rawCategories is List
          ? rawCategories
                .whereType<Map>()
                .map(
                  (Map item) => CvTemplateCategoryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where(
                  (CvTemplateCategoryModel item) => item.category.isNotEmpty,
                )
                .toList()
          : const <CvTemplateCategoryModel>[],
      builderContract: CvBuilderContractModel.fromJson(
        rawContract is Map
            ? Map<String, dynamic>.from(rawContract)
            : const <String, dynamic>{},
      ),
      cvAccess: CvAccessModel.fromJson(
        rawAccess is Map
            ? Map<String, dynamic>.from(rawAccess)
            : const <String, dynamic>{},
      ),
    );
  }
}

class CvTemplateCategoryModel {
  const CvTemplateCategoryModel({required this.category, required this.count});

  final String category;
  final int count;

  factory CvTemplateCategoryModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateCategoryModel(
      category: json['category']?.toString().trim() ?? '',
      count: _toInt(json['count']),
    );
  }
}

class CvBuilderContractModel {
  const CvBuilderContractModel({
    required this.fieldSchema,
    required this.photoFilePurpose,
    required this.photoMaxBytes,
    required this.allowedPhotoMimeTypes,
    required this.autosaveDebounceMs,
  });

  final CvFieldSchema fieldSchema;
  final String photoFilePurpose;
  final int photoMaxBytes;
  final List<String> allowedPhotoMimeTypes;
  final int autosaveDebounceMs;

  factory CvBuilderContractModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSchema = json['fieldSchema'];
    final dynamic rawPhoto = json['photoUpload'];
    final dynamic rawAutosave = json['autosave'];

    final Map<String, dynamic> photo = rawPhoto is Map
        ? Map<String, dynamic>.from(rawPhoto)
        : const <String, dynamic>{};
    final Map<String, dynamic> autosave = rawAutosave is Map
        ? Map<String, dynamic>.from(rawAutosave)
        : const <String, dynamic>{};
    final dynamic rawMimeTypes = photo['allowedMimeTypes'];

    return CvBuilderContractModel(
      fieldSchema: CvFieldSchema.fromJson(
        rawSchema is Map
            ? Map<String, dynamic>.from(rawSchema)
            : const <String, dynamic>{},
      ),
      photoFilePurpose: photo['filePurpose']?.toString().trim() ?? 'cv_photo',
      photoMaxBytes: _toInt(photo['maxBytes'], fallback: 5 * 1024 * 1024),
      allowedPhotoMimeTypes: rawMimeTypes is List
          ? rawMimeTypes
                .map((dynamic item) => item.toString().trim().toLowerCase())
                .where((String item) => item.isNotEmpty)
                .toList()
          : const <String>['image/jpeg', 'image/png', 'image/webp'],
      autosaveDebounceMs: _toInt(
        autosave['recommendedDebounceMs'],
        fallback: 700,
      ),
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
