import 'package:dio/dio.dart';

import '../models/current_user_summary.dart';
import 'api_client.dart';

class CurrentUserSummaryService {
  CurrentUserSummaryService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CurrentUserSummary> getCurrentUser() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/user-settings',
    );
    final Map<String, dynamic> body = _responseMap(response);
    final dynamic rawProfile = body['profile'];
    final Map<String, dynamic> profile = rawProfile is Map
        ? Map<String, dynamic>.from(rawProfile)
        : <String, dynamic>{};

    return CurrentUserSummary.fromJson(profile);
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object.',
    );
  }
}
