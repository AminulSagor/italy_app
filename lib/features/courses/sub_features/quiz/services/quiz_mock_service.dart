import 'dart:math';

import '../models/quiz_models.dart';

class QuizMockService {
  Future<List<QuizQuestionModel>> fetchQuestions({
    int questionCount = 15,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final List<QuizQuestionModel> templates = <QuizQuestionModel>[
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'listening',
        'type': 'listening',
        'eyebrow': '',
        'title': 'What did the speaker order?',
        'subtitle': 'Listen carefully to the dialogue',
        'options': <String>['Coffee', 'Croissant', 'Pasta', 'Tea'],
        'correctOptionIndex': 1,
        'correctAnswer': 'Croissant',
        'correctMeaning': 'Meaning: The speaker ordered a croissant.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'word_translation',
        'type': 'wordTranslation',
        'eyebrow': 'TRANSLATE THIS WORD',
        'title': 'How do you say "Hello" in Italian?',
        'options': <String>['Ciao', 'Grazie', 'Buongiorno', 'Prego'],
        'correctOptionIndex': 0,
        'correctAnswer': 'Ciao',
        'correctMeaning': 'Meaning: Hello in Italian is Ciao.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'sentence_translation',
        'type': 'sentenceTranslation',
        'eyebrow': 'TRANSLATE THIS SENTENCE',
        'title': 'I would like\na coffee',
        'selectedWords': <String>[],
        'answerWordCount': 5,
        'options': <String>['Vorrei', 'un', 'caffé', 'Grazie', 'per', 'favore'],
        'correctWords': <String>['Vorrei', 'un', 'caffé', 'per', 'favore'],
        'correctAnswer': 'Vorrei un caffé, per favore.',
        'correctMeaning': 'Meaning: I would like a coffee.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'true_false',
        'type': 'trueFalse',
        'eyebrow': 'FIND OUT TRUE OR FALSE',
        'title': '“ In Italia, si mangia la\npasta a colazione”',
        'subtitle': 'In Italy people eat pasta for breakfast.',
        'options': <String>['True', 'False'],
        'correctOptionIndex': 1,
        'correctAnswer': 'False',
        'correctMeaning':
            'Meaning: People in Italy do not usually eat pasta for breakfast.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'fill_blank',
        'type': 'fillBlank',
        'eyebrow': '',
        'title': 'Complete the sentence',
        'subtitle': 'Select the correct verb to fill the blank.',
        'prompt': 'Io ___ un caffé.',
        'options': <String>['mangio', 'vorrei', 'sono', 'vado'],
        'correctOptionIndex': 2,
        'correctAnswer': 'Sono',
        'correctMeaning':
            'Meaning: Sono completes the sentence in this mock quiz.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'listening_assembly',
        'type': 'listeningAssembly',
        'eyebrow': '',
        'title': 'Listen and assemble the\nsentence',
        'selectedWords': <String>[],
        'disabledWords': <String>[],
        'answerWordCount': 4,
        'options': <String>[
          'Il',
          'caffé',
          'è',
          'caldo',
          'Io',
          'vorrei',
          'per',
          'favore',
        ],
        'correctWords': <String>['Il', 'caffé', 'è', 'caldo'],
        'correctAnswer': 'Il caffé è caldo',
        'correctMeaning': 'Meaning: The coffee is hot.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'matching',
        'type': 'matchingPairs',
        'eyebrow': '',
        'title': 'Match the pairs',
        'subtitle':
            'Drag the words on the right to match each word on the left.',
        'options': <String>[
          'Buongiorno',
          'Good\nmorning',
          'Ciao',
          'Hello',
          'Grazie',
          'Thank you',
          'Prego',
          "You're\nwelcome",
        ],
        'correctAnswer': 'Ciao = Hello',
        'correctMeaning': 'Meaning: Ciao means Hello.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'writing',
        'type': 'writingWordTranslation',
        'eyebrow': '',
        'title': 'Translate this word',
        'subtitle': 'Type your answer in Italian',
        'objectLabel': 'Apple',
        'correctAnswer': 'Mela',
        'correctMeaning': 'Meaning: Apple means Mela in Italian.',
      }),
      QuizQuestionModel.fromJson(<String, dynamic>{
        'id': 'identify_image',
        'type': 'identifyImage',
        'eyebrow': '',
        'title': 'Identify the object',
        'subtitle': 'Select the correct Italian word',
        'options': <String>['Mela', 'Arancia', 'Limone', 'Fragola'],
        'correctOptionIndex': 0,
        'correctAnswer': 'Mela',
        'correctMeaning':
            'Meaning: The object is an apple, which is Mela in Italian.',
      }),
    ];

    final Random random = Random();
    return List<QuizQuestionModel>.generate(questionCount, (int index) {
      final QuizQuestionModel base =
          templates[random.nextInt(templates.length)];
      final Map<String, dynamic> json = base.toJson();
      json['id'] = '${base.id}_$index';
      return QuizQuestionModel.fromJson(json);
    });
  }

  Future<QuizLessonCompleteModel> fetchLessonComplete() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return QuizLessonCompleteModel.fromJson(<String, dynamic>{
      'title': 'Lesson Complete',
      'appName': 'Italir Pothe',
      'chapterTitle': 'Capitolo 2',
      'headline': 'Bravissimo!',
      'xpEarned': 45,
      'accuracyPercent': 90,
      'timeTaken': '2m 14s',
      'leagueMessage': 'You moved up to #14 in your league!',
      'streakDays': 7,

      // Change this value to true to preview the 2x XP boost state.
      'hasXpBoost': false,
      'xpBoostLabel': '2X XP BOOST ACTIVE',
      'boostRemaining': '47:59:59 remaining',
    });
  }
}
