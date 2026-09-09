import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:italir_pothe/core/utils/app_logger.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/pro_checkout_models.dart';

class CourseGooglePlayBillingService extends GetxService {
  CourseGooglePlayBillingService({
    required StorageService storageService,
    required UserSessionController userSessionController,
  }) : _storageService = storageService,
       _userSessionController = userSessionController;

  static const String _pendingKeyPrefix = 'course_pending_google_play_purchase';
  static const String _legacyPendingKey = 'course_pending_google_play_purchase';

  static final RegExp _sha256Pattern = RegExp(r'^[a-f0-9]{64}$');

  final StorageService _storageService;
  final UserSessionController _userSessionController;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? _productDetails;
  final Map<String, PurchaseDetails> _latestPurchases =
      <String, PurchaseDetails>{};
  Future<void>? _initialization;

  bool pendingPurchaseQueryFailed = false;

  final RxBool isAvailable = false.obs;
  final RxBool isLoadingProduct = false.obs;
  final RxString lastError = ''.obs;

  Stream<PurchaseDetails> get purchaseUpdates => _purchaseController.stream;

  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

  String get localizedPrice => _productDetails?.price ?? '';

  String get localizedTitle => _productDetails?.title.trim() ?? '';

  int? get subscriptionPeriodCount {
    final ProductDetails? details = _productDetails;
    if (details is AppStoreProduct2Details) {
      return details.sk2Product.subscription?.subscriptionPeriod.value;
    }
    if (details is AppStoreProductDetails) {
      return details.skProduct.subscriptionPeriod?.numberOfUnits;
    }
    return null;
  }

  String? get subscriptionPeriodUnit {
    final ProductDetails? details = _productDetails;
    if (details is AppStoreProduct2Details) {
      return details.sk2Product.subscription?.subscriptionPeriod.unit.name;
    }
    if (details is AppStoreProductDetails) {
      return details.skProduct.subscriptionPeriod?.unit.name;
    }
    return null;
  }

  String get localizedCurrencyCode => _productDetails?.currencyCode ?? '';

  String get currentAppUserId =>
      _userSessionController.user.value?.id.trim() ?? '';

