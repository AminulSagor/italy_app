import 'package:dio/dio.dart';

import '../models/learning_activity_models.dart';
import 'api_client.dart';
import 'package:get/get.dart' hide Response;

class LearningActivityApiService {
  LearningActivityApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<bool> recordTime(LearningActivityTimeEntryModel entry) async {
    await _apiClient.dio.post(
      '/learning-activity/time',
      data: entry.toJson(),
    );
    return true;
  }

  Future<WeeklyLearningActivityModel> getWeeklySummary({
    required String weekStart,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/learning-activity/weekly',
      queryParameters: <String, dynamic>{'weekStart': weekStart},
    );
    return WeeklyLearningActivityModel.fromJson(_responseMap(response));
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object_1'.tr,
    );
  }
}
