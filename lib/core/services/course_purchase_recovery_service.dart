import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../features/courses/sub_features/pro_checkout/services/course_google_play_billing_service.dart';
import '../../features/courses/sub_features/pro_checkout/services/pro_checkout_api_service.dart';

class CoursePurchaseRecoveryService extends GetxService
    with WidgetsBindingObserver {
  CoursePurchaseRecoveryService({
    required CourseGooglePlayBillingService billingService,
    required ProCheckoutApiService apiService,
  }) : _billingService = billingService,
        _apiService = apiService;

  final CourseGooglePlayBillingService _billingService;
  final ProCheckoutApiService _apiService;

  bool _isRecovering = false;
  int _suspensionCount = 0;

  bool get isSuspended => _suspensionCount > 0;

  Future<CoursePurchaseRecoveryService> init() async {
    WidgetsBinding.instance.addObserver(this);

    await _billingService.initialize();

    return this;
  }

  /*
   * The checkout controller suspends global recovery while it owns the
   * active Google Play purchase flow.
   */
  void suspend() {
    _suspensionCount += 1;
  }

  /*
   * Resume global recovery after the checkout controller is removed.
   *
   * A counter is used so multiple checkout controllers cannot accidentally
   * resume recovery too early.
   */
  void resume({bool recover = true}) {
    if (_suspensionCount > 0) {
      _suspensionCount -= 1;
    }

    if (recover && !isSuspended) {
      unawaited(recoverPendingPurchase());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isSuspended) {
      unawaited(recoverPendingPurchase());
    }
  }

  Future<void> recoverPendingPurchase() async {
    if (_isRecovering || isSuspended || !Platform.isAndroid) {
      return;
    }

    final pending = _billingService.loadPendingPurchase();

    if (pending == null) {
      return;
    }

    _isRecovering = true;

    try {
      final PurchaseDetails? purchase =
      await _billingService.queryPendingPurchase();

      /*
       * Keep the local record when Google Play temporarily returns no result.
       * The checkout controller or a future app resume can inspect it again.
       */
      if (purchase == null) {
        return;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          return;

        case PurchaseStatus.canceled:
          await _billingService.clearPendingPurchase();
          return;

        case PurchaseStatus.error:
        /*
           * Do not delete the pending order for a generic Billing error.
           * The payment may still require reconciliation.
           */
          dev.log(
            purchase.error?.message ??
                'Google Play returned an error during recovery.',
            name: 'CoursePurchaseRecoveryService',
            error: purchase.error,
          );
          return;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final String purchaseToken = _purchaseToken(purchase);

          if (purchaseToken.isEmpty) {
            dev.log(
              'Recovered Google Play purchase has no purchase token.',
              name: 'CoursePurchaseRecoveryService',
            );
            return;
          }

          await _apiService.verifyGooglePlayPurchaseForRecovery(
            pending: pending,
            purchaseToken: purchaseToken,
            transactionId: _transactionId(purchase),
          );

          /*
           * Complete the client purchase only after the backend has confirmed
           * and granted the entitlement.
           */
          await _billingService.finishVerifiedPurchase(purchase);
          await _billingService.clearPendingPurchase();
          return;
      }
    } on DioException catch (error, stackTrace) {
      final int? statusCode = error.response?.statusCode;

      /*
       * A 403/404 normally means the stored order belongs to a previously
       * logged-in user or no longer exists. Remove it so it cannot block the
       * current account.
       */
      if (statusCode == 403 || statusCode == 404) {
        await _billingService.clearPendingPurchase();
      }

      dev.log(
        'Pending course purchase recovery did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      /*
       * Keep the pending record for network, server and Google Play failures.
       */
      dev.log(
        'Pending course purchase recovery did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isRecovering = false;
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}