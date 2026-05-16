import '../models/vocabulary_models.dart';

class VocabularyMockService {
  Future<VocabularySessionModel> fetchVocabularySession() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final List<Map<String, String>> baseCards = <Map<String, String>>[
      <String, String>{
        'word': 'Buongiorno',
        'meaning': 'Good morning / Hello',
        'example': '"Buongiorno, come va?"',
      },
      <String, String>{
        'word': 'Ciao',
        'meaning': 'Hello / Bye',
        'example': '"Ciao, a presto!"',
      },
      <String, String>{
        'word': 'Grazie',
        'meaning': 'Thank you',
        'example': '"Grazie mille!"',
      },
      <String, String>{
        'word': 'Prego',
        'meaning': "You're welcome",
        'example': '"Prego, entra pure."',
      },
      <String, String>{
        'word': 'Per favore',
        'meaning': 'Please',
        'example': '"Un caffè, per favore."',
      },
    ];

    final List<Map<String, dynamic>> cards =
        List<Map<String, dynamic>>.generate(9, (int index) {
          final Map<String, String> item = baseCards[index % baseCards.length];
          return <String, dynamic>{
            'id': 'vocab_${index + 1}',
            'word': item['word'],
            'languageLabel': 'ITALIAN',
            'meaning': item['meaning'],
            'example': item['example'],
            'hasAudio': true,
          };
        });

    return VocabularySessionModel.fromJson(<String, dynamic>{
      'title': 'Vocabulary',
      'currentCardIndex': 0,
      'streakDays': 12,
      'level': 4,
      'cards': cards,
    });
  }

  Future<VocabularyCompletionModel> completeSession({
    required int reviewedCount,
    required int rightCount,
    required int wrongCount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return VocabularyCompletionModel.fromJson(<String, dynamic>{
      'appName': 'ItalirPothe',
      'reviewedCount': reviewedCount,
      'rightCount': rightCount,
      'wrongCount': wrongCount,
    });
  }
}
