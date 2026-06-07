import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../models/cv_builder_models.dart';

class CvBuilderApiService {
  CvBuilderApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CvTemplateListResponseModel> getTemplates({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/cv-templates',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return CvTemplateListResponseModel.fromJson(_responseMap(response));
  }

  Future<void> saveCvDocument(CvDocumentPayloadModel payload) async {
    await _apiClient.dio.post('/cv-documents', data: payload.toJson());
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
