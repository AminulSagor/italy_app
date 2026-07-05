import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../models/user_block_models.dart';
import 'package:get/get.dart' hide Response;

class UserBlockApiService {
  UserBlockApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiHandledResponse<UserModel>> getUser(String id) {
    return ApiErrorHandler.handle<UserModel>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/users/$id',
        );
        final Map<String, dynamic> map = _responseMap(response);
        return UserModel.fromJson(map);
      },
      fallbackErrorCode: 'get_user_failed',
    );
  }

  Future<ApiHandledResponse<UserSearchResponseModel>> searchByName({
    required String q,
    int page = 1,
    int perPage = 20,
  }) {
    return ApiErrorHandler.handle<UserSearchResponseModel>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/users/search/name',
          queryParameters: <String, dynamic>{
            'q': q,
            'page': page,
            'perPage': perPage,
          },
        );
        final Map<String, dynamic> map = _responseMap(response);
        return UserSearchResponseModel.fromJson(map);
      },
      fallbackErrorCode: 'user_search_failed',
    );
  }

  Future<ApiHandledResponse<List<UserListItemModel>>> getAllUsers() {
    return ApiErrorHandler.handle<List<UserListItemModel>>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/users/all',
        );
        final List<dynamic> data = _responseList(response);
        return data
            .map(
              (dynamic e) => UserListItemModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      },
      fallbackErrorCode: 'get_all_users_failed',
    );
  }

  Future<ApiHandledResponse<BlockStatusModel>> getBlockStatus(
    String otherUserId,
  ) {
    return ApiErrorHandler.handle<BlockStatusModel>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/user-blocks/status/$otherUserId',
        );
        final Map<String, dynamic> map = _responseMap(response);
        return BlockStatusModel.fromJson(map);
      },
      fallbackErrorCode: 'get_block_status_failed',
    );
  }

  Future<ApiHandledResponse<UserBlockModel>> blockUser(String blockedId) {
    return ApiErrorHandler.handle<UserBlockModel>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.post(
          '/user-blocks/$blockedId',
        );
        final Map<String, dynamic> map = _responseMap(response);
        // Some APIs wrap the data in { data: { ... } }
        final Map<String, dynamic> payload = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : map;
        return UserBlockModel.fromJson(payload);
      },
      fallbackErrorCode: 'block_user_failed',
    );
  }

  Future<ApiHandledResponse<void>> unblockUser(String blockedId) {
    return ApiErrorHandler.handle<void>(
      request: () async {
        await _apiClient.dio.delete('/user-blocks/$blockedId');
        return; // void
      },
      fallbackErrorCode: 'unblock_user_failed',
    );
  }

  Future<ApiHandledResponse<List<BlockedUserItemModel>>> getBlockedUsers() {
    return ApiErrorHandler.handle<List<BlockedUserItemModel>>(
      request: () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/user-blocks',
        );
        final Map<String, dynamic> map = _responseMap(response);
        final List<dynamic> list = map['data'] as List<dynamic>? ?? <dynamic>[];
        return list
            .map(
              (dynamic e) => BlockedUserItemModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      },
      fallbackErrorCode: 'get_blocked_users_failed',
    );
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

  List<dynamic> _responseList(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is List<dynamic>) return data;
    if (data is Map && data['items'] is List<dynamic>) {
      return data['items'] as List<dynamic>;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_array'.tr,
    );
  }
}
