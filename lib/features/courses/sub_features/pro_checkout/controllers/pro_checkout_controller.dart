import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/pro_checkout_models.dart';
import '../services/course_google_play_billing_service.dart';
import '../services/pro_checkout_api_service.dart';

class ProCheckoutController extends GetxController with WidgetsBindingObserver {
  ProCheckoutController({
    required ProCheckoutApiService proCheckoutApiService,
    required CourseGooglePlayBillingService billingService,
    required this.courseId,
    required this.courseName,
    required this.lessonCount,
    required this.onPurchaseCompleted,
  }) : _proCheckoutApiService = proCheckoutApiService,
       _billingService = billingService;

  static const Duration _purchaseTimeout = Duration(minutes: 2);
  static const Duration _billingReturnDelay = Duration(milliseconds: 900);

  final ProCheckoutApiService _proCheckoutApiService;
  final CourseGooglePlayBillingService _billingService;
  final String courseId;
  final String courseName;
  final int lessonCount;
  final Future<void> Function() onPurchaseCompleted;

  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isPreparingGooglePlay = false.obs;
  final Rx<ProCurrency> selectedCurrency = ProCurrency.eur.obs;
  final Rx<ProPaymentMethod> selectedPaymentMethod =
      ProPaymentMethod.googlePlay.obs;
  final Rxn<ProOrderModel> order = Rxn<ProOrderModel>();
  final Rxn<ProPurchaseResultModel> purchaseResult =
      Rxn<ProPurchaseResultModel>();
  final RxString billingError = ''.obs;

  StreamSubscription<PurchaseDetails>? _purchaseSubscription;
  Completer<ProPurchaseOutcome>? _activePurchaseCompleter;
  bool _billingFlowActive = false;
  bool _resumeCheckRunning = false;
  ProPurchaseOutcome? _lastOutcome;
  final Set<String> _processingTokens = <String>{};
  final Set<String> _appliedOrderIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _purchaseSubscription = _billingService.purchaseUpdates.listen(
      (PurchaseDetails purchase) => unawaited(_handlePurchase(purchase)),
      onError: (Object error, StackTrace stackTrace) {
        dev.log(
          'Course purchase stream failed.',
          name: 'ProCheckoutController',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    unawaited(loadOrderSummary());
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(_retryPendingPurchase());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _billingFlowActive) {
      unawaited(_reconcileReturnedBillingFlow());
    }
  }

  Future<void> loadOrderSummary() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
            () => _proCheckoutApiService.fetchOrderSummary(
              courseId: courseId,
              fallbackCourseName: courseName,
              lessonCount: lessonCount,
            ),
            errorTitle: 'course_purchase'.tr,
          );
      if (!result.isSuccess || result.data == null) return;

