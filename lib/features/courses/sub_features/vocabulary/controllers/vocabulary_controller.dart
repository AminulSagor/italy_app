import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../models/vocabulary_models.dart';
import '../services/vocabulary_api_service.dart';
import '../services/vocabulary_mock_service.dart';
import '../widgets/vocabulary_completion_dialog.dart';
import '../widgets/vocabulary_exit_dialog.dart';

class VocabularyController extends GetxController {
  final String? lessonId;
  final VocabularyMockService _vocabularyMockService;
  final VocabularyApiService _vocabularyApiService;
  final UserSessionController _userSessionController;

  VocabularyController({
    required VocabularyMockService vocabularyMockService,
    required VocabularyApiService vocabularyApiService,
    required UserSessionController userSessionController,
    this.lessonId,
  })  : _vocabularyMockService = vocabularyMockService,
        _vocabularyApiService = vocabularyApiService,
        _userSessionController = userSessionController;

  final RxBool isLoading = false.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isCompleting = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt rightCount = 0.obs;
  final RxInt wrongCount = 0.obs;
  final Rxn<VocabularySessionModel> session = Rxn<VocabularySessionModel>();
  final RxList<String> knownVocabularyIds = <String>[].obs;
  final RxList<String> weakVocabularyIds = <String>[].obs;

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

  int get currentStreakDays => _userSessionController.currentStreakDays;

  @override
  void onInit() {
    super.onInit();
    unawaited(
      _userSessionController.loadUser(
        forceRefresh: true,
        showError: false,
      ),
    );
    unawaited(loadVocabulary());
  }

  Future<void> loadVocabulary() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final VocabularySessionModel response = await _loadSession();
      session.value = response;
      currentIndex.value = response.currentCardIndex;
      knownVocabularyIds.clear();
      weakVocabularyIds.clear();
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
    final VocabularyCardModel? card = currentCard;
    if (card != null && !weakVocabularyIds.contains(card.id)) {
      weakVocabularyIds.add(card.id);
    }
    wrongCount.value++;
    await _goToNextCard();
  }

  Future<void> markKnown() async {
    final VocabularyCardModel? card = currentCard;
    if (card != null && !knownVocabularyIds.contains(card.id)) {
      knownVocabularyIds.add(card.id);
    }
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
      final VocabularyCompletionModel complete = await _completeSession();

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

  Future<VocabularySessionModel> _loadSession() async {
    final String? currentLessonId = lessonId;
    if (currentLessonId == null || currentLessonId.isEmpty) {
      return _vocabularyMockService.fetchVocabularySession();
    }

    final ApiResult<VocabularySessionModel> result =
        await ApiErrorHandler.call<VocabularySessionModel>(
      () => _vocabularyApiService.fetchVocabularySession(
        lessonId: currentLessonId,
      ),
      errorTitle: 'gen_vocabulary'.tr,
    );

    return result.dataOr(
      VocabularySessionModel.fromJson(<String, dynamic>{
        'title': 'gen_vocabulary'.tr,
        'currentCardIndex': 0,
        'streakDays': 0,
        'level': 1,
        'cards': <Map<String, dynamic>>[],
      }),
    );
  }

  Future<VocabularyCompletionModel> _completeSession() async {
    final String? sessionId = session.value?.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      return _vocabularyMockService.completeSession(
        reviewedCount: totalCards,
        rightCount: rightCount.value == 0 ? totalCards : rightCount.value,
        wrongCount: wrongCount.value,
      );
    }

    final ApiResult<VocabularyCompletionModel> result =
        await ApiErrorHandler.call<VocabularyCompletionModel>(
      () => _vocabularyApiService.completeSession(
        sessionId: sessionId,
        knownVocabularyIds: knownVocabularyIds.toList(),
        weakVocabularyIds: weakVocabularyIds.toList(),
      ),
      errorTitle: 'gen_vocabulary'.tr,
    );

    return result.dataOr(
      VocabularyCompletionModel.fromJson(<String, dynamic>{
        'appName': 'italirpothe'.tr,
        'reviewedCount': totalCards,
        'rightCount': rightCount.value,
        'wrongCount': wrongCount.value,
      }),
    );
  }
}
