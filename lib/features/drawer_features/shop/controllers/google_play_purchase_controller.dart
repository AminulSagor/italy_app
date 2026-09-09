import 'dart:async';
import 'dart:io';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/api_error_handler.dart';
import '../models/google_play_billing_models.dart';
import '../models/shop_models.dart';
import '../models/shop_order_models.dart';
import '../services/app_store_purchase_recovery.dart';
import '../services/google_play_billing_service.dart';
import '../services/shop_api_service.dart';

class GooglePlayPurchaseController extends GetxController
    with WidgetsBindingObserver {
  GooglePlayPurchaseController({
    required ShopApiService apiService,
    required GooglePlayBillingService billingService,
  }) : _apiService = apiService,
       _billingService = billingService;

  static const Uuid _uuid = Uuid();

  static const Duration _purchaseWait = Duration(minutes: 2);

  static const Duration _billingReturnDelay = Duration(milliseconds: 900);

  final ShopApiService _apiService;
  final GooglePlayBillingService _billingService;

  final StreamController<StorePurchaseCompletionModel> _completionController =
      StreamController<StorePurchaseCompletionModel>.broadcast();

  final Set<String> _processingPurchases = <String>{};

  StreamSubscription<PurchaseDetails>? _purchaseSubscription;

  Completer<GooglePlayPurchaseOutcome>? _activeCompleter;

  bool _billingFlowActive = false;
  bool _resumeReconciliationRunning = false;

  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<StorePurchaseCompletionModel> lastCompletion =
      Rxn<StorePurchaseCompletionModel>();

  String get _provider => Platform.isIOS ? 'app_store' : 'google_play';
  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

  Stream<StorePurchaseCompletionModel> get completionStream =>
      _completionController.stream;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _purchaseSubscription = _billingService.purchaseUpdates.listen(
      (PurchaseDetails purchase) {
        unawaited(_handlePurchase(purchase));
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.log(
          'Google Play purchase stream failed.',
          name: 'GooglePlayPurchaseController',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  @override
  void onReady() {
    super.onReady();

    unawaited(retryPendingPurchase());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _billingFlowActive) {
      unawaited(_reconcileReturnedBillingFlow());
    }
  }

  Future<GooglePlayPurchaseOutcome> startPurchase({
    required StorePackageModel package,
    required StoreProviderProductModel storeProduct,
    required RefillCurrency currency,
    required String couponCode,
  }) async {
    if (isProcessing.value) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.pending,
        message: 'A store purchase is already being processed.',
      );
    }

    if (_billingService.currentAppUserId.isEmpty) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'Your account is still loading. Please try again shortly.',
      );
    }

    final String requestedProductId = storeProduct.productId.trim();

    final String requestedBasePlanId = storeProduct.basePlanId.trim();

    final String requestedOfferId = storeProduct.offerId.trim();

    if (requestedProductId.isEmpty) {
      return GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'This package has no $_storeName product ID.',
      );
    }

    if (Platform.isAndroid &&
        storeProduct.isSubscription &&
        requestedBasePlanId.isEmpty) {
      return GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'This subscription has no Google Play base plan ID.',
      );
    }

    /*
     * First reconcile any previous purchase stored
     * on the device.
     */
    final PendingGooglePlayPurchaseModel? existing = _billingService
        .loadPendingPurchase();

    if (existing != null) {
      final bool purchaseFound = await retryPendingPurchase();

      final StorePurchaseCompletionModel? recovered = lastCompletion.value;

      if (recovered != null && recovered.orderId == existing.orderId) {
        return GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.completed,
          message: recovered.message,
          completion: recovered,
        );
      }

      if (purchaseFound && _billingService.loadPendingPurchase() != null) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.pending,
          message: 'Your previous store purchase is still pending.',
        );
      }

      if (!purchaseFound && _billingService.pendingPurchaseQueryFailed) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.pending,
          message: 'The store could not confirm the previous purchase yet.',
        );
      }

      /*
       * Google Play has no matching purchase and the
       * backend order is not completed. Cancel the old
       * backend order before creating another one.
       */
      await _cancelUnfinishedOrder(
        existing.orderId,
        reason: 'Previous store checkout did not create a purchase.',
      );

      await _billingService.clearPendingPurchase();
    }

    if (Platform.isIOS) {
      final GooglePlayPurchaseOutcome? recovered =
          await _recoverUnfinishedAppStorePurchase(
            package: package,
            storeProduct: storeProduct,
          );
      if (recovered != null) return recovered;
    }

    isProcessing.value = true;
    errorMessage.value = '';

    String createdOrderId = '';

    try {
      final ApiResult<PendingGooglePlayPurchaseModel> orderResult =
          await ApiErrorHandler.call<PendingGooglePlayPurchaseModel>(() async {
            final StoreOrderModel order = await _apiService.createOrder(
              CreateStoreOrderPayloadModel(
                packageId: package.id,
                currency: currency,
                paymentProvider: _provider,
                productId: requestedProductId,
                idempotencyKey: _uuid.v4(),
                couponCode: couponCode,
              ),
            );

            /*
           * This assignment is essential. It allows
           * us to cancel the backend order if checkout
           * preparation fails afterward.
           */
            createdOrderId = order.id;

            final String obfuscatedAccountId = order
                .googlePlayObfuscatedAccountId
                .trim()
                .toLowerCase();

            if (Platform.isAndroid && obfuscatedAccountId.isEmpty) {
              throw StateError(
                'Google Play account binding information is missing.',
              );
            }

            final StoreCheckoutResponseModel checkout = await _apiService
                .getCheckout(order.id);

            final StoreProviderOptionModel paymentMethod =
                checkout.paymentMethod;

            final String serverProductId = paymentMethod.productId.trim();

            final String resolvedProductId = serverProductId.isNotEmpty
                ? serverProductId
                : requestedProductId;

            final StoreProviderProductType resolvedProductType =
                serverProductId.isNotEmpty
                ? paymentMethod.productType
                : storeProduct.productType;

            final String resolvedBasePlanId =
                paymentMethod.basePlanId.trim().isNotEmpty
                ? paymentMethod.basePlanId.trim()
                : requestedBasePlanId;

            final String resolvedOfferId =
                paymentMethod.offerId.trim().isNotEmpty
                ? paymentMethod.offerId.trim()
                : requestedOfferId;
            final String resolvedOfferType = paymentMethod.offerType.trim();

            if (resolvedProductId.isEmpty) {
              throw StateError(
                'Google Play product ID is missing from checkout.',
              );
            }

            if (Platform.isAndroid &&
                resolvedProductType == StoreProviderProductType.subscription &&
                resolvedBasePlanId.isEmpty) {
              throw StateError(
                'Google Play base plan ID is missing from checkout.',
              );
            }

            return PendingGooglePlayPurchaseModel(
              appUserId: _billingService.currentAppUserId,
              orderId: order.id,
              packageId: package.id,
              provider: _provider,
              productId: resolvedProductId,
              productType: resolvedProductType,
              basePlanId: resolvedBasePlanId,
              offerId: resolvedOfferId,
              offerType: resolvedOfferType,
              obfuscatedAccountId: obfuscatedAccountId,
              createdAt: DateTime.now(),
              appStorePromotionalOffer: paymentMethod.promotionalOffer,
            );
          }, showError: false);

      if (!orderResult.isSuccess || orderResult.data == null) {
        if (createdOrderId.isNotEmpty) {
          await _cancelUnfinishedOrder(
            createdOrderId,
            reason: 'Checkout preparation failed before the store opened.',
          );
        }

        final String message =
            orderResult.error ?? 'Could not prepare the store purchase.';

        errorMessage.value = message;

        return GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: message,
        );
      }

      final PendingGooglePlayPurchaseModel pending = orderResult.data!;

      final Completer<GooglePlayPurchaseOutcome> completer =
          Completer<GooglePlayPurchaseOutcome>();

      _activeCompleter = completer;
      _billingFlowActive = true;

      final bool launched = await _billingService.launchPurchase(pending);

      if (!launched) {
        _billingFlowActive = false;

        if (_billingService.lastLaunchWasDuplicateAppStoreTransaction) {
          await _cancelUnfinishedOrder(
            pending.orderId,
            reason:
                'A different unfinished StoreKit transaction already exists for this product.',
          );
          await _billingService.clearPendingPurchase();
          _clearActivePurchase();

          final GooglePlayPurchaseOutcome? recovered =
              await _recoverUnfinishedAppStorePurchase(
                package: package,
                storeProduct: storeProduct,
              );
          if (recovered != null) return recovered;
        }

        await _cancelUnfinishedOrder(
          pending.orderId,
          reason: 'The store billing flow could not be opened.',
        );

        await _billingService.clearPendingPurchase();

        _clearActivePurchase();

        final String message = _billingService.lastError.value.isNotEmpty
            ? _billingService.lastError.value
            : 'The store could not start the purchase.';

        errorMessage.value = message;

        return GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: message,
        );
      }

      return await completer.future.timeout(
        _purchaseWait,
        onTimeout: () {
          /*
           * Do not cancel the backend order on timeout.
           * Google Play may still be processing a
           * delayed or pending payment.
           */
          _billingFlowActive = false;
          _clearActivePurchase();

          return const GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.pending,
            message:
                'The purchase is pending. It will be verified automatically.',
          );
        },
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> retryPendingPurchase() async {
    PendingGooglePlayPurchaseModel? pending = _billingService
        .loadPendingPurchase();

    if (pending == null) {
      final PendingGooglePlayPurchaseModel? legacy = _billingService
          .loadLegacyPendingPurchase();
      if (legacy != null) {
        await _billingService.adoptLegacyPendingPurchase(legacy);
        pending = _billingService.loadPendingPurchase();
      }
    }

    if (pending == null) {
      return false;
    }

    final PurchaseDetails? purchase = await _billingService
        .queryPendingPurchase();

    if (purchase != null) {
      await _handlePurchase(purchase);

      return true;
    }

    if (_billingService.pendingPurchaseQueryFailed) {
      return false;
    }

    /*
     * A consumable can disappear from Google's
     * owned-purchase response after the backend
     * consumes it. Check whether the backend order
     * already completed before removing local state.
     */
    final StorePurchaseCompletionModel? recovered =
        await _recoverCompletedOrder(pending.orderId);

    if (recovered == null) {
      return false;
    }

    await _billingService.clearPendingPurchase();

    lastCompletion.value = recovered;

    if (!_completionController.isClosed) {
      _completionController.add(recovered);
    }

    return true;
  }

  Future<GooglePlayPurchaseOutcome?> _recoverUnfinishedAppStorePurchase({
    required StorePackageModel package,
    required StoreProviderProductModel storeProduct,
  }) async {
    final PurchaseDetails? purchase = await _billingService
        .queryUnfinishedAppStorePurchase(storeProduct.productId);

    if (purchase == null) {
      if (_billingService.pendingPurchaseQueryFailed) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.pending,
          message:
              'The App Store could not check a previous purchase yet. Please try again.',
        );
      }
      return null;
    }

    final String originalOrderId = appStoreOrderIdFromPurchase(purchase);
    if (originalOrderId.isEmpty) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message:
            'A previous App Store transaction cannot be linked to its order. Please contact support.',
      );
    }

    final PendingGooglePlayPurchaseModel recoveredPending =
        PendingGooglePlayPurchaseModel(
          appUserId: _billingService.currentAppUserId,
          orderId: originalOrderId,
          packageId: package.id,
          provider: 'app_store',
          productId: storeProduct.productId,
          productType: storeProduct.productType,
          basePlanId: storeProduct.basePlanId,
          offerId: storeProduct.offerId,
          offerType: '',
          obfuscatedAccountId: '',
          createdAt: DateTime.now(),
        );

    await _billingService.savePendingPurchase(recoveredPending);
    lastCompletion.value = null;
    await _handlePurchase(purchase);

    final StorePurchaseCompletionModel? completion = lastCompletion.value;
    if (completion != null && completion.orderId == originalOrderId) {
      return GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.completed,
        message: completion.message,
        completion: completion,
      );
    }

    return const GooglePlayPurchaseOutcome(
      status: GooglePlayPurchaseOutcomeStatus.pending,
      message:
          'Your previous App Store purchase was found and will be verified automatically.',
    );
  }

  Future<GooglePlayPurchaseOutcome> restoreAppStoreSubscription(
    StorePackageModel package,
  ) async {
    if (!Platform.isIOS) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'Restore Purchases is available on iOS only.',
      );
    }
    if (isProcessing.value) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.pending,
        message: 'A store operation is already in progress.',
      );
    }

    final String productId = package.storeProduct?.productId.trim() ?? '';
    if (productId.isEmpty) {
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'This subscription has no App Store product ID.',
      );
    }

    isProcessing.value = true;
    errorMessage.value = '';
    try {
      final PurchaseDetails? purchase = await _billingService
          .restoreAppStoreSubscription(productId);
      if (purchase == null) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: 'No restorable App Store subscription was found.',
        );
      }

      final String signedTransactionInfo = _purchaseToken(purchase);
      final String transactionId = _transactionId(purchase);
      if (signedTransactionInfo.isEmpty || transactionId.isEmpty) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: 'The App Store restore data was incomplete.',
        );
      }

      final ApiResult<StorePurchaseCompletionModel> result =
          await ApiErrorHandler.call<StorePurchaseCompletionModel>(
            () => _apiService.restoreAppStoreSubscription(
              payload: RestoreAppStoreSubscriptionPayloadModel(
                productId: productId,
                transactionId: transactionId,
                signedTransactionInfo: signedTransactionInfo,
              ),
            ),
            showError: false,
          );
      if (!result.isSuccess || result.data == null) {
        return GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: result.error ?? 'The subscription could not be restored.',
        );
      }

      await _billingService.finishVerifiedPurchase(
        purchase,
        StoreProviderProductType.subscription,
      );
      final StorePurchaseCompletionModel completion = result.data!;
      lastCompletion.value = completion;
      if (!_completionController.isClosed) {
        _completionController.add(completion);
      }
      return GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.completed,
        message: 'Your App Store subscription was restored.',
        completion: completion,
      );
    } catch (error, stackTrace) {
      AppLogger.log(
        'App Store subscription restore failed.',
        name: 'GooglePlayPurchaseController',
        error: error,
        stackTrace: stackTrace,
      );
      return const GooglePlayPurchaseOutcome(
        status: GooglePlayPurchaseOutcomeStatus.failed,
        message: 'The App Store subscription could not be restored.',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  StorePurchaseCompletionModel? takeLastCompletion() {
    final StorePurchaseCompletionModel? completion = lastCompletion.value;

    lastCompletion.value = null;

    return completion;
  }

  void resetTransientState({bool cancelActivePurchase = false}) {
    lastCompletion.value = null;
    errorMessage.value = '';

    if (!cancelActivePurchase) {
      return;
    }

    _billingFlowActive = false;

    final Completer<GooglePlayPurchaseOutcome>? completer = _activeCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete(
        const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.cancelled,
          message: 'The purchase flow was closed.',
        ),
      );
    }

    _clearActivePurchase();
  }

  Future<void> _reconcileReturnedBillingFlow() async {
    if (_resumeReconciliationRunning || !_billingFlowActive) {
      return;
    }

    _resumeReconciliationRunning = true;

    try {
      await Future<void>.delayed(_billingReturnDelay);

      if (!_billingFlowActive) {
        return;
      }

      PurchaseDetails? purchase = await _billingService.queryPendingPurchase();

      if (purchase == null && !_billingService.pendingPurchaseQueryFailed) {
        await Future<void>.delayed(_billingReturnDelay);

        if (!_billingFlowActive) {
          return;
        }

        purchase = await _billingService.queryPendingPurchase();
      }

      if (purchase != null) {
        await _handlePurchase(purchase);

        return;
      }

      if (_billingService.pendingPurchaseQueryFailed) {
        return;
      }

      final PendingGooglePlayPurchaseModel? pending = _billingService
          .loadPendingPurchase();

      if (pending != null) {
        await _cancelUnfinishedOrder(
          pending.orderId,
          reason: 'The user returned without completing the store purchase.',
        );
      }

      await _billingService.clearPendingPurchase();

      _billingFlowActive = false;

      _completeActive(
        const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.cancelled,
          message: 'The store purchase was cancelled.',
        ),
      );
    } finally {
      _resumeReconciliationRunning = false;
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final PendingGooglePlayPurchaseModel? pending = _billingService
        .loadPendingPurchase();

    if (pending == null || purchase.productID != pending.productId) {
      return;
    }

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _billingFlowActive = false;

        _completeActive(
          const GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.pending,
            message: 'The store is processing your payment.',
          ),
        );

        return;

      case PurchaseStatus.canceled:
        _billingFlowActive = false;

        await _cancelUnfinishedOrder(
          pending.orderId,
          reason: 'The store purchase was cancelled by the user.',
        );

        await _billingService.clearPendingPurchase();

        _completeActive(
          const GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.cancelled,
            message: 'The store purchase was cancelled.',
          ),
        );

        return;

      case PurchaseStatus.error:
        _billingFlowActive = false;

        await _cancelUnfinishedOrder(
          pending.orderId,
          reason: 'The store returned a purchase error.',
        );

        await _billingService.clearPendingPurchase();

        final String message =
            purchase.error?.message ?? 'The store purchase failed.';

        errorMessage.value = message;

        _completeActive(
          GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.failed,
            message: message,
          ),
        );

        return;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _billingFlowActive = false;

        await _verifyAndDeliver(purchase, pending);

        return;
    }
  }

  Future<void> _verifyAndDeliver(
    PurchaseDetails purchase,
    PendingGooglePlayPurchaseModel pending,
  ) async {
    final String purchaseToken = _purchaseToken(purchase);

    if (purchaseToken.isEmpty || !_processingPurchases.add(purchaseToken)) {
      return;
    }

    try {
      StorePurchaseCompletionModel? completion = pending.verifiedCompletion;

      if (completion == null) {
        completion = await _verifyOrRecoverCompletion(
          purchase: purchase,
          pending: pending,
          purchaseToken: purchaseToken,
        );

        if (completion == null) {
          final bool stalePurchaseWasCleared =
              _billingService.loadPendingPurchase() == null;

          final String message = stalePurchaseWasCleared
              ? 'The previous store purchase was no longer valid and has been cleared. Please try again.'
              : 'Store payment succeeded, but verification is pending.';

          errorMessage.value = message;

          _completeActive(
            GooglePlayPurchaseOutcome(
              status: stalePurchaseWasCleared
                  ? GooglePlayPurchaseOutcomeStatus.failed
                  : GooglePlayPurchaseOutcomeStatus.pending,
              message: message,
            ),
          );

          return;
        }

        pending = pending.copyWith(verifiedCompletion: completion);

        await _billingService.savePendingPurchase(pending);
      }

      final StorePurchaseCompletionModel verifiedCompletion = completion;

      try {
        await _billingService.finishVerifiedPurchase(
          purchase,
          pending.productType,
        );
      } catch (error, stackTrace) {
        /*
         * Backend verification and entitlement
         * delivery already succeeded. Client-side
         * finalization failure must not downgrade
         * the completed purchase.
         */
        AppLogger.log(
          'Google Play client finalization was skipped after successful backend verification.',
          name: 'GooglePlayPurchaseController',
          error: error,
          stackTrace: stackTrace,
        );
      }

      await _billingService.clearPendingPurchase();

      lastCompletion.value = verifiedCompletion;

      if (!_completionController.isClosed) {
        _completionController.add(verifiedCompletion);
      }

      _completeActive(
        GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.completed,
          message: verifiedCompletion.message,
          completion: verifiedCompletion,
        ),
      );
    } catch (error, stackTrace) {
      const String message =
          'The purchase will be verified again when the app opens.';

      errorMessage.value = message;

      AppLogger.log(
        'Google Play purchase verification did not finish.',
        name: 'GooglePlayPurchaseController',
        error: error,
        stackTrace: stackTrace,
      );

      _completeActive(
        const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.pending,
          message: message,
        ),
      );
    } finally {
      _processingPurchases.remove(purchaseToken);
    }
  }

  Future<StorePurchaseCompletionModel?> _verifyOrRecoverCompletion({
    required PurchaseDetails purchase,
    required PendingGooglePlayPurchaseModel pending,
    required String purchaseToken,
  }) async {
    final String transactionId = _transactionId(purchase);
    final ApiResult<StorePurchaseCompletionModel> verification =
        await ApiErrorHandler.call<StorePurchaseCompletionModel>(
          () => Platform.isAndroid
              ? _apiService.verifyGooglePlayPurchase(
                  orderId: pending.orderId,
                  payload: VerifyGooglePlayPurchasePayloadModel(
                    productId: pending.productId,
                    purchaseToken: purchaseToken,
                    transactionId: transactionId,
                  ),
                )
              : pending.offerType == 'offer_code'
              ? _apiService.restoreAppStoreSubscription(
                  payload: RestoreAppStoreSubscriptionPayloadModel(
                    productId: pending.productId,
                    transactionId: transactionId,
                    signedTransactionInfo: purchaseToken,
                    pendingOrderId: pending.orderId,
                  ),
                )
              : _apiService.verifyAppStorePurchase(
                  orderId: pending.orderId,
                  payload: VerifyAppStorePurchasePayloadModel(
                    productId: pending.productId,
                    transactionId: transactionId,
                    signedTransactionInfo: purchaseToken,
                  ),
                ),
          showError: false,
        );

    if (verification.isSuccess && verification.data != null) {
      return verification.data;
    }

    /*
   * Verification may have been completed by another
   * request or by the Google Play RTDN worker.
   */
    StorePurchaseCompletionModel? recovered = await _recoverCompletedOrder(
      pending.orderId,
    );

    if (recovered != null) {
      return recovered;
    }

    final String verificationError = (verification.error ?? '')
        .trim()
        .toLowerCase();

    /*
   * Google may temporarily reject a duplicate request
   * while another verification process is updating the
   * same purchase. Wait briefly and check the backend
   * order again without deleting local pending state.
   */
    final bool isConcurrentUpdate =
        verificationError.contains('already in the process of being updated') ||
        verificationError.contains('already being updated');

    if (isConcurrentUpdate) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      recovered = await _recoverCompletedOrder(pending.orderId);

      return recovered;
    }

    /*
   * A consumed one-time product may no longer appear as
   * owned. Check once more in case another backend path
   * completed the order moments earlier.
   */
    final bool isNotOwned =
        Platform.isAndroid &&
        (verificationError.contains('not owned by the user') ||
            verificationError.contains('product purchase is not owned'));

    if (isNotOwned) {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      recovered = await _recoverCompletedOrder(pending.orderId);

      if (recovered != null) {
        return recovered;
      }

      await _cancelUnfinishedOrder(
        pending.orderId,
        reason: 'Google Play no longer owns this purchase.',
      );

      await _billingService.clearPendingPurchase();
    }

    return null;
  }

  Future<StorePurchaseCompletionModel?> _recoverCompletedOrder(
    String orderId,
  ) async {
    final ApiResult<List<Object>> result =
        await ApiErrorHandler.call<List<Object>>(() async {
          return Future.wait<Object>(<Future<Object>>[
            _apiService.getOrder(orderId),
            _apiService.getBalances(),
          ]);
        }, showError: false);

    if (!result.isSuccess || result.data == null) {
      return null;
    }

    final StoreOrderModel order = result.data![0] as StoreOrderModel;

    if (order.status != 'completed') {
      return null;
    }

    final StoreBalancesModel balances = result.data![1] as StoreBalancesModel;

    return StorePurchaseCompletionModel(
      message: 'Package purchase completed successfully.',
      orderId: order.id,
      orderNumber: order.orderNumber,
      status: order.status,
      packageName: order.package.name,
      packageType: order.package.type,
      creditedVoiceMinutes: order.package.aiVoiceMinutes,
      creditedTextTokens: order.package.aiTextTokens,
      creditedStreakFreezes: order.package.streakFreezeCount,
      creditedCvCredits: order.package.cvCredits,
      streakProtectionMode: order.package.streakProtectionMode,
      unlimitedProtectionUntil: balances.unlimitedProtectionExpiresAt,
      balances: balances,
    );
  }

  Future<void> _cancelUnfinishedOrder(
    String orderId, {
    required String reason,
  }) async {
    if (orderId.trim().isEmpty) {
      return;
    }

    try {
      await _apiService.cancelOrder(orderId, reason: reason);
    } catch (error, stackTrace) {
      /*
       * Cancellation is cleanup only. Never hide the
       * original Google Play error if cleanup fails.
       */
      AppLogger.log(
        'Could not cancel the unfinished package-store order.',
        name: 'GooglePlayPurchaseController',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _purchaseToken(PurchaseDetails purchase) {
    if (purchase is GooglePlayPurchaseDetails) {
      return purchase.billingClientPurchase.purchaseToken;
    }

    return purchase.verificationData.serverVerificationData;
  }

  String _transactionId(PurchaseDetails purchase) {
    if (purchase is GooglePlayPurchaseDetails) {
      return purchase.billingClientPurchase.orderId;
    }

    return purchase.purchaseID ?? '';
  }

  void _completeActive(GooglePlayPurchaseOutcome outcome) {
    final Completer<GooglePlayPurchaseOutcome>? completer = _activeCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete(outcome);
    }

    _clearActivePurchase();
  }

  void _clearActivePurchase() {
    _activeCompleter = null;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    unawaited(_purchaseSubscription?.cancel());

    unawaited(_completionController.close());

    super.onClose();
  }
}
