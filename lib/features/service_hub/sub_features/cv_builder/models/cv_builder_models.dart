class CvTemplateDynamicItemFieldModel {
  const CvTemplateDynamicItemFieldModel({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.placeholder,
  });

  final String key;
  final String label;
  final String type;
  final bool required;
  final String? placeholder;

  factory CvTemplateDynamicItemFieldModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateDynamicItemFieldModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true,
      placeholder: json['placeholder']?.toString(),
    );
  }
}

class CvTemplateFieldModel {
  const CvTemplateFieldModel({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.placeholder,
    required this.options,
    required this.listStyle,
    required this.repeatGap,
    required this.itemFields,
  });

  final String key;
  final String label;
  final String type;
  final bool required;
  final String? placeholder;
  final List<String> options;
  final String listStyle;
  final double repeatGap;
  final List<CvTemplateDynamicItemFieldModel> itemFields;

  factory CvTemplateFieldModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];
    final dynamic rawItemFields = json['itemFields'];
    final List<String> parsedOptions = rawOptions is List
        ? rawOptions.map((dynamic item) => item.toString()).toList()
        : <String>[];

    List<CvTemplateDynamicItemFieldModel> parseOptionItemFields() {
      return parsedOptions
          .map((String item) => item.split('|'))
          .where((List<String> parts) => parts.isNotEmpty)
          .map((List<String> parts) {
        final String key = parts[0].trim();
        final String label = parts.length > 1 ? parts[1].trim() : key;
        final String type = parts.length > 2 ? parts[2].trim() : 'text';
        return CvTemplateDynamicItemFieldModel(
          key: key.isEmpty ? label : key,
          label: label.isEmpty ? key : label,
          type: type == 'textarea' ? 'textarea' : 'text',
          required: false,
          placeholder: label.isEmpty ? key : label,
        );
      }).toList(growable: false);
    }

    final List<CvTemplateDynamicItemFieldModel> parsedItemFields =
        rawItemFields is List
            ? rawItemFields
                .whereType<Map>()
                .map(
                  (Map<dynamic, dynamic> item) =>
                      CvTemplateDynamicItemFieldModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
            : parseOptionItemFields();

    return CvTemplateFieldModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true,
      placeholder: json['placeholder']?.toString(),
      options: parsedOptions,
      listStyle: json['listStyle']?.toString() ?? 'bullet',
      repeatGap: json['repeatGap'] is num
          ? (json['repeatGap'] as num).toDouble()
          : double.tryParse(json['repeatGap']?.toString() ?? '') ?? 10,
      itemFields: parsedItemFields.isEmpty
          ? <CvTemplateDynamicItemFieldModel>[
              const CvTemplateDynamicItemFieldModel(
                key: 'title',
                label: 'Title',
                type: 'text',
                required: false,
                placeholder: 'Senior Software Developer',
              ),
              const CvTemplateDynamicItemFieldModel(
                key: 'subtitle',
                label: 'Company / Institution',
                type: 'text',
                required: false,
                placeholder: 'Company - Country',
              ),
              const CvTemplateDynamicItemFieldModel(
                key: 'dateRange',
                label: 'Date range',
                type: 'text',
                required: false,
                placeholder: 'Jan 2022 - Dec 2023',
              ),
              const CvTemplateDynamicItemFieldModel(
                key: 'description',
                label: 'Description',
                type: 'textarea',
                required: false,
                placeholder: 'Describe the role or achievement',
              ),
            ]
          : parsedItemFields,
    );
  }
}

class CvTemplateSectionModel {
  const CvTemplateSectionModel({
    required this.key,
    required this.title,
    required this.required,
    required this.fields,
    required this.designerJson,
  });

  final String key;
  final String title;
  final bool required;
  final List<CvTemplateFieldModel> fields;
  final Map<String, dynamic> designerJson;

  factory CvTemplateSectionModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawFields = json['fields'];
    final Map<String, dynamic> parsedDesignerJson = json['designerJson'] is Map
        ? Map<String, dynamic>.from(json['designerJson'] as Map)
        : <String, dynamic>{};
    return CvTemplateSectionModel(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      required: json['required'] == true,
      designerJson: parsedDesignerJson,
      fields: rawFields is List
          ? rawFields
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) => CvTemplateFieldModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <CvTemplateFieldModel>[],
    );
  }
}

class CvTemplateSchemaModel {
  const CvTemplateSchemaModel({
    required this.sections,
    required this.colorOptions,
    required this.designJson,
    required this.layout,
  });

  final List<CvTemplateSectionModel> sections;
  final List<String> colorOptions;
  final Map<String, dynamic> designJson;
  final Map<String, dynamic> layout;

  factory CvTemplateSchemaModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSections = json['sections'];
    final dynamic rawColors = json['colorOptions'];
    final Map<String, dynamic> parsedDesignJson = json['designJson'] is Map
        ? Map<String, dynamic>.from(json['designJson'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> parsedLayout = json['layout'] is Map
        ? Map<String, dynamic>.from(json['layout'] as Map)
        : parsedDesignJson;

    return CvTemplateSchemaModel(
      sections: rawSections is List
          ? rawSections
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) => CvTemplateSectionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <CvTemplateSectionModel>[],
      colorOptions: rawColors is List
          ? rawColors.map((dynamic item) => item.toString()).toList()
          : <String>['#006B3F', '#646C7A', '#0B4A7D', '#7B4A2F'],
      designJson: parsedDesignJson.isNotEmpty ? parsedDesignJson : parsedLayout,
      layout: parsedLayout,
    );
  }
}

