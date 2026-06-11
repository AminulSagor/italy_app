class CvTemplateFieldModel {
  const CvTemplateFieldModel({
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

  factory CvTemplateFieldModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateFieldModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true,
      placeholder: json['placeholder']?.toString(),
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
