import 'dart:async';
import 'dart:convert';
import 'package:italir_pothe/core/utils/app_logger.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/controllers/user_session_controller.dart';
import '../models/google_play_billing_models.dart';
import '../models/shop_models.dart';

class StoreBillingPeriod {
  const StoreBillingPeriod({required this.count, required this.unit});

  final int count;
  final String unit;
}

class GooglePlayBillingService extends GetxService {
  GooglePlayBillingService({
    required StorageService storageService,
    required UserSessionController userSessionController,
  }) : _storageService = storageService,
       _userSessionController = userSessionController;

  static const String _pendingPurchaseKeyPrefix =
      'package_store_pending_google_play_purchase';
  static const String _legacyPendingPurchaseKey =
      'package_store_pending_google_play_purchase';
  static final RegExp _sha256Pattern = RegExp(r'^[a-f0-9]{64}$');

  final StorageService _storageService;
  final UserSessionController _userSessionController;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();
  final Map<String, ProductDetails> _productsBySelection =
      <String, ProductDetails>{};
  final Map<String, PurchaseDetails> _latestPurchases =
      <String, PurchaseDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Future<void>? _initialization;
  bool _pendingPurchaseQueryFailed = false;
  bool _lastLaunchWasDuplicateAppStoreTransaction = false;

  final RxBool isAvailable = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString lastError = ''.obs;

  Stream<PurchaseDetails> get purchaseUpdates => _purchaseController.stream;
  bool get pendingPurchaseQueryFailed => _pendingPurchaseQueryFailed;
  bool get lastLaunchWasDuplicateAppStoreTransaction =>
      _lastLaunchWasDuplicateAppStoreTransaction;
  String get _provider => Platform.isIOS ? 'app_store' : 'google_play';
  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';
  String get currentAppUserId =>
      _userSessionController.user.value?.id.trim() ?? '';
  String? get _currentPendingPurchaseKey {
    final String userId = currentAppUserId;
    return userId.isEmpty ? null : '${_pendingPurchaseKeyPrefix}_$userId';
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(initialize());
  }

