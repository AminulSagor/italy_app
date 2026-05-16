import 'package:get/get.dart';

import '../models/vocabulary_models.dart';
import '../services/vocabulary_mock_service.dart';
import '../widgets/vocabulary_completion_dialog.dart';
import '../widgets/vocabulary_exit_dialog.dart';

class VocabularyController extends GetxController {
  final VocabularyMockService _vocabularyMockService;

  VocabularyController({required VocabularyMockService vocabularyMockService})
      : _vocabularyMockService = vocabularyMockService;

  final RxBool isLoading = false.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isCompleting = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt rightCount = 0.obs;
  final RxInt wrongCount = 0.obs;
  final Rxn<VocabularySessionModel> session = Rxn<VocabularySessionModel>();

  VocabularyCardModel? get currentCard {
    final VocabularySessionModel? value = session.value;
    if (value == null || value.cards.isEmpty) {
      return null;
    }
    return value.cards[currentIndex.value.clamp(0, value.cards.length - 1).toInt()];
  }

  int get totalCards => session.value?.cards.length ?? 0;

  int get currentCardNumber => totalCards == 0 ? 0 : currentIndex.value + 1;

  double get progressValue {
    if (totalCards == 0) {
      return 0;
    }
    return currentCardNumber / totalCards;
  }

  int get reviewedCount => rightCount.value + wrongCount.value;

  @override
  void onInit() {
    super.onInit();
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final VocabularySessionModel response = await _vocabularyMockService.fetchVocabularySession();
      session.value = response;
      currentIndex.value = response.currentCardIndex;
    } finally {
      isLoading.value = false;
    }
  }

  void revealAnswer() {
    isRevealed.value = true;
  }

  void flipCard() {
    isRevealed.toggle();
  }

  Future<void> studyAgain() async {
    wrongCount.value++;
    await _goToNextCard();
  }

  Future<void> markKnown() async {
    rightCount.value++;
    await _goToNextCard();
  }

  Future<void> _goToNextCard() async {
    if (totalCards == 0 || isCompleting.value) {
      return;
    }

    if (currentIndex.value >= totalCards - 1) {
      await _showCompletionDialog();
      return;
    }

    currentIndex.value++;
    isRevealed.value = false;
  }

  Future<void> _showCompletionDialog() async {
    isCompleting.value = true;
    try {
      final VocabularyCompletionModel complete = await _vocabularyMockService.completeSession(
        reviewedCount: totalCards,
        rightCount: rightCount.value == 0 ? 38 : rightCount.value,
        wrongCount: wrongCount.value == 0 ? 7 : wrongCount.value,
      );

      await Get.dialog<void>(
        VocabularyCompletionDialog(
          complete: complete,
          onCloseTap: closeCompletion,
        ),
        barrierDismissible: false,
      );
    } finally {
      isCompleting.value = false;
    }
  }

  Future<void> showExitConfirmation() async {
    await Get.dialog<void>(
      VocabularyExitDialog(
        onKeepGoingTap: () => Get.back<void>(),
        onQuitTap: quitVocabulary,
      ),
      barrierDismissible: false,
    );
  }

  void quitVocabulary() {
    Get.back<void>();
    Get.back<void>();
  }

  void closeCompletion() {
    Get.back<void>();
    Get.back(result: true);
  }
}
