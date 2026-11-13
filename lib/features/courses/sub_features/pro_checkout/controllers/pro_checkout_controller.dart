import 'dart:async';
import 'dart:io';
import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/course_purchase_recovery_service.dart';
import '../../../../../core/widgets/app_drawer_controller.dart';
import '../../../../../core/widgets/navbar_and_appbar_wrapper/navbar_and_appbar_wrapper_controller.dart';
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
  static const String _appStorePurchaseLinkedToAnotherUserCode =
      'APP_STORE_PURCHASE_LINKED_TO_ANOTHER_USER';

  final ProCheckoutApiService _proCheckoutApiService;
  final CourseGooglePlayBillingService _billingService;
  final CoursePurchaseRecoveryService _recoveryService;
  final String courseId;
  final String courseName;
  final int lessonCount;
  final Future<void> Function() onPurchaseCompleted;

  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isRestoringSubscription = false.obs;
  final RxBool isPreparingGooglePlay = false.obs;
  final Rx<ProCurrency> selectedCurrency = ProCurrency.eur.obs;
  final Rx<ProPaymentMethod> selectedPaymentMethod =
      (Platform.isIOS ? ProPaymentMethod.appStore : ProPaymentMethod.googlePlay)
          .obs;
  final Rxn<ProOrderModel> order = Rxn<ProOrderModel>();
  final Rxn<ProPurchaseResultModel> purchaseResult =
      Rxn<ProPurchaseResultModel>();
  final RxString billingError = ''.obs;

  StreamSubscription<PurchaseDetails>? _purchaseSubscription;
  Completer<ProPurchaseOutcome>? _activePurchaseCompleter;
  bool _billingFlowActive = false;
  bool _resumeCheckRunning = false;
  bool _didNavigateAfterPurchase = false;
  ProPurchaseOutcome? _lastOutcome;
  final Map<String, Completer<void>> _processingPurchases =
      <String, Completer<void>>{};
  final Set<String> _verifyingOrderIds = <String>{};
  final Set<String> _appliedOrderIds = <String>{};

  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

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
              providerProductId: order.value?.selectedProviderProductId ?? '',
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
        order.value = currentOrder.copyWith(
          plan: currentOrder.plan.copyWith(
            eurPrice: localizedPrice,
            eurOldPrice: localizedPrice,
            bdtPrice: localizedPrice,
            bdtOldPrice: localizedPrice,
            discountLabel: _storeName.toUpperCase(),
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

  void selectPaymentMethod(ProPaymentMethod method) {
    selectedPaymentMethod.value = Platform.isIOS
        ? ProPaymentMethod.appStore
        : ProPaymentMethod.googlePlay;
  }

  bool get isAppStorePurchase {
    final String productType =
        order.value?.storeProduct.productType.toLowerCase() ?? '';
    return Platform.isIOS &&
        (productType == 'subscription' || productType == 'non_consumable');
  }

  bool get isAppStoreSubscription =>
      isAppStorePurchase &&
      order.value?.storeProduct.productType.toLowerCase() == 'subscription';

  String get appStoreSubscriptionTitle {
    final String storeTitle = _billingService.localizedTitle;
    return storeTitle.isNotEmpty
        ? storeTitle
        : order.value?.plan.title ?? courseName;
  }

  String get appStoreSubscriptionPrice {
    // Course promotional offers do not yet carry the StoreKit signature
    // required to purchase the offer. Never present a regular price as if it
    // were the configured offer price.
    if (order.value?.storeProduct.offerId.trim().isNotEmpty == true) return '';
    return _billingService.localizedPrice.trim();
  }

  bool get hasAppStoreSubscriptionPrice =>
      !isAppStoreSubscription || appStoreSubscriptionPrice.isNotEmpty;

  String get appStoreSubscriptionBillingDuration {
    final int count = _billingService.subscriptionPeriodCount ?? 1;
    final String unit = _billingService.subscriptionPeriodUnit ?? 'month';
    final String suffix = count == 1 ? 'one' : 'many';
    return 'subscription_period_${unit}_$suffix'.trParams(<String, String>{
      'count': '$count',
    });
  }

  Future<void> restoreAppStorePurchase(String controllerTag) async {
    final ProOrderModel? currentOrder = order.value;
    if (!isAppStorePurchase ||
        currentOrder == null ||
        isRestoringSubscription.value) {
      return;
    }

    isRestoringSubscription.value = true;
    billingError.value = '';
    try {
      final ProPendingGooglePlayPurchaseModel? existing = _billingService
          .loadPendingPurchase();
      if (existing != null && existing.courseId != courseId) {
        Get.snackbar(
          'restore_purchases'.tr,
          'another_purchase_recovery_pending'.tr,
        );
        return;
      }
      if (existing != null) {
        purchaseResult.value = null;
        final PurchaseDetails? recovered = await _billingService
            .queryPendingPurchase();
        if (recovered != null) {
          await _verifyAndUnlock(recovered, existing);
          if (purchaseResult.value != null) {
            if (!Platform.isIOS) {
              await Get.offNamed(
                AppRoutes.proPurchaseSuccess,
                arguments: ControllerTagRouteArguments(
                  controllerTag: controllerTag,
                ),
              );
            }
            return;
          }
        }
        if (_billingService.pendingPurchaseQueryFailed) {
          Get.snackbar('restore_purchases'.tr, 'restore_check_pending'.tr);
          return;
        }
        if (Platform.isIOS) {
          Get.snackbar('restore_purchases'.tr, 'restore_check_pending'.tr);
          return;
        }
        await _billingService.clearPendingPurchase();
      }

      final PurchaseDetails? purchase = await _billingService
          .queryOwnedPurchase(currentOrder.storeProduct.productId);

      if (purchase == null) {
        if (_billingService.pendingPurchaseQueryFailed) {
          Get.snackbar('restore_purchases'.tr, 'restore_check_pending'.tr);
        } else {
          Get.snackbar('restore_purchases'.tr, 'no_restorable_purchase'.tr);
        }
        return;
      }

      final String signedTransactionInfo = purchase
          .verificationData
          .serverVerificationData
          .trim();
      final String transactionId = purchase.purchaseID?.trim() ?? '';
      if (signedTransactionInfo.isEmpty || transactionId.isEmpty) {
        Get.snackbar('restore_purchases'.tr, 'restore_check_pending'.tr);
        return;
      }

      final ApiResult<ProPurchaseResultModel> result =
          await ApiErrorHandler.call<ProPurchaseResultModel>(
            () => _proCheckoutApiService.restoreAppStorePurchase(
              productId: currentOrder.storeProduct.productId,
              signedTransactionInfo: signedTransactionInfo,
              transactionId: transactionId,
              courseName: courseName,
              lessonCount: lessonCount,
            ),
            errorTitle: 'restore_purchases'.tr,
          );
      if (result.isSuccess && result.data != null) {
        purchaseResult.value = result.data;
        await _billingService.finishVerifiedPurchase(purchase);
        await onPurchaseCompleted();
        await _navigateToPurchasedCourse();
      }
    } finally {
      isRestoringSubscription.value = false;
    }
  }

  Future<void> selectPurchaseOption(ProStoreProductModel option) async {
    if (isLoading.value ||
        option.id == order.value?.selectedProviderProductId) {
      return;
    }
    isLoading.value = true;
    billingError.value = '';
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
            () => _proCheckoutApiService.fetchOrderSummary(
              courseId: courseId,
              fallbackCourseName: courseName,
              lessonCount: lessonCount,
              providerProductId: option.id,
            ),
            errorTitle: 'course_purchase'.tr,
          );
      if (result.isSuccess && result.data != null) {
        await _prepareGooglePlayProduct(result.data!);
      }
    } finally {
      isLoading.value = false;
    }
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

    if (!hasAppStoreSubscriptionPrice) {
      billingError.value = 'app_store_price_unavailable'.tr;
      return;
    }

    if (!_billingService.isAvailable.value) {
      Get.snackbar(
        _storeName,
        _billingService.lastError.value.isEmpty
            ? '$_storeName purchases are unavailable on this device.'
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
            if (!Platform.isIOS) {
              await Get.offNamed(
                AppRoutes.proPurchaseSuccess,
                arguments: ControllerTagRouteArguments(
                  controllerTag: controllerTag,
                ),
              );
            }
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
          if (recoveredOutcome?.status ==
              ProPurchaseOutcomeStatus.accountConflict) {
            await _showCourseAlreadyPurchasedDialog();
            return;
          }
        }
        if (_billingService.pendingPurchaseQueryFailed) {
          Get.snackbar(
            'Payment Pending',
            '$_storeName could not confirm the previous purchase yet.',
          );
          return;
        }
        if (Platform.isIOS) {
          Get.snackbar(
            'Payment Pending',
            'The App Store purchase is still being checked. Please try again shortly.',
          );
          return;
        }
        await _billingService.clearPendingPurchase();
      }

      final ApiResult<ProPendingGooglePlayPurchaseModel> orderResult =
          await ApiErrorHandler.call<ProPendingGooglePlayPurchaseModel>(
            () => _proCheckoutApiService.createStoreOrder(
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

      await _billingService.savePendingPurchase(pending);

      final bool launched = await _billingService.launchPurchase(
        product: currentOrder.storeProduct,
        pendingPurchase: pending,
      );

      if (!launched) {
        final PurchaseDetails? ownedAfterLaunchFailure = await _billingService
            .queryPendingPurchase();

        if (ownedAfterLaunchFailure != null &&
            _isRecoverablePurchaseStatus(ownedAfterLaunchFailure.status)) {
          await _billingService.savePendingPurchase(pending);
          await _handlePurchase(ownedAfterLaunchFailure);
        } else {
          _billingFlowActive = false;
          _activePurchaseCompleter = null;
          Get.snackbar(
            _storeName,
            _billingService.lastError.value.isEmpty
                ? '$_storeName could not start the purchase.'
                : _billingService.lastError.value,
          );
          return;
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
          if (Platform.isIOS) {
            await _navigateToPurchasedCourse();
          } else {
            await Get.offNamed(
              AppRoutes.proPurchaseSuccess,
              arguments: ControllerTagRouteArguments(
                controllerTag: controllerTag,
              ),
            );
          }
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
        case ProPurchaseOutcomeStatus.accountConflict:
          await _showCourseAlreadyPurchasedDialog();
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

      if (Platform.isIOS) {
        // A missing StoreKit transaction immediately after resume is not a
        // cancellation; the successful purchase callback may arrive later.
        _billingFlowActive = false;
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message:
                'The App Store purchase is still being checked. It will be verified automatically.',
          ),
        );
        return;
      }

      await _billingService.clearPendingPurchase();
      _billingFlowActive = false;
      _completeActive(
        ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.cancelled,
          message: 'The $_storeName purchase was cancelled.',
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
    if (Platform.isIOS && purchase is SK2PurchaseDetails) {
      final String transactionOrderId =
          purchase.appAccountToken?.trim().toLowerCase() ?? '';
      if (transactionOrderId.isNotEmpty &&
          transactionOrderId != pending.orderId.toLowerCase()) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _billingFlowActive = false;
          await _resolveMismatchedAppStorePurchase(purchase, pending);
        }
        return;
      }
    }

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _billingFlowActive = false;
        _completeActive(
          ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message: '$_storeName is processing your payment.',
          ),
        );
        return;
      case PurchaseStatus.canceled:
        if (Platform.isIOS && _verifyingOrderIds.contains(pending.orderId)) {
          return;
        }
        _billingFlowActive = false;
        await _billingService.clearPendingPurchase();
        _completeActive(
          ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.cancelled,
            message: 'The $_storeName purchase was cancelled.',
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
        final PurchaseDetails? ownedPurchase = Platform.isIOS
            ? await _billingService.queryPendingPurchase()
            : await _billingService.queryOwnedPurchase(pending.productId);

        if (ownedPurchase != null &&
            (ownedPurchase.status == PurchaseStatus.purchased ||
                ownedPurchase.status == PurchaseStatus.restored)) {
          await _handlePurchase(ownedPurchase);
          return;
        }

        if (ownedPurchase?.status == PurchaseStatus.pending) {
          _completeActive(
            ProPurchaseOutcome(
              status: ProPurchaseOutcomeStatus.pending,
              message: '$_storeName is processing your payment.',
            ),
          );
          return;
        }

        /*
         * Keep the pending order. A generic Billing error does not always
         * prove that no charge or purchase transition occurred.
         */
        final String message =
            purchase.error?.message ?? 'The $_storeName purchase failed.';

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
    if (token.isEmpty) return;
    final Completer<void>? activeProcessing = _processingPurchases[token];
    if (activeProcessing != null) {
      await activeProcessing.future;
      return;
    }
    final Completer<void> processing = Completer<void>();
    _processingPurchases[token] = processing;
    _verifyingOrderIds.add(pending.orderId);

    try {
      ProPurchaseResultModel? completed;
      final ApiResult<ProPurchaseResultModel> verification =
          await ApiErrorHandler.call<ProPurchaseResultModel>(
            () => Platform.isAndroid
                ? _proCheckoutApiService.verifyGooglePlayPurchase(
                    pending: pending,
                    purchaseToken: token,
                    transactionId: _transactionId(purchase),
                    courseName: courseName,
                    lessonCount: lessonCount,
                  )
                : _proCheckoutApiService.verifyAppStorePurchase(
                    pending: pending,
                    signedTransactionInfo: token,
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
      final bool hasActiveCheckout =
          _activePurchaseCompleter != null &&
          !_activePurchaseCompleter!.isCompleted;
      _completeActive(
        const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.completed,
          message: 'Course purchase completed successfully.',
        ),
      );
      if (Platform.isIOS && !hasActiveCheckout) {
        await _navigateToPurchasedCourse();
      }
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
      _verifyingOrderIds.remove(pending.orderId);
      if (!processing.isCompleted) processing.complete();
      _processingPurchases.remove(token);
    }
  }

  Future<void> _resolveMismatchedAppStorePurchase(
    SK2PurchaseDetails purchase,
    ProPendingGooglePlayPurchaseModel pending,
  ) async {
    final String token = _purchaseToken(purchase);
    if (token.isEmpty) return;
    final Completer<void>? activeProcessing = _processingPurchases[token];
    if (activeProcessing != null) {
      await activeProcessing.future;
      return;
    }
    final Completer<void> processing = Completer<void>();
    _processingPurchases[token] = processing;

    try {
      final ApiResult<ProPurchaseResultModel> restore =
          await ApiErrorHandler.call<ProPurchaseResultModel>(
            () => _proCheckoutApiService.restoreAppStorePurchase(
              productId: pending.productId,
              signedTransactionInfo: token,
              transactionId: _transactionId(purchase),
              courseName: courseName,
              lessonCount: lessonCount,
            ),
            showError: false,
          );

      if (restore.errorCode == _appStorePurchaseLinkedToAnotherUserCode) {
        await _billingService.clearPendingPurchase();
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.accountConflict,
            message:
                'This course was already purchased using your Apple Account and is linked to another Italir Pothe account. Please sign in to the original account to access it.',
          ),
        );
        return;
      }

      final ProPurchaseResultModel? completed = restore.data;
      if (!restore.isSuccess || completed == null) {
        _completeActive(
          const ProPurchaseOutcome(
            status: ProPurchaseOutcomeStatus.pending,
            message:
                'The App Store purchase is still being checked. It will be verified automatically.',
          ),
        );
        return;
      }

      await _billingService.finishVerifiedPurchase(purchase);
      await _billingService.clearPendingPurchase();
      purchaseResult.value = completed;
      if (_appliedOrderIds.add(completed.orderId)) {
        await onPurchaseCompleted();
      }
      final bool hasActiveCheckout =
          _activePurchaseCompleter != null &&
          !_activePurchaseCompleter!.isCompleted;
      _completeActive(
        const ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.completed,
          message: 'Course purchase restored successfully.',
        ),
      );
      if (!hasActiveCheckout) {
        await _navigateToPurchasedCourse();
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'App Store account ownership verification did not finish.',
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
      if (!processing.isCompleted) processing.complete();
      _processingPurchases.remove(token);
    }
  }

  Future<void> _showCourseAlreadyPurchasedDialog() async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Course Already Purchased'),
        content: const Text(
          'This course was already purchased using your Apple Account and is linked to another Italir Pothe account. Please sign in to the original account to access it.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back<void>();
              unawaited(Get.toNamed(AppRoutes.contactSupport));
            },
            child: const Text('Contact Support'),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();
              unawaited(_switchAccount());
            },
            child: const Text('Switch Account'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _navigateToPurchasedCourse() async {
    if (_didNavigateAfterPurchase) return;
    _didNavigateAfterPurchase = true;

    await Future<void>.delayed(Duration.zero);
    if (Get.currentRoute != AppRoutes.courseDetail) {
      Get.until(
        (Route<dynamic> route) =>
            route.settings.name == AppRoutes.courseDetail || route.isFirst,
      );
      await Future<void>.delayed(Duration.zero);
    }

    if (Get.currentRoute == AppRoutes.courseDetail) {
      Get.snackbar(
        'Course Unlocked',
        'Your purchase was successful. You can start the course now.',
      );
    }
  }

  Future<void> _switchAccount() async {
    if (Get.isRegistered<NavbarAndAppbarWrapperController>()) {
      await Get.find<NavbarAndAppbarWrapperController>().onLogoutTap();
      return;
    }

    try {
      await Get.find<AuthService>().logout();
    } finally {
      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().clear();
      }
      if (Get.isRegistered<AppDrawerController>()) {
        Get.find<AppDrawerController>().clear();
      }
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
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
        return ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This course is linked to another Italir Pothe account through this $_storeName account. Sign in to the original Italir Pothe account, use a different $_storeName account for this account, or contact support if you need help recovering access.',
        );
      case _accountIdentifierMissingCode:
        return ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This older $_storeName purchase cannot be securely linked to this account. Please contact support.',
        );
      case _purchaseLinkedToAnotherCourseCode:
        return ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This $_storeName purchase is already linked to a different course. Please contact support.',
        );
      case _purchaseNotRestorableCode:
        return ProPurchaseOutcome(
          status: ProPurchaseOutcomeStatus.failed,
          message:
              'This $_storeName purchase cannot be restored automatically. Please contact support.',
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
