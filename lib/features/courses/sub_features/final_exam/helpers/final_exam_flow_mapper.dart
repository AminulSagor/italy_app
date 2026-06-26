import '../../quiz/models/quiz_models.dart';
import '../models/final_exam_api_models.dart';
import '../models/final_exam_models.dart';

class FinalExamFlowMapper {
  const FinalExamFlowMapper._();

  static FinalExamOverviewModel overviewFromGateway(
    FinalExamGatewayModel data,
  ) {
    return FinalExamOverviewModel(
      title: data.examTitle.isEmpty ? 'Final Exam' : data.examTitle,
      heroTitle: 'Ready to Graduate?',
      heroSubtitle: data.examDescription.isNotEmpty
          ? data.examDescription
          : 'Complete the final exam to earn your course certificate.',
      components: const <FinalExamComponentModel>[
        FinalExamComponentModel(
          id: 'core_quiz',
          title: 'Part 1: Core Quiz',
          subtitle: 'Auto-graded knowledge assessment',
          iconName: 'quiz',
          tone: FinalExamComponentTone.green,
        ),
        FinalExamComponentModel(
          id: 'listening_lab',
          title: 'Part 2: Listening Lab',
          subtitle: 'Audio comprehension assessment',
          iconName: 'headphones',
          tone: FinalExamComponentTone.blue,
        ),
        FinalExamComponentModel(
          id: 'writing_task',
          title: 'Part 3: Writing Task',
          subtitle: 'Teacher review may be required',
          iconName: 'write',
          tone: FinalExamComponentTone.orange,
        ),
        FinalExamComponentModel(
          id: 'speaking_lab',
          title: 'Part 4: Speaking Lab',
          subtitle: 'Record and submit your answer',
          iconName: 'speak',
          tone: FinalExamComponentTone.lime,
        ),
      ],
      noteBangla: data.resultNoticeBn,
      noteEnglish: data.resultNotice.isNotEmpty
          ? data.resultNotice
          : 'Writing and speaking answers may require teacher review.',
      canStart: data.isUnlocked,
      startMessage: data.message,
    );
  }

  static QuizQuestionModel quizQuestion(
    FinalExamSectionModel section,
    FinalExamQuestionModel question,
  ) {
    final QuizQuestionType type = quizType(question.format);
    final String mediaUrl = question.audioUrl.isNotEmpty
        ? question.audioUrl
        : question.imageUrl;
    final String mediaMimeType = question.audioUrl.isNotEmpty
        ? question.audioMimeType
        : question.imageMimeType;

    return QuizQuestionModel(
      id: question.id,
      type: type,
      eyebrow: section.title,
      title: question.title.isNotEmpty ? question.title : section.title,
      subtitle: question.subtitle,
      options: quizOptions(question, type),
      optionIds: question.options
          .map((FinalExamOptionModel item) => item.id)
          .toList(growable: false),
      matchingLeftPairIds: question.leftPairs
          .map((FinalExamPairItemModel item) => item.id)
          .toList(growable: false),
      matchingLeftTexts: question.leftPairs
          .map((FinalExamPairItemModel item) => item.text)
          .toList(growable: false),
      matchingRightTexts: question.rightPairs
          .map((FinalExamPairItemModel item) => item.text)
          .toList(growable: false),
      matchingRightPairIds: question.rightPairs
          .map((FinalExamPairItemModel item) => item.id)
          .toList(growable: false),
      selectedWords: const <String>[],
      disabledWords: const <String>[],
      correctWords: const <String>[],
      answerWordCount: question.sequenceItems
          .where((FinalExamSequenceItemModel item) => item.isRequired)
          .length,
      correctOptionIndex: -1,
      correctAnswer: '',
      correctMeaning: question.promptBn,
      prompt: question.prompt,
      objectLabel: question.prompt,
      mediaFileId: question.audioFileId.isNotEmpty
          ? question.audioFileId
          : question.imageFileId,
      mediaUrl: mediaUrl,
      mediaMimeType: mediaMimeType,
    );
  }

