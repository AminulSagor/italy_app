import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../models/quiz_models.dart';
import '../services/quiz_api_service.dart';
import '../services/quiz_mock_service.dart';

class QuizController extends GetxController {
  final QuizMockService _quizMockService;
  final QuizApiService _quizApiService;
  final String? lessonId;
  final String? courseId;
  final String? chapterTitle;
  final bool isExamMode;
  final int questionCount;
  final List<QuizQuestionModel> initialQuestions;
  final QuizExternalAnswerHandler? externalAnswerHandler;

  QuizController({
    required QuizMockService quizMockService,
    required QuizApiService quizApiService,
    this.lessonId,
    this.courseId,
    this.chapterTitle,
    this.isExamMode = false,
    this.questionCount = 15,
    this.initialQuestions = const <QuizQuestionModel>[],
    this.externalAnswerHandler,
  })  : _quizMockService = quizMockService,
        _quizApiService = quizApiService;

  final RxBool isLoading = false.obs;
  final RxBool isSubmittingAnswer = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool hasCheckedAnswer = false.obs;
  final RxBool isAnswerCorrect = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt selectedOptionIndex = (-1).obs;
  final RxInt selectedLeftPairIndex = (-1).obs;
  final RxInt selectedRightPairIndex = (-1).obs;
  final RxList<String> matchingRightOrder = <String>[].obs;
  final RxList<String> matchingRightPairIdOrder = <String>[].obs;
  final RxList<String> sentenceSelectedWords = <String>[].obs;
  final RxList<String> listeningSelectedWords = <String>[].obs;
  final RxList<QuizQuestionModel> questions = <QuizQuestionModel>[].obs;
  final RxList<QuizAnswerReviewModel> answerReviews =
      <QuizAnswerReviewModel>[].obs;
  final Rxn<QuizLessonCompleteModel> lessonComplete =
      Rxn<QuizLessonCompleteModel>();

  final TextEditingController writingAnswerController = TextEditingController();

  String? _activeSessionId;
  QuizApiCheckResult? _lastCheckResult;
  String _externalCorrectMeaning = '';

