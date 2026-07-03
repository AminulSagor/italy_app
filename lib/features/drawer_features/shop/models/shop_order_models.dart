import 'shop_models.dart';

class StoreOrderModel {
  const StoreOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.package,
    required this.paymentProvider,
    required this.currency,
    required this.paymentAmount,
    required this.formattedPaymentAmount,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String status;
  final StorePackageModel package;
  final String paymentProvider;
  final String currency;
  final double paymentAmount;
  final String formattedPaymentAmount;
  final DateTime? createdAt;

  factory StoreOrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> packageJson = shopJsonMap(json['package']);
    final Map<String, dynamic> entitlementJson = shopJsonMap(
      packageJson['entitlements'],
    );
    final Map<String, dynamic> pricingJson = shopJsonMap(json['pricing']);
    final Map<String, dynamic> paymentJson = shopJsonMap(json['payment']);

    final int voiceMinutes = shopInt(entitlementJson['voiceMinutes']);
    final int voiceSeconds = entitlementJson.containsKey('voiceSeconds')
        ? shopInt(entitlementJson['voiceSeconds'])
        : voiceMinutes * 60;

    return StoreOrderModel(
      id: shopString(json['id']),
      orderNumber: shopString(json['orderNumber']),
      status: shopString(json['status']),
      package: StorePackageModel(
        id: shopString(packageJson['id']),
        type: StorePackageType.fromApi(shopString(packageJson['type'])),
        name: shopString(packageJson['name'], fallback: 'Package'),
        description: shopString(packageJson['description']),
        priceEur: shopDouble(pricingJson['packagePriceEur']),
        billingModel: shopString(
          packageJson['billingModel'],
          fallback: 'one_time',
        ),
        marketingBadge: shopString(
          packageJson['marketingBadge'],
          fallback: 'none',
        ),
        aiVoiceMinutes: voiceMinutes,
        aiVoiceSeconds: voiceSeconds,
        aiTextTokens: shopInt(entitlementJson['textTokens']),
        cvCredits: shopInt(entitlementJson['cvCredits']),
        streakFreezeCount: shopInt(entitlementJson['streakFreezes']),
        streakProtectionMode: shopString(
          entitlementJson['streakProtectionMode'],
        ),
        protectionDurationDays: entitlementJson['protectionDurationDays'] == null
            ? null
            : shopInt(entitlementJson['protectionDurationDays']),
        couponEnabled: shopString(pricingJson['couponCode']).isNotEmpty,
        sortOrder: 0,
      ),
      paymentProvider: shopString(paymentJson['provider']),
      currency: shopString(pricingJson['currency'], fallback: 'EUR'),
      paymentAmount: shopDouble(pricingJson['paymentAmount']),
      formattedPaymentAmount: shopString(
        pricingJson['formattedPaymentAmount'],
      ),
      createdAt: shopDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'orderNumber': orderNumber,
    'status': status,
    'package': package.toJson(),
    'paymentProvider': paymentProvider,
    'currency': currency,
    'paymentAmount': paymentAmount,
    'formattedPaymentAmount': formattedPaymentAmount,
    'createdAt': createdAt?.toIso8601String(),
  };

  StoreOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? status,
    StorePackageModel? package,
    String? paymentProvider,
    String? currency,
    double? paymentAmount,
    String? formattedPaymentAmount,
    DateTime? createdAt,
  }) {
    return StoreOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      package: package ?? this.package,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      currency: currency ?? this.currency,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      formattedPaymentAmount:
          formattedPaymentAmount ?? this.formattedPaymentAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StoreCheckoutResponseModel {
  const StoreCheckoutResponseModel({
    required this.order,
    required this.paymentMethod,
  });

  final StoreOrderModel order;
  final StoreProviderOptionModel paymentMethod;

  List<StoreProviderOptionModel> get paymentMethods =>
      <StoreProviderOptionModel>[paymentMethod];

  factory StoreCheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreCheckoutResponseModel(
      order: StoreOrderModel.fromJson(shopJsonMap(json['order'])),
      paymentMethod: StoreProviderOptionModel.fromJson(
        shopJsonMap(json['paymentMethod']),
      ),
    );
  }
}

class StorePurchaseCompletionModel {
  const StorePurchaseCompletionModel({
    required this.message,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.packageName,
    required this.packageType,
    required this.creditedVoiceMinutes,
    required this.creditedTextTokens,
    required this.creditedStreakFreezes,
    required this.creditedCvCredits,
    required this.streakProtectionMode,
    required this.unlimitedProtectionUntil,
    required this.balances,
  });

  final String message;
  final String orderId;
  final String orderNumber;
  final String status;
  final String packageName;
  final StorePackageType packageType;
  final int creditedVoiceMinutes;
  final int creditedTextTokens;
  final int creditedStreakFreezes;
  final int creditedCvCredits;
  final String streakProtectionMode;
  final DateTime? unlimitedProtectionUntil;
  final StoreBalancesModel balances;

