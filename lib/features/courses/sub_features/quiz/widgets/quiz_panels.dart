import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/quiz_models.dart';
import 'quiz_common_widgets.dart';

part 'quiz_panel_parts.dart';
part 'quiz_panel_more_parts.dart';
part 'quiz_panel_shared_parts.dart';

class QuizQuestionPanel extends StatelessWidget {
  final QuizQuestionModel question;
  final int selectedIndex;
  final bool hasCheckedAnswer;
  final bool isAnswerCorrect;
  final List<String> sentenceSelectedWords;
  final List<String> listeningSelectedWords;
  final List<String> matchingRightOrder;
  final List<String> matchingRightKeys;
  final TextEditingController writingAnswerController;
  final ValueChanged<int> onOptionTap;
  final ValueChanged<String> onSentenceWordTap;
  final ValueChanged<String> onSentenceSelectedWordTap;
  final ValueChanged<String> onListeningWordTap;
  final ValueChanged<String> onListeningSelectedWordTap;
  final void Function(int oldIndex, int newIndex) onMatchingRightReorder;

  const QuizQuestionPanel({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.hasCheckedAnswer,
    required this.isAnswerCorrect,
    required this.sentenceSelectedWords,
    required this.listeningSelectedWords,
    required this.matchingRightOrder,
    required this.matchingRightKeys,
    required this.writingAnswerController,
    required this.onOptionTap,
    required this.onSentenceWordTap,
    required this.onSentenceSelectedWordTap,
    required this.onListeningWordTap,
    required this.onListeningSelectedWordTap,
    required this.onMatchingRightReorder,
  });

  @override
  Widget build(BuildContext context) {
    final bool showWrongResult = hasCheckedAnswer && !isAnswerCorrect;

    switch (question.type) {
      case QuizQuestionType.listening:
        return _ListeningPanel(
          question: question,
          selectedIndex: selectedIndex,
          showWrongResult: showWrongResult,
          onOptionTap: onOptionTap,
        );
      case QuizQuestionType.wordTranslation:
        return _WordTranslationPanel(
          question: question,
          selectedIndex: selectedIndex,
          showWrongResult: showWrongResult,
          onOptionTap: onOptionTap,
        );
      case QuizQuestionType.sentenceTranslation:
        return _SentenceTranslationPanel(
          question: question,
          selectedWords: sentenceSelectedWords,
          showWrongResult: showWrongResult,
          onWordTap: onSentenceWordTap,
          onSelectedWordTap: onSentenceSelectedWordTap,
        );
      case QuizQuestionType.trueFalse:
        return _TrueFalsePanel(
          question: question,
          selectedIndex: selectedIndex,
          showWrongResult: showWrongResult,
          onOptionTap: onOptionTap,
        );
      case QuizQuestionType.fillBlank:
        return _FillBlankPanel(
          question: question,
          selectedIndex: selectedIndex,
          showWrongResult: showWrongResult,
          onOptionTap: onOptionTap,
        );
      case QuizQuestionType.listeningAssembly:
        return _ListeningAssemblyPanel(
          question: question,
          selectedWords: listeningSelectedWords,
          showWrongResult: showWrongResult,
          onWordTap: onListeningWordTap,
          onSelectedWordTap: onListeningSelectedWordTap,
        );
      case QuizQuestionType.matchingPairs:
        return _MatchingPairsPanel(
          question: question,
          rightOptions: matchingRightOrder,
          rightKeys: matchingRightKeys,
          isLocked: hasCheckedAnswer,
          showWrongResult: showWrongResult,
          onSwap: onMatchingRightReorder,
        );
      case QuizQuestionType.writingWordTranslation:
        return _WritingWordPanel(
          question: question,
          answerController: writingAnswerController,
          showWrongResult: showWrongResult,
        );
      case QuizQuestionType.identifyImage:
        return _IdentifyImagePanel(
          question: question,
          selectedIndex: selectedIndex,
          showWrongResult: showWrongResult,
          onOptionTap: onOptionTap,
        );
    }
  }
}
