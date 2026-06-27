import 'package:dio/dio.dart';

import '../../../core/models/learning_activity_models.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/learning_activity_api_service.dart';
import '../models/home_models.dart';

class HomeApiService {
  HomeApiService({
    required ApiClient apiClient,
    required LearningActivityApiService learningActivityApiService,
  }) : _apiClient = apiClient,
       _learningActivityApiService = learningActivityApiService;

  final ApiClient _apiClient;
  final LearningActivityApiService _learningActivityApiService;

  Future<HomeOverviewModel> fetchWeeklyOverview() async {
    final WeeklyLearningActivityModel result =
        await _learningActivityApiService.getWeeklySummary(
          weekStart: _currentWeekStart(),
        );
    final String today = _dateOnly(DateTime.now());
    return HomeOverviewModel(
      totalSeconds: result.totalSeconds,
      days: result.days
          .map(
            (LearningActivityDayModel day) => HomeActivityModel(
              date: day.date,
              dayLabel: day.dayLabel,
              durationSeconds: day.durationSeconds,
              isToday: day.date == today,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<HomeChapterModel?> fetchCurrentChapter() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/learning-progress/current-chapter',
    );
    if (response.data == null) return null;
    return HomeChapterModel.fromJson(_responseMap(response));
  }

  Future<List<HomeWorkItemModel>> fetchCareerTracks() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/skill-builder/career-tracks',
      queryParameters: <String, dynamic>{'page': 1, 'limit': 8},
    );
    final Map<String, dynamic> body = _responseMap(response);
    final dynamic rawItems = body['items'];
    if (rawItems is! List) return <HomeWorkItemModel>[];
    return rawItems
        .whereType<Map>()
        .map(
          (Map item) => HomeWorkItemModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<HomeWebinarModel?> fetchNextWebinar() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/webinars/upcoming',
      queryParameters: <String, dynamic>{'page': 1, 'limit': 1},
    );
    final dynamic rawItems = _responseMap(response)['webinars'];
    if (rawItems is! List || rawItems.isEmpty || rawItems.first is! Map) {
      return null;
    }
    return HomeWebinarModel.fromJson(
      Map<String, dynamic>.from(rawItems.first as Map),
    );
  }

  Future<HomeDailyChallengesModel> fetchDailyChallenges() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/daily-challenges/today',
    );
    final Map<String, dynamic> body = _responseMap(response);
    final dynamic rawTasks = body['tasks'];
    final List<dynamic> tasks = rawTasks is List ? rawTasks : <dynamic>[];
    final int completed = tasks.where((dynamic item) {
      if (item is! Map) return false;
      final String status = item['status']?.toString() ?? '';
      return status == 'completed' || status == 'claimed';
    }).length;
    return HomeDailyChallengesModel(
      label: 'DAILY CHALLENGES',
      completed: completed,
      total: tasks.length,
    );
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object.',
    );
  }

  String _currentWeekStart() {
    final DateTime now = DateTime.now();
    final DateTime monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));
    return _dateOnly(monday);
  }

  String _dateOnly(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
