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
  }) {
    final CurrentUserSummary? current = user.value;
    if (current == null) return;

    user.value = current.copyWith(
      fullName: fullName,
      learnerLevel: learnerLevel,
      avatarUrl: avatarUrl,
      currentStreakDays: currentStreakDays,
    );
  }

  void clear() {
    user.value = null;
    isLoaded.value = false;
    isLoading.value = false;
  }
}
