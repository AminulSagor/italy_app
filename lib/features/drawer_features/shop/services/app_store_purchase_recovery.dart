import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

final RegExp _storeOrderIdPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Returns the backend order UUID embedded in a StoreKit 2 transaction, or an
/// empty string when the transaction cannot be linked safely.
String appStoreOrderIdFromPurchase(PurchaseDetails purchase) {
  if (purchase is! SK2PurchaseDetails) return '';

  final String orderId = (purchase.appAccountToken ?? '').trim().toLowerCase();
  return _storeOrderIdPattern.hasMatch(orderId) ? orderId : '';
}