  static Map<String, dynamic> answerPayload(
    FinalExamQuestionModel examQuestion,
    QuizQuestionModel quizQuestion,
    QuizAnswerInput input,
  ) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'sectionId': examQuestion.sectionId,
      'questionId': examQuestion.id,
    };

    switch (quizQuestion.type) {
      case QuizQuestionType.listening:
      case QuizQuestionType.wordTranslation:
      case QuizQuestionType.fillBlank:
      case QuizQuestionType.identifyImage:
        payload['answerType'] = 'single_option';
        if (input.selectedOptionIndex >= 0 &&
            input.selectedOptionIndex < quizQuestion.optionIds.length) {
          payload['selectedOptionId'] =
              quizQuestion.optionIds[input.selectedOptionIndex];
        }
        break;
      case QuizQuestionType.trueFalse:
        payload['answerType'] = 'true_false';
        payload['booleanAnswer'] = input.selectedOptionIndex == 0;
        break;
      case QuizQuestionType.writingWordTranslation:
        payload['answerType'] = 'text';
        payload['textAnswer'] = input.writtenAnswer;
        break;
      case QuizQuestionType.sentenceTranslation:
        payload['answerType'] = 'sequence';
        payload['items'] = sequenceAnswerItems(input.sentenceSelectedWords);
        break;
      case QuizQuestionType.listeningAssembly:
        payload['answerType'] = 'sequence';
        payload['items'] = sequenceAnswerItems(input.listeningSelectedWords);
        break;
      case QuizQuestionType.matchingPairs:
        payload['answerType'] = 'matching';
        payload['items'] = matchingAnswerItems(examQuestion, input);
        break;
    }
    return payload;
  }

  static FinalExamWritingModel writingTask(FinalExamSectionModel section) {
    final FinalExamQuestionModel question = section.questions.first;
    return FinalExamWritingModel(
      sectionId: section.id,
      questionId: question.id,
      title: section.title,
      taskTitle: question.title.isEmpty ? section.title : question.title,
      instruction: question.prompt,
      banglaInstruction: question.promptBn,
      minWords: section.rule.minWords,
      maxWords: section.rule.maxWords,
    );
  }

  static FinalExamSpeakingModel speakingTask(FinalExamSectionModel section) {
    final FinalExamQuestionModel question = section.questions.first;
    return FinalExamSpeakingModel(
      sectionId: section.id,
      questionId: question.id,
      title: section.title,
      taskTitle: question.title.isEmpty ? section.title : question.title,
      instruction: question.prompt,
      banglaInstruction: question.promptBn,
      tip: question.subtitle.isNotEmpty
          ? question.subtitle
          : 'Speak clearly and submit your best recording.',
      maxDurationSeconds: section.rule.maxDurationSeconds > 0
          ? section.rule.maxDurationSeconds
          : 60,
      unlimitedRerecords: section.rule.rerecordPolicy == 'unlimited',
    );
  }

  static FinalExamListeningModel listeningTask(FinalExamSectionModel section) {
    final FinalExamQuestionModel question = section.questions.first;
    return FinalExamListeningModel(
      sectionId: section.id,
      questionId: question.id,
      title: section.title,
      clipTitle: question.title.isEmpty ? section.title : question.title,
      questionTag: 'QUESTION 1',
      question: question.prompt,
      options: question.options
          .map((FinalExamOptionModel item) => item.text)
          .toList(growable: false),
      optionIds: question.options
          .map((FinalExamOptionModel item) => item.id)
          .toList(growable: false),
      tip: question.subtitle,
      audioUrl: question.audioUrl,
      playbackLocked: section.rule.playbackLocked,
    );
  }

  static QuizQuestionType quizType(String format) {
    switch (format) {
      case 'listening_mcq':
        return QuizQuestionType.listening;
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
      case 'word_translation':
      default:
        return QuizQuestionType.wordTranslation;
    }
  }

  static List<String> quizOptions(
    FinalExamQuestionModel question,
    QuizQuestionType type,
  ) {
    if (type == QuizQuestionType.trueFalse && question.options.isEmpty) {
      return const <String>['True', 'False'];
    }
    if (type == QuizQuestionType.sentenceTranslation ||
        type == QuizQuestionType.listeningAssembly) {
      return question.sequenceItems
          .map((FinalExamSequenceItemModel item) => item.text)
          .toList(growable: false);
    }
    if (type == QuizQuestionType.matchingPairs) {
      final List<String> items = <String>[];
      final int maxLength = question.leftPairs.length > question.rightPairs.length
          ? question.leftPairs.length
          : question.rightPairs.length;
      for (int index = 0; index < maxLength; index++) {
        if (index < question.leftPairs.length) {
          items.add(question.leftPairs[index].text);
        }
        if (index < question.rightPairs.length) {
          items.add(question.rightPairs[index].text);
        }
      }
      return items;
    }
    return question.options
        .map((FinalExamOptionModel item) => item.text)
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> sequenceAnswerItems(List<String> words) {
    return List<Map<String, dynamic>>.generate(words.length, (int index) {
      return <String, dynamic>{
        'textValue': words[index],
        'sortOrder': index,
      };
    });
  }

  static List<Map<String, dynamic>> matchingAnswerItems(
    FinalExamQuestionModel question,
    QuizAnswerInput input,
  ) {
    final int count = question.leftPairs.length <
            input.matchingRightPairIdOrder.length
        ? question.leftPairs.length
        : input.matchingRightPairIdOrder.length;

    return List<Map<String, dynamic>>.generate(count, (int index) {
      final FinalExamPairItemModel left = question.leftPairs[index];
      return <String, dynamic>{
        'selectedItemId': left.id,
        'matchedWithItemId': input.matchingRightPairIdOrder[index],
        'textValue': left.text,
        'sortOrder': index,
      };
    });
  }
}
