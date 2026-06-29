import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../models/shop_models.dart';
import '../models/shop_order_models.dart';

class ShopApiService {
  ShopApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _endpoint = '/package-store';

  Future<StoreShopModel> getShop() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '$_endpoint/shop',
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
        'currency': currency.apiValue,
        if (couponCode.trim().isNotEmpty) 'couponCode': couponCode.trim(),
      },
    );
    return StoreQuoteResponseModel.fromJson(_responseMap(response));
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

  Future<StorePurchaseCompletionModel> confirmStripeDemo({
    required String orderId,
    required String paymentIntentId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/orders/$orderId/stripe/demo-confirm',
      data: <String, dynamic>{
        'paymentIntentId': paymentIntentId,
        'demoResult': 'succeeded',
      },
    );
    return StorePurchaseCompletionModel.fromJson(_responseMap(response));
  }

  Future<StorePurchaseCompletionModel> confirmGooglePlayDemo({
    required String orderId,
    required String productId,
    required String purchaseToken,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_endpoint/orders/$orderId/google-play/demo-confirm',
      data: <String, dynamic>{
        'productId': productId,
        'purchaseToken': purchaseToken,
      },
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
      message: 'Response is not a valid JSON object.',
    );
  }
}
