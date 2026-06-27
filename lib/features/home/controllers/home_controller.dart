import 'dart:async';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/user_session_controller.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/learning_activity_tracker_service.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';

class HomeController extends GetxController {
  HomeController({
    required HomeApiService homeApiService,
    required UserSessionController userSessionController,
  }) : _homeApiService = homeApiService,
       _userSessionController = userSessionController;

  static final Uri _communityUri = Uri.parse(
    'https://www.facebook.com/groups/1816913385931720',
  );

  final HomeApiService _homeApiService;
  final UserSessionController _userSessionController;

  final RxBool isLoading = false.obs;
  final Rx<HomeDashboardModel> dashboard = HomeDashboardModel.initial.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadDashboard());
  }

  Future<void> loadDashboard({bool refresh = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      if (refresh) {
        await _userSessionController.loadUser(forceRefresh: true);
        if (Get.isRegistered<NavbarAndAppbarWrapperController>()) {
          unawaited(
            Get.find<NavbarAndAppbarWrapperController>()
                .refreshNotificationState(),
          );
        }
      } else {
        await _userSessionController.loadUser();
      }

      if (Get.isRegistered<LearningActivityTrackerService>()) {
        await Get.find<LearningActivityTrackerService>().syncPending();
      }

      await Future.wait<void>(<Future<void>>[
        _loadOverview(),
        _loadCurrentChapter(),
        _loadCareerTracks(),
        _loadWebinar(),
        _loadDailyChallenges(),
      ]);
      _applyStreak();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOverview() async {
    final ApiResult<HomeOverviewModel> result =
        await ApiErrorHandler.call<HomeOverviewModel>(
          _homeApiService.fetchWeeklyOverview,
          showError: false,
        );
    if (result.isSuccess && result.data != null) {
      dashboard.value = dashboard.value.copyWith(overview: result.data);
    }
  }

  Future<void> _loadCurrentChapter() async {
    final ApiResult<HomeChapterModel?> result =
        await ApiErrorHandler.call<HomeChapterModel?>(
          _homeApiService.fetchCurrentChapter,
          showError: false,
        );
    if (!result.isSuccess) return;
    dashboard.value = result.data == null
        ? dashboard.value.copyWith(clearCurrentChapter: true)
        : dashboard.value.copyWith(currentChapter: result.data);
  }

  Future<void> _loadCareerTracks() async {
    final ApiResult<List<HomeWorkItemModel>> result =
        await ApiErrorHandler.call<List<HomeWorkItemModel>>(
          _homeApiService.fetchCareerTracks,
          showError: false,
        );
    if (result.isSuccess && result.data != null) {
      dashboard.value = dashboard.value.copyWith(workItems: result.data);
    }
  }

  Future<void> _loadWebinar() async {
    final ApiResult<HomeWebinarModel?> result =
        await ApiErrorHandler.call<HomeWebinarModel?>(
          _homeApiService.fetchNextWebinar,
          showError: false,
        );
    if (!result.isSuccess) return;
    dashboard.value = result.data == null
        ? dashboard.value.copyWith(clearWebinar: true)
        : dashboard.value.copyWith(webinar: result.data);
  }

  Future<void> _loadDailyChallenges() async {
    final ApiResult<HomeDailyChallengesModel> result =
        await ApiErrorHandler.call<HomeDailyChallengesModel>(
          _homeApiService.fetchDailyChallenges,
          showError: false,
        );
    if (result.isSuccess && result.data != null) {
      dashboard.value = dashboard.value.copyWith(
        dailyChallenges: result.data,
      );
    }
  }

  void _applyStreak() {
    final int days = _userSessionController.currentStreakDays;
    dashboard.value = dashboard.value.copyWith(
      streak: HomeInfoCardModel(
        eyebrow: 'DAY STREAK',
        title: '$days ${days == 1 ? 'Day' : 'Days'}',
        body: days > 0
            ? 'Keep learning today!'
            : 'Start learning today!',
        actionLabel: '',
      ),
    );
  }

  void openCurrentChapter() {
    final HomeChapterModel? chapter = dashboard.value.currentChapter;
    if (chapter == null) return;
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

  void openCvBuilder() => Get.toNamed<void>(AppRoutes.cvBuilder);

  void openCareerTracks() => Get.toNamed<void>(AppRoutes.jobSentences);

  void openCareerTrack(HomeWorkItemModel item) {
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
        learnedSentenceCount: item.learnedSentenceCount,
      ),
    );
  }

  Future<void> openCommunity() async {
    final bool launched = await launchUrl(
      _communityUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      Get.snackbar('Community', 'Unable to open the Facebook community.');
    }
  }

  void openWebinars() => Get.toNamed<void>(AppRoutes.webinar);

  void openAiTutor() {
    if (!Get.isRegistered<NavbarAndAppbarWrapperController>()) return;
    Get.find<NavbarAndAppbarWrapperController>().onBottomNavTap(2);
  }

  void openDailyChallenges() =>
      Get.toNamed<void>(AppRoutes.dailyChallenges);
}
