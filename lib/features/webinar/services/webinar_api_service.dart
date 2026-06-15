import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/webinar_models.dart';

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

  Future<WebinarParticipantModel> leaveStage({required String webinarId}) async {
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
      message: 'Response is not a valid JSON object',
    );
  }
}
