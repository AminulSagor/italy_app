import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/course_certificate_models.dart';

class CourseCertificateApiService {
  final ApiClient _apiClient;

  CourseCertificateApiService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<CourseCertificateModel> fetchCertificateByAttemptId({
    required String attemptId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/certificates/attempt/${Uri.encodeComponent(attemptId)}',
    );

    return CourseCertificateModel.fromJson(
      _responseMap(response.data),
    );
  }

  Future<String> fetchDownloadUrl({
    required String certificateId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/certificates/${Uri.encodeComponent(certificateId)}/download-url',
    );

    final Map<String, dynamic> data = _responseMap(response.data);
    return data['signedReadUrl']?.toString() ?? '';
  }

  Map<String, dynamic> _responseMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw StateError('Certificate response is not a JSON object.');
  }
}
