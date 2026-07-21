import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';

class HomeController extends GetxController
    with WidgetsBindingObserver {
  HomeController({
    required HomeApiService homeApiService,
  }) : _homeApiService = homeApiService;

  static const String _fallbackCommunityUrl =
      'https://www.facebook.com/groups/1816913385931720';

  /*
   * Prevents automatic refresh calls from repeatedly hitting
   * the backend when the user quickly changes tabs.
   */
  static const Duration _automaticRefreshInterval =
  Duration(seconds: 30);

  final HomeApiService _homeApiService;

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
  }

  @override
  void onReady() {
    super.onReady();

    unawaited(
      loadDashboard(
        force: true,
      ),
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

  Future<void> loadDashboard({
    bool force = false,
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
      final ApiResult<HomeDashboardModel> result =
      await ApiErrorHandler.call<HomeDashboardModel>(
        _homeApiService.fetchDashboard,
        showError: false,
      );

      if (isClosed) {
        return;
      }

      final HomeDashboardModel? data = result.data;

      if (!result.isSuccess || data == null) {
        errorMessage.value =
            'home_dashboard_load_failed'.tr;
        return;
      }

      dashboard.value = data;
      hasLoadedOnce.value = true;
      errorMessage.value = '';
      _lastSuccessfulLoadAt = DateTime.now();
    } catch (error, stackTrace) {
      dev.log(
        'Failed to load the Home dashboard',
        name: 'HomeController',
        error: error,
        stackTrace: stackTrace,
      );

      if (!isClosed) {
        errorMessage.value =
            'home_dashboard_load_failed'.tr;
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

  Future<void> openCommunity() async {
    final Uri? communityUri =
    _resolveCommunityUri();

    if (communityUri == null) {
      _showCommunityLaunchFailure();
      return;
    }

    try {
      final bool launched = await launchUrl(
        communityUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showCommunityLaunchFailure();
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to open Facebook community: $communityUri',
        name: 'HomeController',
        error: error,
        stackTrace: stackTrace,
      );

      _showCommunityLaunchFailure();
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

  Uri? _resolveCommunityUri() {
    final String configuredUrl =
        dotenv.env['FACEBOOK_COMMUNITY_URL']
            ?.trim() ??
            '';

    final String url = configuredUrl.isEmpty
        ? _fallbackCommunityUrl
        : configuredUrl;

    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' &&
            uri.scheme != 'http')) {
      dev.log(
        'Invalid FACEBOOK_COMMUNITY_URL: $url',
        name: 'HomeController',
      );

      return null;
    }

    return uri;
  }

  void _showCommunityLaunchFailure() {
    Get.snackbar(
      'community'.tr,
      'unable_to_open_the_facebook_community'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}