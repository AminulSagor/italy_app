import 'dart:async';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';

class HomeController extends GetxController {
  HomeController({required HomeApiService homeApiService})
    : _homeApiService = homeApiService;

  static final Uri _communityUri = Uri.parse(
    'https://www.facebook.com/groups/1816913385931720',
  );

  final HomeApiService _homeApiService;

  final RxBool isLoading = false.obs;
  final Rx<HomeDashboardModel> dashboard = HomeDashboardModel.initial.obs;

  @override
  void onReady() {
    super.onReady();
    unawaited(loadDashboard());
  }

  Future<void> loadDashboard() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<HomeDashboardModel> result =
          await ApiErrorHandler.call<HomeDashboardModel>(
            _homeApiService.fetchDashboard,
            showError: false,
          );

      if (result.isSuccess && result.data != null) {
        dashboard.value = result.data!;
      }
    } finally {
      isLoading.value = false;
    }
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
