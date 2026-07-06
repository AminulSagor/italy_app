enum ProCurrency { eur, bdt }

enum ProPaymentMethod { card, googlePlay }

enum ProPurchaseOutcomeStatus { completed, pending, cancelled, failed }

class ProStoreProductModel {
  const ProStoreProductModel({
    required this.id,
    required this.provider,
    required this.productId,
    required this.productType,
    required this.basePlanId,
    required this.offerId,
    required this.isActive,
  });

  final String id;
  final String provider;
  final String productId;
  final String productType;
  final String basePlanId;
  final String offerId;
  final bool isActive;

  factory ProStoreProductModel.fromJson(Map<String, dynamic> json) {
    return ProStoreProductModel(
      id: _stringValue(json['id'] ?? json['providerProductId']),
      provider: _stringValue(json['provider']),
      productId: _stringValue(json['productId']),
      productType: _stringValue(
        json['productType'],
        fallback: 'non_consumable',
      ),
      basePlanId: _stringValue(json['basePlanId']),
      offerId: _stringValue(json['offerId']),
      isActive: _boolValue(json['isActive'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'provider': provider,
    'productId': productId,
    'productType': productType,
    'basePlanId': basePlanId,
    'offerId': offerId,
    'isActive': isActive,
  };
}

class ProFeatureModel {
  const ProFeatureModel({
    required this.title,
    required this.iconName,
    required this.tone,
  });

  final String title;
  final String iconName;
  final String tone;

  factory ProFeatureModel.fromJson(Map<String, dynamic> json) {
    return ProFeatureModel(
      title: _stringValue(json['title']),
      iconName: _stringValue(json['iconName']),
      tone: _stringValue(json['tone']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'iconName': iconName,
    'tone': tone,
  };
}

class ProPlanModel {
  const ProPlanModel({
    required this.title,
    required this.subtitle,
    required this.eurPrice,
    required this.eurOldPrice,
    required this.bdtPrice,
    required this.bdtOldPrice,
    required this.discountLabel,
  });

  final String title;
  final String subtitle;
  final String eurPrice;
  final String eurOldPrice;
  final String bdtPrice;
  final String bdtOldPrice;
  final String discountLabel;

  factory ProPlanModel.fromJson(Map<String, dynamic> json) {
    return ProPlanModel(
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitle']),
      eurPrice: _stringValue(json['eurPrice']),
      eurOldPrice: _stringValue(json['eurOldPrice']),
      bdtPrice: _stringValue(json['bdtPrice']),
      bdtOldPrice: _stringValue(json['bdtOldPrice']),
      discountLabel: _stringValue(json['discountLabel']),
    );
  }

  String priceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    return currency == ProCurrency.bdt ? bdtPrice : eurPrice;
  }

  String oldPriceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    return currency == ProCurrency.bdt ? bdtOldPrice : eurOldPrice;
  }

  String couponSaveLabelFor(ProCurrency currency) => discountLabel;

  ProPlanModel copyWith({
    String? title,
    String? subtitle,
    String? eurPrice,
    String? eurOldPrice,
    String? bdtPrice,
    String? bdtOldPrice,
    String? discountLabel,
  }) {
    return ProPlanModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      eurPrice: eurPrice ?? this.eurPrice,
      eurOldPrice: eurOldPrice ?? this.eurOldPrice,
      bdtPrice: bdtPrice ?? this.bdtPrice,
      bdtOldPrice: bdtOldPrice ?? this.bdtOldPrice,
      discountLabel: discountLabel ?? this.discountLabel,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'subtitle': subtitle,
    'eurPrice': eurPrice,
    'eurOldPrice': eurOldPrice,
    'bdtPrice': bdtPrice,
    'bdtOldPrice': bdtOldPrice,
    'discountLabel': discountLabel,
  };
}

class ProOrderModel {
  const ProOrderModel({
    required this.courseId,
    required this.courseName,
    required this.lessonCount,
    required this.appName,
    required this.headline,
    required this.description,
    required this.trustedLabel,
    required this.plan,
    required this.features,
    required this.storeProduct,
  });

  final String courseId;
  final String courseName;
  final int lessonCount;
  final String appName;
  final String headline;
  final String description;
  final String trustedLabel;
  final ProPlanModel plan;
  final List<ProFeatureModel> features;
  final ProStoreProductModel storeProduct;

  factory ProOrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawFeatures = json['features'] is List
        ? json['features'] as List<dynamic>
        : const <dynamic>[];
    final Map<String, dynamic> storeProductJson = proJsonMap(
      json['storeProduct'],
    );
    return ProOrderModel(
      courseId: _stringValue(json['courseId']),
      courseName: _stringValue(
        json['courseName'],
        fallback: _stringValue(json['headline']),
      ),
      lessonCount: _intValue(json['lessonCount']),
      appName: _stringValue(json['appName']),
      headline: _stringValue(json['headline']),
      description: _stringValue(json['description']),
      trustedLabel: _stringValue(json['trustedLabel']),
      plan: ProPlanModel.fromJson(proJsonMap(json['plan'])),
      features: rawFeatures
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) => ProFeatureModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      storeProduct: ProStoreProductModel.fromJson(
        storeProductJson.isEmpty
            ? <String, dynamic>{
                'provider': 'google_play',
                'productType': 'non_consumable',
                'isActive': false,
              }
            : storeProductJson,
      ),
    );
  }

  ProOrderModel copyWith({
    ProPlanModel? plan,
    ProStoreProductModel? storeProduct,
  }) {
    return ProOrderModel(
      courseId: courseId,
      courseName: courseName,
      lessonCount: lessonCount,
      appName: appName,
      headline: headline,
      description: description,
      trustedLabel: trustedLabel,
      plan: plan ?? this.plan,
      features: features,
      storeProduct: storeProduct ?? this.storeProduct,
    );
  }
}

class ProPendingGooglePlayPurchaseModel {
  const ProPendingGooglePlayPurchaseModel({
    required this.courseId,
    required this.orderId,
    required this.orderNumber,
    required this.productId,
    required this.createdAt,
  });

  final String courseId;
  final String orderId;
  final String orderNumber;
  final String productId;
  final DateTime createdAt;

  factory ProPendingGooglePlayPurchaseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProPendingGooglePlayPurchaseModel(
      courseId: _stringValue(json['courseId']),
      orderId: _stringValue(json['orderId']),
      orderNumber: _stringValue(json['orderNumber']),
      productId: _stringValue(json['productId']),
      createdAt: DateTime.tryParse(_stringValue(json['createdAt']))?.toLocal() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'courseId': courseId,
    'orderId': orderId,
    'orderNumber': orderNumber,
    'productId': productId,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

class ProPurchaseResultModel {
  const ProPurchaseResultModel({
    required this.orderId,
    required this.statusLabel,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final String orderId;
  final String statusLabel;
  final String title;
  final String description;
  final String buttonLabel;

  factory ProPurchaseResultModel.fromJson(Map<String, dynamic> json) {
    return ProPurchaseResultModel(
      orderId: _stringValue(json['orderId']),
      statusLabel: _stringValue(json['statusLabel']),
      title: _stringValue(json['title']),
      description: _stringValue(json['description']),
      buttonLabel: _stringValue(json['buttonLabel']),
    );
  }
}

class ProPurchaseOutcome {
  const ProPurchaseOutcome({required this.status, required this.message});

  final ProPurchaseOutcomeStatus status;
  final String message;
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

bool _boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return fallback;
}

Map<String, dynamic> proJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
