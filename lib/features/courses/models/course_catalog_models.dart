import 'course_models.dart';

class CourseCatalogMetaModel {
  const CourseCatalogMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory CourseCatalogMetaModel.fromJson(Map<String, dynamic> json) {
    return CourseCatalogMetaModel(
      page: _intValue(json['page'], fallback: 1),
      limit: _intValue(json['limit'], fallback: 10),
      total: _intValue(json['total']),
      totalPages: _intValue(json['totalPages']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  CourseCatalogMetaModel copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
  }) {
    return CourseCatalogMetaModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class CourseCatalogPageModel {
  const CourseCatalogPageModel({required this.items, required this.meta});

  final List<CourseCardModel> items;
  final CourseCatalogMetaModel meta;

  factory CourseCatalogPageModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] is List<dynamic>
        ? json['items'] as List<dynamic>
        : <dynamic>[];
    final Map<String, dynamic> rawMeta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};

    return CourseCatalogPageModel(
      items: rawItems
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) =>
                CourseCardModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      meta: CourseCatalogMetaModel.fromJson(rawMeta),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((CourseCardModel item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }

  CourseCatalogPageModel copyWith({
    List<CourseCardModel>? items,
    CourseCatalogMetaModel? meta,
  }) {
    return CourseCatalogPageModel(
      items: items ?? this.items,
      meta: meta ?? this.meta,
    );
  }
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
