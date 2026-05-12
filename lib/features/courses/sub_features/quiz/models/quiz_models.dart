enum QuizQuestionType {
  listening,
  wordTranslation,
  sentenceTranslation,
  trueFalse,
  fillBlank,
  listeningAssembly,
  matchingPairs,
  writingWordTranslation,
  identifyImage,
}

class QuizQuestionModel {
  final String id;
  final QuizQuestionType type;
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<String> options;
  final List<String> selectedWords;
  final List<String> disabledWords;
  final List<String> correctWords;
  final int answerWordCount;
  final int correctOptionIndex;
  final String correctAnswer;
  final String correctMeaning;
  final String? prompt;
  final String? objectLabel;

  const QuizQuestionModel({
    required this.id,
    required this.type,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedWords,
    required this.disabledWords,
    required this.correctWords,
    required this.answerWordCount,
    required this.correctOptionIndex,
    required this.correctAnswer,
    required this.correctMeaning,
    this.prompt,
    this.objectLabel,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String,
      type: QuizQuestionType.values.firstWhere(
        (QuizQuestionType item) => item.name == json['type'],
        orElse: () => QuizQuestionType.wordTranslation,
      ),
      eyebrow: json['eyebrow'] as String? ?? '',
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      options: ((json['options'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      selectedWords: ((json['selectedWords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      disabledWords: ((json['disabledWords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      correctWords: ((json['correctWords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      answerWordCount: json['answerWordCount'] as int? ?? 0,
      correctOptionIndex: json['correctOptionIndex'] as int? ?? -1,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      correctMeaning: json['correctMeaning'] as String? ?? '',
      prompt: json['prompt'] as String?,
      objectLabel: json['objectLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'eyebrow': eyebrow,
      'title': title,
      'subtitle': subtitle,
      'options': options,
      'selectedWords': selectedWords,
      'disabledWords': disabledWords,
      'correctWords': correctWords,
      'answerWordCount': answerWordCount,
      'correctOptionIndex': correctOptionIndex,
      'correctAnswer': correctAnswer,
      'correctMeaning': correctMeaning,
      'prompt': prompt,
      'objectLabel': objectLabel,
    };
  }
}

class QuizAnswerReviewModel {
  final String id;
  final QuizQuestionType type;
  final String title;
  final String subtitle;
  final String selectedAnswer;
  final String correctAnswer;
  final List<String> selectedWords;
  final List<String> correctWords;
  final int selectedOptionIndex;
  final int correctOptionIndex;
  final int selectedLeftPairIndex;
  final int selectedRightPairIndex;
  final bool isCorrect;

  const QuizAnswerReviewModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.selectedWords,
    required this.correctWords,
    required this.selectedOptionIndex,
    required this.correctOptionIndex,
    required this.selectedLeftPairIndex,
    required this.selectedRightPairIndex,
    required this.isCorrect,
  });

  factory QuizAnswerReviewModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerReviewModel(
      id: json['id'] as String,
      type: QuizQuestionType.values.firstWhere(
        (QuizQuestionType item) => item.name == json['type'],
        orElse: () => QuizQuestionType.wordTranslation,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      selectedAnswer: json['selectedAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      selectedWords: ((json['selectedWords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      correctWords: ((json['correctWords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item as String)
          .toList(),
      selectedOptionIndex: json['selectedOptionIndex'] as int? ?? -1,
      correctOptionIndex: json['correctOptionIndex'] as int? ?? -1,
      selectedLeftPairIndex: json['selectedLeftPairIndex'] as int? ?? -1,
      selectedRightPairIndex: json['selectedRightPairIndex'] as int? ?? -1,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'selectedWords': selectedWords,
      'correctWords': correctWords,
      'selectedOptionIndex': selectedOptionIndex,
      'correctOptionIndex': correctOptionIndex,
      'selectedLeftPairIndex': selectedLeftPairIndex,
      'selectedRightPairIndex': selectedRightPairIndex,
      'isCorrect': isCorrect,
    };
  }
}

class QuizLessonCompleteModel {
  final String title;
  final String appName;
  final String chapterTitle;
  final String headline;
  final int xpEarned;
  final int accuracyPercent;
  final String timeTaken;
  final String leagueMessage;
  final int streakDays;
  final bool hasXpBoost;
  final String xpBoostLabel;
  final String boostRemaining;

  const QuizLessonCompleteModel({
    required this.title,
    required this.appName,
    required this.chapterTitle,
    required this.headline,
    required this.xpEarned,
    required this.accuracyPercent,
    required this.timeTaken,
    required this.leagueMessage,
    required this.streakDays,
    required this.hasXpBoost,
    required this.xpBoostLabel,
    required this.boostRemaining,
  });

  factory QuizLessonCompleteModel.fromJson(Map<String, dynamic> json) {
    return QuizLessonCompleteModel(
      title: json['title'] as String? ?? 'Lesson Complete',
      appName: json['appName'] as String? ?? 'Italir Pothe',
      chapterTitle: json['chapterTitle'] as String? ?? 'Capitolo 2',
      headline: json['headline'] as String? ?? 'Bravissimo!',
      xpEarned: json['xpEarned'] as int? ?? 45,
      accuracyPercent: json['accuracyPercent'] as int? ?? 90,
      timeTaken: json['timeTaken'] as String? ?? '2m 14s',
      leagueMessage: json['leagueMessage'] as String? ?? '',
      streakDays: json['streakDays'] as int? ?? 7,
      hasXpBoost: json['hasXpBoost'] as bool? ?? false,
      xpBoostLabel: json['xpBoostLabel'] as String? ?? '2X XP BOOST ACTIVE',
      boostRemaining: json['boostRemaining'] as String? ?? '47:59:59 remaining',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'appName': appName,
      'chapterTitle': chapterTitle,
      'headline': headline,
      'xpEarned': xpEarned,
      'accuracyPercent': accuracyPercent,
      'timeTaken': timeTaken,
      'leagueMessage': leagueMessage,
      'streakDays': streakDays,
      'hasXpBoost': hasXpBoost,
      'xpBoostLabel': xpBoostLabel,
      'boostRemaining': boostRemaining,
    };
  }
}
