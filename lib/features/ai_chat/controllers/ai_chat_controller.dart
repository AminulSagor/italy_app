import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/user_session_controller.dart';
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
import '../views/ai_tutor_writing_help_view.dart';
import '../views/guided_learning_level_selection_view.dart';
import '../views/guided_learning_topics_view.dart';

class AiChatController extends GetxController with WidgetsBindingObserver {
  AiChatController({
    AiTutorApiService? apiService,
    AiTutorVoiceService? voiceService,
    AiTutorTtsService? ttsService,
    AiTutorPreferencesService? preferencesService,
    UserSessionController? userSessionController,
  }) : _apiService = apiService ?? Get.find<AiTutorApiService>(),
       voiceService = voiceService ?? Get.find<AiTutorVoiceService>(),
       _ttsService = ttsService ?? Get.find<AiTutorTtsService>(),
       _preferencesService = preferencesService ??
           Get.find<AiTutorPreferencesService>(),
       _userSessionController = userSessionController ??
           Get.find<UserSessionController>();

  final AiTutorApiService _apiService;
  final AiTutorTtsService _ttsService;
  final AiTutorPreferencesService _preferencesService;
  final UserSessionController _userSessionController;
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
  final Rx<AiTutorChatMode> textChatMode = AiTutorChatMode.general.obs;
  final Rxn<AiTutorWritingSourceLanguage> writingSourceLanguage =
      Rxn<AiTutorWritingSourceLanguage>();
  final RxInt remainingVoiceSeconds = 0.obs;
  final RxBool isVoiceBalanceExhausted = false.obs;

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

  bool get isWritingHelpSession =>
      textChatMode.value == AiTutorChatMode.writingHelp &&
      writingSourceLanguage.value != null;

  String get writingHelpLanguageLabel =>
      writingSourceLanguage.value?.displayName ?? 'Italian Writing Help';

  String get writingHelpInputHint {
    switch (writingSourceLanguage.value) {
      case AiTutorWritingSourceLanguage.bangla:
        return 'শব্দ, বাক্য বা ইতালীয় খসড়া লিখুন...';
      case AiTutorWritingSourceLanguage.english:
        return 'Enter a word, sentence, or Italian draft...';
      case null:
        return 'Write what you need help with...';
    }
  }

  AiTutorVoiceSessionModel? _activeVoiceSession;
  String? _activeVoiceTopic;
  AiTutorGuidedSessionContext? _activeGuidedSession;
  int _textSessionVersion = 0;
  Timer? _voiceCountdownTimer;
  Timer? _voiceHeartbeatTimer;
  bool _isEndingVoiceSession = false;
  bool _isSendingVoiceHeartbeat = false;

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

