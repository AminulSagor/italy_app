import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../models/pro_checkout_models.dart';
import '../services/pro_checkout_mock_service.dart';

class ProCheckoutController extends GetxController {
  final ProCheckoutMockService _proCheckoutMockService;
  final Future<void> Function() onPurchaseCompleted;

  ProCheckoutController({
    required ProCheckoutMockService proCheckoutMockService,
    required this.onPurchaseCompleted,
  }) : _proCheckoutMockService = proCheckoutMockService;

  final TextEditingController couponController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isCouponApplying = false.obs;
  final RxBool isCouponApplied = false.obs;
  final RxBool isPurchasing = false.obs;
  final Rx<ProCurrency> selectedCurrency = ProCurrency.eur.obs;
  final Rx<ProPaymentMethod> selectedPaymentMethod = ProPaymentMethod.card.obs;
  final Rxn<ProOrderModel> order = Rxn<ProOrderModel>();
  final Rxn<ProPurchaseResultModel> purchaseResult = Rxn<ProPurchaseResultModel>();

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

  Future<void> loadOrderSummary() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      order.value = await _proCheckoutMockService.fetchOrderSummary();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyCoupon() async {
    final ProOrderModel? currentOrder = order.value;
    if (currentOrder == null || isCouponApplying.value) {
      return;
    }

    final String code = couponController.text.trim().isEmpty
        ? currentOrder.plan.couponCode
        : couponController.text.trim();

    isCouponApplying.value = true;
    try {
      await _proCheckoutMockService.applyCoupon(code);
      couponController.text = code;
      isCouponApplied.value = true;
    } finally {
      isCouponApplying.value = false;
    }
  }

  void setCurrency(ProCurrency currency) {
    if (selectedPaymentMethod.value == ProPaymentMethod.paypal ||
        selectedPaymentMethod.value == ProPaymentMethod.applePay) {
      selectedCurrency.value = ProCurrency.eur;
      return;
    }

    selectedCurrency.value = currency;
  }

  void selectPaymentMethod(ProPaymentMethod method) {
    selectedPaymentMethod.value = method;
    if (method == ProPaymentMethod.bkash) {
      selectedCurrency.value = ProCurrency.bdt;
      return;
    }

    if (method == ProPaymentMethod.paypal || method == ProPaymentMethod.applePay) {
      selectedCurrency.value = ProCurrency.eur;
    }
  }

  Future<void> openCheckout(String controllerTag) async {
    await Get.toNamed(
      AppRoutes.proCheckout,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> completePurchase(String controllerTag) async {
    if (isPurchasing.value || order.value == null) {
      return;
    }

    isPurchasing.value = true;
    try {
      purchaseResult.value = await _proCheckoutMockService.completePurchase(
        currency: selectedCurrency.value,
        paymentMethod: selectedPaymentMethod.value,
      );
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
