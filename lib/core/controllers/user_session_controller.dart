import 'package:get/get.dart';

import '../models/current_user_summary.dart';
import '../services/api_error_handler.dart';
import '../services/current_user_summary_service.dart';

class UserSessionController extends GetxService {
  UserSessionController({
    required CurrentUserSummaryService currentUserSummaryService,
  }) : _currentUserSummaryService = currentUserSummaryService;

  final CurrentUserSummaryService _currentUserSummaryService;

  final Rxn<CurrentUserSummary> user = Rxn<CurrentUserSummary>();
  final RxBool isLoading = false.obs;
  final RxBool isLoaded = false.obs;

  String get displayName {
    final String value = user.value?.fullName.trim() ?? '';
    return value.isEmpty ? 'Italian Learner' : value;
  }

  String get levelLabel {
    final String value = user.value?.learnerLevel.trim() ?? '';
    return value.isEmpty ? 'A1' : value.toUpperCase();
  }

  String? get avatarUrl => user.value?.avatarUrl;

  int get currentStreakDays => user.value?.currentStreakDays ?? 0;
  int get aiVoiceSeconds => user.value?.aiVoiceSeconds ?? 0;

  int get aiTextTokens => user.value?.aiTextTokens ?? 0;

  String get aiVoiceBalanceLabel {
    final int seconds = aiVoiceSeconds;
    final int minutes = seconds ~/ 60;
    final int remainder = seconds % 60;
    if (minutes <= 0) return '${remainder}s Voice';
    if (remainder == 0) return '${minutes}m Voice';
    return '${minutes}m ${remainder}s Voice';
  }

  String get aiTextBalanceLabel {
    final int tokens = aiTextTokens;
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}m Tokens';
    }
    if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}k Tokens';
    }
    return '$tokens Tokens';
  }

  Future<CurrentUserSummary?> loadUser({
    bool forceRefresh = false,
    bool showError = false,
  }) async {
    if (isLoading.value) return user.value;
    if (isLoaded.value && !forceRefresh) return user.value;

    isLoading.value = true;
    try {
      final ApiResult<CurrentUserSummary> result =
          await ApiErrorHandler.call<CurrentUserSummary>(
            _currentUserSummaryService.getCurrentUser,
            showError: showError,
            errorTitle: 'Profile',
          );

      if (result.isSuccess && result.data != null) {
        user.value = result.data;
        isLoaded.value = true;
      }
      return user.value;
    } finally {
      isLoading.value = false;
    }
  }

  void updateUser(CurrentUserSummary value) {
    user.value = value;
    isLoaded.value = true;
  }

  void updateProfile({
    String? fullName,
    String? learnerLevel,
    String? avatarUrl,
    int? currentStreakDays,
    int? aiVoiceSeconds,
    int? aiTextTokens,
  }) {
    final CurrentUserSummary? current = user.value;
    if (current == null) return;

    user.value = current.copyWith(
      fullName: fullName,
      learnerLevel: learnerLevel,
      avatarUrl: avatarUrl,
      currentStreakDays: currentStreakDays,
      aiVoiceSeconds: aiVoiceSeconds,
      aiTextTokens: aiTextTokens,
    );
  }

  Future<void> refreshAiBalances({bool showError = false}) async {
    final ApiResult<Map<String, int>> result =
        await ApiErrorHandler.call<Map<String, int>>(
      _currentUserSummaryService.getAiBalances,
      showError: showError,
      errorTitle: 'AI Balance',
    );
    if (!result.isSuccess || result.data == null || user.value == null) return;

    updateAiBalances(
      voiceSeconds: result.data!['voiceSeconds'] ?? 0,
      textTokens: result.data!['textTokens'] ?? 0,
    );
  }

  void updateAiBalances({
    required int voiceSeconds,
    required int textTokens,
  }) {
    final CurrentUserSummary? current = user.value;
    if (current == null) return;

    user.value = current.copyWith(
      aiVoiceSeconds: voiceSeconds.clamp(0, 1 << 31).toInt(),
      aiTextTokens: textTokens.clamp(0, 1 << 31).toInt(),
    );
  }

  void clear() {
    user.value = null;
    isLoaded.value = false;
    isLoading.value = false;
  }
}
