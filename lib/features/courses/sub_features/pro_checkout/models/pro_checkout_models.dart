enum ProCurrency { eur, bdt }

enum ProPaymentMethod { card, paypal, applePay, bkash }

class ProFeatureModel {
  final String title;
  final String iconName;
  final String tone;

  const ProFeatureModel({
    required this.title,
    required this.iconName,
    required this.tone,
  });

  factory ProFeatureModel.fromJson(Map<String, dynamic> json) {
    return ProFeatureModel(
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      tone: json['tone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'iconName': iconName,
      'tone': tone,
    };
  }

  ProFeatureModel copyWith({String? title, String? iconName, String? tone}) {
    return ProFeatureModel(
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      tone: tone ?? this.tone,
    );
  }
}

class ProPlanModel {
  static const double eurToBdtRate = 144.32;

  final String title;
  final String subtitle;
  final String eurPrice;
  final String eurOldPrice;
  final String bdtPrice;
  final String bdtOldPrice;
  final String discountLabel;
  final String couponCode;
  final String couponEurPrice;
  final String couponSaveLabel;

  const ProPlanModel({
    required this.title,
    required this.subtitle,
    required this.eurPrice,
    required this.eurOldPrice,
    required this.bdtPrice,
    required this.bdtOldPrice,
    required this.discountLabel,
    required this.couponCode,
    required this.couponEurPrice,
    required this.couponSaveLabel,
  });

  factory ProPlanModel.fromJson(Map<String, dynamic> json) {
    return ProPlanModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      eurPrice: json['eurPrice'] as String,
      eurOldPrice: json['eurOldPrice'] as String,
      bdtPrice: json['bdtPrice'] as String,
      bdtOldPrice: json['bdtOldPrice'] as String,
      discountLabel: json['discountLabel'] as String,
      couponCode: json['couponCode'] as String,
      couponEurPrice: json['couponEurPrice'] as String,
      couponSaveLabel: json['couponSaveLabel'] as String,
    );
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
      'couponSaveLabel': couponSaveLabel,
    };
  }

  String priceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    final double amount = isCouponApplied ? _amountFromLabel(couponEurPrice) : _amountFromLabel(eurPrice);
    return _formatPrice(currency, amount);
  }

  String oldPriceLabel(ProCurrency currency, {bool isCouponApplied = false}) {
    final double amount = isCouponApplied ? _amountFromLabel(eurPrice) : _amountFromLabel(eurOldPrice);
    return _formatPrice(currency, amount);
  }

  String couponSaveLabelFor(ProCurrency currency) {
    final double saveAmount = _amountFromLabel(eurPrice) - _amountFromLabel(couponEurPrice);
    return 'YOU SAVE ${_formatPrice(currency, saveAmount)}';
  }

  double _amountFromLabel(String label) {
    final RegExpMatch? match = RegExp(r'\d+(\.\d+)?').firstMatch(label.replaceAll(',', ''));
    if (match == null) {
      return 0;
    }

    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  String _formatPrice(ProCurrency currency, double eurAmount) {
    if (currency == ProCurrency.bdt) {
      return '৳${(eurAmount * eurToBdtRate).round()}';
    }

    return '€${eurAmount.toStringAsFixed(2)}';
  }
}

class ProOrderModel {
  final String appName;
  final String headline;
  final String description;
  final String trustedLabel;
  final ProPlanModel plan;
  final List<ProFeatureModel> features;

  const ProOrderModel({
    required this.appName,
    required this.headline,
    required this.description,
    required this.trustedLabel,
    required this.plan,
    required this.features,
  });

  factory ProOrderModel.fromJson(Map<String, dynamic> json) {
    return ProOrderModel(
      appName: json['appName'] as String,
      headline: json['headline'] as String,
      description: json['description'] as String,
      trustedLabel: json['trustedLabel'] as String,
      plan: ProPlanModel.fromJson(json['plan'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>)
          .map((dynamic item) => ProFeatureModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'headline': headline,
      'description': description,
      'trustedLabel': trustedLabel,
      'plan': plan.toJson(),
      'features': features.map((ProFeatureModel item) => item.toJson()).toList(),
    };
  }
}

class ProPurchaseResultModel {
  final String orderId;
  final String statusLabel;
  final String title;
  final String description;
  final String buttonLabel;

  const ProPurchaseResultModel({
    required this.orderId,
    required this.statusLabel,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  factory ProPurchaseResultModel.fromJson(Map<String, dynamic> json) {
    return ProPurchaseResultModel(
      orderId: json['orderId'] as String,
      statusLabel: json['statusLabel'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      buttonLabel: json['buttonLabel'] as String,
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
}
