import 'dart:async';

import 'package:get/get.dart';

import '../../features/leaderboard/models/leaderboard_models.dart';
import '../../features/leaderboard/services/leaderboard_service.dart';
import '../controllers/user_session_controller.dart';

class AppDrawerController extends GetxController {
  AppDrawerController({
    required UserSessionController userSessionController,
    required LeaderboardService leaderboardService,
  }) : _userSessionController = userSessionController,
       _leaderboardService = leaderboardService;

  final UserSessionController _userSessionController;
  final LeaderboardService _leaderboardService;
  final RxString _leagueLabel = 'BRONZE'.obs;

  RxBool get isLoading => _userSessionController.isLoading;

  String get displayName => _userSessionController.displayName;
  String get leagueLabel => _leagueLabel.value;
  String? get avatarUrl => _userSessionController.avatarUrl;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshProfile());
  }

  Future<void> refreshProfile({bool showError = false}) async {
    await _userSessionController.loadUser(
      forceRefresh: true,
      showError: showError,
    );

    final ProfileModel? leaderboardProfile =
        await _leaderboardService.fetchMe();
    final String leagueName = leaderboardProfile?.league.name.trim() ?? '';
    if (leagueName.isNotEmpty) {
      _leagueLabel.value = leagueName.toUpperCase();
    }
  }

  void updateLeague(String leagueName) {
    final String value = leagueName.trim();
    if (value.isNotEmpty) {
      _leagueLabel.value = value.toUpperCase();
    }
  }

  void clear() {
    _leagueLabel.value = 'BRONZE';
    _userSessionController.clear();
  }
}
