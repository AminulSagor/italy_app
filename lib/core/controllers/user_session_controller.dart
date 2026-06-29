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

  String get aiVoiceBalanceLabel => '${aiVoiceSeconds ~/ 60} min';

  String get aiTextBalanceLabel => '${_formatCompactCount(aiTextTokens)} Tokens';

  String _formatCompactCount(int value) {
    const List<String> suffixes = <String>['', 'K', 'M', 'B', 'T', 'Q'];
    double scaledValue = value.clamp(0, 1 << 53).toDouble();
    int suffixIndex = 0;

    while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
      scaledValue /= 1000;
      suffixIndex++;
    }

    String formatted = scaledValue.toStringAsFixed(
      suffixIndex == 0 ? 0 : 1,
    );
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }

    if (formatted == '1000' && suffixIndex < suffixes.length - 1) {
      formatted = '1';
      suffixIndex++;
    }

    return '$formatted${suffixes[suffixIndex]}';
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
