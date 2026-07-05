import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/important_verb_detail_models.dart';
import '../models/important_verb_models.dart';
import 'package:get/get.dart' hide Response;

class ImportantVerbsApiService {
  ImportantVerbsApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ImportantVerbListResponseModel> fetchVerbs({
    int page = 1,
    int limit = 10,
    String? search,
    String? regularity,
    String? endingType,
    String language = 'en',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/important-verbs',
      queryParameters: _buildListQuery(
        page: page,
        limit: limit,
        search: search,
        regularity: regularity,
        endingType: endingType,
        language: language,
      ),
    );
    return ImportantVerbListResponseModel.fromJson(_responseMap(response));
  }


  Future<List<ImportantVerbSummaryModel>> fetchAllVerbs({
    String? search,
    String? regularity,
    String? endingType,
    String language = 'en',
  }) async {
    final ImportantVerbListResponseModel firstPage = await fetchVerbs(
      page: 1,
      limit: 100,
      search: search,
      regularity: regularity,
      endingType: endingType,
      language: language,
    );
    final List<ImportantVerbSummaryModel> items =
        <ImportantVerbSummaryModel>[...firstPage.items];
    for (int page = 2; page <= firstPage.meta.totalPages; page++) {
      final ImportantVerbListResponseModel response = await fetchVerbs(
        page: page,
        limit: 100,
        search: search,
        regularity: regularity,
        endingType: endingType,
        language: language,
      );
      items.addAll(response.items);
    }
    return items;
  }

  Future<List<ImportantVerbSummaryModel>> searchVerbs({
    required String query,
    int limit = 10,
    String language = 'en',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/important-verbs/search',
      queryParameters: <String, dynamic>{
        'q': query.trim(),
        'limit': limit,
        'language': language,
      },
    );
    final Map<String, dynamic> data = _responseMap(response);
    return _jsonList(data['items'])
        .map(ImportantVerbSummaryModel.fromJson)
        .toList(growable: false);
  }

  Future<ImportantVerbListResponseModel> fetchSavedVerbs({
    int page = 1,
    int limit = 10,
    String? search,
    String? regularity,
    String? endingType,
    String language = 'en',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/important-verbs/saved',
      queryParameters: _buildListQuery(
        page: page,
        limit: limit,
        search: search,
        regularity: regularity,
        endingType: endingType,
        language: language,
      ),
    );
    return ImportantVerbListResponseModel.fromJson(_responseMap(response));
  }


  Future<List<ImportantVerbSummaryModel>> fetchAllSavedVerbs({
    String? search,
    String? regularity,
    String? endingType,
    String language = 'en',
  }) async {
    final ImportantVerbListResponseModel firstPage = await fetchSavedVerbs(
      page: 1,
      limit: 100,
      search: search,
      regularity: regularity,
      endingType: endingType,
      language: language,
    );
    final List<ImportantVerbSummaryModel> items =
        <ImportantVerbSummaryModel>[...firstPage.items];
    for (int page = 2; page <= firstPage.meta.totalPages; page++) {
      final ImportantVerbListResponseModel response = await fetchSavedVerbs(
        page: page,
        limit: 100,
        search: search,
        regularity: regularity,
        endingType: endingType,
        language: language,
      );
      items.addAll(response.items);
    }
    return items;
  }

  Future<ImportantVerbDetailModel> fetchVerbDetails({
    required String verbId,
    String language = 'en',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/important-verbs/$verbId',
      queryParameters: <String, dynamic>{'language': language},
    );
    return ImportantVerbDetailModel.fromJson(_responseMap(response));
  }

  Future<void> saveVerb({required String verbId}) async {
    await _apiClient.dio.post('/important-verbs/$verbId/save');
  }

  Future<void> removeSavedVerb({required String verbId}) async {
    await _apiClient.dio.delete('/important-verbs/$verbId/save');
  }

  Future<void> markVerbReviewed({required String verbId}) async {
    await _apiClient.dio.post(
      '/important-verbs/$verbId/reviewed',
      data: <String, dynamic>{
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Map<String, dynamic> _buildListQuery({
    required int page,
    required int limit,
    required String language,
    String? search,
    String? regularity,
    String? endingType,
  }) {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      'language': language,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (regularity != null && regularity.isNotEmpty)
        'regularity': regularity,
      if (endingType != null && endingType.isNotEmpty)
        'endingType': endingType,
    };
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

  List<Map<String, dynamic>> _jsonList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
