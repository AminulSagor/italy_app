import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../models/quiz_models.dart';
import 'package:get/get.dart' hide Response;

class QuizApiCheckResult {
  final bool isCorrect;
  final String correctAnswer;
  final String meaning;

  const QuizApiCheckResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.meaning,
  });
}

class QuizApiSessionModel {
  final String sessionId;
  final List<QuizQuestionModel> questions;
  final int answeredQuestions;

  const QuizApiSessionModel({
    required this.sessionId,
    required this.questions,
    required this.answeredQuestions,
  });
}

class QuizApiService {
  QuizApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<QuizApiSessionModel> startLessonQuiz({
    required String lessonId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/quiz-sessions/lessons/$lessonId/start',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toUtc().toIso8601String(),
      },
    );
    final Map<String, dynamic> data = _responseMap(response);
    final Map<String, Future<_QuizMediaInfo?>> mediaRequests =
        <String, Future<_QuizMediaInfo?>>{};
    final List<QuizQuestionModel> questions = await Future.wait(
      _jsonList(data['questions']).map(
        (Map<String, dynamic> item) =>
            _questionFromApi(item, mediaRequests: mediaRequests),
      ),
    );
    questions.sort((QuizQuestionModel first, QuizQuestionModel second) {
      final int orderComparison = first.sortOrder.compareTo(second.sortOrder);
      return orderComparison != 0
          ? orderComparison
          : first.id.compareTo(second.id);
    });

