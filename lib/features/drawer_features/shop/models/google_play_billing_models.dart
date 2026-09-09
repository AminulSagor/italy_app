import 'shop_models.dart';
import 'shop_order_models.dart';

class PendingGooglePlayPurchaseModel {
  const PendingGooglePlayPurchaseModel({
    required this.appUserId,
    required this.orderId,
    required this.packageId,
    required this.provider,
    required this.productId,
    required this.productType,
    required this.basePlanId,
    required this.offerId,
    required this.offerType,
    required this.obfuscatedAccountId,
    required this.createdAt,
    this.appStorePromotionalOffer,
    this.verifiedCompletion,
  });

  final String appUserId;
  final String orderId;
  final String packageId;
  final String provider;
  final String productId;
  final StoreProviderProductType productType;
  final String basePlanId;
  final String offerId;
  final String offerType;
  final String obfuscatedAccountId;
  final DateTime createdAt;
  final AppStorePromotionalOfferModel? appStorePromotionalOffer;
  final StorePurchaseCompletionModel? verifiedCompletion;

  factory PendingGooglePlayPurchaseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> completion = shopJsonMap(
      json['verifiedCompletion'],
    );

    return PendingGooglePlayPurchaseModel(
      appUserId: shopString(json['appUserId']),
      orderId: shopString(json['orderId']),
      packageId: shopString(json['packageId']),
      provider: shopString(json['provider'], fallback: 'google_play'),
      productId: shopString(json['productId']),
      productType: StoreProviderProductType.fromApi(
        shopString(json['productType']),
      ),
      basePlanId: shopString(json['basePlanId']),
      offerId: shopString(json['offerId']),
      offerType: shopString(json['offerType']),
      obfuscatedAccountId: shopString(
        json['obfuscatedAccountId'],
      ).trim().toLowerCase(),
      createdAt:
          DateTime.tryParse(shopString(json['createdAt']))?.toLocal() ??
          DateTime.now(),
      appStorePromotionalOffer:
          shopJsonMap(json['appStorePromotionalOffer']).isEmpty
          ? null
          : AppStorePromotionalOfferModel.fromJson(
              shopJsonMap(json['appStorePromotionalOffer']),
            ),
      verifiedCompletion: completion.isEmpty
          ? null
          : StorePurchaseCompletionModel.fromJson(completion),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appUserId': appUserId,
    'orderId': orderId,
    'packageId': packageId,
    'provider': provider,
    'productId': productId,
    'productType': productType.apiValue,
    'basePlanId': basePlanId,
    'offerId': offerId,
    'offerType': offerType,
    'obfuscatedAccountId': obfuscatedAccountId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'appStorePromotionalOffer': appStorePromotionalOffer == null
        ? null
        : <String, dynamic>{
            'offerId': appStorePromotionalOffer!.offerId,
            'keyId': appStorePromotionalOffer!.keyId,
            'nonce': appStorePromotionalOffer!.nonce,
            'timestamp': appStorePromotionalOffer!.timestamp,
            'signature': appStorePromotionalOffer!.signature,
          },
    'verifiedCompletion': verifiedCompletion?.toJson(),
  };

  PendingGooglePlayPurchaseModel copyWith({
    String? appUserId,
    StorePurchaseCompletionModel? verifiedCompletion,
  }) {
    return PendingGooglePlayPurchaseModel(
      appUserId: appUserId ?? this.appUserId,
      orderId: orderId,
      packageId: packageId,
      provider: provider,
      productId: productId,
      productType: productType,
      basePlanId: basePlanId,
      offerId: offerId,
      offerType: offerType,
      obfuscatedAccountId: obfuscatedAccountId,
      createdAt: createdAt,
      appStorePromotionalOffer: appStorePromotionalOffer,
      verifiedCompletion: verifiedCompletion ?? this.verifiedCompletion,
    );
  }
}

enum GooglePlayPurchaseOutcomeStatus { completed, pending, cancelled, failed }

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
