enum StorePackageType {
  aiBundle('ai_bundle'),
  streakFreeze('streak_freeze'),
  cvCredit('cv_credit');
  const StorePackageType(this.apiValue);
  final String apiValue;
  static StorePackageType fromApi(String? value) {
    return StorePackageType.values.firstWhere(
      (StorePackageType type) => type.apiValue == value,
      orElse: () => StorePackageType.aiBundle,
    );
  }
}

enum RefillCurrency {
  eur('EUR', '€'),
  bdt('BDT', '৳');
  const RefillCurrency(this.apiValue, this.symbol);
  final String apiValue;
  final String symbol;
}

enum CheckoutPaymentMethod {
  googlePlay('google_play');
  const CheckoutPaymentMethod(this.providerValue);
  final String providerValue;
  static CheckoutPaymentMethod fromProvider(String? _) {
    return CheckoutPaymentMethod.googlePlay;
  }
}

enum StoreProviderProductType {
  consumable('consumable'),
  nonConsumable('non_consumable'),
  subscription('subscription');
  const StoreProviderProductType(this.apiValue);
  final String apiValue;
  static StoreProviderProductType fromApi(String? value) {
    return StoreProviderProductType.values.firstWhere(
      (StoreProviderProductType type) => type.apiValue == value,
      orElse: () => StoreProviderProductType.consumable,
    );
  }
}

