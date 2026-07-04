import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/notification_models.dart';

class NotificationsApiService {
  NotificationsApiService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  bool? _supportsCategoryFilter;

  Future<NotificationsPageModel> fetchNotifications({
    required NotificationCategory category,
    required int page,
    int limit = 10,
  }) async {
    if (category == NotificationCategory.all) {
      return _fetchServerPage(page: page, limit: limit);
    }

    if (_supportsCategoryFilter == false) {
      return _fetchLegacyFilteredPage(
        category: category,
        page: page,
        limit: limit,
      );
    }

    try {
      final NotificationsPageModel result = await _fetchServerPage(
        page: page,
        limit: limit,
        category: category,
      );
      _supportsCategoryFilter = true;
      return result;
    } on DioException catch (error) {
      if (!_isUnsupportedCategoryError(error)) rethrow;
      _supportsCategoryFilter = false;
      return _fetchLegacyFilteredPage(
        category: category,
        page: page,
        limit: limit,
      );
    }
  }

  Future<void> markRead(String notificationId) async {
    await _apiClient.dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.dio.patch('/notifications/read-all');
  }

  Future<NotificationsPageModel> _fetchServerPage({
    required int page,
    required int limit,
    NotificationCategory? category,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null && category != NotificationCategory.all) {
      query['category'] = category.name;
    }

    final Response<dynamic> response = await _apiClient.dio.get(
      '/notifications/my',
      queryParameters: query,
    );
    return NotificationsPageModel.fromJson(_responseMap(response));
  }

  Future<NotificationsPageModel> _fetchLegacyFilteredPage({
    required NotificationCategory category,
    required int page,
    required int limit,
  }) async {
    const int batchSize = 100;
    final List<NotificationItemModel> matching = <NotificationItemModel>[];
    int serverPage = 1;
    int totalServerPages = 1;

    do {
      final NotificationsPageModel batch = await _fetchServerPage(
        page: serverPage,
        limit: batchSize,
      );
      matching.addAll(
        batch.items.where(
          (NotificationItemModel item) => item.category == category,
        ),
      );
      totalServerPages = batch.meta.totalPages;
      serverPage++;
    } while (serverPage <= totalServerPages);

    final int start = ((page - 1) * limit).clamp(0, matching.length).toInt();
    final int end = (start + limit).clamp(start, matching.length).toInt();
    final int totalPages = matching.isEmpty
        ? 0
        : (matching.length / limit).ceil();

    return NotificationsPageModel(
      items: matching.sublist(start, end),
      meta: NotificationPageMetaModel(
        page: page,
        limit: limit,
        total: matching.length,
        totalPages: totalPages,
      ),
    );
  }

  bool _isUnsupportedCategoryError(DioException error) {
    if (error.response?.statusCode != 400) return false;
    final String message = error.response?.data.toString().toLowerCase() ?? '';
    return message.contains('category') && message.contains('should not exist');
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Notification response is not a JSON object.',
    );
  }
}