  Future<void> initialize() {
    return _initialization ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      lastError.value = 'Store billing is available only on Android or iOS.';
      return;
    }

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        lastError.value = '$_storeName purchase updates failed.';
        AppLogger.log(
          lastError.value,
          name: 'GooglePlayBillingService',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    try {
      isAvailable.value = await _inAppPurchase.isAvailable();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      AppLogger.log(
        'Store initialized: provider=$_provider, available=${isAvailable.value}, '
        'package=${packageInfo.packageName}, version=${packageInfo.version}, '
        'build=${packageInfo.buildNumber}.',
        name: 'GooglePlayBillingService',
      );
      if (!isAvailable.value) {
        lastError.value = '$_storeName is unavailable on this device.';
      }
    } catch (error, stackTrace) {
      isAvailable.value = false;
      lastError.value = 'Could not connect to $_storeName.';
      AppLogger.log(
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
              item.isActive &&
              item.provider.toLowerCase() == _provider &&
              item.productId.isNotEmpty,
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
      AppLogger.log(
        'Querying $_storeName products: ${identifiers.join(', ')}.',
        name: 'GooglePlayBillingService',
      );
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(identifiers);

      AppLogger.log(
        '$_storeName product query result: '
        'returned=${response.productDetails.map((item) => item.id).join(', ')}, '
        'notFound=${response.notFoundIDs.join(', ')}, '
        'error=${response.error}.',
        name: 'GooglePlayBillingService',
      );

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
            '$_storeName products are not available: ${unresolved.join(', ')}';
      }
    } catch (error, stackTrace) {
      lastError.value = 'Could not load $_storeName products.';
      AppLogger.log(
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

  /// The price the current storefront will actually present for this mapping.
  /// For App Store promotional offers this uses the StoreKit offer price,
  /// rather than a backend or hard-coded currency amount.
  String? localizedPurchasePrice(StoreProviderProductModel? mapping) {
    if (mapping == null) return null;
    final ProductDetails? details =
        _productsBySelection[_selectionKey(mapping)];
    if (details == null) return null;

    if (!Platform.isIOS || !mapping.isSubscription || mapping.offerId.isEmpty) {
      return details.price;
    }

    if (details is AppStoreProduct2Details) {
      final Iterable<SK2SubscriptionOffer> offers =
          details.sk2Product.subscription?.promotionalOffers ??
          const <SK2SubscriptionOffer>[];
      for (final SK2SubscriptionOffer offer in offers) {
        if (offer.id == mapping.offerId) {
          return _formatStorePrice(details, offer.price);
        }
      }
    } else if (details is AppStoreProductDetails) {
      for (final SKProductDiscountWrapper offer
          in details.skProduct.discounts) {
        if (offer.identifier == mapping.offerId) {
          final double? price = double.tryParse(offer.price);
          if (price != null) return _formatStorePrice(details, price);
        }
      }
    }

    // Never show a regular or backend price for a promotional purchase whose
    // exact StoreKit offer price could not be resolved.
    return null;
  }

  String? localizedTitle(StoreProviderProductModel? mapping) {
    if (mapping == null) return null;
    final String? title = _productsBySelection[_selectionKey(mapping)]?.title
        .trim();
    return title == null || title.isEmpty ? null : title;
  }

  StoreBillingPeriod? subscriptionPeriod(StoreProviderProductModel? mapping) {
    if (mapping == null || !mapping.isSubscription) return null;
    final ProductDetails? details =
        _productsBySelection[_selectionKey(mapping)];

    if (details is AppStoreProduct2Details) {
      final SK2SubscriptionPeriod? period =
          details.sk2Product.subscription?.subscriptionPeriod;
      if (period == null) return null;
      return StoreBillingPeriod(count: period.value, unit: period.unit.name);
    }

    if (details is AppStoreProductDetails) {
      final SKProductSubscriptionPeriodWrapper? period =
          details.skProduct.subscriptionPeriod;
      if (period == null) return null;
      return StoreBillingPeriod(
        count: period.numberOfUnits,
        unit: period.unit.name,
      );
    }

    return null;
  }

  String _formatStorePrice(ProductDetails details, double price) {
    final locale = Get.locale;
    final String? localeName = locale == null
        ? null
        : locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    return NumberFormat.currency(
      locale: localeName,
      name: details.currencyCode,
      symbol: details.currencySymbol,
    ).format(price);
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
    _lastLaunchWasDuplicateAppStoreTransaction = false;
    await initialize();
    if (!isAvailable.value) return false;

    final StoreProviderProductModel mapping = StoreProviderProductModel(
      id: '',
      provider: pendingPurchase.provider,
      productId: pendingPurchase.productId,
      productType: pendingPurchase.productType,
      basePlanId: pendingPurchase.basePlanId,
      offerId: pendingPurchase.offerId,
      isActive: true,
    );
    ProductDetails? details = _productsBySelection[_selectionKey(mapping)];
    if (details == null) {
      AppLogger.log(
        'No cached $_storeName product for selection=${_selectionKey(mapping)}; '
        'retrying product lookup.',
        name: 'GooglePlayBillingService',
      );
      await prepareProducts(<StoreProviderProductModel>[mapping]);
      details = _productsBySelection[_selectionKey(mapping)];
    }
    if (details == null) {
      AppLogger.log(
        'Purchase blocked because $_storeName returned no matching product for '
        'selection=${_selectionKey(mapping)}. Last lookup error: ${lastError.value}',
        name: 'GooglePlayBillingService',
      );
      lastError.value = 'The selected $_storeName product is unavailable.';
      return false;
    }

    final String obfuscatedAccountId = pendingPurchase.obfuscatedAccountId
        .trim()
        .toLowerCase();

    if (Platform.isAndroid && !_sha256Pattern.hasMatch(obfuscatedAccountId)) {
      lastError.value =
          'The purchase could not be securely linked to your account.';

      AppLogger.log(
        'Invalid Google Play obfuscated account ID.',
        name: 'GooglePlayBillingService',
      );

      return false;
    }

    await savePendingPurchase(pendingPurchase);
    try {
      if (Platform.isIOS && pendingPurchase.offerType == 'offer_code') {
        final InAppPurchaseStoreKitPlatformAddition addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await addition.presentCodeRedemptionSheet();
        return true;
      }

      late final PurchaseParam purchaseParam;
      if (Platform.isAndroid) {
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: details,
          applicationUserName: obfuscatedAccountId,
          offerToken:
              pendingPurchase.productType ==
                  StoreProviderProductType.subscription
              ? (details as GooglePlayProductDetails).offerToken
              : null,
        );
      } else if (pendingPurchase.productType ==
              StoreProviderProductType.subscription &&
          pendingPurchase.offerId.isNotEmpty) {
        final AppStorePromotionalOfferModel? offer =
            pendingPurchase.appStorePromotionalOffer;
        if (offer == null ||
            !offer.isComplete ||
            offer.offerId != pendingPurchase.offerId) {
          await clearPendingPurchase();
          lastError.value =
              'The App Store discount could not be securely prepared.';
          return false;
        }

        purchaseParam = Sk2PurchaseParam(
          productDetails: details,
          applicationUserName: pendingPurchase.orderId,
          promotionalOffer: SK2PromotionalOffer(
            offerId: offer.offerId,
            signature: SK2SubscriptionOfferSignature(
              keyID: offer.keyId,
              nonce: offer.nonce,
              timestamp: offer.timestamp,
              signature: offer.signature,
            ),
          ),
        );
      } else {
        purchaseParam = PurchaseParam(
          productDetails: details,
          // StoreKit sends this UUID back as appAccountToken. The backend
          // verifies it against the order before granting entitlements.
          applicationUserName: pendingPurchase.orderId,
        );
      }
      final bool launched;
      if (pendingPurchase.productType == StoreProviderProductType.consumable) {
        /*
         * Android must not auto-consume before backend verification. On iOS,
         * StoreKit ignores this option and the Flutter plugin requires its
         * default value. The transaction still remains unfinished until
         * finishVerifiedPurchase calls completePurchase below.
         */
        launched = Platform.isAndroid
            ? await _inAppPurchase.buyConsumable(
                purchaseParam: purchaseParam,
                autoConsume: false,
              )
            : await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        launched = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }
      if (!launched) await clearPendingPurchase();
      return launched;
    } catch (error, stackTrace) {
      _lastLaunchWasDuplicateAppStoreTransaction =
          Platform.isIOS &&
          error is PlatformException &&
          error.code == 'storekit_duplicate_product_object';
      if (!_lastLaunchWasDuplicateAppStoreTransaction) {
        await clearPendingPurchase();
      }
      lastError.value = _lastLaunchWasDuplicateAppStoreTransaction
          ? 'A previous App Store purchase is still being recovered.'
          : '$_storeName could not start the purchase.';
      AppLogger.log(
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
    if (pending == null || (!Platform.isAndroid && !Platform.isIOS)) {
      return null;
    }
    await initialize();
    if (!isAvailable.value) return null;

    try {
      if (Platform.isAndroid) {
        final InAppPurchaseAndroidPlatformAddition addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final QueryPurchaseDetailsResponse response = await addition
            .queryPastPurchases();
        if (response.error != null) {
          throw StateError(response.error!.message);
        }
        for (final GooglePlayPurchaseDetails purchase
            in response.pastPurchases) {
          if (purchase.productID == pending.productId) return purchase;
        }
        return null;
      }

      final PurchaseDetails? latest = _latestPurchases[pending.productId];
      if (latest != null && _matchesPendingAppStorePurchase(latest, pending)) {
        return latest;
      }

      if (pending.productType == StoreProviderProductType.consumable) {
        return _queryUnfinishedAppStorePurchase(pending);
      }

      return await _restoreAppStorePurchase(pending.productId);
    } catch (error, stackTrace) {
      _pendingPurchaseQueryFailed = true;
      AppLogger.log(
        'Could not recover the pending Google Play purchase.',
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<PurchaseDetails?> _queryUnfinishedAppStorePurchase(
    PendingGooglePlayPurchaseModel pending,
  ) async {
    final List<SK2Transaction> transactions =
        await SK2Transaction.unfinishedTransactions();
    final SK2Transaction? transaction = transactions.firstWhereOrNull(
      (SK2Transaction item) =>
          item.productId == pending.productId &&
          item.appAccountToken?.trim().toLowerCase() ==
              pending.orderId.trim().toLowerCase(),
    );
    if (transaction == null) return null;

    return _appStorePurchaseDetails(transaction);
  }

  /// Returns an unfinished StoreKit 2 transaction even when this installation
  /// no longer has the local pending-order record that originally created it.
  /// The caller must verify the transaction against the backend order encoded
  /// in [SK2PurchaseDetails.appAccountToken] before completing it.
  Future<PurchaseDetails?> queryUnfinishedAppStorePurchase(
    String productId,
  ) async {
    _pendingPurchaseQueryFailed = false;
    final String normalizedProductId = productId.trim();
    if (!Platform.isIOS || normalizedProductId.isEmpty) return null;

    await initialize();
    if (!isAvailable.value) return null;

    try {
      final List<SK2Transaction> transactions =
          await SK2Transaction.unfinishedTransactions();
      final SK2Transaction? transaction = transactions.firstWhereOrNull(
        (SK2Transaction item) => item.productId == normalizedProductId,
      );
      return transaction == null ? null : _appStorePurchaseDetails(transaction);
    } catch (error, stackTrace) {
      _pendingPurchaseQueryFailed = true;
      AppLogger.log(
        'Could not query unfinished App Store purchases.',
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  SK2PurchaseDetails _appStorePurchaseDetails(SK2Transaction transaction) {
    return SK2PurchaseDetails(
      productID: transaction.productId,
      purchaseID: transaction.id,
      verificationData: PurchaseVerificationData(
        localVerificationData: transaction.jsonRepresentation ?? '',
        serverVerificationData: transaction.receiptData ?? '',
        source: 'app_store',
      ),
      transactionDate: transaction.purchaseDate,
      status: PurchaseStatus.purchased,
      appAccountToken: transaction.appAccountToken,
    );
  }

  bool _matchesPendingAppStorePurchase(
    PurchaseDetails purchase,
    PendingGooglePlayPurchaseModel pending,
  ) {
    return purchase is SK2PurchaseDetails &&
        purchase.appAccountToken?.trim().toLowerCase() ==
            pending.orderId.trim().toLowerCase();
  }

  Future<PurchaseDetails?> _restoreAppStorePurchase(String productId) async {
    final Future<PurchaseDetails> matchingUpdate = purchaseUpdates
        .where(
          (PurchaseDetails purchase) =>
              purchase.productID == productId &&
              (purchase.status == PurchaseStatus.purchased ||
                  purchase.status == PurchaseStatus.restored),
        )
        .first;

    await _inAppPurchase.restorePurchases();

    final PurchaseDetails? immediate = _latestPurchases[productId];
    if (immediate != null &&
        (immediate.status == PurchaseStatus.purchased ||
            immediate.status == PurchaseStatus.restored)) {
      return immediate;
    }

    try {
      return await matchingUpdate.timeout(const Duration(seconds: 15));
    } on TimeoutException catch (error, stackTrace) {
      // A timeout is an indeterminate StoreKit response, not proof that the
      // customer has no purchase. Keep the pending order for a later retry.
      _pendingPurchaseQueryFailed = true;
      AppLogger.log(
        'App Store restore did not complete before the recovery timeout.',
        name: 'GooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<PurchaseDetails?> restoreAppStoreSubscription(String productId) async {
    if (!Platform.isIOS || productId.trim().isEmpty) return null;
    await initialize();
    if (!isAvailable.value) return null;
    _pendingPurchaseQueryFailed = false;
    return _restoreAppStorePurchase(productId.trim());
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

    await _inAppPurchase.completePurchase(purchase);
  }

  PendingGooglePlayPurchaseModel? loadPendingPurchase() {
    final String? key = _currentPendingPurchaseKey;
    if (key == null) return null;
    final String? raw = _storageService.readString(key);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final PendingGooglePlayPurchaseModel pending =
          PendingGooglePlayPurchaseModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );
      if (pending.appUserId != currentAppUserId) {
        unawaited(_storageService.remove(key));
        return null;
      }
      return pending;
    } catch (error, stackTrace) {
      AppLogger.log(
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
    final String? key = _currentPendingPurchaseKey;
    if (key == null || pendingPurchase.appUserId != currentAppUserId) {
      throw StateError(
        'The pending purchase does not belong to the current app user.',
      );
    }
    await _storageService.writeString(
      key,
      jsonEncode(pendingPurchase.toJson()),
    );
  }

  Future<void> clearPendingPurchase() async {
    final String? key = _currentPendingPurchaseKey;
    if (key != null) await _storageService.remove(key);
  }

  PendingGooglePlayPurchaseModel? loadLegacyPendingPurchase() {
    final String? raw = _storageService.readString(_legacyPendingPurchaseKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final PendingGooglePlayPurchaseModel pending =
          PendingGooglePlayPurchaseModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );
      return pending.appUserId.isEmpty ? pending : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> adoptLegacyPendingPurchase(
    PendingGooglePlayPurchaseModel legacyPending,
  ) async {
    if (currentAppUserId.isEmpty) {
      throw StateError('The current application user is unavailable.');
    }
    await savePendingPurchase(
      legacyPending.copyWith(appUserId: currentAppUserId),
    );
    await _storageService.remove(_legacyPendingPurchaseKey);
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

    if (Platform.isIOS) {
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
      _latestPurchases[purchase.productID] = purchase;
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
