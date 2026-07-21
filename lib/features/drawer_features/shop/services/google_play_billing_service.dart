import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../../core/services/storage_service.dart';
import '../models/google_play_billing_models.dart';
import '../models/shop_models.dart';

class GooglePlayBillingService extends GetxService {
  GooglePlayBillingService({required StorageService storageService})
      : _storageService = storageService;

  static const String _pendingPurchaseKey =
      'package_store_pending_google_play_purchase';
  static final RegExp _sha256Pattern =
  RegExp(r'^[a-f0-9]{64}$');

  final StorageService _storageService;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();
  final Map<String, ProductDetails> _productsBySelection =
      <String, ProductDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Future<void>? _initialization;
  bool _pendingPurchaseQueryFailed = false;

  final RxBool isAvailable = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString lastError = ''.obs;

  Stream<PurchaseDetails> get purchaseUpdates => _purchaseController.stream;
  bool get pendingPurchaseQueryFailed => _pendingPurchaseQueryFailed;

  @override
  void onInit() {
    super.onInit();
    unawaited(initialize());
  }

  Future<void> initialize() {
    return _initialization ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    if (!Platform.isAndroid) {
      lastError.value = 'Google Play Billing is available only on Android.';
      return;
    }

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        lastError.value = 'Google Play Billing purchase updates failed.';
        dev.log(
          lastError.value,
          name: 'GooglePlayBillingService',
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
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> prepareProducts(
    Iterable<StoreProviderProductModel> products,
  ) async {
    await initialize();
    final List<StoreProviderProductModel> activeProducts = products
        .where(
          (StoreProviderProductModel item) =>
              item.isActive && item.productId.isNotEmpty,
        )
        .toList(growable: false);
    if (!isAvailable.value || activeProducts.isEmpty) return;

    isLoadingProducts.value = true;
    lastError.value = '';
    try {
      for (final StoreProviderProductModel item in activeProducts) {
        _productsBySelection.remove(_selectionKey(item));
      }
      final Set<String> identifiers = activeProducts
          .map((StoreProviderProductModel item) => item.productId)
          .toSet();
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(identifiers);

      if (response.error != null) {
        throw StateError(response.error!.message);
      }

      for (final StoreProviderProductModel mapping in activeProducts) {
        final ProductDetails? selected = _selectProductDetails(
          mapping,
          response.productDetails,
        );
        if (selected != null) {
          _productsBySelection[_selectionKey(mapping)] = selected;
        }
      }

      final Set<String> unresolved = activeProducts
          .where(
            (StoreProviderProductModel item) =>
                !_productsBySelection.containsKey(_selectionKey(item)),
          )
          .map((StoreProviderProductModel item) => item.productId)
          .toSet();
      unresolved.addAll(response.notFoundIDs);
      if (unresolved.isNotEmpty) {
        lastError.value =
            'Google Play products are not available: ${unresolved.join(', ')}';
      }
    } catch (error, stackTrace) {
      lastError.value = 'Could not load Google Play products.';
      dev.log(
        lastError.value,
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  String? localizedPrice(StoreProviderProductModel? mapping) {
    if (mapping == null) return null;
    return _productsBySelection[_selectionKey(mapping)]?.price;
  }

  String? localizedCurrencyCode(StoreProviderProductModel? mapping) {
    if (mapping == null) return null;
    return _productsBySelection[_selectionKey(mapping)]?.currencyCode;
  }

  bool hasProduct(StoreProviderProductModel mapping) {
    return _productsBySelection.containsKey(_selectionKey(mapping));
  }

  Future<bool> launchPurchase(
    PendingGooglePlayPurchaseModel pendingPurchase,
  ) async {
    await initialize();
    if (!isAvailable.value) return false;

    final StoreProviderProductModel mapping = StoreProviderProductModel(
      id: '',
      provider: 'google_play',
      productId: pendingPurchase.productId,
      productType: pendingPurchase.productType,
      basePlanId: pendingPurchase.basePlanId,
      offerId: pendingPurchase.offerId,
      isActive: true,
    );
    ProductDetails? details = _productsBySelection[_selectionKey(mapping)];
    if (details == null) {
      await prepareProducts(<StoreProviderProductModel>[mapping]);
      details = _productsBySelection[_selectionKey(mapping)];
    }
    if (details == null) {
      lastError.value = 'The selected Google Play product is unavailable.';
      return false;
    }

    final String obfuscatedAccountId =
    pendingPurchase.obfuscatedAccountId
        .trim()
        .toLowerCase();

    if (!_sha256Pattern.hasMatch(obfuscatedAccountId)) {
      lastError.value =
      'The purchase could not be securely linked to your account.';

      dev.log(
        'Invalid Google Play obfuscated account ID.',
        name: 'GooglePlayBillingService',
      );

      return false;
    }

    await savePendingPurchase(pendingPurchase);
    try {
      final String? offerToken = details is GooglePlayProductDetails
          ? details.offerToken
          : null;
      final GooglePlayPurchaseParam purchaseParam =
      GooglePlayPurchaseParam(
        productDetails: details,
        applicationUserName: obfuscatedAccountId,
        offerToken: pendingPurchase.productType ==
            StoreProviderProductType.subscription
            ? offerToken
            : null,
      );
      final bool launched = pendingPurchase.productType ==
              StoreProviderProductType.consumable
          ? await _inAppPurchase.buyConsumable(
              purchaseParam: purchaseParam,
              autoConsume: false,
            )
          : await _inAppPurchase.buyNonConsumable(
              purchaseParam: purchaseParam,
            );
      if (!launched) await clearPendingPurchase();
      return launched;
    } catch (error, stackTrace) {
      await clearPendingPurchase();
      lastError.value = 'Google Play could not start the purchase.';
      dev.log(
        lastError.value,
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<PurchaseDetails?> queryPendingPurchase() async {
    _pendingPurchaseQueryFailed = false;
    final PendingGooglePlayPurchaseModel? pending = loadPendingPurchase();
    if (pending == null || !Platform.isAndroid) return null;
    await initialize();
    if (!isAvailable.value) return null;

    try {
      final InAppPurchaseAndroidPlatformAddition addition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final QueryPurchaseDetailsResponse response =
          await addition.queryPastPurchases();
      if (response.error != null) {
        throw StateError(response.error!.message);
      }
      for (final GooglePlayPurchaseDetails purchase in response.pastPurchases) {
        if (purchase.productID == pending.productId) return purchase;
      }
    } catch (error, stackTrace) {
      _pendingPurchaseQueryFailed = true;
      dev.log(
        'Could not recover the pending Google Play purchase.',
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<void> finishVerifiedPurchase(
      PurchaseDetails purchase,
      StoreProviderProductType _,
      ) async {
    /*
   * The secure backend already:
   *
   * - consumes finite consumables;
   * - acknowledges initial subscriptions.
   *
   * Do not explicitly consume the same purchase
   * again from the client.
   */
    if (!purchase.pendingCompletePurchase) {
      return;
    }

    await _inAppPurchase.completePurchase(
      purchase,
    );
  }

  PendingGooglePlayPurchaseModel? loadPendingPurchase() {
    final String? raw = _storageService.readString(_pendingPurchaseKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PendingGooglePlayPurchaseModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (error, stackTrace) {
      dev.log(
        'Could not read the pending Google Play purchase.',
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> savePendingPurchase(
    PendingGooglePlayPurchaseModel pendingPurchase,
  ) async {
    await _storageService.writeString(
      _pendingPurchaseKey,
      jsonEncode(pendingPurchase.toJson()),
    );
  }

  Future<void> clearPendingPurchase() async {
    await _storageService.remove(_pendingPurchaseKey);
  }

  ProductDetails? _selectProductDetails(
    StoreProviderProductModel mapping,
    List<ProductDetails> available,
  ) {
    final Iterable<ProductDetails> matching = available.where(
      (ProductDetails item) => item.id == mapping.productId,
    );
    if (!mapping.isSubscription) {
      return matching.isEmpty ? null : matching.first;
    }

    for (final ProductDetails item in matching) {
      if (item is! GooglePlayProductDetails) continue;
      final int? index = item.subscriptionIndex;
      final List<SubscriptionOfferDetailsWrapper>? offers =
          item.productDetails.subscriptionOfferDetails;
      if (index == null || offers == null || index >= offers.length) continue;
      final SubscriptionOfferDetailsWrapper offer = offers[index];
      final bool basePlanMatches = offer.basePlanId == mapping.basePlanId;
      final bool offerMatches = mapping.offerId.isEmpty
          ? offer.offerId == null
          : offer.offerId == mapping.offerId;
      if (basePlanMatches && offerMatches) return item;
    }
    return null;
  }

  String _selectionKey(StoreProviderProductModel product) {
    return '${product.productId}|${product.basePlanId}|${product.offerId}';
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final PurchaseDetails purchase in purchases) {
      if (!_purchaseController.isClosed) _purchaseController.add(purchase);
    }
  }

  @override
  void onClose() {
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_purchaseController.close());
    super.onClose();
  }
}
