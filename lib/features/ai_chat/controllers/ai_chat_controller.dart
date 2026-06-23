import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/ai_tutor_guided_learning_models.dart';
import '../models/ai_tutor_level_test_models.dart';
import '../models/ai_tutor_models.dart';
import '../services/ai_tutor_api_service.dart';
import '../services/ai_tutor_preferences_service.dart';
import '../services/ai_tutor_tts_service.dart';
import '../services/ai_tutor_voice_service.dart';
import '../views/ai_level_test_view.dart';
import '../views/ai_tutor_discovery_view.dart';
import '../views/ai_tutor_live_voice_view.dart';
import '../views/guided_learning_level_selection_view.dart';
import '../views/guided_learning_topics_view.dart';

class AiChatController extends GetxController {
  AiChatController({
    AiTutorApiService? apiService,
    AiTutorVoiceService? voiceService,
    AiTutorTtsService? ttsService,
    AiTutorPreferencesService? preferencesService,
  }) : _apiService = apiService ?? Get.find<AiTutorApiService>(),
       voiceService = voiceService ?? Get.find<AiTutorVoiceService>(),
       _ttsService = ttsService ?? Get.find<AiTutorTtsService>(),
       _preferencesService = preferencesService ??
           Get.find<AiTutorPreferencesService>();

  final AiTutorApiService _apiService;
  final AiTutorTtsService _ttsService;
  final AiTutorPreferencesService _preferencesService;
  final AiTutorVoiceService voiceService;

  final TextEditingController inputController = TextEditingController();
  final RxString inputText = ''.obs;
  final RxBool isTextConversationActive = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isStartingVoiceSession = false.obs;
  final RxnString speakingMessageId = RxnString();
  final RxList<String> expandedTranslationIds = <String>[].obs;
  final RxList<AiTutorStarterModel> visibleStarters =
      <AiTutorStarterModel>[].obs;
  final RxList<AiTutorMessageModel> textMessages =
      <AiTutorMessageModel>[].obs;
  final RxnString conversationId = RxnString();
  final RxList<String> conversationMemoryFacts = <String>[].obs;
  final RxList<String> recentMistakeTags = <String>[].obs;

  Rxn<AiTutorLearnerProfileModel> get learnerProfile =>
      _preferencesService.learnerProfile;

  String get levelTestSubtitle {
    final AiTutorLearnerProfileModel? profile = learnerProfile.value;
    return profile == null ? 'লেভেল টেস্ট' : 'Current: ${profile.finalLevel}';
  }

  String get adaptiveModeLabel {
    final AiTutorLearnerProfileModel? profile = learnerProfile.value;
    if (recentMistakeTags.isNotEmpty) {
      return 'Simplified correction mode';
    }
    return profile?.adaptiveLabel ?? 'Adaptive level detection';
  }

  AiTutorVoiceSessionModel? _activeVoiceSession;
  String? _activeVoiceTopic;
  AiTutorGuidedSessionContext? _activeGuidedSession;
  int _textSessionVersion = 0;

  final List<AiTutorStarterModel> _allStarters =
      const <AiTutorStarterModel>[
        AiTutorStarterModel(
          title: 'Practice ordering food',
          subtitle: 'Al ristorante',
          prompt: 'Practice ordering food at an Italian restaurant.',
          isVoice: true,
          icon: Icons.restaurant_rounded,
        ),
        AiTutorStarterModel(
          title: 'Talk about my day',
          subtitle: 'La mia giornata',
          prompt: 'Help me talk about my day in Italian.',
          isVoice: false,
          icon: Icons.wb_sunny_rounded,
        ),
        AiTutorStarterModel(
          title: 'Review basic greetings',
          subtitle: 'I saluti base',
          prompt: 'Teach me basic Italian greetings.',
          isVoice: false,
          icon: Icons.school_rounded,
        ),
        AiTutorStarterModel(
          title: 'Ask for directions',
          subtitle: 'Chiedere indicazioni',
          prompt: 'Practice asking for directions in Italian.',
          isVoice: false,
          icon: Icons.near_me_rounded,
        ),
        AiTutorStarterModel(
          title: 'Coffee shop phrases',
          subtitle: 'Al bar',
          prompt: 'Practice Italian coffee shop phrases with me.',
          isVoice: true,
          icon: Icons.local_cafe_rounded,
        ),
      ];

  bool get isGuidedVoiceSession => _activeGuidedSession != null;

  bool get isLiveVoiceConnecting =>
      isStartingVoiceSession.value ||
      voiceService.connectionState.value ==
          AiTutorVoiceConnectionState.connecting;

  @override
  void onInit() {
    super.onInit();
    refreshStarters();
    unawaited(refreshLearnerProfile());
  }

