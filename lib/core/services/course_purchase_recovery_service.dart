import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:italir_pothe/core/utils/app_logger.dart';

import '../../features/courses/sub_features/pro_checkout/models/pro_checkout_models.dart';
import '../../features/courses/sub_features/pro_checkout/services/course_google_play_billing_service.dart';
import '../../features/courses/sub_features/pro_checkout/services/pro_checkout_api_service.dart';

class CoursePurchaseRecoveryService extends GetxService
    with WidgetsBindingObserver {
  CoursePurchaseRecoveryService({
    required CourseGooglePlayBillingService billingService,
    required ProCheckoutApiService apiService,
  }) : _billingService = billingService,
        _apiService = apiService;

  static const Set<String> _permanentFailureCodes = <String>{
    'GOOGLE_PLAY_PURCHASE_LINKED_TO_ANOTHER_USER',
    'GOOGLE_PLAY_ACCOUNT_IDENTIFIER_MISSING',
    'GOOGLE_PLAY_PURCHASE_LINKED_TO_ANOTHER_COURSE',
    'GOOGLE_PLAY_PURCHASE_NOT_RESTORABLE',
  };

  final CourseGooglePlayBillingService _billingService;
  final ProCheckoutApiService _apiService;

  bool _isRecovering = false;
  int _suspensionCount = 0;

  bool get isSuspended => _suspensionCount > 0;

  Future<CoursePurchaseRecoveryService> init() async {
    WidgetsBinding.instance.addObserver(this);

    await _billingService.initialize();
    await migrateLegacyPendingPurchase();

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

  Future<void> migrateLegacyPendingPurchase() async {
    if (_billingService.loadPendingPurchase() != null) {
      return;
    }

    final ProPendingGooglePlayPurchaseModel? legacyPending =
    _billingService.loadLegacyPendingPurchase();

    if (legacyPending == null || _billingService.currentAppUserId.isEmpty) {
      return;
    }

    try {
      await _apiService.canAccessPendingOrder(pending: legacyPending);
      await _billingService.adoptLegacyPendingPurchase(legacyPending);
    } on DioException catch (error, stackTrace) {
      final int? statusCode = error.response?.statusCode;

      /*
       * A 403/404 means this legacy record belongs to another app user.
       * Leave it in the legacy slot so its original owner can still recover
       * after signing in later, but never expose it to the current user.
       */
      if (statusCode == 403 || statusCode == 404) {
        return;
      }

      AppLogger.log(
        'Legacy course purchase migration did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppLogger.log(
        'Legacy course purchase migration did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> recoverPendingPurchase() async {
    if (_isRecovering || isSuspended || !Platform.isAndroid) {
      return;
    }

    await migrateLegacyPendingPurchase();

    final ProPendingGooglePlayPurchaseModel? pending =
    _billingService.loadPendingPurchase();

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
          AppLogger.log(
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
            AppLogger.log(
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
      final String errorCode = _backendErrorCode(error);

      if (_permanentFailureCodes.contains(errorCode)) {
        await _billingService.clearPendingPurchase();

        AppLogger.log(
          'Pending purchase recovery stopped because the purchase cannot be linked to this app user.',
          name: 'CoursePurchaseRecoveryService',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }

      /*
       * A 403/404 normally means the stored order belongs to a previously
       * logged-in user or no longer exists. Remove only the current user's
       * scoped record so it cannot block this account.
       */
      if (statusCode == 403 || statusCode == 404) {
        await _billingService.clearPendingPurchase();
      }

      AppLogger.log(
        'Pending course purchase recovery did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      /*
       * Keep the pending record for network, server and Google Play failures.
       */
      AppLogger.log(
        'Pending course purchase recovery did not finish.',
        name: 'CoursePurchaseRecoveryService',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isRecovering = false;
    }
  }

  String _backendErrorCode(DioException error) {
    final dynamic data = error.response?.data;

    if (data is! Map) {
      return '';
    }

    final String directCode = data['code']?.toString().trim() ?? '';
    if (directCode.isNotEmpty) {
      return directCode;
    }

    final dynamic nestedError = data['error'];
    if (nestedError is Map) {
      return nestedError['code']?.toString().trim() ?? '';
    }

    return '';
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
