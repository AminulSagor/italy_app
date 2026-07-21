import 'shop_models.dart';
import 'shop_order_models.dart';

class PendingGooglePlayPurchaseModel {
  const PendingGooglePlayPurchaseModel({
    required this.orderId,
    required this.packageId,
    required this.productId,
    required this.productType,
    required this.basePlanId,
    required this.offerId,
    required this.obfuscatedAccountId,
    required this.createdAt,
    this.verifiedCompletion,
  });

  final String orderId;
  final String packageId;
  final String productId;
  final StoreProviderProductType productType;
  final String basePlanId;
  final String offerId;
  final String obfuscatedAccountId;
  final DateTime createdAt;
  final StorePurchaseCompletionModel? verifiedCompletion;

  factory PendingGooglePlayPurchaseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final Map<String, dynamic> completion = shopJsonMap(
      json['verifiedCompletion'],
    );

    return PendingGooglePlayPurchaseModel(
      orderId: shopString(json['orderId']),
      packageId: shopString(json['packageId']),
      productId: shopString(json['productId']),
      productType: StoreProviderProductType.fromApi(
        shopString(json['productType']),
      ),
      basePlanId: shopString(json['basePlanId']),
      offerId: shopString(json['offerId']),
      obfuscatedAccountId: shopString(
        json['obfuscatedAccountId'],
      ).trim().toLowerCase(),
      createdAt:
      DateTime.tryParse(
        shopString(json['createdAt']),
      )?.toLocal() ??
          DateTime.now(),
      verifiedCompletion: completion.isEmpty
          ? null
          : StorePurchaseCompletionModel.fromJson(
        completion,
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'orderId': orderId,
    'packageId': packageId,
    'productId': productId,
    'productType': productType.apiValue,
    'basePlanId': basePlanId,
    'offerId': offerId,
    'obfuscatedAccountId': obfuscatedAccountId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'verifiedCompletion': verifiedCompletion?.toJson(),
  };

  PendingGooglePlayPurchaseModel copyWith({
    StorePurchaseCompletionModel? verifiedCompletion,
  }) {
    return PendingGooglePlayPurchaseModel(
      orderId: orderId,
      packageId: packageId,
      productId: productId,
      productType: productType,
      basePlanId: basePlanId,
      offerId: offerId,
      obfuscatedAccountId: obfuscatedAccountId,
      createdAt: createdAt,
      verifiedCompletion:
      verifiedCompletion ?? this.verifiedCompletion,
    );
  }
}

enum GooglePlayPurchaseOutcomeStatus {
  completed,
  pending,
  cancelled,
  failed,
}

class GooglePlayPurchaseOutcome {
  const GooglePlayPurchaseOutcome({
    required this.status,
    required this.message,
    this.completion,
  });

  final GooglePlayPurchaseOutcomeStatus status;
  final String message;
  final StorePurchaseCompletionModel? completion;
}
