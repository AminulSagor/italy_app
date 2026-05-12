import '../models/chapter_detail_models.dart';

class ChapterDetailMockService {
  Future<ChapterDetailModel> fetchChapterDetail({
    required String chapterId,
    required String chapterTitle,
    required ChapterQuizStatus quizStatus,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final bool isQuizEnabled = quizStatus != ChapterQuizStatus.disabled;
    final bool isQuizCompleted = quizStatus == ChapterQuizStatus.completed;

    return ChapterDetailModel.fromJson(<String, dynamic>{
      'id': chapterId,
      'title': chapterTitle,
      'videoProgressLabel': isQuizEnabled ? '85% Watched – Great Job!' : '60% Watched – Great Job!',
      'watchedTimeLabel': isQuizEnabled ? '17:51' : '12:40',
      'totalTimeLabel': '21:00',
      'videoProgress': isQuizEnabled ? 0.85 : 0.60,
      'lessonContent': <String, dynamic>{
        'title': 'The Alphabet',
        'italianText': "L'italiano usa 21 lettere dell'alfabeto latino. Lettere:",
        'italianHighlightText': 'A B C D E F G H I L M N O P Q R S T U V Z',
        'italianMissingText': 'Mancano le lettere: J, K, W, X, Y',
        'translationLabel': 'বাংলা অনুবাদ',
        'banglaText': 'ইতালীয় বর্ণমালার ২১টি অক্ষর ব্যবহৃত হয়। অক্ষর:',
        'banglaHighlightText': 'A B C D E F G H I L M N O P Q R S T U V Z',
      },
      'resources': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Theory Book',
          'subtitle': '12 Pages',
          'iconName': 'book',
        },
        <String, dynamic>{
          'title': 'Vocabulary',
          'subtitle': '45 Flashcards',
          'iconName': 'cards',
        },
      ],
      'quiz': <String, dynamic>{
        'title': isQuizEnabled ? 'Chapter Quiz' : 'The Alphabet',
        'subtitle': 'Test your knowledge of Chapter 2',
        'status': quizStatus.name,
        'actionLabel': isQuizEnabled ? 'Start Quiz →' : 'REQUIRES 80% VIDEO',
        'scoreLabel': isQuizCompleted ? 'Score: 9/10' : '',
        'xpLabel': isQuizCompleted ? 'XP: +15' : '',
        'timeLabel': isQuizCompleted ? 'Time: 1m 45s' : '',
      },
    });
  }

  Future<void> resumeVideoUntilQuizUnlocked() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
