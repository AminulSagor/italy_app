enum ProCurrency { eur, bdt }

enum ProPaymentMethod { card, googlePlay }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'iconName': iconName,
      'tone': tone,
    };
  }

  ProFeatureModel copyWith({
    String? title,
    String? iconName,
    String? tone,
  }) {
    return ProFeatureModel(
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      tone: tone ?? this.tone,
    );
  }
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
    required this.couponCode,
    this.couponEurPrice,
    this.couponBdtPrice,
    this.couponSaveLabel,
  });

  final String title;
  final String subtitle;
  final String eurPrice;
  final String eurOldPrice;
  final String bdtPrice;
  final String bdtOldPrice;
  final String discountLabel;
  final String couponCode;
  final String? couponEurPrice;
  final String? couponBdtPrice;
  final String? couponSaveLabel;

  factory ProPlanModel.fromJson(Map<String, dynamic> json) {
    return ProPlanModel(
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitle']),
      eurPrice: _stringValue(json['eurPrice']),
      eurOldPrice: _stringValue(json['eurOldPrice']),
      bdtPrice: _stringValue(json['bdtPrice']),
      bdtOldPrice: _stringValue(json['bdtOldPrice']),
      discountLabel: _stringValue(json['discountLabel']),
      couponCode: _stringValue(json['couponCode']),
      couponEurPrice: _nullableString(json['couponEurPrice']),
      couponBdtPrice: _nullableString(json['couponBdtPrice']),
      couponSaveLabel: _nullableString(json['couponSaveLabel']),
    );
  }

  String priceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    if (isCouponApplied) {
      final String? couponPrice = currency == ProCurrency.bdt
          ? couponBdtPrice
          : couponEurPrice;
      if (couponPrice != null && couponPrice.isNotEmpty) {
        return couponPrice;
      }
    }
    return currency == ProCurrency.bdt ? bdtPrice : eurPrice;
  }

  String oldPriceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    return currency == ProCurrency.bdt ? bdtOldPrice : eurOldPrice;
  }

  String couponSaveLabelFor(ProCurrency currency) {
    final String? explicitLabel = couponSaveLabel;
    if (explicitLabel != null && explicitLabel.isNotEmpty) {
      return explicitLabel;
    }

    final double price = _amountFromLabel(
      priceLabel(currency, isCouponApplied: true),
    );
    final double oldPrice = _amountFromLabel(oldPriceLabel(currency));
    final double saved = (oldPrice - price).clamp(0, double.infinity);
    return 'YOU SAVE ${_formatAmount(currency, saved)}';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'eurPrice': eurPrice,
      'eurOldPrice': eurOldPrice,
      'bdtPrice': bdtPrice,
      'bdtOldPrice': bdtOldPrice,
      'discountLabel': discountLabel,
      'couponCode': couponCode,
      'couponEurPrice': couponEurPrice,
      'couponBdtPrice': couponBdtPrice,
      'couponSaveLabel': couponSaveLabel,
    };
  }

  ProPlanModel copyWith({
    String? title,
    String? subtitle,
    String? eurPrice,
    String? eurOldPrice,
    String? bdtPrice,
    String? bdtOldPrice,
    String? discountLabel,
    String? couponCode,
    String? couponEurPrice,
    String? couponBdtPrice,
    String? couponSaveLabel,
  }) {
    return ProPlanModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      eurPrice: eurPrice ?? this.eurPrice,
      eurOldPrice: eurOldPrice ?? this.eurOldPrice,
      bdtPrice: bdtPrice ?? this.bdtPrice,
      bdtOldPrice: bdtOldPrice ?? this.bdtOldPrice,
      discountLabel: discountLabel ?? this.discountLabel,
      couponCode: couponCode ?? this.couponCode,
      couponEurPrice: couponEurPrice ?? this.couponEurPrice,
      couponBdtPrice: couponBdtPrice ?? this.couponBdtPrice,
      couponSaveLabel: couponSaveLabel ?? this.couponSaveLabel,
    );
  }

  double _amountFromLabel(String label) {
    final RegExpMatch? match = RegExp(
      r'\d+(\.\d+)?',
    ).firstMatch(label.replaceAll(',', ''));
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  String _formatAmount(ProCurrency currency, double amount) {
    if (currency == ProCurrency.bdt) {
      return '৳${amount.toStringAsFixed(2)}';
    }
    return '€${amount.toStringAsFixed(2)}';
  }
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

  factory ProOrderModel.fromJson(Map<String, dynamic> json) {
    return ProOrderModel(
      courseId: _stringValue(json['courseId']),
      courseName: _stringValue(
        json['courseName'],
        fallback: _stringValue(json['headline'], fallback: 'Course'),
      ),
      lessonCount: _intValue(json['lessonCount']),
      appName: _stringValue(json['appName']),
      headline: _stringValue(json['headline']),
      description: _stringValue(json['description']),
      trustedLabel: _stringValue(json['trustedLabel']),
      plan: ProPlanModel.fromJson(_jsonMap(json['plan'])),
      features: _jsonList(json['features'])
          .map(ProFeatureModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'courseName': courseName,
      'lessonCount': lessonCount,
      'appName': appName,
      'headline': headline,
      'description': description,
      'trustedLabel': trustedLabel,
      'plan': plan.toJson(),
      'features': features
          .map((ProFeatureModel feature) => feature.toJson())
          .toList(growable: false),
    };
  }

  ProOrderModel copyWith({
    String? courseId,
    String? courseName,
    int? lessonCount,
    String? appName,
    String? headline,
    String? description,
    String? trustedLabel,
    ProPlanModel? plan,
    List<ProFeatureModel>? features,
  }) {
    return ProOrderModel(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      lessonCount: lessonCount ?? this.lessonCount,
      appName: appName ?? this.appName,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      trustedLabel: trustedLabel ?? this.trustedLabel,
      plan: plan ?? this.plan,
      features: features ?? this.features,
    );
  }
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orderId': orderId,
      'statusLabel': statusLabel,
      'title': title,
      'description': description,
      'buttonLabel': buttonLabel,
    };
  }

  ProPurchaseResultModel copyWith({
    String? orderId,
    String? statusLabel,
    String? title,
    String? description,
    String? buttonLabel,
  }) {
    return ProPurchaseResultModel(
      orderId: orderId ?? this.orderId,
      statusLabel: statusLabel ?? this.statusLabel,
      title: title ?? this.title,
      description: description ?? this.description,
      buttonLabel: buttonLabel ?? this.buttonLabel,
    );
  }
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _jsonList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
