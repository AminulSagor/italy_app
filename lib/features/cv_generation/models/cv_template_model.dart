class CvTemplateModel {
  const CvTemplateModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CvTemplateModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvTemplateModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ),
    );
  }
}

class CvTemplatePaginationModel {
  const CvTemplatePaginationModel({
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
  });

  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;

  factory CvTemplatePaginationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CvTemplatePaginationModel(
      page: _toInt(json['page'], fallback: 1),
      limit: _toInt(json['limit'], fallback: 9),
      totalPages: _toInt(json['totalPages']),
      totalItems: _toInt(json['totalItems']),
    );
  }
}

class CvTemplateListResponseModel {
  const CvTemplateListResponseModel({
    required this.templates,
    required this.pagination,
  });

  final List<CvTemplateModel> templates;
  final CvTemplatePaginationModel pagination;

  factory CvTemplateListResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic rawTemplates = json['templates'];
    final dynamic rawPagination = json['pagination'];

    return CvTemplateListResponseModel(
      templates: rawTemplates is List
          ? rawTemplates
          .whereType<Map>()
          .map(
            (Map item) =>
            CvTemplateModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
      )
          .toList()
          : <CvTemplateModel>[],
      pagination: CvTemplatePaginationModel.fromJson(
        rawPagination is Map
            ? Map<String, dynamic>.from(rawPagination)
            : <String, dynamic>{},
      ),
    );
  }
}

int _toInt(
    dynamic value, {
      int fallback = 0,
    }) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ??
      fallback;
}