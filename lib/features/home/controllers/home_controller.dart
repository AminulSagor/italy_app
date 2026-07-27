import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/user_session_controller.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/notification_permission_service.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';
import '../services/home_dashboard_cache_service.dart';
import '../views/guide_video_view.dart';

class HomeController extends GetxController
    with WidgetsBindingObserver {
  HomeController({
    required HomeApiService homeApiService,
    required HomeDashboardCacheService
    homeDashboardCacheService,
    required UserSessionController userSessionController,
  })  : _homeApiService = homeApiService,
        _homeDashboardCacheService =
            homeDashboardCacheService,
        _userSessionController = userSessionController;

  final HomeDashboardCacheService
  _homeDashboardCacheService;

  final UserSessionController _userSessionController;

  static const String _fallbackWhatsAppNumber = '393510066920';

  /*
   * Prevents automatic refresh calls from repeatedly hitting
   * the backend when the user quickly changes tabs.
   */
  static const Duration _automaticRefreshInterval =
  Duration(seconds: 30);

  final HomeApiService _homeApiService;

  final NotificationPermissionService
  _notificationPermissionService =
  NotificationPermissionService();

  /*
   * Existing UI can continue using isLoading.
   *
   * isInitialLoading:
   * First dashboard request where no dashboard data has loaded.
   *
   * isRefreshing:
   * Dashboard already exists, but new data is being requested.
   */
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasLoadedOnce = false.obs;

  /*
   * The Home view should show a Retry state when this contains
   * a message and no successful dashboard has loaded yet.
   */
  final RxString errorMessage = ''.obs;

  final Rx<HomeDashboardModel> dashboard =
      HomeDashboardModel.initial.obs;

  bool _requestInProgress = false;
  DateTime? _lastSuccessfulLoadAt;

  bool get isInitialLoading =>
      isLoading.value && !hasLoadedOnce.value;

  bool get hasError => errorMessage.value.isNotEmpty;

  bool get hasDashboard =>
      hasLoadedOnce.value && !hasError;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    isLoading.value = true;

    unawaited(_initializeDashboard());
  }

  @override
  void onReady() {
    super.onReady();

    unawaited(
      _notificationPermissionService
          .requestAfterHomeShown(),
    );
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    /*
     * Refresh when the application returns from the background.
     *
     * The refresh interval prevents duplicate requests when the
     * user briefly opens another application.
     */
    unawaited(loadDashboard());
  }

  Future<void> _initializeDashboard() async {
    final Stopwatch stopwatch = Stopwatch()..start();

    dev.log(
      'Home initialization started: ${stopwatch.elapsedMilliseconds}ms',
      name: 'HomePerformance',
    );

    final bool restored = await _restoreCachedDashboard();

    dev.log(
      'Cache restore finished: ${stopwatch.elapsedMilliseconds}ms',
      name: 'HomePerformance',
    );

    if (isClosed) {
      return;
    }

    if (restored) {
      isLoading.value = false;
    }

    await loadDashboard(
      force: true,
      performanceStopwatch: stopwatch,
    );

    dev.log(
      'Home initialization completed: ${stopwatch.elapsedMilliseconds}ms',
      name: 'HomePerformance',
    );
  }

  Future<bool> _restoreCachedDashboard() async {
    final String userId = _currentUserId;

    if (userId.isEmpty) {
      return false;
    }

    final HomeDashboardCacheEntry? cache =
    await _homeDashboardCacheService.read(
      userId: userId,
    );

    if (cache == null || isClosed) {
      return false;
    }

    try {
      dashboard.value =
          HomeDashboardModel.fromJson(cache.json);

      hasLoadedOnce.value = true;
      errorMessage.value = '';
      _lastSuccessfulLoadAt = cache.cachedAt;

      return true;
    } catch (error, stackTrace) {
      dev.log(
        'Failed to restore cached Home dashboard',
        name: 'HomeController',
        error: error,
        stackTrace: stackTrace,
      );

      await _homeDashboardCacheService.clear(
        userId: userId,
      );

      return false;
    }
  }

  String get _currentUserId {
    return _userSessionController.user.value?.id.trim() ??
        '';
  }



  Future<void> loadDashboard({
    bool force = false,
    Stopwatch? performanceStopwatch,
  }) async {
    if (_requestInProgress) {
      return;
    }

    if (!force && !_dashboardNeedsRefresh) {
      return;
    }

    _requestInProgress = true;
    errorMessage.value = '';

    if (hasLoadedOnce.value) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      dev.log(
        'Home API started: '
            '${performanceStopwatch?.elapsedMilliseconds ?? 0}ms',
        name: 'HomePerformance',
      );

      final Stopwatch apiStopwatch = Stopwatch()..start();

      final ApiResult<Map<String, dynamic>> result =
      await ApiErrorHandler.call<Map<String, dynamic>>(
        _homeApiService.fetchDashboardJson,
        showError: false,
      );

      apiStopwatch.stop();

      dev.log(
        'Home API finished in ${apiStopwatch.elapsedMilliseconds}ms. '
            'Total: ${performanceStopwatch?.elapsedMilliseconds ?? 0}ms',
        name: 'HomePerformance',
      );

      if (isClosed) {
        return;
      }

      final Map<String, dynamic>? responseJson = result.data;

      if (!result.isSuccess || responseJson == null) {
        errorMessage.value = 'home_dashboard_load_failed'.tr;
        return;
      }

      final Stopwatch parsingStopwatch = Stopwatch()..start();

      final HomeDashboardModel data =
      HomeDashboardModel.fromJson(responseJson);

      parsingStopwatch.stop();

      dev.log(
        'Home JSON parsing finished in '
            '${parsingStopwatch.elapsedMilliseconds}ms',
        name: 'HomePerformance',
      );

      dashboard.value = data;
      hasLoadedOnce.value = true;
      errorMessage.value = '';
      _lastSuccessfulLoadAt = DateTime.now();

      dev.log(
        'Home data assigned to UI. Total: '
            '${performanceStopwatch?.elapsedMilliseconds ?? 0}ms',
        name: 'HomePerformance',
      );

      final String userId = _currentUserId;

      if (userId.isNotEmpty) {
        unawaited(
          _homeDashboardCacheService.write(
            userId: userId,
            json: responseJson,
          ),
        );
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to load the Home dashboard',
        name: 'HomeController',
        error: error,
        stackTrace: stackTrace,
      );

      if (!isClosed) {
        errorMessage.value = 'home_dashboard_load_failed'.tr;
      }
    } finally {
      _requestInProgress = false;

      if (!isClosed) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  /*
   * Use this from RefreshIndicator.
   */
  Future<void> refreshDashboard() async {
    await loadDashboard(
      force: true,
    );
  }

  /*
   * Call this when the Home bottom-navigation tab is selected.
   *
   * It refreshes only when the previously loaded data is stale.
   */
  void onHomeTabSelected() {
    unawaited(loadDashboard());
  }

  /*
   * Call this after completing a lesson, quiz, challenge,
   * purchase, or another action that changes Home information.
   */
  Future<void> reloadAfterProgressChange() async {
    await loadDashboard(
      force: true,
    );
  }

  void clearDashboardError() {
    errorMessage.value = '';
  }

  void openCurrentChapter() {
    final HomeChapterModel? chapter =
        dashboard.value.currentChapter;

    if (chapter == null) {
      return;
    }

    if (chapter.lessonId.isEmpty ||
        chapter.courseId.isEmpty ||
        chapter.chapterId.isEmpty) {
      Get.snackbar(
        'continue_learning'.tr,
        'home_chapter_unavailable'.tr,
      );
      return;
    }

    Get.toNamed<void>(
      AppRoutes.chapterDetail,
      arguments: HomeChapterRouteArguments(
        lessonId: chapter.lessonId,
        courseId: chapter.courseId,
        chapterId: chapter.chapterId,
        title: chapter.lessonTitle,
        subtitle: chapter.chapterTitle.isNotEmpty
            ? chapter.chapterTitle
            : chapter.subtitle,
        progress: chapter.progress,
      ),
    );
  }

  void openQuickTool(HomeToolModel tool) {
    switch (tool.type) {
      case HomeToolType.cvBuilder:
        openCvBuilder();
        return;

      case HomeToolType.guideVideo:
        final String videoId =
            tool.videoId?.trim() ?? '';

        if (videoId.isEmpty) {
          Get.snackbar(
            'guide_video'.tr,
            'guide_video_unavailable'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        Get.to<void>(
              () => GuideVideoView(
            videoId: videoId,
          ),
          transition: Transition.cupertino,
        );
        return;
    }
  }

  void openCvBuilder() {
    if (!Get.isRegistered<NavbarAndAppbarWrapperController>()) {
      Get.snackbar(
        'cv_services'.tr,
        'home_cv_builder_unavailable'.tr,
      );
      return;
    }

    Get.find<NavbarAndAppbarWrapperController>()
        .onBottomNavTap(4);
  }

  void openCareerTracks() {
    Get.toNamed<void>(
      AppRoutes.jobSentences,
    );
  }

  void openCareerTrack(
      HomeWorkItemModel item,
      ) {
    if (item.id.isEmpty) {
      Get.snackbar(
        'learn_for_work'.tr,
        'home_career_track_unavailable'.tr,
      );
      return;
    }

    Get.toNamed<void>(
      AppRoutes.jobDetails,
      arguments: HomeJobTrackRouteArguments(
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        iconKey: item.iconKey,
        cardColor: item.cardColor,
        moduleCount: item.moduleCount,
        sentenceCount: item.sentenceCount,
        learnedSentenceCount:
        item.learnedSentenceCount,
      ),
    );
  }

  Future<void> openWhatsAppSupport() async {
    final String configuredNumber =
        dotenv.env['SUPPORT_PHONE_INTERNATIONAL']?.trim() ?? '';

    final String phoneNumber = configuredNumber
        .replaceAll(RegExp(r'[^0-9]'), '');

    final String finalPhoneNumber = phoneNumber.isEmpty
        ? _fallbackWhatsAppNumber
        : phoneNumber;

    final Uri whatsappUri = Uri.https(
      'wa.me',
      '/$finalPhoneNumber',
      <String, String>{
        'text': 'Hello, I need help with Italir Pothe.',
      },
    );

    try {
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showWhatsAppLaunchFailure();
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to open WhatsApp support: $whatsappUri',
        name: 'HomeController',
        error: error,
        stackTrace: stackTrace,
      );

      _showWhatsAppLaunchFailure();
    }
  }

  void openWebinars() {
    Get.toNamed<void>(
      AppRoutes.webinar,
    );
  }

  void openAiTutor() {
    if (!Get.isRegistered<
        NavbarAndAppbarWrapperController>()) {
      Get.snackbar(
        'ai_tutor_1'.tr,
        'home_ai_tutor_unavailable'.tr,
      );
      return;
    }

    Get.find<NavbarAndAppbarWrapperController>()
        .onBottomNavTap(2);
  }

  void openDailyChallenges() {
    Get.toNamed<void>(
      AppRoutes.dailyChallenges,
    );
  }

  bool get _dashboardNeedsRefresh {
    if (!hasLoadedOnce.value) {
      return true;
    }

    final DateTime? lastLoad =
        _lastSuccessfulLoadAt;

    if (lastLoad == null) {
      return true;
    }

    return DateTime.now().difference(lastLoad) >=
        _automaticRefreshInterval;
  }



  void _showWhatsAppLaunchFailure() {
    Get.snackbar(
      'gen_need_help'.tr,
      'unable_to_open_whatsapp'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}