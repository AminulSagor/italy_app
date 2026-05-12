class VocabularyCardModel {
  final String id;
  final String word;
  final String languageLabel;
  final String meaning;
  final String example;
  final bool hasAudio;

  const VocabularyCardModel({
    required this.id,
    required this.word,
    required this.languageLabel,
    required this.meaning,
    required this.example,
    required this.hasAudio,
  });

  factory VocabularyCardModel.fromJson(Map<String, dynamic> json) {
    return VocabularyCardModel(
      id: json['id'] as String,
      word: json['word'] as String,
      languageLabel: json['languageLabel'] as String,
      meaning: json['meaning'] as String,
      example: json['example'] as String,
      hasAudio: json['hasAudio'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'word': word,
      'languageLabel': languageLabel,
      'meaning': meaning,
      'example': example,
      'hasAudio': hasAudio,
    };
  }

  VocabularyCardModel copyWith({
    String? id,
    String? word,
    String? languageLabel,
    String? meaning,
    String? example,
    bool? hasAudio,
  }) {
    return VocabularyCardModel(
      id: id ?? this.id,
      word: word ?? this.word,
      languageLabel: languageLabel ?? this.languageLabel,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      hasAudio: hasAudio ?? this.hasAudio,
    );
  }
}

class VocabularySessionModel {
  final String title;
  final int currentCardIndex;
  final int streakDays;
  final int level;
  final List<VocabularyCardModel> cards;

  const VocabularySessionModel({
    required this.title,
    required this.currentCardIndex,
    required this.streakDays,
    required this.level,
    required this.cards,
  });

  factory VocabularySessionModel.fromJson(Map<String, dynamic> json) {
    return VocabularySessionModel(
      title: json['title'] as String,
      currentCardIndex: json['currentCardIndex'] as int,
      streakDays: json['streakDays'] as int,
      level: json['level'] as int,
      cards: (json['cards'] as List<dynamic>)
          .map(
            (dynamic item) => VocabularyCardModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'currentCardIndex': currentCardIndex,
      'streakDays': streakDays,
      'level': level,
      'cards': cards.map((VocabularyCardModel item) => item.toJson()).toList(),
    };
  }
}

class VocabularyCompletionModel {
  final String appName;
  final int reviewedCount;
  final int rightCount;
  final int wrongCount;

  const VocabularyCompletionModel({
    required this.appName,
    required this.reviewedCount,
    required this.rightCount,
    required this.wrongCount,
  });

  factory VocabularyCompletionModel.fromJson(Map<String, dynamic> json) {
    return VocabularyCompletionModel(
      appName: json['appName'] as String,
      reviewedCount: json['reviewedCount'] as int,
      rightCount: json['rightCount'] as int,
      wrongCount: json['wrongCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'reviewedCount': reviewedCount,
      'rightCount': rightCount,
      'wrongCount': wrongCount,
    };
  }
}
