import 'dart:async';

import 'package:get/get.dart';

import '../../features/cv_generation/controllers/cv_home_controller.dart';
import '../../features/drawer_features/rewards/reward_controller.dart';
import '../../features/drawer_features/shop/shop_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../routes/routes.dart';
import '../controllers/user_session_controller.dart';
import '../models/account_restriction_details.dart';
import 'auth_service.dart';

class NotificationDeepLinkService {
  NotificationDeepLinkService._();

  static Future<void>? _rewardRefreshFuture;
  static bool _rewardRefreshQueued = false;

  static Future<bool> open(String value) async {
    final String deepLink = value.trim();

    if (deepLink.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(deepLink);

    if (uri == null) {
      return false;
    }

    if (await openAccountRestriction(deepLink)) {
      return true;
    }

    if (_isRewardsUri(uri)) {
      await refreshRewardDataIfNeeded(deepLink);

      final String? rewardId = _extractRewardId(uri);
      if (rewardId == null || rewardId.isEmpty) {
        await Get.toNamed<void>(AppRoutes.rewards);
        return true;
      }

      await Get.toNamed<void>(AppRoutes.rewardDetails, arguments: rewardId);
      if (Get.isRegistered<RewardController>()) {
        await Get.find<RewardController>().loadRewardDetails(rewardId);
      }
      return true;
    }

    final String? attemptId = _extractFinalExamAttemptId(uri);

    if (attemptId == null || attemptId.isEmpty) {
      return false;
    }

    final String controllerTag =
        'final_exam_result_${attemptId}_'
        '${DateTime.now().microsecondsSinceEpoch}';

    await Get.toNamed<void>(
      AppRoutes.finalExamResult,
      arguments: FinalExamResultRouteArguments(
        controllerTag: controllerTag,

        // The result controller loads directly with attemptId.
        // courseId is not needed for notification navigation.
        courseId: '',
        attemptId: attemptId,
      ),
    );

    return true;
  }

  /// Refresh balances and reward screens as soon as a reward push arrives.
  /// Multiple reward pushes received together share the same refresh.
  static Future<void> refreshRewardDataIfNeeded(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !_isRewardsUri(uri)) {
      return Future<void>.value();
    }

    final Future<void>? existing = _rewardRefreshFuture;
    if (existing != null) {
      // A second grant may land while the first network refresh is in flight.
      // Run once more afterwards so a rapid batch of gifts cannot leave stale
      // balances on screen.
      _rewardRefreshQueued = true;
      return existing;
    }

    final Future<void> refresh = _runRewardRefreshLoop();
    _rewardRefreshFuture = refresh;
    return refresh.whenComplete(() {
      if (identical(_rewardRefreshFuture, refresh)) {
        _rewardRefreshFuture = null;
      }
    });
  }

  static Future<void> _runRewardRefreshLoop() async {
    do {
      _rewardRefreshQueued = false;
      await _refreshRewardData();
    } while (_rewardRefreshQueued);
  }

  static Future<void> _refreshRewardData() async {
    await Future.wait<void>(<Future<void>>[
      if (Get.isRegistered<UserSessionController>())
        Get.find<UserSessionController>()
            .loadUser(forceRefresh: true, showError: false)
            .then<void>((_) {}),
      if (Get.isRegistered<ShopController>())
        Get.find<ShopController>().refreshBalances(),
      if (Get.isRegistered<CvHomeController>() &&
          !Get.isPrepared<CvHomeController>())
        Get.find<CvHomeController>().loadHomeBootstrap(
          showBlockingLoading: false,
        ),
      if (Get.isRegistered<RewardController>())
        Get.find<RewardController>().refreshDashboard(),
      if (Get.isRegistered<HomeController>())
        Get.find<HomeController>().reloadAfterProgressChange(),
      if (Get.isRegistered<LeaderboardController>())
        Get.find<LeaderboardController>().refreshLeaderboard(),
    ]);
  }

  static bool _isRewardsUri(Uri uri) {
    final String host = uri.host.toLowerCase();
    final List<String> segments = uri.pathSegments
        .map((String segment) => segment.toLowerCase())
        .toList(growable: false);
    return host == 'rewards' ||
        (segments.isNotEmpty && segments.first == 'rewards');
  }

  static String? _extractRewardId(Uri uri) {
    if (uri.host.toLowerCase() == 'rewards') {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first.trim();
    }

    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first.toLowerCase() == 'rewards') {
      return uri.pathSegments[1].trim();
    }

    return null;
  }

  static Future<bool> openAccountRestriction(String value) async {
    final Uri? uri = Uri.tryParse(value.trim());

    if (uri == null || !_isAccountRestrictionUri(uri)) {
      return false;
    }

    final String reason = uri.queryParameters['reason']?.trim() ?? '';

    final String effectiveAtValue =
        uri.queryParameters['effectiveAt']?.trim() ?? '';

    final String caseNumberValue =
        uri.queryParameters['caseNumber']?.trim() ?? '';

    final AccountRestrictionDetails restriction = AccountRestrictionDetails(
      reason: reason.isEmpty
          ? AccountRestrictionDetails.fallback.reason
          : reason,
      effectiveAt: effectiveAtValue.isEmpty
          ? null
          : DateTime.tryParse(effectiveAtValue),
      caseNumber: caseNumberValue.isEmpty ? null : caseNumberValue,
    );

    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().logout();
    }

    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().clear();
    }

    if (Get.currentRoute != AppRoutes.accountSuspended) {
      Get.offAllNamed(AppRoutes.accountSuspended, arguments: restriction);
    }

    return true;
  }

  static bool _isAccountRestrictionUri(Uri uri) {
    final String host = uri.host.toLowerCase();

    final List<String> segments = uri.pathSegments
        .map((String segment) => segment.toLowerCase())
        .toList(growable: false);

    return host == 'account-suspended' ||
        (segments.isNotEmpty && segments.first == 'account-suspended');
  }

  static String? _extractFinalExamAttemptId(Uri uri) {
    final String host = uri.host.toLowerCase();

    final List<String> segments = uri.pathSegments.toList(growable: false);

    final List<String> normalizedSegments = segments
        .map((String segment) => segment.toLowerCase())
        .toList(growable: false);

    // Handles:
    // italirpothe://final-exams/attempts/{attemptId}/result
    if (host == 'final-exams' &&
        normalizedSegments.length >= 3 &&
        normalizedSegments[0] == 'attempts' &&
        normalizedSegments[2] == 'result') {
      return segments[1].trim();
    }

    // Also handles:
    // /final-exams/attempts/{attemptId}/result
    if (normalizedSegments.length >= 4 &&
        normalizedSegments[0] == 'final-exams' &&
        normalizedSegments[1] == 'attempts' &&
        normalizedSegments[3] == 'result') {
      return segments[2].trim();
    }

    return null;
  }
}
