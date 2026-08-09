import 'dart:async';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/services/course_purchase_recovery_service.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/pro_checkout_models.dart';
import '../services/course_google_play_billing_service.dart';
import '../services/pro_checkout_api_service.dart';

class ProCheckoutController extends GetxController with WidgetsBindingObserver {
  ProCheckoutController({
    required ProCheckoutApiService proCheckoutApiService,
    required CourseGooglePlayBillingService billingService,
    required CoursePurchaseRecoveryService recoveryService,
    required this.courseId,
    required this.courseName,
    required this.lessonCount,
    required this.onPurchaseCompleted,
  }) : _proCheckoutApiService = proCheckoutApiService,
       _billingService = billingService,
       _recoveryService = recoveryService;

  static const Duration _purchaseTimeout = Duration(minutes: 2);
  static const Duration _billingReturnDelay = Duration(milliseconds: 900);

  static const String _purchaseLinkedToAnotherUserCode =
      'GOOGLE_PLAY_PURCHASE_LINKED_TO_ANOTHER_USER';
  static const String _accountIdentifierMissingCode =
      'GOOGLE_PLAY_ACCOUNT_IDENTIFIER_MISSING';
  static const String _purchaseLinkedToAnotherCourseCode =
      'GOOGLE_PLAY_PURCHASE_LINKED_TO_ANOTHER_COURSE';
  static const String _purchaseNotRestorableCode =
      'GOOGLE_PLAY_PURCHASE_NOT_RESTORABLE';