    return QuizApiSessionModel(
      sessionId: _stringValue(data['id']),
      questions: questions,
      answeredQuestions: _intValue(data['answeredQuestions']),
    );
  }

  Future<QuizApiCheckResult> checkAnswer({
    required String sessionId,
    required QuizQuestionModel question,
    required int selectedOptionIndex,
    required List<String> sentenceSelectedWords,
    required List<String> listeningSelectedWords,
    required List<String> matchingRightOrder,
    required String writtenAnswer,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/quiz-sessions/$sessionId/answers/check',
      data: _answerPayload(
        question: question,
        selectedOptionIndex: selectedOptionIndex,
        sentenceSelectedWords: sentenceSelectedWords,
        listeningSelectedWords: listeningSelectedWords,
        matchingRightOrder: matchingRightOrder,
        writtenAnswer: writtenAnswer,
      ),
    );
    final Map<String, dynamic> data = _responseMap(response);

    return QuizApiCheckResult(
      isCorrect: _boolValue(data['isCorrect']),
      correctAnswer: _correctAnswerText(_jsonMap(data['correctAnswer'])),
      meaning: _fallbackString(data['meaning'], data['explanation']),
    );
  }

  Future<QuizLessonCompleteModel> completeSession({
    required String sessionId,
    required String chapterTitle,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/quiz-sessions/$sessionId/complete',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toUtc().toIso8601String(),
      },
    );
    final Map<String, dynamic> data = _responseMap(response);
    final int totalSeconds = _intValue(data['timeTakenSeconds']);
    final int remainingBoostSeconds = _intValue(
      _jsonMap(data['xpBoost'])['remainingSeconds'],
    );

    return QuizLessonCompleteModel.fromJson(<String, dynamic>{
      'title': _fallbackString(data['completedTitle'], 'Lesson Complete'),
      'appName': 'Italir Pothe',
      'chapterTitle': _fallbackString(data['lessonTitle'], chapterTitle),
      'headline': _fallbackString(data['completedMessage'], 'Ottimo lavoro!'),
      'xpEarned': _intValue(data['totalXpEarned']) > 0
          ? _intValue(data['totalXpEarned'])
          : _intValue(data['earnedXp']),
      'accuracyPercent': _intValue(data['accuracyPercent']) > 0
          ? _intValue(data['accuracyPercent'])
          : _intValue(data['scorePercentage']),
      'timeTaken': _timeLabel(totalSeconds),
      'leagueMessage': _leagueMessage(_jsonMap(data['league'])),
      'streakDays': _intValue(_jsonMap(data['streak'])['currentDays']),
      'hasXpBoost': _boolValue(_jsonMap(data['xpBoost'])['isActive']),
      'xpBoostLabel': '2X XP BOOST ACTIVE',
      'boostRemaining': remainingBoostSeconds > 0
          ? _timeLabel(remainingBoostSeconds)
          : '',
    });
  }

  Future<void> markLessonCompleted({
    required String courseId,
    required String lessonId,
  }) async {
    await _apiClient.dio.post(
      '/learning-progress/lessons/complete',
      data: <String, dynamic>{
        'courseId': courseId,
        'lessonId': lessonId,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Map<String, dynamic> _answerPayload({
    required QuizQuestionModel question,
    required int selectedOptionIndex,
    required List<String> sentenceSelectedWords,
    required List<String> listeningSelectedWords,
    required List<String> matchingRightOrder,
    required String writtenAnswer,
  }) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'questionId': question.id,
    };

    switch (question.type) {
      case QuizQuestionType.listening:
      case QuizQuestionType.wordTranslation:
      case QuizQuestionType.trueFalse:
      case QuizQuestionType.fillBlank:
      case QuizQuestionType.identifyImage:
        if (selectedOptionIndex >= 0 &&
            selectedOptionIndex < question.optionIds.length) {
          payload['selectedOptionId'] = question.optionIds[selectedOptionIndex];
        }
        break;
      case QuizQuestionType.sentenceTranslation:
        payload['sequenceAnswerTexts'] = sentenceSelectedWords;
        break;
      case QuizQuestionType.listeningAssembly:
        payload['sequenceAnswerTexts'] = listeningSelectedWords;
        break;
      case QuizQuestionType.matchingPairs:
        final int pairCount =
            question.matchingLeftPairIds.length < matchingRightOrder.length
            ? question.matchingLeftPairIds.length
            : matchingRightOrder.length;
        payload['matchingAnswers'] = List<Map<String, dynamic>>.generate(
          pairCount,
          (int index) => <String, dynamic>{
            'pairId': question.matchingLeftPairIds[index],
            'matchedText': matchingRightOrder[index],
          },
        );
        break;
      case QuizQuestionType.writingWordTranslation:
        payload['writtenAnswer'] = writtenAnswer;
        break;
    }

    return payload;
  }

  Future<QuizQuestionModel> _questionFromApi(
    Map<String, dynamic> item, {
    required Map<String, Future<_QuizMediaInfo?>> mediaRequests,
  }) async {
    final QuizQuestionType type = _typeFromApi(
      _stringValue(item['questionType']),
    );
    final List<Map<String, dynamic>> options = _jsonList(item['options']);
    final List<Map<String, dynamic>> sequenceItems = _jsonList(
      item['sequenceItems'],
    );
    final Map<String, dynamic> matchingItems = _jsonMap(item['matchingItems']);
    final List<Map<String, dynamic>> leftItems = _jsonList(
      matchingItems['leftItems'],
    );
    final List<Map<String, dynamic>> rightItems = _jsonList(
      matchingItems['rightItems'],
    );
    final String mediaFileId = _stringValue(item['mediaFileId']);
    final _QuizMediaInfo? media = mediaFileId.isEmpty
        ? null
        : await mediaRequests.putIfAbsent(
            mediaFileId,
            () => _fetchMediaInfo(mediaFileId),
          );

    return QuizQuestionModel.fromJson(<String, dynamic>{
      'id': _stringValue(item['id']),
      'type': type.name,
      'eyebrow': _eyebrowForType(type),
      'title': _titleForType(type, item),
      'subtitle': _stringValue(item['helperText']),
      'prompt': _stringValue(item['promptText']),
      'options': _optionsForType(
        type,
        options,
        sequenceItems,
        leftItems,
        rightItems,
      ),
      'optionIds': options
          .map((Map<String, dynamic> option) => _stringValue(option['id']))
          .toList(),
      'matchingLeftPairIds': leftItems
          .map((Map<String, dynamic> item) => _stringValue(item['pairId']))
          .toList(),
      'matchingLeftTexts': leftItems
          .map((Map<String, dynamic> item) => _stringValue(item['leftText']))
          .toList(),
      'matchingRightTexts': rightItems
          .map((Map<String, dynamic> item) => _stringValue(item['rightText']))
          .toList(),
      'matchingRightPairIds': rightItems
          .map((Map<String, dynamic> item) => _stringValue(item['pairId']))
          .toList(),
      'selectedWords': <String>[],
      'disabledWords': <String>[],
      'correctWords': <String>[],
      'answerWordCount': _requiredSequenceCount(sequenceItems),
      'correctOptionIndex': -1,
      'correctAnswer': '',
      'correctMeaning': _stringValue(item['translationText']),
      'objectLabel': _stringValue(item['promptText']),
      'mediaFileId': mediaFileId,
      'mediaUrl': media?.url ?? '',
      'mediaMimeType': media?.mimeType ?? '',
      'generatedAudioText': _stringValue(item['generatedAudioText']),
      'sortOrder': _intValue(item['sortOrder']),
      'answered': _boolValue(item['answered']),
      'isCorrect': item['isCorrect'] is bool ? item['isCorrect'] : null,
    });
  }

  Future<_QuizMediaInfo?> _fetchMediaInfo(String fileId) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/files/$fileId/signed-read-url',
      );
      final Map<String, dynamic> data = _responseMap(response);
      final Map<String, dynamic> file = _jsonMap(data['file']);
      final String url = _fallbackString(
        data['signedReadUrl'],
        data['publicUrl'],
      );
      if (url.isEmpty) {
        return null;
      }

      return _QuizMediaInfo(url: url, mimeType: _stringValue(file['mimeType']));
    } on DioException {
      return null;
    }
  }

  List<String> _optionsForType(
    QuizQuestionType type,
    List<Map<String, dynamic>> options,
    List<Map<String, dynamic>> sequenceItems,
    List<Map<String, dynamic>> leftItems,
    List<Map<String, dynamic>> rightItems,
  ) {
    if (type == QuizQuestionType.sentenceTranslation ||
        type == QuizQuestionType.listeningAssembly) {
      return sequenceItems
          .map((Map<String, dynamic> item) => _stringValue(item['wordText']))
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }

    if (type == QuizQuestionType.matchingPairs) {
      final List<String> pairOptions = <String>[];
      final int maxLength = leftItems.length > rightItems.length
          ? leftItems.length
          : rightItems.length;
      for (int index = 0; index < maxLength; index++) {
        if (index < leftItems.length) {
          pairOptions.add(_stringValue(leftItems[index]['leftText']));
        }
        if (index < rightItems.length) {
          pairOptions.add(_stringValue(rightItems[index]['rightText']));
        }
      }
      return pairOptions;
    }

    return options
        .map((Map<String, dynamic> item) => _stringValue(item['optionText']))
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  QuizQuestionType _typeFromApi(String value) {
    switch (value) {
      case 'listening_mcq':
        return QuizQuestionType.listening;
      case 'word_translation':
        return QuizQuestionType.wordTranslation;
      case 'sentence_translation':
        return QuizQuestionType.sentenceTranslation;
      case 'true_false':
        return QuizQuestionType.trueFalse;
      case 'fill_in_the_blanks':
        return QuizQuestionType.fillBlank;
      case 'listen_and_assemble':
        return QuizQuestionType.listeningAssembly;
      case 'match_the_pair':
        return QuizQuestionType.matchingPairs;
      case 'writing_word_translation':
        return QuizQuestionType.writingWordTranslation;
      case 'identify_image':
        return QuizQuestionType.identifyImage;
      default:
        return QuizQuestionType.wordTranslation;
    }
  }

  String _titleForType(QuizQuestionType type, Map<String, dynamic> item) {
    final String title = _stringValue(item['title']);
    if (title.isNotEmpty) return title;
    if (type == QuizQuestionType.fillBlank) return 'Complete the sentence';
    if (type == QuizQuestionType.trueFalse) return 'Find out true or false';
    if (type == QuizQuestionType.matchingPairs) return 'Match the pairs';
    return _fallbackString(item['promptText'], 'Answer the question');
  }

  String _eyebrowForType(QuizQuestionType type) {
    switch (type) {
      case QuizQuestionType.wordTranslation:
        return 'TRANSLATE THIS WORD';
      case QuizQuestionType.sentenceTranslation:
        return 'TRANSLATE THIS SENTENCE';
      case QuizQuestionType.trueFalse:
        return 'Find out true or false';
      default:
        return '';
    }
  }

  int _requiredSequenceCount(List<Map<String, dynamic>> items) {
    return items.where((Map<String, dynamic> item) {
      return item['isRequired'] != false;
    }).length;
  }

  String _correctAnswerText(Map<String, dynamic> correctAnswer) {
    final String optionText = _stringValue(correctAnswer['optionText']);
    if (optionText.isNotEmpty) return optionText;

    final String answerText = _stringValue(correctAnswer['answerText']);
    if (answerText.isNotEmpty) return answerText;

    final String sequenceText = _stringValue(correctAnswer['sequenceText']);
    if (sequenceText.isNotEmpty) return sequenceText;

    final List<Map<String, dynamic>> pairs = _jsonList(correctAnswer['pairs']);
    if (pairs.isNotEmpty) {
      return pairs
          .map(
            (Map<String, dynamic> pair) =>
                '${_stringValue(pair['leftText'])} = ${_stringValue(pair['rightText'])}',
          )
          .join(', ');
    }
    return '';
  }

  String _leagueMessage(Map<String, dynamic> league) {
    if (_boolValue(league['movedUp'])) {
      return 'You moved up in your league!';
    }
    return 'Quiz completed successfully!';
  }

  String _timeLabel(int totalSeconds) {
    if (totalSeconds <= 0) return '0m 00s';
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
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

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
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

  String _fallbackString(dynamic value, dynamic fallback) {
    final String text = _stringValue(value);
    if (text.isNotEmpty) return text;
    return _stringValue(fallback);
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}

class _QuizMediaInfo {
  const _QuizMediaInfo({required this.url, required this.mimeType});

  final String url;
  final String mimeType;
}
