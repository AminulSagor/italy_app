import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../../../core/services/storage_service.dart';
import '../models/pro_checkout_models.dart';

class CourseGooglePlayBillingService extends GetxService {
  CourseGooglePlayBillingService({required StorageService storageService})
      : _storageService = storageService;

  static const String _pendingKey = 'course_pending_google_play_purchase';

  final StorageService _storageService;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _productDetails;
  Future<void>? _initialization;
  bool pendingPurchaseQueryFailed = false;

  final RxBool isAvailable = false.obs;
  final RxBool isLoadingProduct = false.obs;
  final RxString lastError = ''.obs;

  Stream<PurchaseDetails> get purchaseUpdates => _purchaseController.stream;
  String get localizedPrice => _productDetails?.price ?? '';
  String get localizedCurrencyCode => _productDetails?.currencyCode ?? '';

  Future<void> initialize() => _initialization ??= _initializeInternal();

  Future<void> _initializeInternal() async {
    if (!Platform.isAndroid) {
      lastError.value = 'Google Play Billing is available only on Android.';
      return;
    }

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchases) {
        for (final PurchaseDetails purchase in purchases) {
          if (!_purchaseController.isClosed) {
            _purchaseController.add(purchase);
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        lastError.value = 'Google Play purchase updates failed.';
        dev.log(
          lastError.value,
          name: 'CourseGooglePlayBillingService',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    try {
      isAvailable.value = await _inAppPurchase.isAvailable();
      if (!isAvailable.value) {
        lastError.value = 'Google Play Billing is unavailable on this device.';
      }
    } catch (error, stackTrace) {
      isAvailable.value = false;
      lastError.value = 'Could not connect to Google Play Billing.';
      dev.log(
        lastError.value,
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> prepareProduct(ProStoreProductModel product) async {
    await initialize();
    final bool isSupportedMapping = product.isActive &&
        product.provider.toLowerCase() == 'google_play' &&
        product.productType.toLowerCase() == 'non_consumable' &&
        product.productId.isNotEmpty;
    if (!isAvailable.value || !isSupportedMapping) {
      lastError.value = 'This course has no active Google Play product.';
      return false;
    }

    isLoadingProduct.value = true;
    lastError.value = '';
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(<String>{product.productId});
      if (response.error != null) {
        throw StateError(response.error!.message);
      }
      _productDetails = response.productDetails.firstWhereOrNull(
        (ProductDetails item) => item.id == product.productId,
      );
      if (_productDetails == null) {
        lastError.value = 'This course is not available in Google Play.';
        return false;
      }
      return true;
    } catch (error, stackTrace) {
      lastError.value = 'Could not load this course from Google Play.';
      dev.log(
        lastError.value,
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      isLoadingProduct.value = false;
    }
  }

  Future<bool> launchPurchase({
    required ProStoreProductModel product,
    required ProPendingGooglePlayPurchaseModel pendingPurchase,
  }) async {
    final bool ready = _productDetails?.id == product.productId ||
        await prepareProduct(product);
    if (!ready || _productDetails == null) return false;

    await savePendingPurchase(pendingPurchase);
    try {
      final GooglePlayPurchaseParam purchaseParam =
          GooglePlayPurchaseParam(productDetails: _productDetails!);
      final bool launched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!launched) await clearPendingPurchase();
      return launched;
    } catch (error, stackTrace) {
      await clearPendingPurchase();
      lastError.value = 'Google Play could not start the course purchase.';
      dev.log(
        lastError.value,
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<PurchaseDetails?> queryPendingPurchase() async {
    pendingPurchaseQueryFailed = false;
    final ProPendingGooglePlayPurchaseModel? pending = loadPendingPurchase();
    if (pending == null || !Platform.isAndroid) return null;

    await initialize();
    if (!isAvailable.value) return null;
    try {
      final InAppPurchaseAndroidPlatformAddition addition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final QueryPurchaseDetailsResponse response =
          await addition.queryPastPurchases();
      if (response.error != null) throw StateError(response.error!.message);
      return response.pastPurchases.firstWhereOrNull(
        (PurchaseDetails purchase) => purchase.productID == pending.productId,
      );
    } catch (error, stackTrace) {
      pendingPurchaseQueryFailed = true;
      dev.log(
        'Could not recover the pending course purchase.',
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> finishVerifiedPurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  ProPendingGooglePlayPurchaseModel? loadPendingPurchase() {
    final String? raw = _storageService.readString(_pendingKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ProPendingGooglePlayPurchaseModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (error, stackTrace) {
      dev.log(
        'Could not read the pending course purchase.',
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> savePendingPurchase(
    ProPendingGooglePlayPurchaseModel pendingPurchase,
  ) {
    return _storageService.writeString(
      _pendingKey,
      jsonEncode(pendingPurchase.toJson()),
    );
  }

  Future<void> clearPendingPurchase() => _storageService.remove(_pendingKey);

  @override
  void onClose() {
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_purchaseController.close());
    super.onClose();
  }
}
