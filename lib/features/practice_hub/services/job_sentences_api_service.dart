import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/job_sentence_models.dart';
import '../models/job_track_models.dart';

class JobSentencesApiService {
  JobSentencesApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<JobCareerTrackListResponseModel> fetchCareerTracks({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/skill-builder/career-tracks',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return JobCareerTrackListResponseModel.fromJson(_responseMap(response));
  }

  Future<JobCareerTrackDetailsModel> fetchCareerTrackDetails({
    required String trackId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/skill-builder/career-tracks/$trackId',
    );
    return JobCareerTrackDetailsModel.fromJson(_responseMap(response));
  }

  Future<JobModuleSentencesResponseModel> fetchModuleSentences({
    required String moduleId,
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/skill-builder/modules/$moduleId/sentences',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return JobModuleSentencesResponseModel.fromJson(_responseMap(response));
  }

  Future<void> reviewSentence({required String sentenceId}) async {
    await _apiClient.dio.post(
      '/skill-builder/sentences/$sentenceId/reviewed',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> recordVideoProgress({
    required String trackId,
    required int watchedPercent,
    int? timeSpentSeconds,
  }) async {
    await _apiClient.dio.post(
      '/skill-builder/career-tracks/$trackId/video-progress',
      data: <String, dynamic>{
        'watchedPercent': watchedPercent.clamp(0, 100),
        if (timeSpentSeconds != null) 'timeSpentSeconds': timeSpentSeconds,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> markTheoryOpened({required String trackId}) async {
    await _apiClient.dio.post(
      '/skill-builder/career-tracks/$trackId/theory-opened',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
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
}
