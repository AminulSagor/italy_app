import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/ai_data_consent_service.dart';
import '../models/ai_tutor_level_test_models.dart';
import '../models/ai_tutor_models.dart';

class AiTutorApiService {
  AiTutorApiService({
    required ApiClient apiClient,
    required AiDataConsentService aiDataConsentService,
  }) : _apiClient = apiClient,
       _aiDataConsentService = aiDataConsentService;

  final ApiClient _apiClient;
  final AiDataConsentService _aiDataConsentService;

  Future<void> _requireConsent() async {
    if (!await _aiDataConsentService.requireConsent()) {
      throw StateError('AI data-sharing permission was not granted.');
    }
  }

  Future<AiTutorVoiceSessionModel> startVoiceSession({
    String? topic,
    int ttlSeconds = 900,
    List<String> memoryFacts = const <String>[],
    List<String> recentMistakeTags = const <String>[],
    String? guidedMode,
    String? guidedLevel,
  }) async {
    await _requireConsent();
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

    return _voiceSession(response.data);
  }

  Future<AiTutorVoiceSessionModel> startLevelTestVoiceSession() async {
    await _requireConsent();
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/level-test/voice/session',
      options: Options(receiveTimeout: const Duration(seconds: 45)),
    );
    return _voiceSession(response.data);
  }

  Future<AiTutorBalanceModel> endVoiceSession(String sessionId) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions/${Uri.encodeComponent(sessionId)}/end',
    );
    return AiTutorBalanceModel.fromEnvelope(_asMap(response.data));
  }

  Future<AiTutorVoiceHeartbeatModel> heartbeatVoiceSession(
    String sessionId,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions/${Uri.encodeComponent(sessionId)}/heartbeat',
    );
    return AiTutorVoiceHeartbeatModel.fromJson(_asMap(response.data));
  }

  Future<AiTutorVoiceSessionModel> reconnectVoiceSession(
    String sessionId, {
    String? resumptionHandle,
  }) async {
    await _requireConsent();
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions/${Uri.encodeComponent(sessionId)}/reconnect',
      data: <String, dynamic>{
        if (resumptionHandle?.trim().isNotEmpty == true)
          'resumptionHandle': resumptionHandle!.trim(),
      },
    );
    return _voiceSession(response.data);
  }

  AiTutorVoiceSessionModel _voiceSession(dynamic data) {
    final AiTutorVoiceSessionModel session =
        AiTutorVoiceSessionModel.fromJson(_asMap(data));
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        session.provider != 'gemini_live') {
      throw StateError('iOS AI voice requires Google Gemini Live.');
    }
    return session;
  }

  Future<void> recordLiveEvents(
    String sessionId,
    List<AiTutorLiveEventModel> events,
  ) async {
    if (events.isEmpty) return;
    await _apiClient.dio.post<dynamic>(
      '/ai-tutor/voice/sessions/${Uri.encodeComponent(sessionId)}/events',
      data: <String, dynamic>{
        'events': events
            .map((AiTutorLiveEventModel event) => event.toJson())
            .toList(),
      },
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
    await _requireConsent();
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
    await _requireConsent();
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/ai-tutor/level-test/profile',
    );
    return AiTutorLevelProfileResponseModel.fromJson(_asMap(response.data));
  }

  Future<AiTutorLevelTranscriptionResponseModel> transcribeLevelTestAnswer({
    required String question,
    required String audioPath,
  }) async {
    await _requireConsent();
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
    await _requireConsent();
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
