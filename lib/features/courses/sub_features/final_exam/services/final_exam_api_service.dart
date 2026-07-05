import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../models/final_exam_api_models.dart';
import 'package:get/get.dart' hide Response;

class FinalExamApiService {
  FinalExamApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<FinalExamGatewayModel> fetchGateway({required String courseId}) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/final-exams/courses/$courseId/gateway',
    );
    return FinalExamGatewayModel.fromJson(_responseMap(response));
  }

  Future<FinalExamAttemptModel> startAttempt({
    required String courseId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/final-exams/start',
      data: <String, dynamic>{'courseId': courseId},
    );
    final FinalExamAttemptModel attempt = FinalExamAttemptModel.fromJson(
      _responseMap(response),
    );
    return _resolveAttemptMedia(attempt);
  }

  Future<FinalExamAttemptModel> fetchAttempt({
    required String attemptId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/final-exams/attempts/$attemptId',
    );
    final FinalExamAttemptModel attempt = FinalExamAttemptModel.fromJson(
      _responseMap(response),
    );
    return _resolveAttemptMedia(attempt);
  }

  Future<FinalExamAnswerResultModel> submitAnswer({
    required String attemptId,
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/final-exams/attempts/$attemptId/answers',
      data: payload,
    );
    return FinalExamAnswerResultModel.fromJson(_responseMap(response));
  }

  Future<FinalExamSubmissionModel> submitAttempt({
    required String attemptId,
    required int totalDurationSeconds,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/final-exams/attempts/$attemptId/submit',
      data: <String, dynamic>{
        'totalDurationSeconds': totalDurationSeconds.clamp(0, 86400).toInt(),
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
    return FinalExamSubmissionModel.fromJson(_responseMap(response));
  }

  Future<FinalExamResultResponseModel> fetchResult({
    required String attemptId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/final-exams/attempts/$attemptId/result',
    );
    return FinalExamResultResponseModel.fromJson(_responseMap(response));
  }

  Future<String> uploadSpeakingAudio({
    required String filePath,
    required int durationSeconds,
  }) async {
    final File audioFile = File(filePath);
    if (!await audioFile.exists()) {
      throw StateError('Recorded audio file was not found.');
    }

    final int sizeBytes = await audioFile.length();
    if (sizeBytes <= 0) {
      throw StateError('Recorded audio file is empty.');
    }

    final String originalName = _fileName(filePath);
    const String mimeType = 'audio/mp4';

    final Response<dynamic> signedResponse = await _apiClient.dio.post(
      '/files/signed-upload-url',
      data: <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': 'exam_speaking_audio',
        'visibility': 'private',
      },
    );
    final Map<String, dynamic> signed = _responseMap(signedResponse);
    final String signedUploadUrl = _string(signed['signedUploadUrl']);
    final String storageKey = _string(signed['storageKey']);

    if (signedUploadUrl.isEmpty || storageKey.isEmpty) {
      throw StateError('Could not prepare the speaking audio upload.');
    }

    final Uint8List bytes = await audioFile.readAsBytes();
    await Dio().put<dynamic>(
      signedUploadUrl,
      data: bytes,
      options: Options(
        headers: const <String, String>{'Content-Type': mimeType},
        contentType: mimeType,
        responseType: ResponseType.plain,
      ),
    );

    final Response<dynamic> confirmResponse = await _apiClient.dio.post(
      '/files/confirm-upload',
      data: <String, dynamic>{
        'storageKey': storageKey,
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': 'exam_speaking_audio',
        'visibility': 'private',
        'mediaType': 'audio',
        'durationSeconds': durationSeconds.clamp(0, 3600).toInt(),
        'title': originalName,
      },
    );
    final Map<String, dynamic> confirmed = _responseMap(confirmResponse);
    final Map<String, dynamic> file = _map(confirmed['file']);
    final String fileId = _string(file['id']);

    if (fileId.isEmpty) {
      throw StateError('Speaking audio upload was not confirmed.');
    }
    return fileId;
  }

  Future<FinalExamAttemptModel> _resolveAttemptMedia(
    FinalExamAttemptModel attempt,
  ) async {
    final Map<String, Future<_FileMediaInfo?>> mediaRequests =
        <String, Future<_FileMediaInfo?>>{};

    final List<FinalExamSectionModel> sections = await Future.wait(
      attempt.sections.map((FinalExamSectionModel section) async {
        final List<FinalExamQuestionModel> questions = await Future.wait(
          section.questions.map((FinalExamQuestionModel question) async {
            final _FileMediaInfo? audio = question.audioFileId.isEmpty
                ? null
                : await mediaRequests.putIfAbsent(
                    question.audioFileId,
                    () => _fetchMediaInfo(question.audioFileId),
                  );
            final _FileMediaInfo? image = question.imageFileId.isEmpty
                ? null
                : await mediaRequests.putIfAbsent(
                    question.imageFileId,
                    () => _fetchMediaInfo(question.imageFileId),
                  );

            return question.copyWith(
              audioUrl: audio?.url,
              audioMimeType: audio?.mimeType,
              imageUrl: image?.url,
              imageMimeType: image?.mimeType,
            );
          }),
        );
        return section.copyWith(questions: questions);
      }),
    );

    return attempt.copyWith(sections: sections);
  }

  Future<_FileMediaInfo?> _fetchMediaInfo(String fileId) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/files/$fileId/signed-read-url',
      );
      final Map<String, dynamic> data = _responseMap(response);
      final Map<String, dynamic> file = _map(data['file']);
      final String url = _fallbackString(
        data['signedReadUrl'],
        data['publicUrl'],
      );
      if (url.isEmpty) return null;
      return _FileMediaInfo(
        url: url,
        mimeType: _string(file['mimeType']),
      );
    } on DioException {
      return null;
    }
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object'.tr,
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _fallbackString(dynamic primary, dynamic fallback) {
    final String value = _string(primary);
    return value.isNotEmpty ? value : _string(fallback);
  }

  String _fileName(String path) {
    final List<String> parts = path.split(Platform.pathSeparator);
    final String name = parts.isEmpty ? '' : parts.last.trim();
    return name.isEmpty ? 'final-exam-speaking.m4a' : name;
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
}

class _FileMediaInfo {
  final String url;
  final String mimeType;

  const _FileMediaInfo({required this.url, required this.mimeType});
}
