import 'package:get/get.dart';

import '../models/current_user_summary.dart';
import '../services/api_error_handler.dart';
import '../services/current_user_summary_service.dart';

class AppDrawerController extends GetxController {
  AppDrawerController({
    required CurrentUserSummaryService currentUserSummaryService,
  }) : _currentUserSummaryService = currentUserSummaryService;

  final CurrentUserSummaryService _currentUserSummaryService;

  final Rxn<CurrentUserSummary> user = Rxn<CurrentUserSummary>();
  final RxBool isLoading = false.obs;

  String get displayName {
    final String value = user.value?.fullName.trim() ?? '';
    return value.isEmpty ? 'Italian Learner' : value;
  }

  String get levelLabel {
    final String value = user.value?.learnerLevel.trim() ?? '';
    return value.isEmpty ? 'A1' : value.toUpperCase();
  }

  String? get avatarUrl => user.value?.avatarUrl;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<void> refreshProfile({bool showError = false}) async {
    if (isLoading.value) return;

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
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    user.value = null;
  }
}