  String get remainingVoiceTimeLabel {
    final int totalSeconds = remainingVoiceSeconds.value.clamp(0, 86400).toInt();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshStarters();
    unawaited(refreshLearnerProfile());
    unawaited(_userSessionController.refreshAiBalances());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(endLiveVoiceSession());
    }
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
    unawaited(_userSessionController.refreshAiBalances());
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
    textChatMode.value = AiTutorChatMode.general;
    writingSourceLanguage.value = null;
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
              chatMode: textChatMode.value,
              writingSourceLanguage: writingSourceLanguage.value,
            ),
          );
      if (!result.isSuccess ||
          result.data == null ||
          sessionVersion != _textSessionVersion ||
          !isTextConversationActive.value) {
        return;
      }

      _applyAiBalances(result.data!.balances);
      conversationId.value = result.data!.conversationId;
      conversationMemoryFacts.assignAll(result.data!.memoryFacts);
      recentMistakeTags.assignAll(result.data!.recentMistakeTags);

      final AiTutorMessageModel responseMessage = result.data!.message;
      if (!_hasUsableAssistantText(responseMessage.primary)) {
        textMessages.add(
          AiTutorMessageModel.assistant(_invalidAssistantResponseMessage()),
        );
        return;
      }
      textMessages.add(responseMessage);
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

    final String speechText = isWritingHelpSession &&
            message.italianSpeechText?.trim().isNotEmpty == true
        ? message.italianSpeechText!.trim()
        : message.primary.trim();

    await _ttsService.stop();
    speakingMessageId.value = message.id;
    try {
      await _ttsService.speakItalian(speechText);
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
    textChatMode.value = AiTutorChatMode.general;
    writingSourceLanguage.value = null;
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

    await _userSessionController.refreshAiBalances();
    if (_userSessionController.aiVoiceSeconds <= 0) {
      isVoiceBalanceExhausted.value = true;
      voiceService.connectionState.value = AiTutorVoiceConnectionState.error;
      voiceService.status.value = 'No AI voice time remaining';
      Get.snackbar(
        'AI Voice Balance',
        'You do not have any AI voice time remaining.',
      );
      return;
    }

    isStartingVoiceSession.value = true;
    isVoiceBalanceExhausted.value = false;
    AiTutorVoiceSessionModel? createdSession;
    try {
      final ApiResult<AiTutorVoiceSessionModel> result =
          await ApiErrorHandler.call<AiTutorVoiceSessionModel>(
        () => _apiService.startVoiceSession(
          topic: _activeVoiceTopic,
          ttlSeconds: min(_userSessionController.aiVoiceSeconds, 3600),
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
      remainingVoiceSeconds.value = createdSession.allocatedSeconds;
      _applyAiBalances(createdSession.balances);
      await voiceService.connect(createdSession);
      await _sendVoiceHeartbeat();
      _startVoiceUsageTimers();
    } catch (_) {
      if (createdSession != null) {
        final ApiResult<AiTutorBalanceModel> endResult =
            await ApiErrorHandler.call<AiTutorBalanceModel>(
          () => _apiService.endVoiceSession(createdSession!.sessionId),
          showError: false,
        );
        if (endResult.data != null) {
          _applyAiBalances(endResult.data!);
        }
      }
      _activeVoiceSession = null;
      _stopVoiceUsageTimers();
    } finally {
      isStartingVoiceSession.value = false;
    }
  }

  void _startVoiceUsageTimers() {
    _stopVoiceUsageTimers();
    _voiceCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeVoiceSession == null || !voiceService.isConnected) return;
      if (remainingVoiceSeconds.value > 0) {
        remainingVoiceSeconds.value--;
      }
      if (remainingVoiceSeconds.value <= 0) {
        unawaited(_handleVoiceBalanceExhausted());
      }
    });
    _voiceHeartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_sendVoiceHeartbeat());
    });
  }

  void _stopVoiceUsageTimers() {
    _voiceCountdownTimer?.cancel();
    _voiceCountdownTimer = null;
    _voiceHeartbeatTimer?.cancel();
    _voiceHeartbeatTimer = null;
  }

  Future<void> _sendVoiceHeartbeat() async {
    final AiTutorVoiceSessionModel? session = _activeVoiceSession;
    if (session == null || _isSendingVoiceHeartbeat || _isEndingVoiceSession) {
      return;
    }

    _isSendingVoiceHeartbeat = true;
    try {
      final ApiResult<AiTutorVoiceHeartbeatModel> result =
          await ApiErrorHandler.call<AiTutorVoiceHeartbeatModel>(
        () => _apiService.heartbeatVoiceSession(session.sessionId),
        showError: false,
      );
      if (!result.isSuccess || result.data == null) return;

      final AiTutorVoiceHeartbeatModel heartbeat = result.data!;
      remainingVoiceSeconds.value = heartbeat.sessionRemainingSeconds;
      _applyAiBalances(heartbeat.balances);
      if (heartbeat.shouldEnd || !heartbeat.active) {
        await _handleVoiceBalanceExhausted();
      }
    } finally {
      _isSendingVoiceHeartbeat = false;
    }
  }

  Future<void> _handleVoiceBalanceExhausted() async {
    if (_isEndingVoiceSession) return;
    isVoiceBalanceExhausted.value = true;
    voiceService.status.value = 'AI voice time finished';
    await endLiveVoiceSession();
  }

  Future<void> retryLiveVoice() async {
    await endLiveVoiceSession();
    await ensureLiveVoiceConnected();
  }

  Future<void> toggleLiveVoiceMute() async {
    await voiceService.toggleMute();
  }

  Future<void> endLiveVoiceSession() async {
    if (_isEndingVoiceSession) return;
    _isEndingVoiceSession = true;
    final AiTutorVoiceSessionModel? session = _activeVoiceSession;
    _activeVoiceSession = null;
    _stopVoiceUsageTimers();
    try {
      await voiceService.disconnect();
      if (session != null) {
        final ApiResult<AiTutorBalanceModel> result =
            await ApiErrorHandler.call<AiTutorBalanceModel>(
          () => _apiService.endVoiceSession(session.sessionId),
          showError: false,
        );
        if (result.data != null) {
          _applyAiBalances(result.data!);
        } else {
          await _userSessionController.refreshAiBalances();
        }
      }
    } finally {
      _isEndingVoiceSession = false;
    }
  }

  void _applyAiBalances(AiTutorBalanceModel balances) {
    _userSessionController.updateAiBalances(
      voiceSeconds: balances.voiceSeconds,
      textTokens: balances.textTokens,
    );
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

  void openWritingHelp(AiTutorWritingSourceLanguage sourceLanguage) {
    resetTextConversation();
    textChatMode.value = AiTutorChatMode.writingHelp;
    writingSourceLanguage.value = sourceLanguage;
    isTextConversationActive.value = true;
    textMessages.add(
      AiTutorMessageModel.assistant(_writingHelpWelcome(sourceLanguage)),
    );
    Get.to<void>(
      () => const AiTutorWritingHelpView(),
      transition: Transition.rightToLeft,
    );
  }

  Future<bool> handleWritingHelpSystemBack() async {
    resetTextConversation();
    return true;
  }

  void closeWritingHelpPage() {
    resetTextConversation();
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<void>();
    }
  }

  String _writingHelpWelcome(AiTutorWritingSourceLanguage sourceLanguage) {
    switch (sourceLanguage) {
      case AiTutorWritingSourceLanguage.english:
        return 'Send a word, sentence, or Italian draft. I will show the '
            'natural Italian writing and explain the main point briefly in English.';
      case AiTutorWritingSourceLanguage.bangla:
        return 'একটি শব্দ, বাক্য বা ইতালীয় খসড়া লিখুন। আমি স্বাভাবিক '
            'ইতালীয় লেখাটি দেখাব এবং মূল বিষয়টি বাংলায় সংক্ষেপে বুঝিয়ে দেব।';
    }
  }

  bool _hasUsableAssistantText(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return false;
    }
    return !(text.startsWith('{') &&
        text.endsWith('}') &&
        text.contains('"primary"'));
  }

  String _invalidAssistantResponseMessage() {
    if (!isWritingHelpSession) {
      return 'I could not prepare a response. Please try again.';
    }
    switch (writingSourceLanguage.value) {
      case AiTutorWritingSourceLanguage.bangla:
        return 'লেখার উত্তরটি তৈরি করা যায়নি। শব্দ বা বাক্যটি আবার পাঠান।';
      case AiTutorWritingSourceLanguage.english:
      case null:
        return 'I could not prepare the writing answer. Please send the word or sentence again.';
    }
  }

  void onRecentSessionTap() {
    Get.snackbar('Recent Sessions', 'This feature is coming soon.');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopVoiceUsageTimers();
    unawaited(endLiveVoiceSession());
    unawaited(_ttsService.dispose());
    inputController.dispose();
    super.onClose();
  }
}
