import 'package:dio/dio.dart';

import 'api_client.dart';
import 'package:get/get.dart' hide Response;

class NotificationSummaryService {
  NotificationSummaryService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<bool> hasUnreadNotifications() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/notifications/my',
      queryParameters: <String, dynamic>{
        'page': 1,
        'limit': 1,
        'unreadOnly': true,
      },
    );
    final Map<String, dynamic> body = _responseMap(response);
    final dynamic rawItems = body['items'] ?? body['data'];
    if (rawItems is List && rawItems.isNotEmpty) return true;
    final dynamic rawMeta = body['meta'];
    if (rawMeta is Map) {
      final dynamic total = rawMeta['total'] ?? rawMeta['unreadCount'];
      if (total is num) return total > 0;
      return (int.tryParse(total?.toString() ?? '') ?? 0) > 0;
    }
    return false;
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
