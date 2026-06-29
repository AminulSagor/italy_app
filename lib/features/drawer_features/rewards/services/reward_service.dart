import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class RewardService {
  RewardService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final response = await _apiClient.dio.get('/rewards/dashboard');
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data['data'] is Map<String, dynamic> 
            ? Map<String, dynamic>.from(data['data'])
            : Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> fetchHistory({
    int page = 1,
    int limit = 20,
    String? status,
    String? rewardType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (rewardType != null && rewardType.isNotEmpty) queryParams['rewardType'] = rewardType;

      final response = await _apiClient.dio.get('/rewards/history', queryParameters: queryParams);
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> fetchRewardDetails(String id) async {
    try {
      final response = await _apiClient.dio.get('/rewards/$id');
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
         return data['data'] is Map<String, dynamic> 
            ? Map<String, dynamic>.from(data['data'])
            : Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> markAsSeen(String id) async {
    try {
      final response = await _apiClient.dio.post('/rewards/$id/seen');
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> openReward(String id) async {
    try {
      final response = await _apiClient.dio.post('/rewards/$id/open');
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
         return data['data'] is Map<String, dynamic> 
            ? Map<String, dynamic>.from(data['data'])
            : Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> getDownload(String id) async {
    try {
      final response = await _apiClient.dio.get('/rewards/$id/download');
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return null;
  }

  Future<bool> saveShippingAddress(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.put('/rewards/$id/shipping-address', data: payload);
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmDelivery(String id) async {
    try {
      final response = await _apiClient.dio.post('/rewards/$id/confirm-delivery');
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }
}
