import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/pro_checkout_models.dart';
import '../services/pro_checkout_api_service.dart';

class ProCheckoutController extends GetxController {
  ProCheckoutController({
    required ProCheckoutApiService proCheckoutApiService,
    required this.courseId,
    required this.courseName,
    required this.lessonCount,
    required this.onPurchaseCompleted,
  }) : _proCheckoutApiService = proCheckoutApiService;

  final ProCheckoutApiService _proCheckoutApiService;
  final String courseId;
  final String courseName;
  final int lessonCount;
  final Future<void> Function() onPurchaseCompleted;

  final TextEditingController couponController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isCouponApplying = false.obs;
  final RxBool isCouponApplied = false.obs;
  final RxBool isPurchasing = false.obs;
  final Rx<ProCurrency> selectedCurrency = ProCurrency.eur.obs;
  final Rx<ProPaymentMethod> selectedPaymentMethod = ProPaymentMethod.card.obs;
  final Rxn<ProOrderModel> order = Rxn<ProOrderModel>();
  final Rxn<ProPurchaseResultModel> purchaseResult =
      Rxn<ProPurchaseResultModel>();

  @override
  void onInit() {
    super.onInit();
    loadOrderSummary();
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }

  Future<void> loadOrderSummary({String? couponCode}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
        () => _proCheckoutApiService.fetchOrderSummary(
          courseId: courseId,
          fallbackCourseName: courseName,
          lessonCount: lessonCount,
          couponCode: couponCode,
        ),
        errorTitle: 'Course Purchase',
      );
      if (result.isSuccess && result.data != null) {
        order.value = result.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyCoupon() async {
    if (order.value == null || isCouponApplying.value) return;

    final String code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar('Coupon', 'Enter a coupon code first.');
      return;
    }

    isCouponApplying.value = true;
    try {
      final ApiResult<ProOrderModel> result =
          await ApiErrorHandler.call<ProOrderModel>(
        () => _proCheckoutApiService.fetchOrderSummary(
          courseId: courseId,
          fallbackCourseName: courseName,
          lessonCount: lessonCount,
          couponCode: code,
        ),
        errorTitle: 'Coupon',
      );
      if (!result.isSuccess || result.data == null) return;

      order.value = result.data;
      couponController.text = code;
      isCouponApplied.value = true;
    } finally {
      isCouponApplying.value = false;
    }
  }

  void setCurrency(ProCurrency currency) {
    selectedCurrency.value = currency;
  }

  void selectPaymentMethod(ProPaymentMethod method) {
    selectedPaymentMethod.value = method;
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

    isPurchasing.value = true;
    try {
      final ApiResult<ProPurchaseResultModel> result =
          await ApiErrorHandler.call<ProPurchaseResultModel>(
        () => _proCheckoutApiService.completePurchase(
          order: currentOrder,
          currency: selectedCurrency.value,
          paymentMethod: selectedPaymentMethod.value,
          couponCode: isCouponApplied.value
              ? couponController.text.trim()
              : null,
        ),
        errorTitle: 'Course Purchase',
      );
      if (!result.isSuccess || result.data == null) return;

      purchaseResult.value = result.data;
      await onPurchaseCompleted();
      await Get.offNamed(
        AppRoutes.proPurchaseSuccess,
        arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
      );
    } finally {
      isPurchasing.value = false;
    }
  }
}
