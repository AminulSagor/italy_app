import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../models/reward_models.dart';
import '../models/reward_response_models.dart';

class RewardApiService {
  RewardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _endpoint = '/rewards';

  Future<RewardDashboardModel> getDashboard() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/dashboard',
    );
    return RewardDashboardModel.fromJson(_responseMap(response));
  }

  Future<RewardHistoryResponseModel> getHistory({
    int page = 1,
    int limit = 20,
    String search = '',
    RewardType? rewardType,
    String? status,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/history',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': 'createdAt',
        'sortOrder': 'DESC',
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (rewardType != null && rewardType != RewardType.unknown)
          'rewardType': rewardType.apiValue,
        if (status?.trim().isNotEmpty == true) 'status': status!.trim(),
      },
    );
    return RewardHistoryResponseModel.fromJson(_responseMap(response));
  }

  Future<RewardModel> getReward(String rewardId) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/$rewardId',
    );
    return RewardModel.fromJson(_responseMap(response));
  }

  Future<void> markSeen(String rewardId) async {
    await _apiClient.dio.post('$_endpoint/$rewardId/seen');
  }

  Future<RewardOpenResponseModel> openReward(String rewardId) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/$rewardId/open',
    );
    return RewardOpenResponseModel.fromJson(_responseMap(response));
  }

  Future<RewardModel> saveShippingAddress({
    required String rewardId,
    required RewardShippingAddressPayloadModel payload,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.put(
      '$_endpoint/$rewardId/shipping-address',
      data: payload.toJson(),
    );

    final Map<String, dynamic> data = _responseMap(response);
    return getReward(data['rewardId']?.toString() ?? rewardId);
  }

  Future<void> confirmDelivery(String rewardId) async {
    await _apiClient.dio.post('$_endpoint/$rewardId/confirm-delivery');
  }

  Future<RewardDownloadModel> getDownload(String rewardId) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/$rewardId/download',
    );
    return RewardDownloadModel.fromJson(_responseMap(response));
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
}
