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
        'limit': 10,
        'unreadOnly': true,
      },
    );

    final Map<String, dynamic> body = _responseMap(response);

    final dynamic rawMeta = body['meta'];

    if (rawMeta is Map) {
      final dynamic unreadCount = rawMeta['unreadCount'];

      if (unreadCount != null) {
        return (int.tryParse(unreadCount.toString()) ?? 0) > 0;
      }
    }

    final dynamic rawItems = body['items'] ?? body['data'];

    if (rawItems is List) {
      return rawItems.whereType<Map>().any((Map item) {
        final dynamic isRead = item['isRead'];

        return isRead == false ||
            isRead == 0 ||
            isRead?.toString().toLowerCase() == 'false';
      });
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
