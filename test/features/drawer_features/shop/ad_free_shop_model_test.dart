import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/features/drawer_features/shop/models/shop_models.dart';

void main() {
  test('parses a yearly Ad-Free subscription and its store mapping', () {
    final StorePackageModel package = StorePackageModel.fromJson(
      <String, dynamic>{
        'id': 'package-id',
        'type': 'ad_free',
        'name': 'Ad-Free Yearly',
        'priceEur': '15.00',
        'billingModel': 'yearly',
        'couponEnabled': false,
        'storeProduct': <String, dynamic>{
          'id': 'mapping-id',
          'provider': 'google_play',
          'productId': 'ad_free',
          'productType': 'subscription',
          'basePlanId': 'yearly',
          'isActive': true,
        },
      },
    );

    expect(package.type, StorePackageType.adFree);
    expect(package.isSubscription, isTrue);
    expect(package.isYearly, isTrue);
    expect(package.couponEnabled, isFalse);
    expect(package.storeProduct?.productId, 'ad_free');
    expect(package.storeProduct?.basePlanId, 'yearly');
    expect(package.entitlementSummary, '1 year without ads');
  });
}
