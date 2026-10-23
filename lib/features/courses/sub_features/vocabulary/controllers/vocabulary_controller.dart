import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../../practice_hub/services/italian_tts_service.dart';
import '../../../../practice_hub/controllers/practice_hub_controller.dart';
import '../models/vocabulary_models.dart';
import '../services/vocabulary_api_service.dart';
import '../widgets/vocabulary_completion_dialog.dart';
import '../widgets/vocabulary_exit_dialog.dart';

enum VocabularyDisplayMode { list, flashcard }

class VocabularyController extends GetxController {
  final String? lessonId;
  final VocabularyApiService _vocabularyApiService;
  final UserSessionController _userSessionController;
  final ItalianTtsService _ttsService;
  final RxBool isCardChoiceSubmitting = false.obs;

  VocabularyController({
    required VocabularyApiService vocabularyApiService,
    required UserSessionController userSessionController,
    required ItalianTtsService ttsService,
    this.lessonId,
  }) : _vocabularyApiService = vocabularyApiService,
       _userSessionController = userSessionController,
       _ttsService = ttsService;

  final RxBool isLoading = false.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool isStartingWeakReview = false.obs;
  final RxBool isWeakReviewMode = false.obs;

  final Rx<VocabularyDisplayMode> displayMode = VocabularyDisplayMode.list.obs;

  final RxString searchQuery = ''.obs;
  final RxBool showMeanings = true.obs;
  final RxBool isPlayingAll = false.obs;

  final RxInt currentIndex = 0.obs;
  final RxInt rightCount = 0.obs;
  final RxInt wrongCount = 0.obs;

  final Rxn<VocabularySessionModel> session = Rxn<VocabularySessionModel>();

  final RxList<String> knownVocabularyIds = <String>[].obs;
  final RxList<String> weakVocabularyIds = <String>[].obs;

  int _ttsRequestId = 0;
  Timer? _dailyChallengeRefreshDebounce;

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

  List<VocabularyCardModel> get weakCards =>
      (session.value?.cards ?? <VocabularyCardModel>[])
          .where((VocabularyCardModel card) => card.masteryStatus == 'weak')
          .toList(growable: false);

  int get weakWordCount => weakCards.length;

  bool get isCurrentCardMarkedWeak {
    final VocabularyCardModel? card = currentCard;
    return card != null && weakVocabularyIds.contains(card.id);
  }

  List<VocabularyCardModel> get filteredCards {
    final List<VocabularyCardModel> cards =
        session.value?.cards ?? <VocabularyCardModel>[];

    final String query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      return cards;
    }

    return cards
        .where((VocabularyCardModel card) {
          return card.word.toLowerCase().contains(query) ||
              card.meaning.toLowerCase().contains(query) ||
              card.example.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  int get learnedCount {
    return session.value?.cards
            .where((VocabularyCardModel card) => card.isLearned)
            .length ??
        0;
  }

  double get learnedProgressValue {
    if (totalCards == 0) {
      return 0;
    }

    return learnedCount / totalCards;
  }

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
      _userSessionController.loadUser(forceRefresh: true, showError: false),
    );

    unawaited(loadVocabulary());
  }