  final ProCheckoutApiService _proCheckoutApiService;
  final CourseGooglePlayBillingService _billingService;
  final CoursePurchaseRecoveryService _recoveryService;
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
  final TextEditingController couponTextController = TextEditingController();
  final RxString couponCode = ''.obs;
  final RxBool isCouponApplied = false.obs;
  final RxBool isApplyingCoupon = false.obs;
  String _regularGooglePlayPrice = '';

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
    _recoveryService.suspend();
    WidgetsBinding.instance.addObserver(this);
    _purchaseSubscription = _billingService.purchaseUpdates.listen(
      (PurchaseDetails purchase) => unawaited(_handlePurchase(purchase)),
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.log(
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
    unawaited(_preparePendingRecovery());
  }

  Future<void> _preparePendingRecovery() async {
    await _recoveryService.migrateLegacyPendingPurchase();
    await _retryPendingPurchase();
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

      await _prepareGooglePlayProduct(result.data!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _prepareGooglePlayProduct(ProOrderModel currentOrder) async {
    isPreparingGooglePlay.value = true;
    billingError.value = '';
    try {
      final bool ready = await _billingService.prepareProduct(
        currentOrder.storeProduct,
      );
      if (!ready) {
        order.value = currentOrder;
        billingError.value = _billingService.lastError.value;
        return false;
      }

      final String localizedPrice = _billingService.localizedPrice;
      final String currencyCode = _billingService.localizedCurrencyCode;
      if (currencyCode.toUpperCase() == 'BDT') {
        selectedCurrency.value = ProCurrency.bdt;
      } else {
        selectedCurrency.value = ProCurrency.eur;
      }
      if (localizedPrice.isNotEmpty) {
        if (!currentOrder.hasCoupon) {
          _regularGooglePlayPrice = localizedPrice;
        } else if (_regularGooglePlayPrice.isEmpty) {
          _regularGooglePlayPrice = currentOrder.plan.oldPriceLabel(
            selectedCurrency.value,
          );
        }

        final String oldPrice =
            currentOrder.hasCoupon && _regularGooglePlayPrice.isNotEmpty
            ? _regularGooglePlayPrice
            : localizedPrice;
        final String discountLabel = currentOrder.hasCoupon
            ? _googlePlaySavingsLabel(
                regularPriceText: oldPrice,
                discountedPriceText: localizedPrice,
                fallback: currentOrder.plan.discountLabel,
              )
            : 'GOOGLE PLAY';

        order.value = currentOrder.copyWith(
          plan: currentOrder.plan.copyWith(
            eurPrice: localizedPrice,
            eurOldPrice: oldPrice,
            bdtPrice: localizedPrice,
            bdtOldPrice: oldPrice,
            discountLabel: discountLabel,
          ),
        );
      } else {
        order.value = currentOrder;
      }
      return true;
    } finally {
      isPreparingGooglePlay.value = false;
    }
  }

  void setCurrency(ProCurrency currency) {
    if (_billingService.localizedCurrencyCode.isNotEmpty) return;
    selectedCurrency.value = currency;
  }

  void onCouponChanged(String value) {
    couponCode.value = value.trim();
    billingError.value = '';
    if (isCouponApplied.value) isCouponApplied.value = false;
  }

  Future<void> applyCoupon() async {
    if (isApplyingCoupon.value) return;

    final String code = couponTextController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('coupon_required'.tr, 'please_enter_a_coupon_code'.tr);
      return;
    }

    isApplyingCoupon.value = true;
    billingError.value = '';
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
            () => _proCheckoutApiService.fetchOrderSummary(
              courseId: courseId,
              fallbackCourseName: courseName,
              lessonCount: lessonCount,
              couponCode: code,
            ),
            showError: false,
          );

      if (!result.isSuccess || result.data == null) {
        billingError.value = 'Coupon is not valid for this item.';
        Get.snackbar('coupon'.tr, billingError.value);
        return;
      }

      final bool ready = await _prepareGooglePlayProduct(result.data!);
      if (!ready) {
        Get.snackbar(
          'Google Play',
          billingError.value.isEmpty
              ? 'The discounted store product is unavailable.'
              : billingError.value,
        );
        return;
      }

      billingError.value = '';
      couponTextController.text = code;
      couponCode.value = code;
      isCouponApplied.value = true;
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  Future<void> clearCoupon() async {
    if (isApplyingCoupon.value) return;

    isApplyingCoupon.value = true;
    billingError.value = '';
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
            () => _proCheckoutApiService.fetchOrderSummary(
              courseId: courseId,
              fallbackCourseName: courseName,
              lessonCount: lessonCount,
            ),
            showError: false,
          );
      if (result.isSuccess && result.data != null) {
        couponTextController.clear();
        couponCode.value = '';
        isCouponApplied.value = false;
        await _prepareGooglePlayProduct(result.data!);
      }
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  String _googlePlaySavingsLabel({
    required String regularPriceText,
    required String discountedPriceText,
    required String fallback,
  }) {
    final double? regular = _parseLocalizedAmount(regularPriceText);
    final double? discounted = _parseLocalizedAmount(discountedPriceText);
    if (regular == null || discounted == null || regular <= discounted) {
      return fallback.isEmpty ? 'COUPON APPLIED' : fallback;
    }

    final String prefix = _localizedPricePrefix(regularPriceText);
    return 'YOU SAVED $prefix${(regular - discounted).toStringAsFixed(2)}';
  }

  double? _parseLocalizedAmount(String value) {
    String amount = value.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (amount.isEmpty) return null;

    final int lastComma = amount.lastIndexOf(',');
    final int lastDot = amount.lastIndexOf('.');
    if (lastComma > -1 && lastDot > -1) {
      final bool commaIsDecimal = lastComma > lastDot;
      amount = commaIsDecimal
          ? amount.replaceAll('.', '').replaceAll(',', '.')
          : amount.replaceAll(',', '');
    } else if (lastComma > -1) {
      final int decimals = amount.length - lastComma - 1;
      amount = decimals == 2
          ? amount.replaceAll(',', '.')
          : amount.replaceAll(',', '');
    }

    return double.tryParse(amount);
  }

  String _localizedPricePrefix(String value) {
    final RegExpMatch? match = RegExp(r'^\s*([^0-9.,-]+)').firstMatch(value);
    return match?.group(1)?.trimRight() ?? '';
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
        Get.snackbar(
          'Payment Pending',
          'A previous course purchase is still being recovered. Please try again shortly.',
        );
        return;
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
          if (recoveredOutcome?.status == ProPurchaseOutcomeStatus.failed) {
            Get.snackbar('Purchase Unavailable', recoveredOutcome!.message);
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
              couponCode: currentOrder.hasCoupon ? currentOrder.couponCode : '',
            ),
            errorTitle: 'course_purchase'.tr,
          );
      if (!orderResult.isSuccess || orderResult.data == null) return;

      final ProPendingGooglePlayPurchaseModel pending = orderResult.data!;
      final Completer<ProPurchaseOutcome> completer =
          Completer<ProPurchaseOutcome>();
      _activePurchaseCompleter = completer;
      _billingFlowActive = true;

      await _billingService.savePendingPurchase(pending);

      final PurchaseDetails? ownedPurchase = await _billingService
          .queryOwnedPurchase(pending.productId);

      if (ownedPurchase != null &&
          _isRecoverablePurchaseStatus(ownedPurchase.status)) {
        await _handlePurchase(ownedPurchase);
      } else {
        final bool launched = await _billingService.launchPurchase(
          product: currentOrder.storeProduct,
          pendingPurchase: pending,
        );

        if (!launched) {
          final PurchaseDetails? ownedAfterLaunchFailure = await _billingService
              .queryOwnedPurchase(pending.productId);

          if (ownedAfterLaunchFailure != null &&
              _isRecoverablePurchaseStatus(ownedAfterLaunchFailure.status)) {
            await _billingService.savePendingPurchase(pending);
            await _handlePurchase(ownedAfterLaunchFailure);
          } else {
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
        }
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

        /*
         * Google may report ITEM_ALREADY_OWNED as a Billing error instead of
         * emitting the owned purchase on the normal purchase stream. Query
         * owned purchases once and let the backend resolve its app-account
         * ownership before falling back to the generic Billing error.
         */
        final PurchaseDetails? ownedPurchase = await _billingService
            .queryOwnedPurchase(pending.productId);

        if (ownedPurchase != null &&
            (ownedPurchase.status == PurchaseStatus.purchased ||
                ownedPurchase.status == PurchaseStatus.restored)) {
          await _verifyAndUnlock(ownedPurchase, pending);
          return;
        }

        if (ownedPurchase?.status == PurchaseStatus.pending) {
          _completeActive(
            const ProPurchaseOutcome(
              status: ProPurchaseOutcomeStatus.pending,
              message: 'Google Play is processing your payment.',
            ),
          );
          return;
        }

        /*
         * Keep the pending order. A generic Billing error does not always
         * prove that no charge or purchase transition occurred.
         */
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

      if (!verification.isSuccess) {
        final ProPurchaseOutcome? permanentFailure =
            _permanentVerificationFailure(verification.errorCode);

        if (permanentFailure != null) {
          await _billingService.clearPendingPurchase();
          _completeActive(permanentFailure);
          return;
        }
      }

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
      AppLogger.log(
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

  bool _isRecoverablePurchaseStatus(PurchaseStatus status) {
    return status == PurchaseStatus.purchased ||
        status == PurchaseStatus.restored ||
        status == PurchaseStatus.pending;
  }

  ProPurchaseOutcome? _permanentVerificationFailure(String? errorCode) {
    switch (errorCode) {
      case _purchaseLinkedToAnotherUserCode:
        return const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This course is linked to another Italir Pothe account through this Google Play account. Sign in to the original Italir Pothe account, use a different Google Play account for this account, or contact support if you need help recovering access.',
        );
      case _accountIdentifierMissingCode:
        return const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This older Google Play purchase cannot be securely linked to this account. Please contact support.',
        );
      case _purchaseLinkedToAnotherCourseCode:
        return const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This Google Play purchase is already linked to a different course. Please contact support.',
        );
      case _purchaseNotRestorableCode:
        return const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This Google Play purchase cannot be restored automatically. Please contact support.',
        );
      default:
        return null;
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
    couponTextController.dispose();

    final StreamSubscription<PurchaseDetails>? subscription =
        _purchaseSubscription;

    if (subscription == null) {
      _recoveryService.resume();
    } else {
      unawaited(
        subscription.cancel().whenComplete(() => _recoveryService.resume()),
      );
    }

    super.onClose();
  }
}
