import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/course_catalog_models.dart';
import '../models/course_models.dart';

class CourseCatalogApiService {
  CourseCatalogApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CourseCatalogPageModel> fetchCourses({
    required int page,
    required int limit,
    String search = '',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/courses/catalog',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final Map<String, dynamic> body = _responseMap(response);
    final List<CourseCardModel> items = _jsonList(body['items'])
        .map(_courseCardFromApi)
        .toList(growable: false);

    return CourseCatalogPageModel.fromJson(<String, dynamic>{
      'items': items.map((CourseCardModel item) => item.toJson()).toList(),
      'meta': body['meta'],
    });
  }

  Future<CourseCardModel> fetchCourseProgress(
    CourseCardModel course,
  ) async {
    if (course.courseId.isEmpty) return course;

    final Response<dynamic> response = await _apiClient.dio.get(
      '/learning-progress/courses/${course.courseId}',
    );
    final Map<String, dynamic> body = _responseMap(response);
    final dynamic rawPercent = body['completionPercent'];
    final double percent = rawPercent is num
        ? rawPercent.toDouble()
        : double.tryParse(rawPercent?.toString() ?? '') ?? 0;
    final double progress = (percent / 100).clamp(0.0, 1.0).toDouble();

    return course.copyWith(
      progressLabel: '${percent.round()}%',
      progress: progress,
    );
  }

  CourseCardModel _courseCardFromApi(Map<String, dynamic> json) {
    final String id = _stringValue(json['id']);
    final String subtitle = _stringValue(json['subtitle']).isNotEmpty
        ? _stringValue(json['subtitle'])
        : _stringValue(json['description']);

    return CourseCardModel(
      id: id,
      courseId: _fallbackString(json['courseId'], id),
      chapterId: _stringValue(json['chapterId']),
      title: _fallbackString(json['title'], 'Untitled Course'),
      subtitle: subtitle,
      progressLabel: '-',
      progress: 0,
      statusLabel: 'ACTIVE',
      state: CourseCardState.active,
    );
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object',
    );
  }

  List<Map<String, dynamic>> _jsonList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String _fallbackString(dynamic value, String fallback) {
    final String text = _stringValue(value);
    return text.isEmpty ? fallback : text;
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';
}
