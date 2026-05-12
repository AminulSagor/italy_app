import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';

enum AiRefillPlan { basic, fluent, elite }

enum RefillCurrency { eur, bdt }

enum CheckoutPaymentMethod { card, paypal, applePay, bkash }

class StreakFreezePackTitles {
  static const String singleFreezeTitle = 'Single Freeze';
  static const String tripleProtectionTitle = 'Triple Protection (3x)';
  static const String unlimitedMonthlyShieldTitle = 'Unlimited Monthly Shield';
}

class CvCreditOffer {
  final String id;
  final String title;
  final String subtitle;
  final int credits;
  final double priceEur;
  final double? couponPriceEur;
  final String badge;
  final bool isMonthly;
  final IconData icon;

  const CvCreditOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.priceEur,
    this.couponPriceEur,
    this.badge = '',
    this.isMonthly = false,
    required this.icon,
  });
}

class OrderHistoryFilterTitles {
  static const String allOrders = 'All Orders';
  static const String courses = 'Courses';
  static const String aiRefills = 'AI Refills';
}

class OrderHistoryItem {
  final String id;
  final String title;
  final String category;
  final String price;
  final String date;
  final String status;

  const OrderHistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.date,
    this.status = 'COMPLETED',
  });
}

class ShopController extends GetxController {
  void onRefillCreditTap() {
    Get.toNamed(AppRoutes.aiRefillCenter);
  }

  // AI refill center state
  final Rx<AiRefillPlan> selectedPlan = AiRefillPlan.fluent.obs;

  void selectPlan(AiRefillPlan plan) {
    selectedPlan.value = plan;
    clearCoupon();
  }

  bool isSelected(AiRefillPlan plan) {
    return selectedPlan.value == plan;
  }