class StoreProviderProductModel {
  const StoreProviderProductModel({
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
  final StoreProviderProductType productType;
  final String basePlanId;
  final String offerId;
  final bool isActive;
  bool get isConsumable => productType == StoreProviderProductType.consumable;
  bool get isSubscription =>
      productType == StoreProviderProductType.subscription;
  factory StoreProviderProductModel.fromJson(Map<String, dynamic> json) {
    return StoreProviderProductModel(
      id: _string(json['id']),
      provider: _string(json['provider'], fallback: 'google_play'),
      productId: _string(json['productId']),
      productType: StoreProviderProductType.fromApi(
        _string(json['productType']),
      ),
      basePlanId: _string(json['basePlanId']),
      offerId: _string(json['offerId']),
      isActive: _bool(json['isActive']),
    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'provider': provider,
    'productId': productId,
    'productType': productType.apiValue,
    'basePlanId': basePlanId.isEmpty ? null : basePlanId,
    'offerId': offerId.isEmpty ? null : offerId,
    'isActive': isActive,
  };
}

class StoreBalancesModel {
  const StoreBalancesModel({
    required this.aiVoiceMinutes,
    required this.aiVoiceSeconds,
    required this.aiTextTokens,
    required this.streakFreezeCount,
    required this.unlimitedProtectionActive,
    required this.unlimitedProtectionExpiresAt,
    required this.cvCredits,
    required this.freeCvCreditsPerSignup,
    required this.allowCvEditingWithoutCredit,
  });
  final int aiVoiceMinutes;
  final int aiVoiceSeconds;
  final int aiTextTokens;
  final int streakFreezeCount;
  final bool unlimitedProtectionActive;
  final DateTime? unlimitedProtectionExpiresAt;
  final int cvCredits;
  final int freeCvCreditsPerSignup;
  final bool allowCvEditingWithoutCredit;
  factory StoreBalancesModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ai = _map(json['ai']);
    final Map<String, dynamic> streak = _map(json['streakFreeze']);
    final Map<String, dynamic> unlimited = _map(streak['unlimitedProtection']);
    final Map<String, dynamic> cv = _map(json['cv']);
    final int voiceSeconds = ai.containsKey('voiceSeconds')
        ? _int(ai['voiceSeconds'])
        : (_double(ai['voiceMinutes']) * 60).round();
    return StoreBalancesModel(
      aiVoiceMinutes: voiceSeconds <= 0 ? 0 : (voiceSeconds / 60).ceil(),
      aiVoiceSeconds: voiceSeconds,
      aiTextTokens: _int(ai['textTokens']),
      streakFreezeCount: _int(streak['count']),
      unlimitedProtectionActive: _bool(unlimited['active']),
      unlimitedProtectionExpiresAt: _date(unlimited['expiresAt']),
      cvCredits: _int(cv['credits']),
      freeCvCreditsPerSignup: _int(cv['freeCreditsPerSignup']),
      allowCvEditingWithoutCredit: _bool(cv['allowEditingWithoutCredit']),
    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'ai': <String, dynamic>{
      'voiceMinutes': aiVoiceMinutes,
      'voiceSeconds': aiVoiceSeconds,
      'textTokens': aiTextTokens,
    },
    'streakFreeze': <String, dynamic>{
      'count': streakFreezeCount,
      'unlimitedProtection': <String, dynamic>{
        'active': unlimitedProtectionActive,
        'expiresAt': unlimitedProtectionExpiresAt?.toIso8601String(),
      },
    },
    'cv': <String, dynamic>{
      'credits': cvCredits,
      'freeCreditsPerSignup': freeCvCreditsPerSignup,
      'allowEditingWithoutCredit': allowCvEditingWithoutCredit,
    },
  };
}

class StorePackageModel {
  const StorePackageModel({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.priceEur,
    required this.billingModel,
    required this.marketingBadge,
    required this.aiVoiceMinutes,
    required this.aiTextTokens,
    required this.cvCredits,
    required this.streakFreezeCount,
    required this.streakProtectionMode,
    required this.protectionDurationDays,
    required this.couponEnabled,
    required this.sortOrder,
    this.aiVoiceSeconds = 0,
    this.storeProduct,
  });
  final String id;
  final StorePackageType type;
  final String name;
  final String description;
  final double priceEur;
  final String billingModel;
  final String marketingBadge;
  final int aiVoiceMinutes;
  final int aiVoiceSeconds;
  final int aiTextTokens;
  final int cvCredits;
  final int streakFreezeCount;
  final String streakProtectionMode;
  final int? protectionDurationDays;
  final bool couponEnabled;
  final int sortOrder;
  final StoreProviderProductModel? storeProduct;

  bool get isMonthly => billingModel == 'monthly';
  bool get isUnlimitedStreak => streakProtectionMode == 'monthly_unlimited';

  String get badgeLabel {
    switch (marketingBadge) {
      case 'limited_time':
        return 'LIMITED TIME';
      case 'most_popular':
        return 'MOST POPULAR';
      case 'best_value':
        return 'BEST VALUE';
      default:
        return '';
    }
  }

  String get entitlementSummary {
    switch (type) {
      case StorePackageType.aiBundle:
        return '$aiVoiceMinutes Mins Voice | ${_compactNumber(aiTextTokens)} Tokens';
      case StorePackageType.streakFreeze:
        if (isUnlimitedStreak) {
          return '${protectionDurationDays ?? 30} days unlimited protection';
        }
        return '$streakFreezeCount Streak Freeze${streakFreezeCount == 1 ? '' : 's'}';
      case StorePackageType.cvCredit:
        return '$cvCredits CV Credit${cvCredits == 1 ? '' : 's'}';
    }
  }

  factory StorePackageModel.fromJson(Map<String, dynamic> json) {
    final int voiceMinutes = _int(json['aiVoiceMinutes']);
    final int voiceSeconds = json.containsKey('aiVoiceSeconds')
        ? _int(json['aiVoiceSeconds'])
        : voiceMinutes * 60;
    final Map<String, dynamic> product = _map(json['storeProduct']);

    return StorePackageModel(
      id: _string(json['id']),
      type: StorePackageType.fromApi(_string(json['type'])),
      name: _string(json['name'], fallback: 'Package'),
      description: _string(json['description']),
      priceEur: _double(json['priceEur']),
      billingModel: _string(json['billingModel'], fallback: 'one_time'),
      marketingBadge: _string(json['marketingBadge'], fallback: 'none'),
      aiVoiceMinutes: voiceMinutes,
      aiTextTokens: _int(json['aiTextTokens']),
      cvCredits: _int(json['cvCredits']),
      streakFreezeCount: _int(json['streakFreezeCount']),
      streakProtectionMode: _string(json['streakProtectionMode']),
      protectionDurationDays: _nullableInt(json['protectionDurationDays']),
      couponEnabled: _bool(json['couponEnabled']),
      sortOrder: _int(json['sortOrder']),
      aiVoiceSeconds: voiceSeconds,
      storeProduct: product.isEmpty
          ? null
          : StoreProviderProductModel.fromJson(product),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.apiValue,
    'name': name,
    'description': description,
    'priceEur': priceEur.toStringAsFixed(2),
    'billingModel': billingModel,
    'marketingBadge': marketingBadge,
    'aiVoiceMinutes': aiVoiceMinutes,
    'aiVoiceSeconds': aiVoiceSeconds,
    'aiTextTokens': aiTextTokens,
    'cvCredits': cvCredits,
    'streakFreezeCount': streakFreezeCount,
    'streakProtectionMode': streakProtectionMode,
    'protectionDurationDays': protectionDurationDays,
    'couponEnabled': couponEnabled,
    'sortOrder': sortOrder,
    'storeProduct': storeProduct?.toJson(),
  };
}

class StoreShopSectionModel {
  const StoreShopSectionModel({
    required this.packageType,
    required this.title,
    required this.subtitle,
    required this.packageCount,
    required this.startingPriceEur,
  });

  final StorePackageType packageType;
  final String title;
  final String subtitle;
  final int packageCount;
  final double? startingPriceEur;

  factory StoreShopSectionModel.fromJson(Map<String, dynamic> json) {
    return StoreShopSectionModel(
      packageType: StorePackageType.fromApi(_string(json['packageType'])),
      title: _string(json['title']),
      subtitle: _string(json['subtitle']),
      packageCount: _int(json['packageCount']),
      startingPriceEur: _nullableDouble(json['startingPriceEur']),
    );
  }
}

class StoreShopModel {
  const StoreShopModel({
    required this.balances,
    required this.sections,
    required this.hasOrders,
    required this.latestOrderNumber,
  });

  final StoreBalancesModel balances;
  final List<StoreShopSectionModel> sections;
  final bool hasOrders;
  final String latestOrderNumber;

  factory StoreShopModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> history = _map(json['orderHistory']);
    return StoreShopModel(
      balances: StoreBalancesModel.fromJson(_map(json['balances'])),
      sections: _list(json['sections'])
          .map(StoreShopSectionModel.fromJson)
          .toList(growable: false),
      hasOrders: _bool(history['hasOrders']),
      latestOrderNumber: _string(history['latestOrderNumber']),
    );
  }
}

class StoreProviderOptionModel {
  const StoreProviderOptionModel({
    required this.provider,
    required this.enabled,
    required this.productId,
    required this.productType,
    required this.basePlanId,
    required this.offerId,
    required this.developmentVerification,
    this.label = 'Google Play',
    this.unavailableReason = '',
  });

  final String provider;
  final bool enabled;
  final String productId;
  final StoreProviderProductType productType;
  final String basePlanId;
  final String offerId;
  final bool developmentVerification;
  final String label;
  final String unavailableReason;

  CheckoutPaymentMethod get method => CheckoutPaymentMethod.googlePlay;

  factory StoreProviderOptionModel.fromJson(Map<String, dynamic> json) {
    return StoreProviderOptionModel(
      provider: _string(json['provider'], fallback: 'google_play'),
      enabled: json.containsKey('enabled') ? _bool(json['enabled']) : true,
      productId: _string(json['productId']),
      productType: StoreProviderProductType.fromApi(
        _string(json['productType']),
      ),
      basePlanId: _string(json['basePlanId']),
      offerId: _string(json['offerId']),
      developmentVerification: _bool(json['developmentVerification']),
      label: _string(json['label'], fallback: 'Google Play'),
      unavailableReason: _string(json['unavailableReason']),
    );
  }
}

class StoreQuotePricingModel {
  const StoreQuotePricingModel({
    required this.selectedCurrency,
    required this.originalAmount,
    required this.couponCode,
    required this.discountPercentage,
    required this.discountAmount,
    required this.payableAmount,
  });

  final String selectedCurrency;
  final double originalAmount;
  final String couponCode;
  final int discountPercentage;
  final double discountAmount;
  final double payableAmount;

  factory StoreQuotePricingModel.fromJson(Map<String, dynamic> json) {
    return StoreQuotePricingModel(
      selectedCurrency: _string(json['selectedCurrency'], fallback: 'EUR'),
      originalAmount: _double(json['originalAmount']),
      couponCode: _string(json['couponCode']),
      discountPercentage: _int(json['discountPercentage']),
      discountAmount: _double(json['discountAmount']),
      payableAmount: _double(json['payableAmount']),
    );
  }
}

class StoreQuoteResponseModel {
  const StoreQuoteResponseModel({
    required this.package,
    required this.pricing,
    required this.balances,
    required this.storeProduct,
    required this.supportedProviders,
  });

  final StorePackageModel package;
  final StoreQuotePricingModel pricing;
  final StoreBalancesModel balances;
  final StoreProviderProductModel storeProduct;
  final List<StoreProviderOptionModel> supportedProviders;

  factory StoreQuoteResponseModel.fromJson(Map<String, dynamic> json) {
    final StorePackageModel package = StorePackageModel.fromJson(
      _map(json['package']),
    );
    final Map<String, dynamic> productJson = _map(json['storeProduct']);
    final StoreProviderProductModel product = productJson.isEmpty
        ? package.storeProduct ?? _emptyProviderProduct()
        : StoreProviderProductModel.fromJson(productJson);
    final Map<String, dynamic> payment = _map(json['payment']);
    final String provider = _string(
      payment['provider'],
      fallback: product.provider,
    );
    final bool enabled = product.productId.isNotEmpty && product.isActive;

    return StoreQuoteResponseModel(
      package: package,
      pricing: StoreQuotePricingModel.fromJson(_map(json['pricing'])),
      balances: StoreBalancesModel.fromJson(_map(json['balances'])),
      storeProduct: product,
      supportedProviders: <StoreProviderOptionModel>[
        StoreProviderOptionModel(
          provider: provider,
          enabled: enabled,
          productId: product.productId,
          productType: product.productType,
          basePlanId: product.basePlanId,
          offerId: product.offerId,
          developmentVerification: _bool(payment['developmentVerification']),
          unavailableReason: enabled
              ? ''
              : 'This package is not configured in Google Play.',
        ),
      ],
    );
  }
}

class StorePackageListResponseModel {
  const StorePackageListResponseModel({
    required this.balances,
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final StoreBalancesModel balances;
  final List<StorePackageModel> items;
  final int page;
  final int totalPages;

  factory StorePackageListResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> meta = _map(json['meta']);
    return StorePackageListResponseModel(
      balances: StoreBalancesModel.fromJson(_map(json['balances'])),
      items: _list(json['items'])
          .map(StorePackageModel.fromJson)
          .toList(growable: false),
      page: _int(meta['page'], fallback: 1),
      totalPages: _int(meta['totalPages'], fallback: 1),
    );
  }
}

class CreateStoreOrderPayloadModel {
  const CreateStoreOrderPayloadModel({
    required this.packageId,
    required this.currency,
    required this.paymentProvider,
    required this.productId,
    required this.idempotencyKey,
    required this.couponCode,
  });

  final String packageId;
  final RefillCurrency currency;
  final String paymentProvider;
  final String productId;
  final String idempotencyKey;
  final String couponCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'packageId': packageId,
    'currency': currency.apiValue,
    'paymentProvider': paymentProvider,
    'productId': productId,
    'idempotencyKey': idempotencyKey,
    if (couponCode.trim().isNotEmpty) 'couponCode': couponCode.trim(),
  };
}

class VerifyGooglePlayPurchasePayloadModel {
  const VerifyGooglePlayPurchasePayloadModel({
    required this.productId,
    required this.purchaseToken,
    required this.transactionId,
  });

  final String productId;
  final String purchaseToken;
  final String transactionId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productId': productId,
    'purchaseToken': purchaseToken,
    if (transactionId.isNotEmpty) 'transactionId': transactionId,
  };
}

Map<String, dynamic> shopJsonMap(dynamic value) => _map(value);
List<Map<String, dynamic>> shopJsonList(dynamic value) => _list(value);
String shopString(dynamic value, {String fallback = ''}) =>
    _string(value, fallback: fallback);
int shopInt(dynamic value, {int fallback = 0}) =>
    _int(value, fallback: fallback);
double shopDouble(dynamic value, {double fallback = 0}) =>
    _double(value, fallback: fallback);
bool shopBool(dynamic value) => _bool(value);
DateTime? shopDate(dynamic value) => _date(value);

StoreProviderProductModel _emptyProviderProduct() {
  return const StoreProviderProductModel(
    id: '',
    provider: 'google_play',
    productId: '',
    productType: StoreProviderProductType.consumable,
    basePlanId: '',
    offerId: '',
    isActive: false,
  );
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.map(_map).toList(growable: false);
}

String _string(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  return _int(value);
}

double _double(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _nullableDouble(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return null;
  return _double(value);
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

DateTime? _date(dynamic value) {
  final String raw = _string(value);
  return raw.isEmpty ? null : DateTime.tryParse(raw)?.toLocal();
}

String _compactNumber(int value) {
  if (value < 1000) return value.toString();
  if (value % 1000 == 0) return '${value ~/ 1000}k';
  return '${(value / 1000).toStringAsFixed(1)}k';
}
