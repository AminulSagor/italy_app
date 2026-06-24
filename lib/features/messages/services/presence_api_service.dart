import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../models/presence_model.dart';

class PresenceApiService {
  PresenceApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiHandledResponse<void>> sendHeartbeat(String deviceId) {
    return ApiErrorHandler.handle<void>(
      request: () async {
        await _apiClient.dio.post(
          '/presence/heartbeat',
          data: <String, dynamic>{
            'deviceId': deviceId,
            'connectionContext': 'app',
          },
        );
      },
      fallbackErrorCode: 'presence_heartbeat_failed',
    );
  }

  Future<ApiHandledResponse<List<MessagePresenceModel>>> getBatchStatus(
    List<String> userIds,
  ) {
    return ApiErrorHandler.handle<List<MessagePresenceModel>>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.post(
          '/presence/status/batch',
          data: <String, dynamic>{
            'userIds': userIds,
          },
        );
        final dynamic data = response.data;
        List<dynamic> items = <dynamic>[];
        if (data is List) {
          items = data;
        } else if (data is Map && data['data'] is List) {
          items = data['data'] as List<dynamic>;
        } else if (data is Map && data['items'] is List) {
          items = data['items'] as List<dynamic>;
        }

        return items
            .map(
              (dynamic e) => MessagePresenceModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      },
      fallbackErrorCode: 'presence_batch_failed',
    );
  }
}