  int get totalQuestions => questions.length;
  int get correctAnswerCount =>
      answerReviews.where((QuizAnswerReviewModel item) => item.isCorrect).length;
  bool get showWrongResult => hasCheckedAnswer.value && !isAnswerCorrect.value;
  bool get hasApiLessonQuiz => lessonId?.trim().isNotEmpty ?? false;
  QuizQuestionModel? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex.value];

  String get currentCorrectAnswer {
    final String apiAnswer = _lastCheckResult?.correctAnswer ?? '';
    if (apiAnswer.isNotEmpty) {
      return apiAnswer;
    }

    final QuizQuestionModel? question = currentQuestion;
    if (question == null) {
      return '';
    }

    if (question.correctAnswer.isNotEmpty) {
      return question.correctAnswer;
    }

    if (question.correctOptionIndex >= 0 &&
        question.correctOptionIndex < question.options.length) {
      return question.options[question.correctOptionIndex];
    }

    if (question.correctWords.isNotEmpty) {
      return question.correctWords.join(' ');
    }

    return '';
  }

  String get currentCorrectMeaning {
    if (_externalCorrectMeaning.isNotEmpty) {
      return _externalCorrectMeaning;
    }

    final String apiMeaning = _lastCheckResult?.meaning ?? '';
    if (apiMeaning.isNotEmpty) {
      return apiMeaning;
    }

    final String meaning = currentQuestion?.correctMeaning ?? '';
    if (meaning.isNotEmpty) {
      return meaning;
    }
    return 'Meaning: $currentCorrectAnswer';
  }

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  @override
  void onClose() {
    writingAnswerController.dispose();
    super.onClose();
  }

  Future<void> loadQuestions() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      if (initialQuestions.isNotEmpty) {
        questions.assignAll(initialQuestions);
      } else if (hasApiLessonQuiz) {
        final ApiResult<QuizApiSessionModel> result =
            await ApiErrorHandler.call<QuizApiSessionModel>(
          () => _quizApiService.startLessonQuiz(lessonId: lessonId!.trim()),
          errorTitle: 'Quiz',
        );

        if (!result.isSuccess || result.data == null) {
          return;
        }

        _activeSessionId = result.data!.sessionId;
        questions.assignAll(result.data!.questions);
      } else {
        questions.assignAll(
          await _quizMockService.fetchQuestions(questionCount: questionCount),
        );
      }

      answerReviews.clear();
      lessonComplete.value = null;
      currentIndex.value = 0;
      _resetInteractionState();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLessonComplete() async {
    if (isCompleting.value || lessonComplete.value != null) {
      return;
    }

    isCompleting.value = true;
    try {
      if (_activeSessionId != null) {
        final ApiResult<QuizLessonCompleteModel> result =
            await ApiErrorHandler.call<QuizLessonCompleteModel>(
          () => _quizApiService.completeSession(
            sessionId: _activeSessionId!,
            chapterTitle: chapterTitle ?? 'Chapter Complete',
          ),
          errorTitle: 'Quiz Complete',
        );

        if (result.isSuccess && result.data != null) {
          lessonComplete.value = result.data;
          await _markLessonCompletedAfterQuiz();
        }
        return;
      }

      lessonComplete.value = await _quizMockService.fetchLessonComplete();
    } finally {
      isCompleting.value = false;
    }
  }

  Future<void> _markLessonCompletedAfterQuiz() async {
    final String resolvedCourseId = courseId?.trim() ?? '';
    final String resolvedLessonId = lessonId?.trim() ?? '';
    if (resolvedCourseId.isEmpty || resolvedLessonId.isEmpty) {
      return;
    }

    await ApiErrorHandler.call<Object?>(
      () async {
        await _quizApiService.markLessonCompleted(
          courseId: resolvedCourseId,
          lessonId: resolvedLessonId,
        );
        return null;
      },
      showError: false,
      errorTitle: 'Lesson Progress',
    );
  }

  void selectOption(int index) {
    if (hasCheckedAnswer.value) {
      return;
    }
    selectedOptionIndex.value = index;
  }

  void addSentenceWord(String word) {
    if (_canAddSequenceWord(sentenceSelectedWords, word)) {
      sentenceSelectedWords.add(word);
    }
  }

  void removeSentenceWord(String word) {
    if (hasCheckedAnswer.value) {
      return;
    }
    sentenceSelectedWords.remove(word);
  }

  void addListeningWord(String word) {
    if (_canAddSequenceWord(listeningSelectedWords, word)) {
      listeningSelectedWords.add(word);
    }
  }

  void removeListeningWord(String word) {
    if (hasCheckedAnswer.value) {
      return;
    }
    listeningSelectedWords.remove(word);
  }


  bool _canAddSequenceWord(RxList<String> selectedWords, String word) {
    if (hasCheckedAnswer.value) return false;

    final QuizQuestionModel? question = currentQuestion;
    if (question == null ||
        (question.answerWordCount > 0 &&
            selectedWords.length >= question.answerWordCount)) {
      return false;
    }

    final int availableCount = question.options
        .where((String option) => option == word)
        .length;
    final int selectedCount = selectedWords
        .where((String selected) => selected == word)
        .length;
    return selectedCount < availableCount;
  }

  void selectLeftPair(int index) {
    if (hasCheckedAnswer.value) {
      return;
    }
    selectedLeftPairIndex.value = index;
  }

  void selectRightPair(int index) {
    if (hasCheckedAnswer.value) return;
    selectedRightPairIndex.value = index;
  }

  void reorderMatchingRight(int oldIndex, int newIndex) {
    if (hasCheckedAnswer.value ||
        oldIndex < 0 ||
        oldIndex >= matchingRightOrder.length) {
      return;
    }

    int targetIndex = newIndex;
    if (targetIndex > oldIndex) targetIndex -= 1;
    if (targetIndex < 0 || targetIndex >= matchingRightOrder.length) return;

    final String movedText = matchingRightOrder.removeAt(oldIndex);
    matchingRightOrder.insert(targetIndex, movedText);

    if (matchingRightPairIdOrder.length == matchingRightOrder.length) {
      final String movedId = matchingRightPairIdOrder.removeAt(oldIndex);
      matchingRightPairIdOrder.insert(targetIndex, movedId);
    }
  }

  Future<bool> checkAnswer() async {
    if (isSubmittingAnswer.value || hasCheckedAnswer.value) {
      return isAnswerCorrect.value;
    }

    final QuizQuestionModel? question = currentQuestion;
    if (question == null) {
      return false;
    }

    if (externalAnswerHandler != null) {
      isSubmittingAnswer.value = true;
      try {
        final QuizExternalAnswerResult externalResult =
            await externalAnswerHandler!(
          question,
          QuizAnswerInput(
            selectedOptionIndex: selectedOptionIndex.value,
            selectedLeftPairIndex: selectedLeftPairIndex.value,
            selectedRightPairIndex: selectedRightPairIndex.value,
            sentenceSelectedWords: sentenceSelectedWords.toList(),
            listeningSelectedWords: listeningSelectedWords.toList(),
            matchingRightOrder: matchingRightOrder.toList(),
            matchingRightPairIdOrder: matchingRightPairIdOrder.toList(),
            writtenAnswer: writingAnswerController.text.trim(),
          ),
        );

        hasCheckedAnswer.value = true;
        isAnswerCorrect.value = externalResult.isCorrect;
        _externalCorrectMeaning = externalResult.meaning;
        _saveCurrentReview(
          externalResult.isCorrect,
          correctAnswer: externalResult.correctAnswer,
        );
        return externalResult.isCorrect;
      } catch (_) {
        return false;
      } finally {
        isSubmittingAnswer.value = false;
      }
    }

    if (_activeSessionId == null) {
      hasCheckedAnswer.value = true;
      isAnswerCorrect.value = _isCurrentAnswerCorrect();
      _saveCurrentReview(isAnswerCorrect.value);
      return isAnswerCorrect.value;
    }

    isSubmittingAnswer.value = true;
    try {
      final ApiResult<QuizApiCheckResult> result =
          await ApiErrorHandler.call<QuizApiCheckResult>(
        () => _quizApiService.checkAnswer(
          sessionId: _activeSessionId!,
          question: question,
          selectedOptionIndex: selectedOptionIndex.value,
          sentenceSelectedWords: sentenceSelectedWords.toList(),
          listeningSelectedWords: listeningSelectedWords.toList(),
          matchingRightOrder: matchingRightOrder.toList(),
          writtenAnswer: writingAnswerController.text.trim(),
        ),
        errorTitle: 'Check Answer',
      );

      if (!result.isSuccess || result.data == null) {
        return false;
      }

      _lastCheckResult = result.data;
      hasCheckedAnswer.value = true;
      isAnswerCorrect.value = result.data!.isCorrect;
      _saveCurrentReview(
        isAnswerCorrect.value,
        correctAnswer: result.data!.correctAnswer,
      );
      return isAnswerCorrect.value;
    } finally {
      isSubmittingAnswer.value = false;
    }
  }

  bool goNext() {
    if (currentIndex.value >= questions.length - 1) {
      return true;
    }

    currentIndex.value += 1;
    _resetInteractionState();
    return false;
  }

  void resetCurrentQuestion() {
    _resetInteractionState();
  }

  void _resetInteractionState() {
    _lastCheckResult = null;
    _externalCorrectMeaning = '';
    hasCheckedAnswer.value = false;
    isAnswerCorrect.value = false;
    selectedOptionIndex.value = -1;
    selectedLeftPairIndex.value = -1;
    selectedRightPairIndex.value = -1;
    writingAnswerController.clear();

    final QuizQuestionModel? question = currentQuestion;
    matchingRightOrder.assignAll(question?.matchingRightTexts ?? <String>[]);
    matchingRightPairIdOrder.assignAll(
      question?.matchingRightPairIds ?? <String>[],
    );
    sentenceSelectedWords.assignAll(
      question?.type == QuizQuestionType.sentenceTranslation
          ? question!.selectedWords
          : <String>[],
    );
    listeningSelectedWords.assignAll(
      question?.type == QuizQuestionType.listeningAssembly
          ? question!.selectedWords
          : <String>[],
    );
  }

  void _saveCurrentReview(bool isCorrect, {String? correctAnswer}) {
    final QuizQuestionModel? question = currentQuestion;
    if (question == null) {
      return;
    }

    final QuizAnswerReviewModel review = QuizAnswerReviewModel(
      id: question.id,
      type: question.type,
      title: question.title,
      subtitle: question.subtitle,
      selectedAnswer: _selectedAnswerText(question),
      correctAnswer: correctAnswer?.trim().isNotEmpty == true
          ? correctAnswer!.trim()
          : currentCorrectAnswer,
      selectedWords: _selectedWords(question),
      correctWords: question.correctWords,
      selectedOptionIndex: selectedOptionIndex.value,
      correctOptionIndex: question.correctOptionIndex,
      selectedLeftPairIndex: selectedLeftPairIndex.value,
      selectedRightPairIndex: selectedRightPairIndex.value,
      isCorrect: isCorrect,
    );

    final int existingIndex = answerReviews.indexWhere(
      (QuizAnswerReviewModel item) => item.id == question.id,
    );

    if (existingIndex >= 0) {
      answerReviews[existingIndex] = review;
    } else {
      answerReviews.add(review);
    }
  }

  String _selectedAnswerText(QuizQuestionModel question) {
    switch (question.type) {
      case QuizQuestionType.listening:
      case QuizQuestionType.wordTranslation:
      case QuizQuestionType.trueFalse:
      case QuizQuestionType.fillBlank:
      case QuizQuestionType.identifyImage:
        if (selectedOptionIndex.value >= 0 &&
            selectedOptionIndex.value < question.options.length) {
          return question.options[selectedOptionIndex.value];
        }
        return '';
      case QuizQuestionType.sentenceTranslation:
        return sentenceSelectedWords.join(' ');
      case QuizQuestionType.listeningAssembly:
        return listeningSelectedWords.join(' ');
      case QuizQuestionType.matchingPairs:
        return _selectedPairText(question);
      case QuizQuestionType.writingWordTranslation:
        return writingAnswerController.text.trim();
    }
  }

  List<String> _selectedWords(QuizQuestionModel question) {
    switch (question.type) {
      case QuizQuestionType.sentenceTranslation:
        return sentenceSelectedWords.toList();
      case QuizQuestionType.listeningAssembly:
        return listeningSelectedWords.toList();
      default:
        return const <String>[];
    }
  }

  String _selectedPairText(QuizQuestionModel question) {
    final List<String> leftOptions = question.matchingLeftTexts.isNotEmpty
        ? question.matchingLeftTexts
        : _alternatingOptions(question.options, even: true);
    final int count = leftOptions.length < matchingRightOrder.length
        ? leftOptions.length
        : matchingRightOrder.length;

    return List<String>.generate(
      count,
      (int index) => '${leftOptions[index]} = ${matchingRightOrder[index]}',
    ).join(', ');
  }

  List<String> _alternatingOptions(List<String> options, {required bool even}) {
    return <String>[
      for (int index = 0; index < options.length; index++)
        if (index.isEven == even) options[index],
    ];
  }

  bool _isCurrentAnswerCorrect() {
    final QuizQuestionModel? question = currentQuestion;
    if (question == null) {
      return false;
    }

    switch (question.type) {
      case QuizQuestionType.listening:
      case QuizQuestionType.wordTranslation:
      case QuizQuestionType.trueFalse:
      case QuizQuestionType.fillBlank:
      case QuizQuestionType.identifyImage:
        return selectedOptionIndex.value == question.correctOptionIndex;
      case QuizQuestionType.sentenceTranslation:
        return _areWordListsSame(sentenceSelectedWords, question.correctWords);
      case QuizQuestionType.listeningAssembly:
        return _areWordListsSame(listeningSelectedWords, question.correctWords);
      case QuizQuestionType.matchingPairs:
        if (question.matchingRightPairIds.isNotEmpty &&
            matchingRightPairIdOrder.length ==
                question.matchingLeftPairIds.length) {
          return _areWordListsSame(
            matchingRightPairIdOrder,
            question.matchingLeftPairIds,
          );
        }
        return _areWordListsSame(
          matchingRightOrder,
          question.matchingRightTexts,
        );
      case QuizQuestionType.writingWordTranslation:
        return _normalize(writingAnswerController.text) ==
            _normalize(question.correctAnswer);
    }
  }

  bool _areWordListsSame(List<String> selected, List<String> correct) {
    if (selected.length != correct.length) {
      return false;
    }

    for (int index = 0; index < selected.length; index++) {
      if (_normalize(selected[index]) != _normalize(correct[index])) {
        return false;
      }
    }

    return true;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
