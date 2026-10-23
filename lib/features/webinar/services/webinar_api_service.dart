import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/webinar_models.dart';
import 'package:get/get.dart' hide Response;

class WebinarApiService {
  WebinarApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<WebinarListResponseModel> getLiveWebinars({
    int page = 1,
    int limit = 10,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/webinars/live',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return WebinarListResponseModel.fromJson(_responseMap(response));
  }

  Future<WebinarListResponseModel> getUpcomingWebinars({
    int page = 1,
    int limit = 10,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/webinars/upcoming',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return WebinarListResponseModel.fromJson(_responseMap(response));
  }

  Future<WebinarParticipantsResponseModel> getParticipants({
    required String webinarId,
    int page = 1,
    int limit = 50,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/webinars/$webinarId/participants',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return WebinarParticipantsResponseModel.fromJson(_responseMap(response));
  }

  Future<WebinarChatMessagesResponseModel> getChatMessages({
    required String webinarId,
    int page = 1,
    int limit = 50,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/webinars/$webinarId/chat-messages',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return WebinarChatMessagesResponseModel.fromJson(_responseMap(response));
  }

  Future<WebinarLiveChatModel> sendChatMessage({
    required String webinarId,
    required String message,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/webinars/$webinarId/chat-messages',
      data: <String, dynamic>{'message': message},
    );
    final Map<String, dynamic> data = _responseMap(response);
    return WebinarLiveChatModel.fromJson(_jsonMap(data['chatMessage']));
  }

  Future<List<Map<String, dynamic>>> getReportReasons() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/user-reports/reasons',
    );
    final dynamic data = response.data is Map
        ? (response.data as Map)['data']
        : response.data;
    if (data is! List) return <Map<String, dynamic>>[];
    return data
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<void> reportChatMessage({
    required WebinarLiveChatModel message,
    required String reasonId,
  }) async {
    final String context =
        '[Webinar ${message.webinarId}; message ${message.id}] ${message.message}';
    await _apiClient.dio.post<dynamic>(
      '/user-reports',
      data: <String, dynamic>{
        'reportedUserId': message.senderUserId,
        'reasonId': reasonId,
        'description': context.length <= 500
            ? context
            : context.substring(0, 500),
        'clientReportId':
            'webinar-${message.id}-${DateTime.now().millisecondsSinceEpoch}',
      },
    );
  }

  Future<void> blockUser(String userId) async {
    await _apiClient.dio.post<dynamic>(
      '/user-blocks/${Uri.encodeComponent(userId)}',
    );
  }

  Future<void> removeChatMessage({
    required String webinarId,
    required String messageId,
  }) async {
    await _apiClient.dio.delete<dynamic>(
      '/webinars/${Uri.encodeComponent(webinarId)}/chat-messages/'
      '${Uri.encodeComponent(messageId)}',
    );
  }

  Future<Set<String>> getBlockedUserIds() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/user-blocks',
    );
    final dynamic raw = response.data is Map
        ? (response.data as Map)['data']
        : null;
    if (raw is! List) return <String>{};
    return raw
        .whereType<Map>()
        .map((Map item) => item['blockedUserId']?.toString() ?? '')
        .where((String id) => id.isNotEmpty)
        .toSet();
  }

  Future<WebinarJoinResultModel> joinWebinar({
    required String webinarId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/webinars/$webinarId/join-token',
    );
    return WebinarJoinResultModel.fromJson(_responseMap(response));
  }

  Future<void> leaveWebinar({required String webinarId}) async {
    await _apiClient.dio.patch('/webinars/$webinarId/leave');
  }

  Future<void> requestToSpeak({required String webinarId}) async {
    await _apiClient.dio.post('/webinars/$webinarId/request-to-speak');
  }

  Future<AgoraTokenModel> getSpeakerToken({required String webinarId}) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/webinars/$webinarId/speaker-token',
    );
    final Map<String, dynamic> data = _responseMap(response);
    return AgoraTokenModel.fromJson(_jsonMap(data['token']));
  }

  Future<WebinarParticipantModel> leaveStage({
    required String webinarId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.patch(
      '/webinars/$webinarId/leave-stage',
    );
    final Map<String, dynamic> data = _responseMap(response);
    return WebinarParticipantModel.fromJson(_jsonMap(data['participant']));
  }

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object'.tr,
    );
  }
}