  @override
  void onClose() {
    _dailyChallengeRefreshDebounce?.cancel();
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

      final VocabularySessionModel response = await _loadSession();

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
      isWeakReviewMode.value = false;

      rightCount.value = 0;
      wrongCount.value = 0;
      isRevealed.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDisplayMode(VocabularyDisplayMode mode) async {
    if (displayMode.value == mode) {
      return;
    }

    await stopSpeaking();

    isPlayingAll.value = false;
    displayMode.value = mode;
  }

  Future<void> startWeakReview() async {
    if (isStartingWeakReview.value || weakCards.isEmpty) {
      return;
    }

    final String? currentLessonId = lessonId?.trim();
    if (currentLessonId == null || currentLessonId.isEmpty) {
      return;
    }

    final List<VocabularyCardModel> cards = List<VocabularyCardModel>.from(
      weakCards,
    );
    isStartingWeakReview.value = true;

    try {
      await stopSpeaking();

      final ApiResult<String> result = await ApiErrorHandler.call<String>(
        () => _vocabularyApiService.startWeakReviewSession(
          lessonId: currentLessonId,
        ),
        errorTitle: 'vocabulary_needs_attention'.tr,
      );

      final String sessionId = result.data?.trim() ?? '';
      if (!result.isSuccess || sessionId.isEmpty) {
        return;
      }

      final VocabularySessionModel current = session.value!;
      session.value = VocabularySessionModel(
        title: 'vocabulary_needs_review'.tr,
        sessionId: sessionId,
        currentCardIndex: 0,
        streakDays: current.streakDays,
        level: current.level,
        cards: cards,
      );
      currentIndex.value = 0;
      rightCount.value = 0;
      wrongCount.value = 0;
      knownVocabularyIds.clear();
      weakVocabularyIds.clear();
      isRevealed.value = false;
      isWeakReviewMode.value = true;
      displayMode.value = VocabularyDisplayMode.flashcard;
    } finally {
      isStartingWeakReview.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setShowMeanings(bool value) {
    showMeanings.value = value;
  }

  Future<void> speakCurrentWord() async {
    final VocabularyCardModel? card = currentCard;

    if (card == null) {
      return;
    }

    await speakCard(card);
  }

  Future<void> speakCard(VocabularyCardModel card) async {
    final String text = card.word.trim();

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

      final bool started = await _ttsService.speakText(text, locale: 'it-IT');
      if (!started && requestId == _ttsRequestId) {
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

  Future<void> playAllVisibleWords() async {
    if (isPlayingAll.value) {
      isPlayingAll.value = false;
      await stopSpeaking();
      return;
    }

    final List<VocabularyCardModel> cards = List<VocabularyCardModel>.from(
      filteredCards,
    );

    if (cards.isEmpty) {
      return;
    }

    isPlayingAll.value = true;

    try {
      for (final VocabularyCardModel card in cards) {
        if (!isPlayingAll.value) {
          break;
        }

        final bool started = await _ttsService.speakText(
          card.word,
          locale: 'it-IT',
        );
        if (!started) {
          Get.snackbar(
            'pronunciation_unavailable'.tr,
            'italian_voice_unavailable_message'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        }
      }
    } finally {
      isPlayingAll.value = false;
    }
  }

  Future<void> stopSpeaking() async {
    _ttsRequestId++;
    isPlayingAll.value = false;

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

    if (card == null || isCompleting.value || isCardChoiceSubmitting.value) {
      return;
    }

    isCardChoiceSubmitting.value = true;

    try {
      await stopSpeaking();

      // Record this word as wrong only once.
      if (!weakVocabularyIds.contains(card.id)) {
        weakVocabularyIds.add(card.id);
        wrongCount.value++;

        // Give immediate visual feedback instead of waiting for the activity
        // request to finish.
        isRevealed.value = false;
        await _recordCardReview(card.id, isKnown: false);
        return;
      }

      // Flip back to the word. The primary action becomes "Next" for this card
      // so advancing cannot overwrite the weak result.
      isRevealed.value = false;
    } finally {
      isCardChoiceSubmitting.value = false;
    }
  }

  Future<void> markKnown() async {
    final VocabularyCardModel? card = currentCard;

    if (card == null || isCompleting.value || isCardChoiceSubmitting.value) {
      return;
    }

    isCardChoiceSubmitting.value = true;

    try {
      await stopSpeaking();

      if (!weakVocabularyIds.contains(card.id) &&
          !knownVocabularyIds.contains(card.id)) {
        knownVocabularyIds.add(card.id);
        rightCount.value++;
        await _recordCardReview(card.id, isKnown: true);
      }

      await _goToNextCard();
    } finally {
      isCardChoiceSubmitting.value = false;
    }
  }

  Future<void> _recordCardReview(
    String vocabularyId, {
    required bool isKnown,
  }) async {
    final String? sessionId = session.value?.sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) return;

    final ApiResult<bool> result = await ApiErrorHandler.call<bool>(
      () => _vocabularyApiService.recordCardReview(
        sessionId: sessionId,
        vocabularyId: vocabularyId,
        isKnown: isKnown,
      ),
      showError: false,
    );

    // The full-session submission remains the retry/fallback if this optional
    // immediate call fails (for example while an old backend is still rolling
    // out). Refresh an already-mounted challenge dashboard without coupling the
    // vocabulary flow to its availability.
    if (result.isSuccess && Get.isRegistered<PracticeHubController>()) {
      _dailyChallengeRefreshDebounce?.cancel();
      _dailyChallengeRefreshDebounce = Timer(
        const Duration(milliseconds: 400),
        () => unawaited(
          Get.find<PracticeHubController>().loadDailyChallenges(
            showError: false,
          ),
        ),
      );
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
      final VocabularyCompletionModel? complete = await _completeSession();
      if (complete == null) {
        return;
      }

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

    if (displayMode.value == VocabularyDisplayMode.list) {
      Get.back<void>();
      return;
    }

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

    if (currentLessonId == null || currentLessonId.isEmpty) {
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

  Future<VocabularyCompletionModel?> _completeSession() async {
    final String? sessionId = session.value?.sessionId?.trim();

    if (sessionId == null || sessionId.isEmpty) {
      return null;
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

    return result.isSuccess ? result.data : null;
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
}
