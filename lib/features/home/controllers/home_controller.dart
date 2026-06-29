import 'dart:async';
import 'dart:developer' as dev;

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
  void onReady() {
    super.onReady();
    // Start network work after the wrapper has completed its first frame.
    // This keeps initial layout and plugin startup from competing with five
    // dashboard responses on lower-memory emulators.
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
        try {
          await Get.find<LearningActivityTrackerService>().syncPending();
        } catch (error, stackTrace) {
          dev.log(
            'Unable to sync pending learning activity',
            error: error,
            stackTrace: stackTrace,
            name: 'HomeController',
          );
        }
      }

      final Future<ApiResult<HomeOverviewModel>> overviewFuture =
          ApiErrorHandler.call<HomeOverviewModel>(
            _homeApiService.fetchWeeklyOverview,
            showError: false,
          );
      final Future<ApiResult<HomeChapterModel?>> currentChapterFuture =
          ApiErrorHandler.call<HomeChapterModel?>(
            _homeApiService.fetchCurrentChapter,
            showError: false,
          );
      final Future<ApiResult<List<HomeWorkItemModel>>> careerTracksFuture =
          ApiErrorHandler.call<List<HomeWorkItemModel>>(
            _homeApiService.fetchCareerTracks,
            showError: false,
          );
      final Future<ApiResult<HomeWebinarModel?>> webinarFuture =
          ApiErrorHandler.call<HomeWebinarModel?>(
            _homeApiService.fetchNextWebinar,
            showError: false,
          );
      final Future<ApiResult<HomeDailyChallengesModel>> challengesFuture =
          ApiErrorHandler.call<HomeDailyChallengesModel>(
            _homeApiService.fetchDailyChallenges,
            showError: false,
          );

      await Future.wait<dynamic>(<Future<dynamic>>[
        overviewFuture,
        currentChapterFuture,
        careerTracksFuture,
        webinarFuture,
        challengesFuture,
      ]);

      final ApiResult<HomeOverviewModel> overviewResult =
          await overviewFuture;
      final ApiResult<HomeChapterModel?> currentChapterResult =
          await currentChapterFuture;
      final ApiResult<List<HomeWorkItemModel>> careerTracksResult =
          await careerTracksFuture;
      final ApiResult<HomeWebinarModel?> webinarResult = await webinarFuture;
      final ApiResult<HomeDailyChallengesModel> challengesResult =
          await challengesFuture;

      HomeDashboardModel nextDashboard = dashboard.value;

      if (overviewResult.isSuccess && overviewResult.data != null) {
        nextDashboard = nextDashboard.copyWith(
          overview: overviewResult.data,
        );
      }

      if (currentChapterResult.isSuccess) {
        nextDashboard = currentChapterResult.data == null
            ? nextDashboard.copyWith(clearCurrentChapter: true)
            : nextDashboard.copyWith(
                currentChapter: currentChapterResult.data,
              );
      }

      if (careerTracksResult.isSuccess &&
          careerTracksResult.data != null) {
        nextDashboard = nextDashboard.copyWith(
          workItems: careerTracksResult.data,
        );
      }

      if (webinarResult.isSuccess) {
        nextDashboard = webinarResult.data == null
            ? nextDashboard.copyWith(clearWebinar: true)
            : nextDashboard.copyWith(webinar: webinarResult.data);
      }

      if (challengesResult.isSuccess && challengesResult.data != null) {
        nextDashboard = nextDashboard.copyWith(
          dailyChallenges: challengesResult.data,
        );
      }

      // Publish the whole dashboard once. Previously every response updated
      // the same Rx object independently, rebuilding the complete long home
      // page several times during a single frame window.
      dashboard.value = nextDashboard.copyWith(streak: _buildStreakCard());
    } catch (error, stackTrace) {
      dev.log(
        'Unable to load the home dashboard',
        error: error,
        stackTrace: stackTrace,
        name: 'HomeController',
      );
      dashboard.value = dashboard.value.copyWith(
        streak: _buildStreakCard(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  HomeInfoCardModel _buildStreakCard() {
    final int days = _userSessionController.currentStreakDays;
    return HomeInfoCardModel(
      eyebrow: 'DAY STREAK',
      title: '$days ${days == 1 ? 'Day' : 'Days'}',
      body: days > 0 ? 'Keep learning today!' : 'Start learning today!',
      actionLabel: '',
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
