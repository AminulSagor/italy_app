import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../../practice_hub/services/italian_tts_service.dart';
import '../models/vocabulary_models.dart';
import '../services/vocabulary_api_service.dart';
import '../widgets/vocabulary_completion_dialog.dart';
import '../widgets/vocabulary_exit_dialog.dart';

class VocabularyController extends GetxController {
  final String? lessonId;
  final VocabularyApiService _vocabularyApiService;
  final UserSessionController _userSessionController;
  final ItalianTtsService _ttsService;
  final RxBool isKnownSubmitting = false.obs;

  VocabularyController({
    required VocabularyApiService vocabularyApiService,
    required UserSessionController userSessionController,
    required ItalianTtsService ttsService,
    this.lessonId,
  })  : _vocabularyApiService = vocabularyApiService,
        _userSessionController = userSessionController,
        _ttsService = ttsService;

  final RxBool isLoading = false.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isSpeaking = false.obs;

  final RxInt currentIndex = 0.obs;
  final RxInt rightCount = 0.obs;
  final RxInt wrongCount = 0.obs;

  final Rxn<VocabularySessionModel> session =
  Rxn<VocabularySessionModel>();

  final RxList<String> knownVocabularyIds = <String>[].obs;
  final RxList<String> weakVocabularyIds = <String>[].obs;

  int _ttsRequestId = 0;

  VocabularyCardModel? get currentCard {
    final VocabularySessionModel? value = session.value;

    if (value == null || value.cards.isEmpty) {
      return null;
    }

    final int safeIndex = currentIndex.value
        .clamp(0, value.cards.length - 1)
        .toInt();

    return value.cards[safeIndex];
  }

  int get totalCards => session.value?.cards.length ?? 0;

  int get currentCardNumber {
    return totalCards == 0 ? 0 : currentIndex.value + 1;
  }

  double get progressValue {
    if (totalCards == 0) {
      return 0;
    }

    return currentCardNumber / totalCards;
  }

  int get reviewedCount {
    return rightCount.value + wrongCount.value;
  }

  int get currentStreakDays {
    return _userSessionController.currentStreakDays;
  }

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

  @override
  void onClose() {
    unawaited(stopSpeaking());
    super.onClose();
  }

  Future<void> loadVocabulary() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      await stopSpeaking();

      final VocabularySessionModel response =
      await _loadSession();

      session.value = response;

      if (response.cards.isEmpty) {
        currentIndex.value = 0;
      } else {
        currentIndex.value = response.currentCardIndex
            .clamp(0, response.cards.length - 1)
            .toInt();
      }

      knownVocabularyIds.clear();
      weakVocabularyIds.clear();

