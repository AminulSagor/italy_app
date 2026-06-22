import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/ai_tutor_models.dart';

class AiTutorApiService {
  AiTutorApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AiTutorVoiceSessionModel> startVoiceSession({
    String? topic,
    int ttlSeconds = 900,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions',
      options: Options(
        receiveTimeout: const Duration(seconds: 45),
      ),
      data: <String, dynamic>{
        if (topic != null && topic.trim().isNotEmpty) 'topic': topic.trim(),
        'ttlSeconds': ttlSeconds,
      },
    );

    return AiTutorVoiceSessionModel.fromJson(_asMap(response.data));
  }

  Future<void> endVoiceSession(String sessionId) async {
    await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions/${Uri.encodeComponent(sessionId)}/end',
    );
  }

  Future<AiTutorChatResponseModel> sendMessage({
    required String message,
    required List<AiTutorMessageModel> history,
    String? conversationId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/chat',
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
      ),
      data: <String, dynamic>{
        'message': message.trim(),
        if (conversationId != null && conversationId.trim().isNotEmpty)
          'conversationId': conversationId.trim(),
        'history': history
            .takeLast(20)
            .map((AiTutorMessageModel item) => item.toHistoryJson())
            .toList(growable: false),
      },
    );

    return AiTutorChatResponseModel.fromJson(_asMap(response.data));
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw const FormatException('AI tutor API returned an invalid response');
  }
}

extension _IterableTakeLast<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final List<T> values = toList(growable: false);
    if (values.length <= count) {
      return values;
    }
    return values.skip(values.length - count);
  }
}
