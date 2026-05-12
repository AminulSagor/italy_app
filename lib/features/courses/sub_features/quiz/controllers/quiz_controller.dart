import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/quiz_models.dart';
import '../services/quiz_mock_service.dart';

class QuizController extends GetxController {
  final QuizMockService _quizMockService;

  QuizController({required QuizMockService quizMockService})
      : _quizMockService = quizMockService;

  final RxBool isLoading = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool hasCheckedAnswer = false.obs;
  final RxBool isAnswerCorrect = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt selectedOptionIndex = (-1).obs;
  final RxInt selectedLeftPairIndex = (-1).obs;
  final RxInt selectedRightPairIndex = (-1).obs;
  final RxList<String> sentenceSelectedWords = <String>[].obs;
  final RxList<String> listeningSelectedWords = <String>[].obs;
  final RxList<QuizQuestionModel> questions = <QuizQuestionModel>[].obs;
  final RxList<QuizAnswerReviewModel> answerReviews =
      <QuizAnswerReviewModel>[].obs;
  final Rxn<QuizLessonCompleteModel> lessonComplete =
      Rxn<QuizLessonCompleteModel>();

  final TextEditingController writingAnswerController = TextEditingController();

  int get totalQuestions => questions.length;
  int get correctAnswerCount =>
      answerReviews.where((QuizAnswerReviewModel item) => item.isCorrect).length;
  bool get showWrongResult => hasCheckedAnswer.value && !isAnswerCorrect.value;
  QuizQuestionModel? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex.value];

  String get currentCorrectAnswer {
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
      questions.assignAll(await _quizMockService.fetchQuestions());
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
      lessonComplete.value = await _quizMockService.fetchLessonComplete();
    } finally {
      isCompleting.value = false;
    }
  }

  void selectOption(int index) {
    if (hasCheckedAnswer.value) {
      return;
    }
    selectedOptionIndex.value = index;
  }

  void addSentenceWord(String word) {
    if (hasCheckedAnswer.value || sentenceSelectedWords.contains(word)) {
      return;
    }

    final int slotCount = currentQuestion?.answerWordCount ?? 0;
    if (slotCount > 0 && sentenceSelectedWords.length >= slotCount) {
      return;
    }

    sentenceSelectedWords.add(word);
  }

  void removeSentenceWord(String word) {
    if (hasCheckedAnswer.value) {
      return;
    }
    sentenceSelectedWords.remove(word);
  }

  void addListeningWord(String word) {
    if (hasCheckedAnswer.value || listeningSelectedWords.contains(word)) {
      return;
    }

    final int slotCount = currentQuestion?.answerWordCount ?? 0;
    if (slotCount > 0 && listeningSelectedWords.length >= slotCount) {
      return;
    }

    listeningSelectedWords.add(word);
  }

  void removeListeningWord(String word) {
    if (hasCheckedAnswer.value) {
      return;
    }
    listeningSelectedWords.remove(word);
  }

  void selectLeftPair(int index) {
    if (hasCheckedAnswer.value) {
      return;
    }
    selectedLeftPairIndex.value = index;
  }

  void selectRightPair(int index) {
    if (hasCheckedAnswer.value) {
      return;
    }
    selectedRightPairIndex.value = index;
  }

  bool checkAnswer() {
    hasCheckedAnswer.value = true;
    isAnswerCorrect.value = _isCurrentAnswerCorrect();
    _saveCurrentReview(isAnswerCorrect.value);
    return isAnswerCorrect.value;
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
    hasCheckedAnswer.value = false;
    isAnswerCorrect.value = false;
    selectedOptionIndex.value = -1;
    selectedLeftPairIndex.value = -1;
    selectedRightPairIndex.value = -1;
    writingAnswerController.clear();

    final QuizQuestionModel? question = currentQuestion;
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

  void _saveCurrentReview(bool isCorrect) {
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
      correctAnswer: currentCorrectAnswer,
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
    final List<String> leftOptions = <String>[];
    final List<String> rightOptions = <String>[];

    for (int index = 0; index < question.options.length; index++) {
      if (index.isEven) {
        leftOptions.add(question.options[index]);
      } else {
        rightOptions.add(question.options[index]);
      }
    }

    final String left = selectedLeftPairIndex.value >= 0 &&
            selectedLeftPairIndex.value < leftOptions.length
        ? leftOptions[selectedLeftPairIndex.value]
        : '';
    final String right = selectedRightPairIndex.value >= 0 &&
            selectedRightPairIndex.value < rightOptions.length
        ? rightOptions[selectedRightPairIndex.value]
        : '';

    if (left.isEmpty && right.isEmpty) {
      return '';
    }
    return '$left = $right';
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
        return selectedLeftPairIndex.value >= 0 &&
            selectedRightPairIndex.value >= 0 &&
            selectedLeftPairIndex.value == selectedRightPairIndex.value;
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
