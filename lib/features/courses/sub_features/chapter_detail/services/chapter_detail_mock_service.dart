import 'package:get/get.dart';

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
      'videoProgressLabel': isQuizEnabled
          ? '85% ${'watched'.tr} – ${'great_job'.tr}'
          : '60% ${'watched'.tr} – ${'great_job'.tr}',
      'watchedTimeLabel': isQuizEnabled ? '17:51' : '12:40',
      'totalTimeLabel': '21:00',
      'videoProgress': isQuizEnabled ? 0.85 : 0.60,
      'lessonContent': <String, dynamic>{
        'title': 'alphabet'.tr,
        'italianText':
            "L'italiano usa 21 lettere dell'alfabeto latino. Lettere:",
        'italianHighlightText': 'A B C D E F G H I L M N O P Q R S T U V Z',
        'italianMissingText': 'Mancano le lettere: J, K, W, X, Y',
        'translationLabel': 'translation_label'.tr,
        'banglaText': 'ইতালীয় বর্ণমালার ২১টি অক্ষর ব্যবহৃত হয়। অক্ষর:',
        'banglaHighlightText': 'A B C D E F G H I L M N O P Q R S T U V Z',
      },
      'resources': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'gen_theory_book'.tr,
          'subtitle': '12 ${'pages'.tr}',
          'iconName': 'book',
        },
        <String, dynamic>{
          'title': 'gen_vocabulary'.tr,
          'subtitle': '45 ${'flashcards'.tr}',
          'iconName': 'cards',
        },
      ],
      'quiz': <String, dynamic>{
        'title': isQuizEnabled ? 'chapter_quiz'.tr : 'alphabet'.tr,
        'subtitle': 'chapter_quiz_description'.tr,
        'status': quizStatus.name,
        'actionLabel': isQuizEnabled ? 'start_quiz'.tr : 'requires_80_video'.tr,
        'scoreLabel': isQuizCompleted
            ? 'score_label'.trParams(<String, String>{'score': '9/10'})
            : '',
        'xpLabel': isQuizCompleted
            ? 'xp_label'.trParams(<String, String>{'xp': '+15'})
            : '',
        'timeLabel': isQuizCompleted
            ? 'time_label'.trParams(<String, String>{'time': '1m 45s'})
            : '',
      },
    });
  }

  Future<void> resumeVideoUntilQuizUnlocked() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