  String get selectedPlanTitle {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return 'Basic Starter';
      case AiRefillPlan.fluent:
        return 'Fluent Learner';
      case AiRefillPlan.elite:
        return 'Elite Mastery';
    }
  }

  String get selectedPlanSubtitle {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return '15 Mins Voice | 1,000 Tokens';
      case AiRefillPlan.fluent:
        return '60 Mins Voice | 5,000 Tokens';
      case AiRefillPlan.elite:
        return '180 Mins | 15,000 Tokens';
    }
  }

  // Order summary state
  final Rx<RefillCurrency> selectedCurrency = RefillCurrency.eur.obs;

  final TextEditingController couponTextController = TextEditingController();

  final RxString couponCode = ''.obs;
  final RxBool isCouponApplied = false.obs;

  void selectCurrency(RefillCurrency currency) {
    selectedCurrency.value = currency;
    syncDefaultPaymentMethod();
  }

  void onCouponChanged(String value) {
    couponCode.value = value;

    if (isCouponApplied.value) {
      isCouponApplied.value = false;
    }
  }

  void applyCoupon() {
    final code = couponTextController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        'Coupon Required',
        'Please enter a coupon code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    couponCode.value = code;
    isCouponApplied.value = true;
  }

  void clearCoupon() {
    couponTextController.clear();
    couponCode.value = '';
    isCouponApplied.value = false;
  }

  double get selectedPlanPriceEurValue {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return 2.49;
      case AiRefillPlan.fluent:
        return 5.99;
      case AiRefillPlan.elite:
        return 14.99;
    }
  }

  double get selectedPlanPriceBdtValue {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return 299;
      case AiRefillPlan.fluent:
        return 867;
      case AiRefillPlan.elite:
        return 1799;
    }
  }

  double get currentBasePrice {
    return selectedCurrency.value == RefillCurrency.eur
        ? selectedPlanPriceEurValue
        : selectedPlanPriceBdtValue;
  }

  double get discountAmount {
    if (!isCouponApplied.value) return 0;
    return currentBasePrice * 0.20;
  }

  double get payableAmount {
    return currentBasePrice - discountAmount;
  }

  // Checkout design always shows the sale/discount badge like the reference UI.
  double get checkoutDiscountAmount => currentBasePrice * 0.20;

  double get checkoutPayableAmount => currentBasePrice - checkoutDiscountAmount;

  String formatPrice(double? value) {
    final double safeValue = value ?? 0;

    if (selectedCurrency.value == RefillCurrency.eur) {
      return '€${safeValue.toStringAsFixed(2)}';
    }

    return '৳${safeValue.toStringAsFixed(0)}';
  }

  String get selectedPlanPrice => formatPrice(selectedPlanPriceEurValue);

  String get selectedPlanPriceBdt => formatPrice(selectedPlanPriceBdtValue);

  String get orderSummaryPrice => formatPrice(payableAmount);

  String get originalPriceText => formatPrice(currentBasePrice);

  String get payablePriceText => formatPrice(payableAmount);

  String get savedAmountText => formatPrice(discountAmount);

  String get checkoutOriginalPriceText => formatPrice(currentBasePrice);

  String get checkoutPayablePriceText => formatPrice(checkoutPayableAmount);

  String get checkoutSavedAmountText => formatPrice(checkoutDiscountAmount);

  void confirmPurchase() {
    clearCoupon();
    Get.toNamed(AppRoutes.orderSummary);
  }

  void buySelectedPlan() {
    goToCheckout();
  }

  // Checkout state
  final Rx<CheckoutPaymentMethod> selectedPaymentMethod =
      CheckoutPaymentMethod.card.obs;

  final RxBool isCheckoutLoading = false.obs;
  final RxString checkoutError = ''.obs;

  void syncDefaultPaymentMethod() {
    selectedPaymentMethod.value = selectedCurrency.value == RefillCurrency.bdt
        ? CheckoutPaymentMethod.bkash
        : CheckoutPaymentMethod.card;
  }

  List<CheckoutPaymentMethod> get availablePaymentMethods => const [
    CheckoutPaymentMethod.card,
    CheckoutPaymentMethod.paypal,
    CheckoutPaymentMethod.applePay,
    CheckoutPaymentMethod.bkash,
  ];

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    selectedPaymentMethod.value = method;
    checkoutError.value = '';
  }

  bool isPaymentMethodSelected(CheckoutPaymentMethod method) {
    return selectedPaymentMethod.value == method;
  }

  String get selectedPaymentMethodTitle {
    switch (selectedPaymentMethod.value) {
      case CheckoutPaymentMethod.card:
        return 'Card';
      case CheckoutPaymentMethod.paypal:
        return 'PayPal';
      case CheckoutPaymentMethod.applePay:
        return 'Apple Pay';
      case CheckoutPaymentMethod.bkash:
        return 'Bkash';
    }
  }

  void goToCheckout() {
    syncDefaultPaymentMethod();
    checkoutError.value = '';
    Get.toNamed(AppRoutes.checkout);
  }

  Future<void> confirmCheckout() async {
    isCheckoutLoading.value = true;
    checkoutError.value = '';

    try {
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('Plan: $selectedPlanTitle');
      debugPrint('Currency: ${selectedCurrency.value}');
      debugPrint('Amount: $checkoutPayablePriceText');
      debugPrint('Payment method: $selectedPaymentMethodTitle');

      Get.snackbar(
        'Payment Started',
        'Redirecting to $selectedPaymentMethodTitle',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      checkoutError.value = 'Something went wrong. Please try again.';
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  String get selectedPlanVoiceMinutes {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return '15m';
      case AiRefillPlan.fluent:
        return '60m';
      case AiRefillPlan.elite:
        return '180m';
    }
  }

  String get selectedPlanTokensShort {
    switch (selectedPlan.value) {
      case AiRefillPlan.basic:
        return '1k';
      case AiRefillPlan.fluent:
        return '5k';
      case AiRefillPlan.elite:
        return '15k';
    }
  }

  String get completedMessage {
    return "Your '$selectedPlanTitle' bundle is\nactive. You now have ${selectedPlanVoiceMinutes.replaceAll('m', ' Mins')} of\nVoice and ${selectedPlanSubtitle.split('|').last.trim()}.";
  }

  final RxString completedOrderId = '#IT-SHK-1024'.obs;

  void goToPurchaseCompleted() {
    completedOrderId.value = '#IT-SHK-1024';
    Get.offNamed(AppRoutes.purchaseCompleted);
  }

  void startLearningNow() {
    // TODO: replace with your learning/home route
    Get.back();
  }

  // Streak freeze store state
  final RxString selectedStreakFreezePack =
      StreakFreezePackTitles.tripleProtectionTitle.obs;

  void selectStreakFreezePack(String title) {
    selectedStreakFreezePack.value = title;
    clearCoupon();
  }

  bool isStreakFreezePackSelected(String title) {
    return selectedStreakFreezePack.value == title;
  }

  String get selectedStreakFreezePackTitle => selectedStreakFreezePack.value;

  int get selectedStreakFreezeCount {
    switch (selectedStreakFreezePackTitle) {
      case StreakFreezePackTitles.tripleProtectionTitle:
        return 3;
      case StreakFreezePackTitles.unlimitedMonthlyShieldTitle:
        return 30;
      default:
        return 1;
    }
  }

  String streakFreezePackSubtitle(String title) {
    switch (title) {
      case StreakFreezePackTitles.tripleProtectionTitle:
        return 'Best for short breaks';
      case StreakFreezePackTitles.unlimitedMonthlyShieldTitle:
        return 'Maximum streak safety';
      default:
        return 'Protect 1 missed day';
    }
  }

  String streakFreezePackBadge(String title) {
    switch (title) {
      case StreakFreezePackTitles.tripleProtectionTitle:
        return 'Popular';
      case StreakFreezePackTitles.unlimitedMonthlyShieldTitle:
        return 'Best Value';
      default:
        return '';
    }
  }

  double streakFreezePackPriceValue(String title) {
    final bool isEur = selectedCurrency.value == RefillCurrency.eur;

    switch (title) {
      case StreakFreezePackTitles.tripleProtectionTitle:
        return isEur ? 2.49 : 299;
      case StreakFreezePackTitles.unlimitedMonthlyShieldTitle:
        return isEur ? 4.99 : 599;
      default:
        return isEur ? 0.99 : 119;
    }
  }

  double get currentStreakFreezeBasePrice {
    return streakFreezePackPriceValue(selectedStreakFreezePackTitle);
  }

  double get streakFreezeDiscountAmount {
    if (!isCouponApplied.value) return 0;
    return currentStreakFreezeBasePrice * 0.20;
  }

  double get streakFreezePayableAmount {
    return currentStreakFreezeBasePrice - streakFreezeDiscountAmount;
  }

  String get streakFreezeOriginalPriceText {
    return formatPrice(currentStreakFreezeBasePrice);
  }

  String get streakFreezeSavedAmountText {
    return formatPrice(streakFreezeDiscountAmount);
  }

  String get streakFreezePayablePriceText {
    return formatPrice(streakFreezePayableAmount);
  }

  void onStreakFreezeTap() {
    clearCoupon();
    syncDefaultPaymentMethod();
    checkoutError.value = '';
    Get.toNamed(AppRoutes.streakFreeze);
  }

  void goToStreakFreezeOrderSummary() {
    clearCoupon();
    checkoutError.value = '';
    syncDefaultPaymentMethod();

    // Use your existing order summary route.
    // If you create a separate route, replace this with AppRoutes.streakFreezeOrderSummary.
    Get.toNamed(AppRoutes.streakFreezeOrderSummary);
  }

  Future<void> confirmStreakFreezePurchase() async {
    isCheckoutLoading.value = true;
    checkoutError.value = '';

    try {
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('Pack: $selectedStreakFreezePackTitle');
      debugPrint('Freezes: $selectedStreakFreezeCount');
      debugPrint('Currency: ${selectedCurrency.value}');
      debugPrint('Amount: $streakFreezePayablePriceText');
      debugPrint('Payment method: $selectedPaymentMethodTitle');

      Get.snackbar(
        'Purchase Started',
        'Redirecting to $selectedPaymentMethodTitle',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      checkoutError.value = 'Something went wrong. Please try again.';
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  // CV credit store state
  static const double cvCreditBdtRate = 144.32;

  final RxInt cvCreditBalance = 1.obs;

  final RxList<CvCreditOffer> cvCreditOffers = <CvCreditOffer>[
    const CvCreditOffer(
      id: 'single_refill',
      title: 'Single Refill',
      subtitle: '1 Credit',
      credits: 1,
      priceEur: 0.99,
      icon: Icons.history_edu_rounded,
    ),
    const CvCreditOffer(
      id: 'pro_hunter_pack',
      title: 'Pro Hunter Pack (5×)',
      subtitle: '5 Credits',
      credits: 5,
      priceEur: 2.99,
      couponPriceEur: 1.99,
      badge: 'BEST VALUE',
      icon: Icons.history_edu_rounded,
    ),
    const CvCreditOffer(
      id: 'career_sprint_pack',
      title: 'Career Sprint Pack',
      subtitle: '10 Credits',
      credits: 10,
      priceEur: 9.99,
      isMonthly: true,
      icon: Icons.all_inclusive_rounded,
    ),
  ].obs;

  final RxString selectedCvCreditOfferId = 'pro_hunter_pack'.obs;

  CvCreditOffer get selectedCvCreditOffer {
    return cvCreditOffers.firstWhere(
      (offer) => offer.id == selectedCvCreditOfferId.value,
      orElse: () => cvCreditOffers.first,
    );
  }

  void selectCvCreditOffer(String offerId) {
    selectedCvCreditOfferId.value = offerId;
    clearCoupon();
  }

  bool isCvCreditOfferSelected(String offerId) {
    return selectedCvCreditOfferId.value == offerId;
  }

  String get selectedCvCreditOfferSummary {
    final int count = selectedCvCreditOffer.credits;
    return '$count CV Credit${count == 1 ? '' : 's'} | Instant Activation';
  }

  double cvCreditOfferPriceValue(CvCreditOffer offer) {
    if (selectedCurrency.value == RefillCurrency.eur) {
      return offer.priceEur;
    }

    return offer.priceEur * cvCreditBdtRate;
  }

  double cvCreditOfferCouponPriceValue(CvCreditOffer offer) {
    final double eurValue = offer.couponPriceEur ?? (offer.priceEur * 0.80);

    if (selectedCurrency.value == RefillCurrency.eur) {
      return eurValue;
    }

    return eurValue * cvCreditBdtRate;
  }

  String cvCreditOfferPriceText(CvCreditOffer offer) {
    final String price = formatPrice(cvCreditOfferPriceValue(offer));
    return offer.isMonthly ? '$price/mo' : price;
  }

  double get currentCvCreditBasePrice {
    return cvCreditOfferPriceValue(selectedCvCreditOffer);
  }

  double get currentCvCreditCouponPrice {
    return cvCreditOfferCouponPriceValue(selectedCvCreditOffer);
  }

  double get cvCreditDiscountAmount {
    if (!isCouponApplied.value) return 0;
    return currentCvCreditBasePrice - currentCvCreditCouponPrice;
  }

  double get cvCreditPayableAmount {
    if (!isCouponApplied.value) return currentCvCreditBasePrice;
    return currentCvCreditCouponPrice;
  }

  String get cvCreditOriginalPriceText {
    return formatPrice(currentCvCreditBasePrice);
  }

  String get cvCreditSavedAmountText {
    return formatPrice(cvCreditDiscountAmount);
  }

  String get cvCreditPayablePriceText {
    return formatPrice(cvCreditPayableAmount);
  }

  void onCvCreditTap() {
    clearCoupon();
    checkoutError.value = '';
    syncDefaultPaymentMethod();
    Get.toNamed(AppRoutes.cvCreditStore);
  }

  void goToCvCreditOrderSummary() {
    clearCoupon();
    checkoutError.value = '';
    syncDefaultPaymentMethod();
    Get.toNamed(AppRoutes.cvCreditOrderSummary);
  }

  Future<void> confirmCvCreditPurchase() async {
    isCheckoutLoading.value = true;
    checkoutError.value = '';

    try {
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('CV Pack: ${selectedCvCreditOffer.title}');
      debugPrint('Credits: ${selectedCvCreditOffer.credits}');
      debugPrint('Currency: ${selectedCurrency.value}');
      debugPrint('Amount: $cvCreditPayablePriceText');
      debugPrint(
        'Coupon: ${isCouponApplied.value ? couponCode.value : 'none'}',
      );

      Get.snackbar(
        'Purchase Started',
        'Your CV credits will be added after payment confirmation.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      checkoutError.value = 'Something went wrong. Please try again.';
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  @override
  void onClose() {
    couponTextController.dispose();
    orderSearchTextController.dispose();
    super.onClose();
  }

  // Order history state
  final List<String> orderHistoryFilters = const <String>[
    OrderHistoryFilterTitles.allOrders,
    OrderHistoryFilterTitles.courses,
    OrderHistoryFilterTitles.aiRefills,
  ];

  final RxString selectedOrderHistoryFilter =
      OrderHistoryFilterTitles.allOrders.obs;

  final TextEditingController orderSearchTextController =
      TextEditingController();

  final RxString orderSearchQuery = ''.obs;

  final List<OrderHistoryItem> orderHistoryItems = const <OrderHistoryItem>[
    OrderHistoryItem(
      id: '#IT-SHK-1024',
      title: 'Fluent Learner\nBundle',
      category: OrderHistoryFilterTitles.aiRefills,
      price: '€6.99',
      date: 'Oct 24, 2023',
    ),
    OrderHistoryItem(
      id: '#IT-SHK-0988',
      title: 'Level A1:\nLifetime Access',
      category: OrderHistoryFilterTitles.courses,
      price: '€29.99',
      date: 'Oct 15, 2023',
    ),
  ];

  List<OrderHistoryItem> get filteredOrderHistoryItems {
    final String filter = selectedOrderHistoryFilter.value;
    final String search = orderSearchQuery.value.trim().toLowerCase();

    return orderHistoryItems.where((OrderHistoryItem item) {
      final bool matchesFilter =
          filter == OrderHistoryFilterTitles.allOrders ||
          item.category == filter;

      final bool matchesSearch =
          search.isEmpty ||
          item.title.toLowerCase().contains(search) ||
          item.id.toLowerCase().contains(search) ||
          item.date.toLowerCase().contains(search) ||
          item.price.toLowerCase().contains(search);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void selectOrderHistoryFilter(String filter) {
    selectedOrderHistoryFilter.value = filter;
  }

  void onOrderSearchChanged(String value) {
    orderSearchQuery.value = value;
  }

  void onOrderHistoryTap() {
    Get.toNamed(AppRoutes.orderHistory);
  }

  void contactOrderSupport() {
    Get.snackbar(
      'Support',
      'Support chat will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