  Future<void> refreshLearnerProfile() async {
    final ApiResult<AiTutorLevelProfileResponseModel> result =
        await ApiErrorHandler.call<AiTutorLevelProfileResponseModel>(
      _apiService.getLevelTestProfile,
      showError: false,
    );
    if (!result.isSuccess || result.data == null) {
      return;
    }

    final AiTutorLearnerProfileModel? profile = result.data!.profile;
    if (profile == null) {
      _preferencesService.clearProfile();
      return;
    }
    _preferencesService.setProfile(profile);
  }

  void onEnterLabTap() {
    prepareDiscoverySession();
    Get.to<void>(
      () => const AiTutorDiscoveryView(),
      transition: Transition.rightToLeft,
    );
  }

  void prepareDiscoverySession() {
    resetTextConversation();
    refreshStarters();
  }

  void refreshStarters() {
    final List<AiTutorStarterModel> shuffled =
        List<AiTutorStarterModel>.from(_allStarters)..shuffle(Random());
    visibleStarters.assignAll(shuffled.take(3));
  }

  void onInputChanged(String value) {
    inputText.value = value;
  }

  void onStarterTap(AiTutorStarterModel starter) {
    if (starter.isVoice) {
      openLiveVoiceSession(topic: starter.prompt);
      return;
    }
    startTextConversation(starter.prompt);
  }

  void sendTextFromDiscovery() {
    final String value = inputController.text.trim();
    if (value.isEmpty) {
      return;
    }
    startTextConversation(value);
  }

  void startTextConversation(String prompt) {
    _textSessionVersion++;
    conversationId.value = null;
    textMessages.clear();
    expandedTranslationIds.clear();
    conversationMemoryFacts.clear();
    recentMistakeTags.clear();
    inputController.clear();
    inputText.value = '';
    isTextConversationActive.value = true;
    isSendingMessage.value = false;
    unawaited(_ttsService.stop());
    speakingMessageId.value = null;

    final String cleanPrompt = prompt.trim();
    if (cleanPrompt.isNotEmpty) {
      unawaited(_sendMessage(cleanPrompt));
    }
  }

  void sendTextFromChat() {
    final String value = inputController.text.trim();
    if (value.isEmpty || isSendingMessage.value) {
      return;
    }

    inputController.clear();
    inputText.value = '';
    unawaited(_sendMessage(value));
  }

  Future<void> _sendMessage(String text) async {
    if (isSendingMessage.value) {
      return;
    }

    final int sessionVersion = _textSessionVersion;
    final List<AiTutorMessageModel> history =
        List<AiTutorMessageModel>.from(textMessages);
    textMessages.add(AiTutorMessageModel.user(text));
    isSendingMessage.value = true;

    try {
      final ApiResult<AiTutorChatResponseModel> result =
          await ApiErrorHandler.call<AiTutorChatResponseModel>(
            () => _apiService.sendMessage(
              message: text,
              history: history,
              conversationId: conversationId.value,
              memoryFacts: conversationMemoryFacts,
              recentMistakeTags: recentMistakeTags,
            ),
          );
      if (!result.isSuccess ||
          result.data == null ||
          sessionVersion != _textSessionVersion ||
          !isTextConversationActive.value) {
        return;
      }

      conversationId.value = result.data!.conversationId;
      conversationMemoryFacts.assignAll(result.data!.memoryFacts);
      recentMistakeTags.assignAll(result.data!.recentMistakeTags);
      textMessages.add(result.data!.message);
    } finally {
      if (sessionVersion == _textSessionVersion) {
        isSendingMessage.value = false;
      }
    }
  }

  void toggleTranslations(String id) {
    if (expandedTranslationIds.contains(id)) {
      expandedTranslationIds.remove(id);
    } else {
      expandedTranslationIds.add(id);
    }
  }

  Future<void> toggleItalianSpeech(AiTutorMessageModel message) async {
    if (message.isUser || message.primary.trim().isEmpty) {
      return;
    }

    if (speakingMessageId.value == message.id) {
      await _ttsService.stop();
      speakingMessageId.value = null;
      return;
    }

    await _ttsService.stop();
    speakingMessageId.value = message.id;
    try {
      await _ttsService.speakItalian(message.primary);
    } catch (_) {
      Get.snackbar(
        'Italian voice unavailable',
        'Install or enable an Italian text-to-speech voice on this device.',
      );
    } finally {
      if (speakingMessageId.value == message.id) {
        speakingMessageId.value = null;
      }
    }
  }

  void resetTextConversation() {
    _textSessionVersion++;
    conversationId.value = null;
    textMessages.clear();
    expandedTranslationIds.clear();
    conversationMemoryFacts.clear();
    recentMistakeTags.clear();
    inputController.clear();
    inputText.value = '';
    isTextConversationActive.value = false;
    isSendingMessage.value = false;
    speakingMessageId.value = null;
    unawaited(_ttsService.stop());
  }

