import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/api_error_handler.dart';
import '../models/google_play_billing_models.dart';
import '../models/shop_models.dart';
import '../models/shop_order_models.dart';
import '../services/google_play_billing_service.dart';
import '../services/shop_api_service.dart';

class GooglePlayPurchaseController extends GetxController
    with WidgetsBindingObserver {
  GooglePlayPurchaseController({
    required ShopApiService apiService,
    required GooglePlayBillingService billingService,
  })  : _apiService = apiService,
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

  Stream<StorePurchaseCompletionModel> get completionStream =>
      _completionController.stream;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _purchaseSubscription = _billingService.purchaseUpdates.listen(
      (PurchaseDetails purchase) => unawaited(_handlePurchase(purchase)),
      onError: (Object error, StackTrace stackTrace) {
        dev.log(
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
        message: 'A Google Play purchase is already being processed.',
      );
    }

    final PendingGooglePlayPurchaseModel? existing =
        _billingService.loadPendingPurchase();
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
          message: 'Your previous Google Play purchase is still pending.',
        );
      }
      if (!purchaseFound && _billingService.pendingPurchaseQueryFailed) {
        return const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.pending,
          message: 'Google Play could not confirm the previous purchase yet.',
        );
      }
      await _billingService.clearPendingPurchase();
    }

    isProcessing.value = true;
    errorMessage.value = '';
    try {
      final ApiResult<PendingGooglePlayPurchaseModel> orderResult =
          await ApiErrorHandler.call<PendingGooglePlayPurchaseModel>(() async {
        final StoreOrderModel order = await _apiService.createOrder(
          CreateStoreOrderPayloadModel(
            packageId: package.id,
            currency: currency,
            paymentProvider: 'google_play',
            productId: storeProduct.productId,
            idempotencyKey: _uuid.v4(),
            couponCode: couponCode,
          ),
        );
        final StoreCheckoutResponseModel checkout =
            await _apiService.getCheckout(order.id);
        final StoreProviderOptionModel paymentMethod = checkout.paymentMethod;
        if (paymentMethod.productId.isEmpty) {
          throw StateError('Google Play product ID is missing from checkout.');
        }

        return PendingGooglePlayPurchaseModel(
          orderId: order.id,
          packageId: package.id,
          productId: paymentMethod.productId,
          productType: paymentMethod.productType,
          basePlanId: paymentMethod.basePlanId,
          offerId: paymentMethod.offerId,
          createdAt: DateTime.now(),
        );
      }, showError: false);

      if (!orderResult.isSuccess || orderResult.data == null) {
        final String message =
            orderResult.error ?? 'Could not create the Google Play order.';
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
        _clearActivePurchase();
        final String message = _billingService.lastError.value.isNotEmpty
            ? _billingService.lastError.value
            : 'Google Play could not start the purchase.';
        errorMessage.value = message;
        return GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.failed,
          message: message,
        );
      }

      return await completer.future.timeout(
        _purchaseWait,
        onTimeout: () {
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
    final PendingGooglePlayPurchaseModel? pending =
        _billingService.loadPendingPurchase();
    if (pending == null) return false;

    final PurchaseDetails? purchase =
        await _billingService.queryPendingPurchase();
    if (purchase == null) return false;
    await _handlePurchase(purchase);
    return true;
  }

  StorePurchaseCompletionModel? takeLastCompletion() {
    final StorePurchaseCompletionModel? completion = lastCompletion.value;
    lastCompletion.value = null;
    return completion;
  }

  void resetTransientState({bool cancelActivePurchase = false}) {
    lastCompletion.value = null;
    errorMessage.value = '';
    if (!cancelActivePurchase) return;

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
    if (_resumeReconciliationRunning || !_billingFlowActive) return;
    _resumeReconciliationRunning = true;
    try {
      await Future<void>.delayed(_billingReturnDelay);
      if (!_billingFlowActive) return;

      PurchaseDetails? purchase = await _billingService.queryPendingPurchase();
      if (purchase == null && !_billingService.pendingPurchaseQueryFailed) {
        await Future<void>.delayed(_billingReturnDelay);
        if (!_billingFlowActive) return;
        purchase = await _billingService.queryPendingPurchase();
      }
      if (purchase != null) {
        await _handlePurchase(purchase);
        return;
      }
      if (_billingService.pendingPurchaseQueryFailed) return;

      await _billingService.clearPendingPurchase();
      _billingFlowActive = false;
      _completeActive(
        const GooglePlayPurchaseOutcome(
          status: GooglePlayPurchaseOutcomeStatus.cancelled,
          message: 'The Google Play purchase was cancelled.',
        ),
      );
    } finally {
      _resumeReconciliationRunning = false;
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final PendingGooglePlayPurchaseModel? pending =
        _billingService.loadPendingPurchase();
    if (pending == null || purchase.productID != pending.productId) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _billingFlowActive = false;
        _completeActive(
          const GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.pending,
            message: 'Google Play is processing your payment.',
          ),
        );
        return;
      case PurchaseStatus.canceled:
        _billingFlowActive = false;
        await _billingService.clearPendingPurchase();
        _completeActive(
          const GooglePlayPurchaseOutcome(
            status: GooglePlayPurchaseOutcomeStatus.cancelled,
            message: 'The Google Play purchase was cancelled.',
          ),
        );
        return;
      case PurchaseStatus.error:
        _billingFlowActive = false;
        await _billingService.clearPendingPurchase();
        final String message =
            purchase.error?.message ?? 'The Google Play purchase failed.';
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
          const String message =
              'Google Play payment succeeded, but verification is pending.';
          errorMessage.value = message;
          _completeActive(
            const GooglePlayPurchaseOutcome(
              status: GooglePlayPurchaseOutcomeStatus.pending,
              message: message,
            ),
          );
          return;
        }
        pending = pending.copyWith(verifiedCompletion: completion);
        await _billingService.savePendingPurchase(pending);
      }
      final StorePurchaseCompletionModel verifiedCompletion = completion;

      await _billingService.finishVerifiedPurchase(
        purchase,
        pending.productType,
      );
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
      dev.log(
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
    final ApiResult<StorePurchaseCompletionModel> verification =
        await ApiErrorHandler.call<StorePurchaseCompletionModel>(
      () => _apiService.verifyGooglePlayPurchase(
        orderId: pending.orderId,
        payload: VerifyGooglePlayPurchasePayloadModel(
          productId: pending.productId,
          purchaseToken: purchaseToken,
          transactionId: _transactionId(purchase),
        ),
      ),
      showError: false,
    );
    if (verification.isSuccess && verification.data != null) {
      return verification.data;
    }
    return _recoverCompletedOrder(pending.orderId);
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
    if (!result.isSuccess || result.data == null) return null;

    final StoreOrderModel order = result.data![0] as StoreOrderModel;
    if (order.status != 'completed') return null;
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
      unlimitedProtectionUntil: null,
      balances: balances,
    );
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
