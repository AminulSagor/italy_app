import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../models/vocabulary_models.dart';
import 'package:get/get.dart' hide Response;

class VocabularyApiService {
  VocabularyApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<VocabularySessionModel> fetchVocabularySession({
    required String lessonId,
  }) async {
    final Response<dynamic> cardsResponse = await _apiClient.dio.get(
      '/lessons/$lessonId/vocabulary/flashcards',
    );
    final Map<String, dynamic> cardsData = _responseMap(cardsResponse);
    final List<Map<String, dynamic>> cards = _jsonList(cardsData['cards']);

    String? sessionId;
    if (cards.isNotEmpty) {
      final Response<dynamic> sessionResponse = await _apiClient.dio.post(
        '/lessons/$lessonId/vocabulary/review-sessions',
        data: const <String, dynamic>{'mode': 'full_lesson'},
      );
      sessionId = _stringValue(_responseMap(sessionResponse)['id']);
    }

    return VocabularySessionModel.fromJson(<String, dynamic>{
      'title': 'Vocabulary',
      'sessionId': sessionId,
      'currentCardIndex': 0,
      'streakDays': 0,
      'level': 1,
      'cards': cards.map(_cardFromApi).toList(growable: false),
    });
  }

  Future<VocabularyCompletionModel> completeSession({
    required String sessionId,
    required List<String> knownVocabularyIds,
    required List<String> weakVocabularyIds,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/vocabulary-review-sessions/$sessionId/complete',
      data: <String, dynamic>{
        'knownVocabularyIds': knownVocabularyIds,
        'weakVocabularyIds': weakVocabularyIds,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
    final Map<String, dynamic> data = _responseMap(response);

    return VocabularyCompletionModel.fromJson(<String, dynamic>{
      'appName': 'ItalirPothe',
      'reviewedCount': _intValue(data['totalReviewed']),
      'rightCount': _intValue(data['knownCount']),
      'wrongCount': _intValue(data['weakCount']),
    });
  }

  Map<String, dynamic> _cardFromApi(Map<String, dynamic> item) {
    return <String, dynamic>{
      'id': _stringValue(item['id']),
      'word': _fallbackString(item['italianWord'], 'Vocabulary'),
      'languageLabel': 'Italian',
      'meaning': _stringValue(item['englishMeaning']),
      'example': _stringValue(item['englishExample']),
      'hasAudio': _stringValue(item['aiPronunciationFileId']).isNotEmpty,
      'audioFileId': _stringValue(item['aiPronunciationFileId']),
      'masteryStatus':
      _fallbackString(
        item['masteryStatus'],
        'new',
      ),
    };
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

  List<Map<String, dynamic>> _jsonList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return <Map<String, dynamic>>[];
  }

  String _fallbackString(dynamic value, String fallback) {
    final String text = _stringValue(value);
    return text.isEmpty ? fallback : text;
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