  factory StorePurchaseCompletionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> order = shopJsonMap(json['order']);
    final Map<String, dynamic> package = shopJsonMap(order['package']);
    final Map<String, dynamic> credited = shopJsonMap(json['credited']);

    return StorePurchaseCompletionModel(
      message: shopString(json['message']),
      orderId: shopString(order['id']),
      orderNumber: shopString(order['orderNumber']),
      status: shopString(order['status']),
      packageName: shopString(package['name'], fallback: 'Package'),
      packageType: StorePackageType.fromApi(shopString(package['type'])),
      creditedVoiceMinutes: shopInt(credited['voiceMinutes']),
      creditedTextTokens: shopInt(credited['textTokens']),
      creditedStreakFreezes: shopInt(credited['streakFreezes']),
      creditedCvCredits: shopInt(credited['cvCredits']),
      streakProtectionMode: shopString(credited['streakProtectionMode']),
      unlimitedProtectionUntil: shopDate(
        credited['unlimitedProtectionUntil'],
      ),
      balances: StoreBalancesModel.fromJson(shopJsonMap(json['balances'])),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'order': <String, dynamic>{
      'id': orderId,
      'orderNumber': orderNumber,
      'status': status,
      'package': <String, dynamic>{
        'name': packageName,
        'type': packageType.apiValue,
      },
    },
    'credited': <String, dynamic>{
      'voiceMinutes': creditedVoiceMinutes,
      'textTokens': creditedTextTokens,
      'streakFreezes': creditedStreakFreezes,
      'cvCredits': creditedCvCredits,
      'streakProtectionMode': streakProtectionMode,
      'unlimitedProtectionUntil':
          unlimitedProtectionUntil?.toIso8601String(),
    },
    'balances': balances.toJson(),
  };
}

class StoreOrderHistoryItemModel {
  const StoreOrderHistoryItemModel({
    required this.id,
    required this.orderNumber,
    required this.category,
    required this.name,
    required this.status,
    required this.paymentProvider,
    required this.currency,
    required this.amount,
    required this.formattedAmount,
    required this.purchasedAt,
    required this.iconType,
  });

  final String id;
  final String orderNumber;
  final String category;
  final String name;
  final String status;
  final String paymentProvider;
  final String currency;
  final double amount;
  final String formattedAmount;
  final DateTime? purchasedAt;
  final String iconType;

  factory StoreOrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return StoreOrderHistoryItemModel(
      id: shopString(json['id']),
      orderNumber: shopString(json['orderNumber']),
      category: shopString(json['category']),
      name: shopString(json['name'], fallback: 'Purchase'),
      status: shopString(json['status']),
      paymentProvider: shopString(json['paymentProvider']),
      currency: shopString(json['currency'], fallback: 'EUR'),
      amount: shopDouble(json['amount']),
      formattedAmount: shopString(json['formattedAmount']),
      purchasedAt: shopDate(json['purchasedAt']),
      iconType: shopString(json['iconType']),
    );
  }

  String get formattedDate {
    final DateTime? date = purchasedAt;
    if (date == null) return '';
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'orderNumber': orderNumber,
    'category': category,
    'name': name,
    'status': status,
    'paymentProvider': paymentProvider,
    'currency': currency,
    'amount': amount,
    'formattedAmount': formattedAmount,
    'purchasedAt': purchasedAt?.toIso8601String(),
    'iconType': iconType,
  };

  StoreOrderHistoryItemModel copyWith({
    String? id,
    String? orderNumber,
    String? category,
    String? name,
    String? status,
    String? paymentProvider,
    String? currency,
    double? amount,
    String? formattedAmount,
    DateTime? purchasedAt,
    String? iconType,
  }) {
    return StoreOrderHistoryItemModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      category: category ?? this.category,
      name: name ?? this.name,
      status: status ?? this.status,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      formattedAmount: formattedAmount ?? this.formattedAmount,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      iconType: iconType ?? this.iconType,
    );
  }
}

class StoreOrderHistoryResponseModel {
  const StoreOrderHistoryResponseModel({
    required this.items,
    required this.page,
    required this.total,
    required this.totalPages,
  });

  final List<StoreOrderHistoryItemModel> items;
  final int page;
  final int total;
  final int totalPages;

  factory StoreOrderHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> meta = shopJsonMap(json['meta']);
    return StoreOrderHistoryResponseModel(
      items: shopJsonList(json['items'])
          .map(StoreOrderHistoryItemModel.fromJson)
          .toList(growable: false),
      page: shopInt(meta['page'], fallback: 1),
      total: shopInt(meta['total']),
      totalPages: shopInt(meta['totalPages'], fallback: 1),
    );
  }
}