      rightCount.value = 0;
      wrongCount.value = 0;
      isRevealed.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> speakCurrentWord() async {
    final VocabularyCardModel? card = currentCard;
    final String text = card?.word.trim() ?? '';

    if (text.isEmpty || isSpeaking.value) {
      return;
    }

    final int requestId = ++_ttsRequestId;

    isSpeaking.value = true;

    try {
      await _ttsService.stop();

      if (requestId != _ttsRequestId) {
        return;
      }

      await _ttsService.speakText(
        text,
        locale: 'it-IT',
      );
    } catch (_) {
      if (requestId == _ttsRequestId) {
        Get.snackbar(
          'pronunciation_unavailable'.tr,
          'italian_voice_unavailable_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (requestId == _ttsRequestId) {
        isSpeaking.value = false;
      }
    }
  }

  Future<void> stopSpeaking() async {
    _ttsRequestId++;

    try {
      await _ttsService.stop();
    } finally {
      isSpeaking.value = false;
    }
  }

  void revealAnswer() {
    if (currentCard == null) {
      return;
    }

    isRevealed.value = true;
  }

  void flipCard() {
    if (currentCard == null) {
      return;
    }

    isRevealed.toggle();
  }

  Future<void> studyAgain() async {
    final VocabularyCardModel? card = currentCard;

    if (card == null || isCompleting.value) {
      return;
    }

    await stopSpeaking();

    // Record this word as wrong only once.
    if (!weakVocabularyIds.contains(card.id)) {
      weakVocabularyIds.add(card.id);
      wrongCount.value++;
    }

    // Keep showing the same word from the front side.
    isRevealed.value = false;
  }

  Future<void> markKnown() async {
    final VocabularyCardModel? card = currentCard;

    if (card == null ||
        isCompleting.value ||
        isKnownSubmitting.value) {
      return;
    }

    final bool isLastCard =
        currentIndex.value >= totalCards - 1;

    if (isLastCard) {
      isKnownSubmitting.value = true;
    }

    try {
      await stopSpeaking();

      if (!weakVocabularyIds.contains(card.id) &&
          !knownVocabularyIds.contains(card.id)) {
        knownVocabularyIds.add(card.id);
        rightCount.value++;
      }

      await _goToNextCard();
    } finally {
      isKnownSubmitting.value = false;
    }
  }

  Future<void> _goToNextCard() async {
    if (totalCards == 0 || isCompleting.value) {
      return;
    }

    await stopSpeaking();

    if (currentIndex.value >= totalCards - 1) {
      await _showCompletionDialog();
      return;
    }

    currentIndex.value++;
    isRevealed.value = false;
  }

  Future<void> _showCompletionDialog() async {
    if (totalCards == 0) {
      return;
    }

    isCompleting.value = true;

    try {
      final VocabularyCompletionModel complete =
      await _completeSession();

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
    if (Get.isDialogOpen ?? false) {
      return;
    }

    await stopSpeaking();

    await Get.dialog<void>(
      VocabularyExitDialog(
        onKeepGoingTap: () => Get.back<void>(),
        onQuitTap: quitVocabulary,
      ),
      barrierDismissible: false,
    );
  }

  void quitVocabulary() {
    unawaited(stopSpeaking());

    Get.back<void>();
    Get.back<void>();
  }

  void closeCompletion() {
    unawaited(stopSpeaking());

    Get.back<void>();
    Get.back<bool>(result: true);
  }

  Future<VocabularySessionModel> _loadSession() async {
    final String? currentLessonId = lessonId?.trim();

    if (currentLessonId == null ||
        currentLessonId.isEmpty) {
      return _emptySession();
    }

    final ApiResult<VocabularySessionModel> result =
    await ApiErrorHandler.call<VocabularySessionModel>(
          () => _vocabularyApiService.fetchVocabularySession(
        lessonId: currentLessonId,
      ),
      errorTitle: 'gen_vocabulary'.tr,
    );

    return result.dataOr(_emptySession());
  }

  Future<VocabularyCompletionModel>
  _completeSession() async {
    final String? sessionId =
    session.value?.sessionId?.trim();

    if (sessionId == null || sessionId.isEmpty) {
      return _localCompletion();
    }

    final ApiResult<VocabularyCompletionModel> result =
    await ApiErrorHandler.call<VocabularyCompletionModel>(
          () => _vocabularyApiService.completeSession(
        sessionId: sessionId,
        knownVocabularyIds:
        knownVocabularyIds.toList(),
        weakVocabularyIds:
        weakVocabularyIds.toList(),
      ),
      errorTitle: 'gen_vocabulary'.tr,
    );

    return result.dataOr(_localCompletion());
  }

  VocabularySessionModel _emptySession() {
    return VocabularySessionModel(
      title: 'gen_vocabulary'.tr,
      currentCardIndex: 0,
      streakDays: 0,
      level: 1,
      cards: const <VocabularyCardModel>[],
    );
  }

  VocabularyCompletionModel _localCompletion() {
    return VocabularyCompletionModel(
      appName: 'italirpothe'.tr,
      reviewedCount: reviewedCount,
      rightCount: rightCount.value,
      wrongCount: wrongCount.value,
    );
  }
}