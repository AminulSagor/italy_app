import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/services/api_client.dart';
import '../models/pro_checkout_models.dart';

class ProCheckoutApiService {
  ProCheckoutApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const Uuid _uuid = Uuid();

  Future<ProOrderModel> fetchOrderSummary({
    required String courseId,
    required String fallbackCourseName,
    required int lessonCount,
    String? couponCode,
  }) async {
    final String? normalizedCoupon = _nullableUpper(couponCode);
    final List<Response<dynamic>> responses = await Future.wait(
      <Future<Response<dynamic>>>[
        _fetchQuote(courseId, 'EUR', normalizedCoupon),
        _fetchQuote(courseId, 'BDT', normalizedCoupon),
      ],
    );

    final Map<String, dynamic> eur = _responseMap(responses[0]);
    final Map<String, dynamic> bdt = _responseMap(responses[1]);
    final Map<String, dynamic> course = _jsonMap(eur['course']);
    final String courseName = _stringValue(course['title']).isEmpty
        ? fallbackCourseName
        : _stringValue(course['title']);
    final int discountPercentage = _intValue(eur['discountPercentage']);

    return ProOrderModel(
      courseId: courseId,
      courseName: courseName,
      lessonCount: lessonCount,
      appName: 'Italir Pothe',
      headline: 'Unlock $courseName',
      description:
          'Get full access to all $lessonCount lessons in $courseName.',
      trustedLabel: 'SECURE COURSE PURCHASE',
      plan: ProPlanModel(
        title: courseName,
        subtitle: '$lessonCount lessons • course access',
        eurPrice: _formatPrice(
          ProCurrency.eur,
          _stringValue(eur['payableAmount']),
        ),
        eurOldPrice: _formatPrice(
          ProCurrency.eur,
          _stringValue(eur['originalAmount']),
        ),
        bdtPrice: _formatPrice(
          ProCurrency.bdt,
          _stringValue(bdt['payableAmount']),
        ),
        bdtOldPrice: _formatPrice(
          ProCurrency.bdt,
          _stringValue(bdt['originalAmount']),
        ),
        discountLabel: discountPercentage > 0
            ? '$discountPercentage% OFF'
            : 'COURSE PRICE',
        couponCode: _stringValue(eur['couponCode']),
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
    );
  }

  Future<ProPurchaseResultModel> completePurchase({
    required ProOrderModel order,
    required ProCurrency currency,
    required ProPaymentMethod paymentMethod,
    String? couponCode,
  }) async {
    final String provider = paymentMethod == ProPaymentMethod.googlePlay
        ? 'google_play'
        : 'stripe';
    final Map<String, dynamic> createPayload = <String, dynamic>{
      'courseId': order.courseId,
      'currency': currency == ProCurrency.bdt ? 'BDT' : 'EUR',
      'paymentProvider': provider,
      'idempotencyKey': _uuid.v4(),
    };
    final String? normalizedCoupon = _nullableUpper(couponCode);
    if (normalizedCoupon != null) {
      createPayload['couponCode'] = normalizedCoupon;
    }
    final Response<dynamic> createResponse = await _apiClient.dio.post(
      '/course-purchases/orders',
      data: createPayload,
    );
    final Map<String, dynamic> created = _responseMap(createResponse);
    final Map<String, dynamic> checkoutAction = _jsonMap(
      created['checkoutAction'],
    );
    final String orderId = _stringValue(created['id']);
    if (orderId.isEmpty) {
      throw DioException(
        requestOptions: createResponse.requestOptions,
        message: 'Course purchase order ID is missing.',
      );
    }

    late final Response<dynamic> confirmationResponse;
    if (provider == 'google_play') {
      final String productId = _stringValue(checkoutAction['productId']);
      confirmationResponse = await _apiClient.dio.post(
        '/course-purchases/orders/$orderId/google-play/demo-confirm',
        data: <String, dynamic>{
          'productId': productId,
          'purchaseToken': 'demo_gplay_${_uuid.v4()}',
        },
      );
    } else {
      final String paymentIntentId = _stringValue(
        checkoutAction['paymentIntentId'],
      );
      confirmationResponse = await _apiClient.dio.post(
        '/course-purchases/orders/$orderId/stripe/demo-confirm',
        data: <String, dynamic>{
          'paymentIntentId': paymentIntentId,
          'demoResult': 'succeeded',
        },
      );
    }

    final Map<String, dynamic> confirmed = _responseMap(confirmationResponse);
    final Map<String, dynamic> confirmedOrder = _jsonMap(
      confirmed['order'],
    );
    final String orderNumber = _stringValue(
      confirmedOrder['orderNumber'] ?? created['orderNumber'],
    );
    final String status = _stringValue(
      confirmedOrder['status'] ?? confirmed['status'] ?? 'completed',
    );

    return ProPurchaseResultModel(
      orderId: orderNumber.isEmpty ? orderId : orderNumber,
      statusLabel: 'Status: ${_titleCase(status)}',
      title: 'Course Unlocked!',
      description:
          'You now have full access to ${order.courseName} and all ${order.lessonCount} lessons.',
      buttonLabel: 'Start Learning Now',
    );
  }

  Future<Response<dynamic>> _fetchQuote(
    String courseId,
    String currency,
    String? couponCode,
  ) {
    return _apiClient.dio.get(
      '/course-purchases/courses/$courseId/quote',
      queryParameters: <String, dynamic>{
        'currency': currency,
        if (couponCode != null) 'couponCode': couponCode,
      },
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

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _formatPrice(ProCurrency currency, String amount) {
    final double parsed = double.tryParse(amount) ?? 0;
    return currency == ProCurrency.bdt
        ? '৳${parsed.toStringAsFixed(2)}'
        : '€${parsed.toStringAsFixed(2)}';
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _nullableUpper(String? value) {
    final String clean = value?.trim().toUpperCase() ?? '';
    return clean.isEmpty ? null : clean;
  }

  String _titleCase(String value) {
    final String clean = value.trim();
    if (clean.isEmpty) return 'Completed';
    return '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
  }
}
