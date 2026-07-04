import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/services/api_client.dart';
import '../models/pro_checkout_models.dart';

class ProCheckoutApiService {
  ProCheckoutApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const Uuid _uuid = Uuid();
  final ApiClient _apiClient;

  Future<ProOrderModel> fetchOrderSummary({
    required String courseId,
    required String fallbackCourseName,
    required int lessonCount,
  }) async {
    final List<Response<dynamic>> responses = await Future.wait(
      <Future<Response<dynamic>>>[
        _fetchQuote(courseId, 'EUR'),
        _fetchQuote(courseId, 'BDT'),
      ],
    );

    final Map<String, dynamic> eur = _responseMap(responses[0]);
    final Map<String, dynamic> bdt = _responseMap(responses[1]);
    final Map<String, dynamic> course = proJsonMap(eur['course']);
    final Map<String, dynamic> product = proJsonMap(eur['storeProduct']);
    final String courseName = _stringValue(course['title']).isEmpty
        ? fallbackCourseName
        : _stringValue(course['title']);
    final int discountPercentage = _intValue(eur['discountPercentage']);

    if (product.isEmpty || _stringValue(product['productId']).isEmpty) {
      throw DioException(
        requestOptions: responses[0].requestOptions,
        message: 'Google Play product mapping is missing for this course.',
      );
    }

    return ProOrderModel(
      courseId: courseId,
      courseName: courseName,
      lessonCount: lessonCount,
      appName: 'Italir Pothe',
      headline: 'Unlock $courseName',
      description: 'Get full access to all $lessonCount lessons in $courseName.',
      trustedLabel: 'SECURE GOOGLE PLAY PURCHASE',
      plan: ProPlanModel(
        title: courseName,
        subtitle: '$lessonCount lessons • lifetime access',
        eurPrice: _formatPrice(ProCurrency.eur, eur['payableAmount']),
        eurOldPrice: _formatPrice(ProCurrency.eur, eur['originalAmount']),
        bdtPrice: _formatPrice(ProCurrency.bdt, bdt['payableAmount']),
        bdtOldPrice: _formatPrice(ProCurrency.bdt, bdt['originalAmount']),
        discountLabel:
            discountPercentage > 0 ? '$discountPercentage% OFF' : 'GOOGLE PLAY',
      ),
      features: <ProFeatureModel>[
        ProFeatureModel(
          title: 'All $lessonCount\nLessons',
          iconName: 'school',
          tone: 'green',
        ),
        const ProFeatureModel(
          title: 'Course\nResources',
          iconName: 'description',
          tone: 'blue',
        ),
        const ProFeatureModel(
          title: 'Progress\nTracking',
          iconName: 'smart_toy',
          tone: 'orange',
        ),
        const ProFeatureModel(
          title: 'Final Exam &\nCertificate',
          iconName: 'workspace_premium',
          tone: 'purple',
        ),
      ],
      storeProduct: ProStoreProductModel.fromJson(product),
    );
  }

  Future<ProPendingGooglePlayPurchaseModel> createGooglePlayOrder({
    required ProOrderModel order,
    required ProCurrency currency,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/course-commerce/orders',
      data: <String, dynamic>{
        'courseId': order.courseId,
        'paymentProvider': 'google_play',
        'productId': order.storeProduct.productId,
        'currency': currency == ProCurrency.bdt ? 'BDT' : 'EUR',
        'idempotencyKey': _uuid.v4(),
      },
    );
    final Map<String, dynamic> body = _responseMap(response);
    final String orderId = _stringValue(body['id']);
    if (orderId.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Course purchase order ID is missing.',
      );
    }

    return ProPendingGooglePlayPurchaseModel(
      courseId: order.courseId,
      orderId: orderId,
      orderNumber: _stringValue(body['orderNumber'], fallback: orderId),
      productId: order.storeProduct.productId,
      createdAt: DateTime.now(),
    );
  }

  Future<ProPurchaseResultModel> verifyGooglePlayPurchase({
    required ProPendingGooglePlayPurchaseModel pending,
    required String purchaseToken,
    required String transactionId,
    required String courseName,
    required int lessonCount,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/course-commerce/orders/${pending.orderId}/google-play/verify',
      data: <String, dynamic>{
        'productId': pending.productId,
        'purchaseToken': purchaseToken,
        if (transactionId.isNotEmpty) 'transactionId': transactionId,
      },
    );
    final Map<String, dynamic> body = _responseMap(response);
    final Map<String, dynamic> order = proJsonMap(body['order']);
    return _purchaseResult(
      order: order,
      fallbackOrderNumber: pending.orderNumber,
      courseName: courseName,
      lessonCount: lessonCount,
    );
  }

  Future<ProPurchaseResultModel?> recoverCompletedOrder({
    required ProPendingGooglePlayPurchaseModel pending,
    required String courseName,
    required int lessonCount,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/course-commerce/orders/${pending.orderId}',
    );
    final Map<String, dynamic> order = _responseMap(response);
    final String status = _stringValue(order['status']).toLowerCase();
    if (status != 'paid' && status != 'completed') return null;
    return _purchaseResult(
      order: order,
      fallbackOrderNumber: pending.orderNumber,
      courseName: courseName,
      lessonCount: lessonCount,
    );
  }

  Future<Response<dynamic>> _fetchQuote(String courseId, String currency) {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Google Play course purchases require Android.');
    }
    return _apiClient.dio.get(
      '/course-purchases/courses/$courseId/quote',
      queryParameters: <String, dynamic>{
        'currency': currency,
        'provider': 'google_play',
      },
    );
  }

  ProPurchaseResultModel _purchaseResult({
    required Map<String, dynamic> order,
    required String fallbackOrderNumber,
    required String courseName,
    required int lessonCount,
  }) {
    final String status = _stringValue(order['status'], fallback: 'paid');
    final String orderNumber = _stringValue(
      order['orderNumber'],
      fallback: fallbackOrderNumber,
    );
    return ProPurchaseResultModel(
      orderId: orderNumber,
      statusLabel: 'Status: ${_titleCase(status)}',
      title: 'Course Unlocked!',
      description:
          'You now have full access to $courseName and all $lessonCount lessons.',
      buttonLabel: 'Start Learning Now',
    );
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

  String _formatPrice(ProCurrency currency, dynamic amount) {
    final double parsed = double.tryParse(amount?.toString() ?? '') ?? 0;
    return currency == ProCurrency.bdt
        ? '৳${parsed.toStringAsFixed(2)}'
        : '€${parsed.toStringAsFixed(2)}';
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _titleCase(String value) {
    final String clean = value.trim();
    if (clean.isEmpty) return 'Completed';
    return '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
  }
}
