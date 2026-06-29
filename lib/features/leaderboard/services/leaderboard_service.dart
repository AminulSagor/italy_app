import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/token_service.dart';
import '../models/leaderboard_models.dart';

class LeaderboardService {
  LeaderboardService({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  // TokenService intentionally accepted for future use (injection kept).

  /// Fetch leaderboard view. Returns parsed LeaderboardResponseModel on success
  /// or throws on failure.
  Future<LeaderboardResponseModel> fetchLeaderboard({
    LeaderboardQueryDto dto = const LeaderboardQueryDto(),
  }) async {
    final Map<String, dynamic> params = dto.toQueryParameters();

    final Response<dynamic> response = await _apiClient.dio.get(
      '/leaderboard',
      queryParameters: params,
    );

    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return LeaderboardResponseModel.fromJson(data);
    }

    // Some backends wrap in { data: { ... } }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return LeaderboardResponseModel.fromJson(
        Map<String, dynamic>.from(data['data']),
      );
    }

    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Unexpected leaderboard response',
    );
  }

  Future<ProfileModel?> fetchMe() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/leaderboard/me',
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        final Map<String, dynamic> payload =
            data['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['data'])
            : data;
        return ProfileModel.fromJson(payload);
      }
    } catch (_) {}
    return null;
  }

  Future<List<LeagueModel>> fetchLeagues() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/leaderboard/leagues',
    );
    final dynamic data = response.data;
    final List<LeagueModel> out = <LeagueModel>[];
    if (data is List) {
      for (final dynamic item in data) {
        if (item is Map)
          out.add(LeagueModel.fromJson(Map<String, dynamic>.from(item)));
      }
      return out;
    }

    // Support the documented wrapper: { leagues: [...] }
    if (data is Map) {
      if (data['leagues'] is List) {
        for (final dynamic item in data['leagues'] as List<dynamic>) {
          if (item is Map)
            out.add(LeagueModel.fromJson(Map<String, dynamic>.from(item)));
        }
        return out;
      }

      if (data['data'] is List) {
        for (final dynamic item in data['data'] as List<dynamic>) {
          if (item is Map)
            out.add(LeagueModel.fromJson(Map<String, dynamic>.from(item)));
        }
        return out;
      }
    }

    return out;
  }

  Future<Map<String, dynamic>?> fetchPendingPromotion() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/leaderboard/promotions/pending',
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> fetchScoringGuide() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/leaderboard/scoring-guide',
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
      if (data is Map && data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<ProfileModel?> fetchUserPreview(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/leaderboard/users/$userId/preview',
      );
      final dynamic data = response.data;
      final Map<String, dynamic>? payload = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic>
                ? Map<String, dynamic>.from(data['data'])
                : Map<String, dynamic>.from(data))
          : null;
      if (payload != null) return ProfileModel.fromJson(payload);
    } catch (_) {}
    return null;
  }

  Future<bool> acknowledgePromotion(String promotionId) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.post(
        '/leaderboard/promotions/$promotionId/acknowledge',
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }
}
