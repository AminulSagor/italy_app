import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../models/shop_models.dart';
import '../models/shop_order_models.dart';
import 'package:get/get.dart' hide Response;

class ShopApiService {
  ShopApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _endpoint = '/package-store';
  String get provider => Platform.isIOS ? 'app_store' : 'google_play';

  Future<StoreShopModel> getShop() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/shop',
      queryParameters: <String, dynamic>{'provider': provider},
    );
    return StoreShopModel.fromJson(_responseMap(response));
  }

  Future<StorePackageListResponseModel> getPackages({
    required StorePackageType packageType,
    int page = 1,
    int limit = 100,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/packages',
      queryParameters: <String, dynamic>{
        'provider': provider,
        'packageType': packageType.apiValue,
        'page': page,
        'limit': limit,
        'sortBy': 'sortOrder',
        'sortOrder': 'ASC',
      },
    );
    return StorePackageListResponseModel.fromJson(_responseMap(response));
  }

  Future<StorePackageModel> getPackage(String packageId) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/packages/$packageId',
      queryParameters: <String, dynamic>{'provider': provider},
    );
    return StorePackageModel.fromJson(_responseMap(response));
  }

  Future<StoreBalancesModel> getBalances() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/balances',
    );
    return StoreBalancesModel.fromJson(_responseMap(response));
  }

  Future<StoreQuoteResponseModel> getQuote({
    required String packageId,
    required RefillCurrency currency,
    String couponCode = '',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/packages/$packageId/quote',
      queryParameters: <String, dynamic>{
        'provider': provider,
        'currency': currency.apiValue,
        if (couponCode.trim().isNotEmpty) 'couponCode': couponCode.trim(),
      },
    );
    return StoreQuoteResponseModel.fromJson(_responseMap(response));
  }

  Future<void> cancelOrder(
    String orderId, {
    String reason = 'Checkout setup failed before Google Play opened.',
  }) async {
    await _apiClient.dio.post(
      '$_endpoint/orders/$orderId/cancel',
      data: <String, dynamic>{'reason': reason},
    );
  }

  Future<StoreOrderModel> createOrder(
    CreateStoreOrderPayloadModel payload,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/orders',
      data: payload.toJson(),
    );
    return StoreOrderModel.fromJson(_responseMap(response));
  }

  Future<StoreCheckoutResponseModel> getCheckout(String orderId) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/orders/$orderId/checkout',
    );
    return StoreCheckoutResponseModel.fromJson(_responseMap(response));
  }

  Future<StorePurchaseCompletionModel> verifyGooglePlayPurchase({
    required String orderId,
    required VerifyGooglePlayPurchasePayloadModel payload,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/orders/$orderId/google-play/verify',
      data: payload.toJson(),
    );
    return StorePurchaseCompletionModel.fromJson(_responseMap(response));
  }

  Future<StorePurchaseCompletionModel> verifyAppStorePurchase({
    required String orderId,
    required VerifyAppStorePurchasePayloadModel payload,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/orders/$orderId/app-store/verify',
      data: payload.toJson(),
    );
    return StorePurchaseCompletionModel.fromJson(_responseMap(response));
  }

  Future<StorePurchaseCompletionModel> restoreAppStoreSubscription({
    required RestoreAppStoreSubscriptionPayloadModel payload,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/app-store/restore',
      data: payload.toJson(),
    );
    return StorePurchaseCompletionModel.fromJson(_responseMap(response));
  }

  Future<StoreOrderHistoryResponseModel> getOrderHistory({
    required String category,
    required String search,
    required int page,
    int limit = 10,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/orders/history',
      queryParameters: <String, dynamic>{
        'category': category,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
        'sortBy': 'purchasedAt',
        'sortOrder': 'DESC',
      },
    );
    return StoreOrderHistoryResponseModel.fromJson(_responseMap(response));
  }

  Future<StoreOrderModel> getOrder(String orderId) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/orders/$orderId',
    );
    return StoreOrderModel.fromJson(_responseMap(response));
  }

  Future<Uint8List> downloadInvoice(String orderId) async {
    final Response<List<int>> response = await _apiClient.dio.get<List<int>>(
      '$_endpoint/orders/$orderId/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? <int>[]);
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object_1'.tr,
    );
  }
}