class CvTemplateModel {
  const CvTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.styleType,
    required this.pageSize,
    required this.fontFamily,
    required this.primaryColor,
    required this.accentColor,
    required this.isPremium,
    required this.status,
    required this.previewImageUrl,
    required this.schema,
  });

  final String id;
  final String title;
  final String? description;
  final String styleType;
  final String pageSize;
  final String fontFamily;
  final String primaryColor;
  final String accentColor;
  final bool isPremium;
  final String status;
  final String? previewImageUrl;
  final CvTemplateSchemaModel schema;

  factory CvTemplateModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      styleType: json['styleType']?.toString() ?? 'ats',
      pageSize: json['pageSize']?.toString() ?? 'a4',
      fontFamily: json['fontFamily']?.toString() ?? 'Inter',
      primaryColor: json['primaryColor']?.toString() ?? '#006B3F',
      accentColor: json['accentColor']?.toString() ?? '#E6F6F0',
      isPremium: json['isPremium'] == true,
      status: json['status']?.toString() ?? 'active',
      previewImageUrl: json['previewImageUrl']?.toString(),
      schema: CvTemplateSchemaModel.fromJson(
        json['schema'] is Map
            ? Map<String, dynamic>.from(json['schema'] as Map)
            : <String, dynamic>{},
      ),
    );
  }
}

class CvPaginationModel {
  const CvPaginationModel({
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
  });

  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;

  factory CvPaginationModel.fromJson(Map<String, dynamic> json) {
    int readInt(String key, int fallback) {
      final dynamic value = json[key];
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return CvPaginationModel(
      page: readInt('page', 1),
      limit: readInt('limit', 20),
      totalPages: readInt('totalPages', 1),
      totalItems: readInt('totalItems', 0),
    );
  }
}

class CvTemplateListResponseModel {
  const CvTemplateListResponseModel({
    required this.templates,
    required this.pagination,
  });

  final List<CvTemplateModel> templates;
  final CvPaginationModel pagination;

  factory CvTemplateListResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawTemplates = json['templates'];
    final dynamic rawPagination = json['pagination'];
    return CvTemplateListResponseModel(
      templates: rawTemplates is List
          ? rawTemplates
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) => CvTemplateModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <CvTemplateModel>[],
      pagination: CvPaginationModel.fromJson(
        rawPagination is Map
            ? Map<String, dynamic>.from(rawPagination)
            : <String, dynamic>{},
      ),
    );
  }
}

class CvDocumentPayloadModel {
  const CvDocumentPayloadModel({
    required this.templateId,
    required this.title,
    required this.themeColor,
    required this.accentColor,
    required this.formData,
  });

  final String templateId;
  final String title;
  final String themeColor;
  final String accentColor;
  final Map<String, dynamic> formData;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'templateId': templateId,
      'title': title,
      'themeColor': themeColor,
      'accentColor': accentColor,
      'formData': formData,
    };
  }
}

class CvDocumentModel {
  const CvDocumentModel({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.title,
    required this.themeColor,
    required this.accentColor,
    required this.formData,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.template,
  });

  final String id;
  final String templateId;
  final String? templateTitle;
  final String title;
  final String themeColor;
  final String accentColor;
  final Map<String, dynamic> formData;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final CvTemplateModel? template;

  factory CvDocumentModel.fromJson(Map<String, dynamic> json) {
    return CvDocumentModel(
      id: json['id']?.toString() ?? '',
      templateId: json['templateId']?.toString() ?? '',
      templateTitle: json['templateTitle']?.toString(),
      title: json['title']?.toString() ?? 'My CV',
      themeColor: json['themeColor']?.toString() ?? '#006B3F',
      accentColor: json['accentColor']?.toString() ?? '#E6F6F0',
      formData: json['formData'] is Map
          ? Map<String, dynamic>.from(json['formData'] as Map)
          : <String, dynamic>{},
      status: json['status']?.toString() ?? 'ready',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      template: json['template'] is Map
          ? CvTemplateModel.fromJson(
              Map<String, dynamic>.from(json['template'] as Map),
            )
          : null,
    );
  }
}

class CvDocumentResponseModel {
  const CvDocumentResponseModel({required this.document});

  final CvDocumentModel document;

  factory CvDocumentResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDocument = json['document'];
    return CvDocumentResponseModel(
      document: CvDocumentModel.fromJson(
        rawDocument is Map
            ? Map<String, dynamic>.from(rawDocument)
            : <String, dynamic>{},
      ),
    );
  }
}

class CvSignedUploadUrlModel {
  const CvSignedUploadUrlModel({
    required this.storageKey,
    required this.publicUrl,
    required this.signedUploadUrl,
  });

  final String storageKey;
  final String publicUrl;
  final String signedUploadUrl;

  factory CvSignedUploadUrlModel.fromJson(Map<String, dynamic> json) {
    return CvSignedUploadUrlModel(
      storageKey: json['storageKey']?.toString() ?? '',
      publicUrl: json['publicUrl']?.toString() ?? '',
      signedUploadUrl: json['signedUploadUrl']?.toString() ?? '',
    );
  }
}

class CvConfirmUploadResponseModel {
  const CvConfirmUploadResponseModel({required this.publicUrl});

  final String publicUrl;

  factory CvConfirmUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return CvConfirmUploadResponseModel(
      publicUrl: json['publicUrl']?.toString() ?? '',
    );
  }
}