  String? get _currentPendingKey {
    final String userId = currentAppUserId;
    if (userId.isEmpty) {
      return null;
    }

    return '${_pendingKeyPrefix}_$userId';
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
      (List<PurchaseDetails> purchases) {
        for (final PurchaseDetails purchase in purchases) {
          _latestPurchases[purchase.productID] = purchase;
          if (!_purchaseController.isClosed) {
            _purchaseController.add(purchase);
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        lastError.value = '$_storeName purchase updates failed.';

        AppLogger.log(
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
        lastError.value =
            '$_storeName purchases are unavailable on this device.';
      }
    } catch (error, stackTrace) {
      isAvailable.value = false;
      lastError.value = 'Could not connect to $_storeName.';

      AppLogger.log(
        lastError.value,
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> prepareProduct(ProStoreProductModel product) async {
    await initialize();

    final String expectedProvider = Platform.isAndroid
        ? 'google_play'
        : Platform.isIOS
        ? 'app_store'
        : '';
    final bool isSupportedMapping =
        product.isActive &&
        product.provider.toLowerCase() == expectedProvider &&
        (product.productType.toLowerCase() == 'non_consumable' ||
            product.productType.toLowerCase() == 'subscription') &&
        product.productId.trim().isNotEmpty;

    if (!isAvailable.value || !isSupportedMapping) {
      lastError.value =
          'This course has no active purchase option for this platform.';
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

      final List<ProductDetails> matching = response.productDetails
          .where((ProductDetails item) => item.id == product.productId)
          .toList(growable: false);
      if (Platform.isAndroid && product.productType == 'subscription') {
        _productDetails = null;
        for (final GooglePlayProductDetails item
            in matching.whereType<GooglePlayProductDetails>()) {
          final int? index = item.subscriptionIndex;
          if (index == null) continue;
          final offer = item.productDetails.subscriptionOfferDetails![index];
          if (offer.basePlanId == product.basePlanId &&
              (product.offerId.isEmpty || offer.offerId == product.offerId)) {
            _productDetails = item;
            break;
          }
        }
      } else {
        _productDetails = matching.firstOrNull;
      }

      if (_productDetails == null) {
        lastError.value = 'This purchase option is not available in the store.';
        return false;
      }

      return true;
    } catch (error, stackTrace) {
      lastError.value = 'Could not load this course from $_storeName.';

      AppLogger.log(
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
    final bool ready =
        _productDetails?.id == product.productId ||
        await prepareProduct(product);

    if (!ready || _productDetails == null) {
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
        name: 'CourseGooglePlayBillingService',
      );

      return false;
    }

    await savePendingPurchase(pendingPurchase);

    try {
      final PurchaseParam purchaseParam = Platform.isAndroid
          ? GooglePlayPurchaseParam(
              productDetails: _productDetails!,
              applicationUserName: obfuscatedAccountId,
              offerToken: _productDetails is GooglePlayProductDetails
                  ? (_productDetails! as GooglePlayProductDetails).offerToken
                  : null,
            )
          : PurchaseParam(
              productDetails: _productDetails!,
              applicationUserName: pendingPurchase.orderId,
            );

      final bool launched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!launched) {
        await clearPendingPurchase();
      }

      return launched;
    } catch (error, stackTrace) {
      /*
       * Keep the pending backend order. An exception can occur after Google
       * Play has already started processing the billing flow.
       */
      lastError.value =
          '$_storeName could not confirm that the purchase screen started.';

      AppLogger.log(
        lastError.value,
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<PurchaseDetails?> queryOwnedPurchase(String productId) async {
    pendingPurchaseQueryFailed = false;

    final String normalizedProductId = productId.trim();

    if ((!Platform.isAndroid && !Platform.isIOS) ||
        normalizedProductId.isEmpty) {
      return null;
    }

    await initialize();

    if (!isAvailable.value) {
      return null;
    }

    try {
      if (Platform.isAndroid) {
        final InAppPurchaseAndroidPlatformAddition addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final QueryPurchaseDetailsResponse response = await addition
            .queryPastPurchases();
        if (response.error != null) throw StateError(response.error!.message);
        return response.pastPurchases.firstWhereOrNull(
          (PurchaseDetails purchase) =>
              purchase.productID == normalizedProductId,
        );
      }

      return await _restoreAppStorePurchase(normalizedProductId);
    } catch (error, stackTrace) {
      pendingPurchaseQueryFailed = true;

      AppLogger.log(
        'Could not query owned $_storeName course purchases.',
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );

      return null;
    }
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
      // Do not interpret a slow StoreKit response as "not purchased".
      pendingPurchaseQueryFailed = true;
      AppLogger.log(
        'App Store course restore did not complete before the timeout.',
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<PurchaseDetails?> queryPendingPurchase() async {
    final ProPendingGooglePlayPurchaseModel? pending = loadPendingPurchase();

    if (pending == null) {
      pendingPurchaseQueryFailed = false;
      return null;
    }

    if (!Platform.isIOS) return queryOwnedPurchase(pending.productId);

    pendingPurchaseQueryFailed = false;
    await initialize();
    if (!isAvailable.value) return null;
    try {
      final PurchaseDetails? latest = _latestPurchases[pending.productId];
      if (latest is SK2PurchaseDetails &&
          latest.appAccountToken?.trim().toLowerCase() ==
              pending.orderId.trim().toLowerCase()) {
        return latest;
      }

      final List<SK2Transaction> transactions =
          await SK2Transaction.unfinishedTransactions();
      final SK2Transaction? transaction = transactions.firstWhereOrNull(
        (SK2Transaction item) =>
            item.productId == pending.productId &&
            item.appAccountToken?.trim().toLowerCase() ==
                pending.orderId.trim().toLowerCase(),
      );
      if (transaction == null) return null;

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
    } catch (error, stackTrace) {
      pendingPurchaseQueryFailed = true;
      AppLogger.log(
        'Could not query unfinished App Store course purchases.',
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
    final String? key = _currentPendingKey;

    if (key == null) {
      return null;
    }

    final ProPendingGooglePlayPurchaseModel? pending = _readPendingPurchase(
      key,
    );

    if (pending == null) {
      return null;
    }

    if (pending.appUserId != currentAppUserId) {
      unawaited(_storageService.remove(key));
      return null;
    }

    return pending;
  }

  ProPendingGooglePlayPurchaseModel? loadLegacyPendingPurchase() {
    final ProPendingGooglePlayPurchaseModel? pending = _readPendingPurchase(
      _legacyPendingKey,
    );

    if (pending == null || pending.appUserId.isNotEmpty) {
      return null;
    }

    return pending;
  }

  Future<void> adoptLegacyPendingPurchase(
    ProPendingGooglePlayPurchaseModel legacyPending,
  ) async {
    final String userId = currentAppUserId;

    if (userId.isEmpty) {
      throw StateError(
        'The current application user is unavailable for purchase recovery.',
      );
    }

    await savePendingPurchase(legacyPending.copyWith(appUserId: userId));
    await clearLegacyPendingPurchase();
  }

  Future<void> savePendingPurchase(
    ProPendingGooglePlayPurchaseModel pendingPurchase,
  ) {
    final String? key = _currentPendingKey;

    if (key == null || pendingPurchase.appUserId != currentAppUserId) {
      throw StateError(
        'The pending purchase does not belong to the current app user.',
      );
    }

    return _storageService.writeString(
      key,
      jsonEncode(pendingPurchase.toJson()),
    );
  }

  Future<void> clearPendingPurchase() async {
    final String? key = _currentPendingKey;

    if (key != null) {
      await _storageService.remove(key);
    }
  }

  Future<void> clearLegacyPendingPurchase() {
    return _storageService.remove(_legacyPendingKey);
  }

  ProPendingGooglePlayPurchaseModel? _readPendingPurchase(String key) {
    final String? raw = _storageService.readString(key);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return null;
      }

      return ProPendingGooglePlayPurchaseModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (error, stackTrace) {
      AppLogger.log(
        'Could not read the pending course purchase.',
        name: 'CourseGooglePlayBillingService',
        error: error,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  @override
  void onClose() {
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_purchaseController.close());
    super.onClose();
  }
}
