class CvTemplateFieldModel {
  const CvTemplateFieldModel({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.placeholder,
    required this.options,
  });

  final String key;
  final String label;
  final String type;
  final bool required;
  final String? placeholder;
  final List<String> options;

  factory CvTemplateFieldModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];

    return CvTemplateFieldModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true,
      placeholder: json['placeholder']?.toString(),
      options: rawOptions is List
          ? rawOptions.map((dynamic item) => item.toString()).toList()
          : <String>[],
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

class CvTemplateListResponseModel {
  const CvTemplateListResponseModel({required this.templates});

  final List<CvTemplateModel> templates;

  factory CvTemplateListResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawTemplates = json['templates'];
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
    );
  }
}

class CvDocumentPayloadModel {
  const CvDocumentPayloadModel({
    required this.templateId,
    required this.title,
    required this.themeColor,
    required this.formData,
  });

  final String templateId;
  final String title;
  final String themeColor;
  final Map<String, dynamic> formData;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'templateId': templateId,
      'title': title,
      'themeColor': themeColor,
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