      order.value = result.data;
      await _prepareGooglePlayProduct(result.data!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _prepareGooglePlayProduct(ProOrderModel currentOrder) async {
    isPreparingGooglePlay.value = true;
    billingError.value = '';
    try {
      final bool ready = await _billingService.prepareProduct(
        currentOrder.storeProduct,
      );
      if (!ready) {
        billingError.value = _billingService.lastError.value;
        return;
      }

      final String localizedPrice = _billingService.localizedPrice;
      final String currencyCode = _billingService.localizedCurrencyCode;
      if (currencyCode.toUpperCase() == 'BDT') {
        selectedCurrency.value = ProCurrency.bdt;
      } else {
        selectedCurrency.value = ProCurrency.eur;
      }
      if (localizedPrice.isNotEmpty) {
        order.value = currentOrder.copyWith(
          plan: currentOrder.plan.copyWith(
            eurPrice: localizedPrice,
            eurOldPrice: localizedPrice,
            bdtPrice: localizedPrice,
            bdtOldPrice: localizedPrice,
            discountLabel: 'GOOGLE PLAY',
          ),
        );
      }
    } finally {
      isPreparingGooglePlay.value = false;
    }
  }

  void setCurrency(ProCurrency currency) {
    if (_billingService.localizedCurrencyCode.isNotEmpty) return;
    selectedCurrency.value = currency;
  }

  void selectPaymentMethod(ProPaymentMethod method) {
    selectedPaymentMethod.value = ProPaymentMethod.googlePlay;
  }

  Future<void> openCheckout(String controllerTag) async {
    await Get.toNamed(
      AppRoutes.proCheckout,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> completePurchase(String controllerTag) async {
    final ProOrderModel? currentOrder = order.value;
    if (isPurchasing.value || currentOrder == null) return;

    if (!_billingService.isAvailable.value) {
      Get.snackbar(
        'Google Play',
        _billingService.lastError.value.isEmpty
            ? 'Google Play Billing is unavailable on this device.'
            : _billingService.lastError.value,
      );
      return;
    }

    isPurchasing.value = true;
    billingError.value = '';
    try {
      final ProPendingGooglePlayPurchaseModel? existing = _billingService
          .loadPendingPurchase();
      if (existing != null && existing.courseId != courseId) {
        await _billingService.clearPendingPurchase();
      } else if (existing != null) {
        _lastOutcome = null;
        final bool recovered = await _retryPendingPurchase();
        if (recovered) {
          final ProPurchaseOutcome? recoveredOutcome = _lastOutcome;
          if (recoveredOutcome?.status == ProPurchaseOutcomeStatus.completed) {
            await Get.offNamed(
              AppRoutes.proPurchaseSuccess,
              arguments: ControllerTagRouteArguments(
                controllerTag: controllerTag,
              ),
            );
            return;
          }
          if (recoveredOutcome?.status == ProPurchaseOutcomeStatus.pending) {
            Get.snackbar('Payment Pending', recoveredOutcome!.message);
            return;
          }
        }
        if (_billingService.pendingPurchaseQueryFailed) {
          Get.snackbar(
            'Payment Pending',
            'Google Play could not confirm the previous purchase yet.',
          );
          return;
        }
        await _billingService.clearPendingPurchase();
      }

      final ApiResult<ProPendingGooglePlayPurchaseModel> orderResult =
          await ApiErrorHandler.call<ProPendingGooglePlayPurchaseModel>(
            () => _proCheckoutApiService.createGooglePlayOrder(
              order: currentOrder,
              currency: selectedCurrency.value,
            ),
            errorTitle: 'course_purchase'.tr,
          );
      if (!orderResult.isSuccess || orderResult.data == null) return;

      final ProPendingGooglePlayPurchaseModel pending = orderResult.data!;
      final Completer<ProPurchaseOutcome> completer =
          Completer<ProPurchaseOutcome>();
      _activePurchaseCompleter = completer;
      _billingFlowActive = true;

      final bool launched = await _billingService.launchPurchase(
        product: currentOrder.storeProduct,
        pendingPurchase: pending,
      );
      if (!launched) {
        _billingFlowActive = false;
        _activePurchaseCompleter = null;
        Get.snackbar(
          'Google Play',
          _billingService.lastError.value.isEmpty
              ? 'Google Play could not start the purchase.'
              : _billingService.lastError.value,
        );
        return;
      }

      final ProPurchaseOutcome outcome = await completer.future.timeout(
        _purchaseTimeout,
        onTimeout: () {
          _billingFlowActive = false;
          _activePurchaseCompleter = null;
          return const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message:
                'The purchase is pending and will be verified automatically.',
          );
        },
      );

      switch (outcome.status) {
        case ProPurchaseOutcomeStatus.completed:
          await Get.offNamed(
            AppRoutes.proPurchaseSuccess,
            arguments: ControllerTagRouteArguments(
              controllerTag: controllerTag,
            ),
          );
          break;
        case ProPurchaseOutcomeStatus.pending:
          Get.snackbar('Payment Pending', outcome.message);
          break;
        case ProPurchaseOutcomeStatus.cancelled:
          Get.snackbar('Purchase Cancelled', outcome.message);
          break;
        case ProPurchaseOutcomeStatus.failed:
          Get.snackbar('Purchase Failed', outcome.message);
          break;
      }
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<bool> _retryPendingPurchase() async {
    final ProPendingGooglePlayPurchaseModel? pending = _billingService
        .loadPendingPurchase();
    if (pending == null || pending.courseId != courseId) return false;

    final PurchaseDetails? purchase = await _billingService
        .queryPendingPurchase();
    if (purchase == null) return false;
    await _handlePurchase(purchase);
    return true;
  }

  Future<void> _reconcileReturnedBillingFlow() async {
    if (_resumeCheckRunning || !_billingFlowActive) return;
    _resumeCheckRunning = true;
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
        const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.cancelled,
          message: 'The Google Play purchase was cancelled.',
        ),
      );
    } finally {
      _resumeCheckRunning = false;
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final ProPendingGooglePlayPurchaseModel? pending = _billingService
        .loadPendingPurchase();
    if (pending == null || purchase.productID != pending.productId) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _billingFlowActive = false;
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message: 'Google Play is processing your payment.',
          ),
        );
        return;
      case PurchaseStatus.canceled:
        _billingFlowActive = false;
        await _billingService.clearPendingPurchase();
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.cancelled,
            message: 'The Google Play purchase was cancelled.',
          ),
        );
        return;
      case PurchaseStatus.error:
        _billingFlowActive = false;
        await _billingService.clearPendingPurchase();
        final String message =
            purchase.error?.message ?? 'The Google Play purchase failed.';
        _completeActive(
          ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.failed,
            message: message,
          ),
        );
        return;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _billingFlowActive = false;
        await _verifyAndUnlock(purchase, pending);
        return;
    }
  }

  Future<void> _verifyAndUnlock(
    PurchaseDetails purchase,
    ProPendingGooglePlayPurchaseModel pending,
  ) async {
    final String token = _purchaseToken(purchase);
    if (token.isEmpty || !_processingTokens.add(token)) return;

    try {
      ProPurchaseResultModel? completed;
      final ApiResult<ProPurchaseResultModel> verification =
          await ApiErrorHandler.call<ProPurchaseResultModel>(
            () => _proCheckoutApiService.verifyGooglePlayPurchase(
              pending: pending,
              purchaseToken: token,
              transactionId: _transactionId(purchase),
              courseName: courseName,
              lessonCount: lessonCount,
            ),
            showError: false,
          );
      if (verification.isSuccess && verification.data != null) {
        completed = verification.data;
      } else {
        completed = await _proCheckoutApiService.recoverCompletedOrder(
          pending: pending,
          courseName: courseName,
          lessonCount: lessonCount,
        );
      }

      if (completed == null) {
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message:
                'Payment succeeded, but course access verification is pending.',
          ),
        );
        return;
      }

      await _billingService.finishVerifiedPurchase(purchase);
      await _billingService.clearPendingPurchase();
      purchaseResult.value = completed;
      if (_appliedOrderIds.add(pending.orderId)) {
        await onPurchaseCompleted();
      }
      _completeActive(
        const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.completed,
          message: 'Course purchase completed successfully.',
        ),
      );
    } catch (error, stackTrace) {
      dev.log(
        'Course purchase verification did not finish.',
        name: 'ProCheckoutController',
        error: error,
        stackTrace: stackTrace,
      );
      _completeActive(
        const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.pending,
          message: 'The purchase will be verified again when the app opens.',
        ),
      );
    } finally {
      _processingTokens.remove(token);
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

  void _completeActive(ProPurchaseOutcome outcome) {
    _lastOutcome = outcome;
    final Completer<ProPurchaseOutcome>? completer = _activePurchaseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(outcome);
    }
    _activePurchaseCompleter = null;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_purchaseSubscription?.cancel());
    super.onClose();
  }
}