  void openLiveVoiceSession({
    String? topic,
    AiTutorGuidedSessionContext? guidedSession,
  }) {
    _activeVoiceTopic = topic?.trim();
    _activeGuidedSession = guidedSession;
    Get.to<void>(
      () => const AiTutorLiveVoiceView(),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> ensureLiveVoiceConnected() async {
    if (isStartingVoiceSession.value || voiceService.isConnected) {
      return;
    }

    isStartingVoiceSession.value = true;
    AiTutorVoiceSessionModel? createdSession;
    try {
      final ApiResult<AiTutorVoiceSessionModel> result =
          await ApiErrorHandler.call<AiTutorVoiceSessionModel>(
            () => _apiService.startVoiceSession(
              topic: _activeVoiceTopic,
              memoryFacts: conversationMemoryFacts,
              recentMistakeTags: recentMistakeTags,
              guidedMode: _activeGuidedSession?.mode.apiValue,
              guidedLevel: _activeGuidedSession?.level,
            ),
          );
      if (!result.isSuccess || result.data == null) {
        voiceService.connectionState.value = AiTutorVoiceConnectionState.error;
        voiceService.status.value = 'Unable to start voice session';
        return;
      }

      createdSession = result.data!;
      _activeVoiceSession = createdSession;
      await voiceService.connect(createdSession);
    } catch (_) {
      if (createdSession != null) {
        await ApiErrorHandler.call<void>(
          () => _apiService.endVoiceSession(createdSession!.sessionId),
          showError: false,
        );
      }
      _activeVoiceSession = null;
    } finally {
      isStartingVoiceSession.value = false;
    }
  }

  Future<void> retryLiveVoice() async {
    await endLiveVoiceSession();
    await ensureLiveVoiceConnected();
  }

  Future<void> toggleLiveVoiceMute() async {
    await voiceService.toggleMute();
  }

  Future<void> endLiveVoiceSession() async {
    final AiTutorVoiceSessionModel? session = _activeVoiceSession;
    _activeVoiceSession = null;
    await voiceService.disconnect();

    if (session != null) {
      await ApiErrorHandler.call<void>(
        () => _apiService.endVoiceSession(session.sessionId),
        showError: false,
      );
    }
  }

  Future<bool> handleLiveVoiceSystemBack() async {
    if (isLiveVoiceConnecting) {
      return false;
    }
    await endLiveVoiceSession();
    _activeGuidedSession = null;
    _activeVoiceTopic = null;
    return true;
  }

  Future<void> closeLiveVoicePage() async {
    if (isLiveVoiceConnecting) {
      return;
    }
    await endLiveVoiceSession();
    _activeGuidedSession = null;
    _activeVoiceTopic = null;
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<void>();
    }
  }

  Future<void> switchLiveVoiceToText() async {
    if (isLiveVoiceConnecting || isGuidedVoiceSession) {
      return;
    }

    final String prompt = _activeVoiceTopic?.trim().isNotEmpty == true
        ? _activeVoiceTopic!.trim()
        : 'Continue helping me practice Italian.';
    await endLiveVoiceSession();
    _activeGuidedSession = null;
    _activeVoiceTopic = null;
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<void>();
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    startTextConversation(prompt);
  }

  void onGuidedLearningTap() {
    Get.to<void>(
      () => const GuidedLearningLevelSelectionView(),
      transition: Transition.rightToLeft,
    );
  }

  void openGuidedTopics({
    required String level,
    required AiTutorGuidedMode mode,
  }) {
    Get.to<void>(
      () => GuidedLearningTopicsView(level: level, mode: mode),
      transition: Transition.rightToLeft,
    );
  }

  void onGuidedTopicTap({
    required String level,
    required AiTutorGuidedMode mode,
    required String topicTitle,
  }) {
    final AiTutorGuidedSessionContext guidedSession =
        AiTutorGuidedSessionContext(
      level: level.trim().toUpperCase(),
      mode: mode,
      topic: topicTitle.trim(),
    );
    openLiveVoiceSession(
      topic: guidedSession.topic,
      guidedSession: guidedSession,
    );
  }

  void onLevelTestTap() {
    Get.to<void>(
      () => const AiLevelTestView(),
      transition: Transition.rightToLeft,
    );
  }

  void onWritingHelpTap() {
    Get.snackbar('Writing Help', 'This feature is coming soon.');
  }

  void onRecentSessionTap() {
    Get.snackbar('Recent Sessions', 'This feature is coming soon.');
  }

  @override
  void onClose() {
    unawaited(endLiveVoiceSession());
    unawaited(_ttsService.dispose());
    inputController.dispose();
    super.onClose();
  }
}
