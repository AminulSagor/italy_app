class CvTemplateSectionModel {
  const CvTemplateSectionModel({
    required this.key,
    required this.title,
    required this.required,
  });

  final String key;
  final String title;
  final bool required;

  factory CvTemplateSectionModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateSectionModel(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      required: json['required'] == true,
    );
  }
}

class CvTemplateSchemaModel {
  const CvTemplateSchemaModel({
    required this.sections,
    required this.colorOptions,
    required this.layout,
  });

  final List<CvTemplateSectionModel> sections;
  final List<String> colorOptions;
  final Map<String, dynamic> layout;

  factory CvTemplateSchemaModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSections = json['sections'];
    final dynamic rawColors = json['colorOptions'];
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
      layout: json['layout'] is Map
          ? Map<String, dynamic>.from(json['layout'] as Map)
          : <String, dynamic>{},
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
