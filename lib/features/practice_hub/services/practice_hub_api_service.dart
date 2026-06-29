import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/daily_challenge_models.dart';
import '../models/practice_hub_models.dart';
import '../models/survival_italian_models.dart';

class PracticeHubApiService {
  PracticeHubApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PracticeHubOverviewModel> fetchOverview() async {
    final List<Response<dynamic>> responses = await Future.wait(
      <Future<Response<dynamic>>>[
        _apiClient.dio.get('/important-verbs/progress'),
        _apiClient.dio.get(
          '/skill-builder/career-tracks',
          queryParameters: <String, dynamic>{'page': 1, 'limit': 100},
        ),
        _apiClient.dio.get('/survival-italian/situations'),
        _apiClient.dio.get('/daily-challenges/today'),
        _apiClient.dio.get(
          '/webinars/live',
          queryParameters: <String, dynamic>{'page': 1, 'limit': 1},
        ),
        _apiClient.dio.get(
          '/webinars/upcoming',
          queryParameters: <String, dynamic>{'page': 1, 'limit': 1},
        ),
      ],
    );

    final int reviewedVerbCount = _responseList(responses[0]).length;
    final Map<String, dynamic> careerTracks = _responseMap(responses[1]);
    final SurvivalSituationsResponseModel survival =
        SurvivalSituationsResponseModel.fromJson(_responseMap(responses[2]));
    final DailyChallengeDashboardModel daily =
        DailyChallengeDashboardModel.fromJson(_responseMap(responses[3]));
    final List<Map<String, dynamic>> liveWebinars = _jsonList(
      _responseMap(responses[4])['webinars'],
    );
    final List<Map<String, dynamic>> upcomingWebinars = _jsonList(
      _responseMap(responses[5])['webinars'],
    );

    final int careerTrackCount = _intValue(
      _jsonMap(careerTracks['meta'])['total'],
      fallback: _jsonList(careerTracks['items']).length,
    );
    final Map<String, dynamic>? featuredWebinarJson = liveWebinars.isNotEmpty
        ? liveWebinars.first
        : upcomingWebinars.isNotEmpty
        ? upcomingWebinars.first
        : null;

    return PracticeHubOverviewModel(
      skillBuilders: <PracticeHubSkillBuilderModel>[
        PracticeHubSkillBuilderModel(
          type: PracticeHubSkillBuilderType.importantVerbs,
          title: 'gen_important_verbs'.tr,
          subtitle: 'gen_reviewedverbcount_reviewed'.tr.replaceFirst(
            r'$reviewedVerbCount',
            reviewedVerbCount.toString(),
          ),
        ),
        PracticeHubSkillBuilderModel(
          type: PracticeHubSkillBuilderType.survivalItalian,
          title: 'gen_survival_italian'.tr,
          subtitle: 'gen_survival_italian_progress'.tr
              .replaceFirst(
                '{completed}',
                survival.progress.completedCount.toString(),
              )
              .replaceFirst('{total}', survival.progress.totalCount.toString()),
        ),
        PracticeHubSkillBuilderModel(
          type: PracticeHubSkillBuilderType.jobSentences,
          title: 'gen_job_sentences'.tr,
          subtitle: 'gen_careertrackcount_career_tracks'.tr.replaceFirst(
            r'$careerTrackCount',
            careerTrackCount.toString(),
          ),
        ),
        PracticeHubSkillBuilderModel(
          type: PracticeHubSkillBuilderType.dailyChallenges,
          title: 'gen_daily_challenges'.tr,
          subtitle: 'gen_daily_challenges_progress'.tr
              .replaceFirst('{completed}', daily.completedTaskCount.toString())
              .replaceFirst('{total}', daily.tasks.length.toString()),
        ),
      ],
      featuredWebinar: featuredWebinarJson == null
          ? null
          : PracticeHubWebinarModel.fromJson(featuredWebinarJson),
    );
  }

  Future<List<PracticeFinalExamCourseModel>>
      fetchCurrentCourseFinalExams() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/final-exams/my-courses/gateways',
    );
    final Map<String, dynamic> body = _responseMap(response);
    return _jsonList(body['items'])
        .map(PracticeFinalExamCourseModel.fromJson)
        .where(
          (PracticeFinalExamCourseModel item) => item.courseId.isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<SurvivalSituationsResponseModel> fetchSurvivalSituations() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/survival-italian/situations',
    );
    return SurvivalSituationsResponseModel.fromJson(_responseMap(response));
  }

  Future<SurvivalSituationDetailModel> fetchSurvivalSituationDetails({
    required String situationId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/survival-italian/situations/$situationId',
    );
    return SurvivalSituationDetailModel.fromJson(_responseMap(response));
  }

  Future<void> completeSurvivalSituation({required String situationId}) async {
    await _apiClient.dio.post(
      '/survival-italian/situations/$situationId/complete',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<DailyChallengeDashboardModel> fetchDailyChallenges() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/daily-challenges/today',
    );
    DailyChallengeDashboardModel dashboard =
        DailyChallengeDashboardModel.fromJson(_responseMap(response));

    final List<DailyChallengeTaskModel> claimableTasks = dashboard.tasks
        .where((DailyChallengeTaskModel task) => task.canClaim)
        .toList(growable: false);
    for (final DailyChallengeTaskModel task in claimableTasks) {
      try {
        dashboard = await claimDailyChallengeTask(
          taskKey: task.taskKey,
          challengeDate: dashboard.challengeDate,
        );
      } on DioException {
        // Keep the dashboard usable if a claim races with another request.
      }
    }

    return dashboard;
  }

  Future<DailyChallengeDashboardModel> claimDailyChallengeTask({
    required String taskKey,
    required String challengeDate,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/daily-challenges/tasks/claim',
      data: <String, dynamic>{
        'taskKey': taskKey,
        'challengeDate': challengeDate,
      },
    );
    return DailyChallengeDashboardModel.fromJson(_responseMap(response));
  }

  Future<DailyChestRewardModel> openDailyChest({
    required String challengeDate,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/daily-challenges/chest/open',
      data: <String, dynamic>{'challengeDate': challengeDate},
    );
    return DailyChestRewardModel.fromJson(_responseMap(response));
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object',
    );
  }

  List<Map<String, dynamic>> _responseList(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is List) return _jsonList(data);
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      return _jsonList(map['items'] ?? map['data']);
    }
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _jsonList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int _intValue(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
