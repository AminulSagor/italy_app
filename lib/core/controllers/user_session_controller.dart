import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../models/current_user_summary.dart';
import '../services/api_error_handler.dart';
import '../services/current_user_summary_service.dart';
import '../services/storage_service.dart';

class UserSessionController extends GetxService {
  UserSessionController({
    required CurrentUserSummaryService currentUserSummaryService,
    required StorageService storageService,
  })  : _currentUserSummaryService = currentUserSummaryService,
        _storageService = storageService {
    _restoreCachedUser();
  }

  static const String _cachedCurrentUserKey =
      'cached_current_user_summary_v1';

  final CurrentUserSummaryService _currentUserSummaryService;
  final StorageService _storageService;

  final Rxn<CurrentUserSummary> user = Rxn<CurrentUserSummary>();
  final RxBool isLoading = false.obs;
  final RxBool isLoaded = false.obs;

  String get displayName {
    final String value = user.value?.fullName.trim() ?? '';
    return value.isEmpty ? 'italian_learner'.tr : value;
  }

  String get levelLabel {
    final String value = user.value?.learnerLevel.trim() ?? '';
    return value.isEmpty ? 'a1'.tr : value.toUpperCase();
  }

  String? get avatarUrl => user.value?.avatarUrl;

  int get currentStreakDays => user.value?.currentStreakDays ?? 0;
  int get aiVoiceSeconds => user.value?.aiVoiceSeconds ?? 0;
  int get aiTextTokens => user.value?.aiTextTokens ?? 0;

  String get aiVoiceBalanceLabel => '${aiVoiceSeconds ~/ 60} min';

  String get aiTextBalanceLabel =>
      '${_formatCompactCount(aiTextTokens)} Tokens';

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
    if (isLoading.value) {
      return user.value;
    }

    if (isLoaded.value && !forceRefresh) {
      return user.value;
    }

    isLoading.value = true;

    try {
      final ApiResult<CurrentUserSummary> result =
      await ApiErrorHandler.call<CurrentUserSummary>(
        _currentUserSummaryService.getCurrentUser,
        showError: showError,
        errorTitle: 'gen_profile'.tr,
      );

      if (result.isSuccess && result.data != null) {
        updateUser(result.data!);
      }

      /*
       * On a temporary API failure, keep returning the cached user instead of
       * clearing the UI or blocking application startup.
       */
      return user.value;
    } finally {
      isLoading.value = false;
    }
  }

  void updateUser(CurrentUserSummary value) {
    user.value = value;
    isLoaded.value = true;

    unawaited(
      _persistUser(value),
    );
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

    if (current == null) {
      return;
    }

    updateUser(
      current.copyWith(
        fullName: fullName,
        learnerLevel: learnerLevel,
        avatarUrl: avatarUrl,
        currentStreakDays: currentStreakDays,
        aiVoiceSeconds: aiVoiceSeconds,
        aiTextTokens: aiTextTokens,
      ),
    );
  }

  Future<void> refreshAiBalances({
    bool showError = false,
  }) async {
    final ApiResult<Map<String, int>> result =
    await ApiErrorHandler.call<Map<String, int>>(
      _currentUserSummaryService.getAiBalances,
      showError: showError,
      errorTitle: 'ai_balance'.tr,
    );

    if (!result.isSuccess ||
        result.data == null ||
        user.value == null) {
      return;
    }

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

    if (current == null) {
      return;
    }

    updateUser(
      current.copyWith(
        aiVoiceSeconds: voiceSeconds.clamp(0, 1 << 31).toInt(),
        aiTextTokens: textTokens.clamp(0, 1 << 31).toInt(),
      ),
    );
  }

  void clear() {
    user.value = null;
    isLoaded.value = false;
    isLoading.value = false;

    unawaited(
      _storageService.remove(_cachedCurrentUserKey),
    );
  }

  void _restoreCachedUser() {
    final String raw =
        _storageService.readString(_cachedCurrentUserKey)?.trim() ?? '';

    if (raw.isEmpty) {
      return;
    }

    try {
      final dynamic decoded = jsonDecode(raw);

      if (decoded is! Map) {
        throw const FormatException(
          'Cached current user is not a JSON object.',
        );
      }

      final CurrentUserSummary cachedUser =
      CurrentUserSummary.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      /*
       * A user ID is required for user-specific Home dashboard caching.
       */
      if (cachedUser.id.isEmpty) {
        throw const FormatException(
          'Cached current user does not contain an ID.',
        );
      }

      user.value = cachedUser;
      isLoaded.value = true;
    } catch (_) {
      user.value = null;
      isLoaded.value = false;

      unawaited(
        _storageService.remove(_cachedCurrentUserKey),
      );
    }
  }

  Future<void> _persistUser(CurrentUserSummary value) async {
    if (value.id.trim().isEmpty) {
      return;
    }

    await _storageService.writeString(
      _cachedCurrentUserKey,
      jsonEncode(value.toJson()),
    );
  }
}
