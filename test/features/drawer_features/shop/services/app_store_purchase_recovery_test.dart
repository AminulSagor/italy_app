import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:italir_pothe/features/drawer_features/shop/services/app_store_purchase_recovery.dart';

void main() {
  PurchaseVerificationData verificationData() => PurchaseVerificationData(
    localVerificationData: 'local',
    serverVerificationData: 'signed-transaction',
    source: 'app_store',
  );

  test('returns the normalized backend order ID from StoreKit 2', () {
    final SK2PurchaseDetails purchase = SK2PurchaseDetails(
      productID: 'test_cv_pack_one',
      purchaseID: '123',
      verificationData: verificationData(),
      transactionDate: '2026-09-09T14:00:00Z',
      status: PurchaseStatus.purchased,
      appAccountToken: ' A8DBE663-0BC9-47FA-AB9A-02F72B420DCA ',
    );

    expect(
      appStoreOrderIdFromPurchase(purchase),
      'a8dbe663-0bc9-47fa-ab9a-02f72b420dca',
    );
  });

  test('rejects a missing or malformed StoreKit app account token', () {
    for (final String? token in <String?>[null, '', 'not-an-order-id']) {
      final SK2PurchaseDetails purchase = SK2PurchaseDetails(
        productID: 'test_cv_pack_one',
        purchaseID: '123',
        verificationData: verificationData(),
        transactionDate: '2026-09-09T14:00:00Z',
        status: PurchaseStatus.purchased,
        appAccountToken: token,
      );

      expect(appStoreOrderIdFromPurchase(purchase), isEmpty);
    }
  });

  test('rejects non-StoreKit-2 purchase details', () {
    final PurchaseDetails purchase = PurchaseDetails(
      productID: 'test_cv_pack_one',
      purchaseID: '123',
      verificationData: verificationData(),
      transactionDate: '2026-09-09T14:00:00Z',
      status: PurchaseStatus.purchased,
    );

    expect(appStoreOrderIdFromPurchase(purchase), isEmpty);
  });
}
