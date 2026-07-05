import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../../core/services/api_client.dart';
import '../models/home_models.dart';

class HomeApiService {
  HomeApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HomeDashboardModel> fetchDashboard() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/home/dashboard',
      queryParameters: <String, dynamic>{'weekStart': _currentWeekStart()},
    );
    return HomeDashboardModel.fromJson(_responseMap(response));
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

  String _currentWeekStart() {
    final DateTime now = DateTime.now();
    final DateTime monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));
    return _dateOnly(monday);
  }

  String _dateOnly(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
