import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/ai_tutor_level_test_models.dart';
import '../models/ai_tutor_models.dart';

class AiTutorApiService {
  AiTutorApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AiTutorVoiceSessionModel> startVoiceSession({
    String? topic,
    int ttlSeconds = 900,
    List<String> memoryFacts = const <String>[],
    List<String> recentMistakeTags = const <String>[],
    String? guidedMode,
    String? guidedLevel,
  }) async {
    final AiTutorVoiceSessionRequestModel request =
        AiTutorVoiceSessionRequestModel(
      topic: topic,
      ttlSeconds: ttlSeconds,
      memoryFacts: memoryFacts,
      recentMistakeTags: recentMistakeTags,
      guidedMode: guidedMode,
      guidedLevel: guidedLevel,
    );
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions',
      options: Options(receiveTimeout: const Duration(seconds: 45)),
      data: request.toJson(),
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
    List<String> memoryFacts = const <String>[],
    List<String> recentMistakeTags = const <String>[],
    AiTutorChatMode chatMode = AiTutorChatMode.general,
    AiTutorWritingSourceLanguage? writingSourceLanguage,
  }) async {
    final AiTutorChatRequestModel request = AiTutorChatRequestModel(
      message: message,
      history: history,
      conversationId: conversationId,
      memoryFacts: memoryFacts,
      recentMistakeTags: recentMistakeTags,
      chatMode: chatMode,
      writingSourceLanguage: writingSourceLanguage,
    );
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/chat',
      options: Options(receiveTimeout: const Duration(seconds: 60)),
      data: request.toJson(),
    );

    return AiTutorChatResponseModel.fromJson(_asMap(response.data));
  }

  Future<AiTutorLevelProfileResponseModel> getLevelTestProfile() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/ai-tutor/level-test/profile',
    );
    return AiTutorLevelProfileResponseModel.fromJson(_asMap(response.data));
  }

  Future<AiTutorLevelTranscriptionResponseModel> transcribeLevelTestAnswer({
    required String question,
    required String audioPath,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'question': question.trim(),
      'audio': await MultipartFile.fromFile(
        audioPath,
        filename: 'level-test-answer.m4a',
      ),
    });
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/level-test/transcribe',
      options: Options(receiveTimeout: const Duration(seconds: 90)),
      data: formData,
    );
    return AiTutorLevelTranscriptionResponseModel.fromJson(
      _asMap(response.data),
    );
  }

  Future<AiTutorLevelTestResponseModel> evaluateLevelTest({
    required List<AiTutorLevelAnswerModel> answers,
  }) async {
    final AiTutorLevelTestRequestModel request = AiTutorLevelTestRequestModel(
      answers: answers,
    );
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/level-test/evaluate',
      options: Options(receiveTimeout: const Duration(seconds: 90)),
      data: request.toJson(),
    );

    return AiTutorLevelTestResponseModel.fromJson(_asMap(response.data));
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
