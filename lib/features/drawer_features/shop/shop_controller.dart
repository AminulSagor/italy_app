import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/controllers/user_session_controller.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../routes/routes.dart';
import 'models/shop_models.dart';
import 'models/shop_order_models.dart';
import 'services/shop_api_service.dart';

class OrderHistoryFilterTitles {
  static const String allOrders = 'All Orders';
  static const String courses = 'Courses';
  static const String aiRefills = 'AI Refills';
  static const String streakFreezes = 'Streak Freezes';
  static const String cvCredits = 'CV Credits';
}

class ShopController extends GetxController {
  ShopController({required ShopApiService apiService})
    : _apiService = apiService;

  final ShopApiService _apiService;
  static const Uuid _uuid = Uuid();

  final RxBool isLoadingShop = false.obs;
  final RxBool isLoadingQuote = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxString shopError = ''.obs;
  final RxString checkoutError = ''.obs;

  final Rxn<StoreShopModel> shop = Rxn<StoreShopModel>();
  final Rxn<StoreBalancesModel> balances = Rxn<StoreBalancesModel>();
  final RxList<StorePackageModel> aiPackages = <StorePackageModel>[].obs;
  final RxList<StorePackageModel> streakPackages = <StorePackageModel>[].obs;
  final RxList<StorePackageModel> cvPackages = <StorePackageModel>[].obs;

  final RxString selectedAiPackageId = ''.obs;
  final RxString selectedStreakPackageId = ''.obs;
  final RxString selectedCvPackageId = ''.obs;
  final Rxn<StorePackageModel> activePackage = Rxn<StorePackageModel>();

  final Rx<RefillCurrency> selectedCurrency = RefillCurrency.eur.obs;
  final TextEditingController couponTextController = TextEditingController();
  final RxString couponCode = ''.obs;
  final RxBool isCouponApplied = false.obs;
  final Rxn<StoreQuoteResponseModel> quote = Rxn<StoreQuoteResponseModel>();
  final Rx<CheckoutPaymentMethod> selectedPaymentMethod =
      CheckoutPaymentMethod.card.obs;

  final Rxn<StorePurchaseCompletionModel> completedPurchase =
      Rxn<StorePurchaseCompletionModel>();

  @override
  void onInit() {
    super.onInit();
    loadShop();
  }

  StorePackageModel? get selectedAiPackage =>
      _findPackage(aiPackages, selectedAiPackageId.value);
  StorePackageModel? get selectedStreakPackage =>
      _findPackage(streakPackages, selectedStreakPackageId.value);
  StorePackageModel? get selectedCvPackage =>
      _findPackage(cvPackages, selectedCvPackageId.value);

  int get aiVoiceMinutes => balances.value?.aiVoiceMinutes ?? 0;
  int get aiTextTokens => balances.value?.aiTextTokens ?? 0;
  int get streakFreezeBalance => balances.value?.streakFreezeCount ?? 0;
  int get cvCreditBalance => balances.value?.cvCredits ?? 0;

  StoreShopSectionModel? sectionFor(StorePackageType type) {
    for (final StoreShopSectionModel item in shop.value?.sections ?? const []) {
      if (item.packageType == type) return item;
    }
    return null;
  }

  Future<void> loadShop() async {
    if (isLoadingShop.value) return;
    isLoadingShop.value = true;
    shopError.value = '';

    final ApiResult<List<Object>> result =
        await ApiErrorHandler.call<List<Object>>(() async {
          final List<Object> values = await Future.wait<Object>(<Future<Object>>[
            _apiService.getShop(),
            _apiService.getPackages(packageType: StorePackageType.aiBundle),
            _apiService.getPackages(
              packageType: StorePackageType.streakFreeze,
            ),
            _apiService.getPackages(packageType: StorePackageType.cvCredit),
          ]);
          return values;
        }, showError: false);

    if (result.isSuccess && result.data != null) {
      final List<Object> data = result.data!;
      final StoreShopModel shopData = data[0] as StoreShopModel;
      shop.value = shopData;
      balances.value = shopData.balances;
      _syncUserSessionBalances(shopData.balances);
      aiPackages.assignAll((data[1] as StorePackageListResponseModel).items);
      streakPackages.assignAll((data[2] as StorePackageListResponseModel).items);
      cvPackages.assignAll((data[3] as StorePackageListResponseModel).items);
      _selectDefaults();
    } else {
      shopError.value = result.error ?? 'Could not load the shop.';
    }
    isLoadingShop.value = false;
  }

  Future<void> refreshBalances() async {
    final ApiResult<StoreBalancesModel> result =
        await ApiErrorHandler.call<StoreBalancesModel>(
          _apiService.getBalances,
          showError: false,
        );
    if (result.isSuccess && result.data != null) {
      balances.value = result.data;
      _syncUserSessionBalances(result.data!);
    }
  }

  void selectAiPackage(String packageId) {
    selectedAiPackageId.value = packageId;
    _resetQuote();
  }

  void selectStreakPackage(String packageId) {
    selectedStreakPackageId.value = packageId;
    _resetQuote();
  }

  void selectCvPackage(String packageId) {
    selectedCvPackageId.value = packageId;
    _resetQuote();
  }

  bool isAiPackageSelected(String id) => selectedAiPackageId.value == id;
  bool isStreakPackageSelected(String id) =>
      selectedStreakPackageId.value == id;
  bool isCvPackageSelected(String id) => selectedCvPackageId.value == id;

  String packagePriceText(StorePackageModel package) {
    final String price = '€${package.priceEur.toStringAsFixed(2)}';
    return package.isMonthly ? '$price/mo' : price;
  }

  Future<void> selectCurrency(RefillCurrency currency) async {
    if (selectedCurrency.value == currency) return;
    selectedCurrency.value = currency;
    await _loadQuote(coupon: isCouponApplied.value ? couponCode.value : '');
  }

  void onCouponChanged(String value) {
    couponCode.value = value.trim();
    if (isCouponApplied.value) isCouponApplied.value = false;
  }

  Future<void> applyCoupon() async {
    final String code = couponTextController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('Coupon Required', 'Please enter a coupon code.');
      return;
    }
    final bool loaded = await _loadQuote(coupon: code);
    if (loaded) {
      couponCode.value = code;
      isCouponApplied.value = true;
    }
  }

  Future<void> clearCoupon() async {
    couponTextController.clear();
    couponCode.value = '';
    isCouponApplied.value = false;
    if (activePackage.value != null) await _loadQuote();
  }

  String formatPrice(double value) {
    final bool eur = selectedCurrency.value == RefillCurrency.eur;
    return eur ? '€${value.toStringAsFixed(2)}' : '৳${value.toStringAsFixed(0)}';
  }

  StoreQuotePricingModel? get pricing => quote.value?.pricing;
  double get currentBasePrice =>
      pricing?.originalAmount ?? activePackage.value?.priceEur ?? 0;
  double get discountAmount => pricing?.discountAmount ?? 0;
  double get payableAmount => pricing?.payableAmount ?? currentBasePrice;
  String get originalPriceText => formatPrice(currentBasePrice);
  String get payablePriceText => formatPrice(payableAmount);
  String get savedAmountText => formatPrice(discountAmount);
  String get orderSummaryPrice => payablePriceText;
  String get checkoutOriginalPriceText => originalPriceText;
  String get checkoutPayablePriceText => payablePriceText;
  String get checkoutSavedAmountText => savedAmountText;
  String get streakFreezeOriginalPriceText => originalPriceText;
  String get streakFreezePayablePriceText => payablePriceText;
  String get streakFreezeSavedAmountText => savedAmountText;
  String get cvCreditOriginalPriceText => originalPriceText;
  String get cvCreditPayablePriceText => payablePriceText;
  String get cvCreditSavedAmountText => savedAmountText;

  StorePackageModel? get checkoutPackage =>
      activePackage.value ?? selectedAiPackage;
  String get selectedPlanTitle => checkoutPackage?.name ?? 'Package';
  String get selectedPlanSubtitle => checkoutPackage?.entitlementSummary ?? '';
  String get checkoutBillingLabel =>
      checkoutPackage?.isMonthly == true ? '/ month' : '/ one-time';
  String get selectedStreakFreezePackTitle =>
      selectedStreakPackage?.name ?? 'Streak Freeze';
  int get selectedStreakFreezeCount =>
      selectedStreakPackage?.streakFreezeCount ?? 0;
  StorePackageModel get selectedCvCreditOffer =>
      selectedCvPackage ?? _emptyPackage(StorePackageType.cvCredit);
  String get selectedCvCreditOfferSummary =>
      selectedCvPackage?.entitlementSummary ?? '';

  Future<void> onRefillCreditTap() async {
    await _openPackageList(StorePackageType.aiBundle, AppRoutes.aiRefillCenter);
  }

  Future<void> onStreakFreezeTap() async {
    await _openPackageList(StorePackageType.streakFreeze, AppRoutes.streakFreeze);
  }

  Future<void> onCvCreditTap() async {
    await _openPackageList(StorePackageType.cvCredit, AppRoutes.cvCreditStore);
  }

  Future<void> confirmPurchase() async {
    await _openSummary(selectedAiPackage, AppRoutes.orderSummary);
  }

  Future<void> goToStreakFreezeOrderSummary() async {
    await _openSummary(
      selectedStreakPackage,
      AppRoutes.streakFreezeOrderSummary,
    );
  }

  Future<void> goToCvCreditOrderSummary() async {
    await _openSummary(selectedCvPackage, AppRoutes.cvCreditOrderSummary);
  }

  Future<void> buySelectedPlan() async {
    if (quote.value == null && !await _loadQuote()) return;
    _selectDefaultPaymentMethod();
    Get.toNamed(AppRoutes.checkout);
  }

  List<CheckoutPaymentMethod> get availablePaymentMethods =>
      quote.value?.supportedProviders
          .map((StoreProviderOptionModel item) => item.method)
          .toList(growable: false) ??
      const <CheckoutPaymentMethod>[];

  StoreProviderOptionModel? paymentOption(CheckoutPaymentMethod method) {
    for (final StoreProviderOptionModel option
        in quote.value?.supportedProviders ?? const []) {
      if (option.method == method) return option;
    }
    return null;
  }

  bool isPaymentMethodSelected(CheckoutPaymentMethod method) =>
      selectedPaymentMethod.value == method;

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    final StoreProviderOptionModel? option = paymentOption(method);
    if (option == null || !option.enabled) {
      Get.snackbar(
        'Payment Unavailable',
        option?.unavailableReason.isNotEmpty == true
            ? option!.unavailableReason
            : 'This payment method is unavailable.',
      );
      return;
    }
    selectedPaymentMethod.value = method;
    checkoutError.value = '';
  }

  String paymentMethodTitle(CheckoutPaymentMethod method) {
    final String apiLabel = paymentOption(method)?.label ?? '';
    if (apiLabel.isNotEmpty) return apiLabel;
    switch (method) {
      case CheckoutPaymentMethod.googlePlay:
        return 'Google Play';
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

  Future<void> confirmCheckout() async {
    await _completeSelectedPurchase(selectedPaymentMethod.value);
  }

  Future<void> confirmStreakFreezePurchase() async {
    activePackage.value = selectedStreakPackage;
    await buySelectedPlan();
  }

  Future<void> confirmCvCreditPurchase() async {
    activePackage.value = selectedCvPackage;
    await buySelectedPlan();
  }

  String get completedMessage {
    final StorePurchaseCompletionModel? value = completedPurchase.value;
    if (value == null) return 'Your purchase is now active.';
    switch (value.packageType) {
      case StorePackageType.aiBundle:
        return "Your '${value.packageName}' bundle is active. Voice minutes and AI tokens were added to your balance.";
      case StorePackageType.streakFreeze:
        return "Your '${value.packageName}' protection is active and ready to protect your streak.";
      case StorePackageType.cvCredit:
        return "Your '${value.packageName}' credits are active and ready for CV generation.";
    }
  }

  String get completedOrderId =>
      completedPurchase.value?.orderNumber ?? '';
  String get completionFirstValue {
    final StorePurchaseCompletionModel? value = completedPurchase.value;
    if (value == null) return '0';
    switch (value.packageType) {
      case StorePackageType.aiBundle:
        return '${value.creditedVoiceMinutes}m';
      case StorePackageType.streakFreeze:
        return value.streakProtectionMode == 'monthly_unlimited'
            ? '∞'
            : '${value.creditedStreakFreezes}×';
      case StorePackageType.cvCredit:
        return '${value.creditedCvCredits}×';
    }
  }

  String get completionFirstLabel {
    switch (completedPurchase.value?.packageType) {
      case StorePackageType.aiBundle:
        return 'Voice Interaction';
      case StorePackageType.streakFreeze:
        return 'Protection Added';
      case StorePackageType.cvCredit:
        return 'CV Credits Added';
      case null:
        return 'Credits Added';
    }
  }

  String get completionSecondValue {
    final StorePurchaseCompletionModel? value = completedPurchase.value;
    if (value == null) return '0';
    switch (value.packageType) {
      case StorePackageType.aiBundle:
        return _compact(value.creditedTextTokens);
      case StorePackageType.streakFreeze:
        return '${value.balances.streakFreezeCount}×';
      case StorePackageType.cvCredit:
        return '${value.balances.cvCredits}×';
    }
  }

  String get completionSecondLabel {
    switch (completedPurchase.value?.packageType) {
      case StorePackageType.aiBundle:
        return 'AI Smart Tokens';
      case StorePackageType.streakFreeze:
        return 'Current Balance';
      case StorePackageType.cvCredit:
        return 'Current Balance';
      case null:
        return 'Current Balance';
    }
  }

  void startLearningNow() => Get.offAllNamed(AppRoutes.wrapper);

  void onOrderHistoryTap() => Get.toNamed(AppRoutes.orderHistory);

  Future<void> _openPackageList(
    StorePackageType type,
    String route,
  ) async {
    if (_packagesFor(type).isEmpty) await loadShop();
    if (_packagesFor(type).isEmpty) {
      Get.snackbar('Unavailable', 'No published packages are available.');
      return;
    }
    _resetQuote();
    Get.toNamed(route);
  }

  Future<void> _openSummary(
    StorePackageModel? package,
    String route,
  ) async {
    if (package == null) {
      Get.snackbar('Select a Package', 'Please select a package first.');
      return;
    }
    activePackage.value = package;
    _resetQuote(keepActivePackage: true);
    if (await _loadQuote()) Get.toNamed(route);
  }

  Future<bool> _loadQuote({String coupon = ''}) async {
    final StorePackageModel? package = activePackage.value;
    if (package == null || isLoadingQuote.value) return false;
    isLoadingQuote.value = true;
    final ApiResult<StoreQuoteResponseModel> result =
        await ApiErrorHandler.call<StoreQuoteResponseModel>(
          () => _apiService.getQuote(
            packageId: package.id,
            currency: selectedCurrency.value,
            couponCode: coupon,
          ),
        );
    isLoadingQuote.value = false;
    if (!result.isSuccess || result.data == null) return false;
    quote.value = result.data;
    balances.value = result.data!.balances;
    _syncUserSessionBalances(result.data!.balances);
    _selectDefaultPaymentMethod();
    return true;
  }

  Future<void> _completeSelectedPurchase(
    CheckoutPaymentMethod method,
  ) async {
    if (isCheckoutLoading.value) return;
    final StorePackageModel? package = activePackage.value;
    final StoreProviderOptionModel? provider = paymentOption(method);
    if (package == null || provider == null || !provider.enabled) {
      checkoutError.value = 'A valid package and payment method are required.';
      return;
    }
    if (!provider.demo) {
      const String message =
          'The supplied backend does not include the production payment SDK flow yet.';
      checkoutError.value = message;
      Get.snackbar('Payment Setup Required', message);
      return;
    }

    isCheckoutLoading.value = true;
    checkoutError.value = '';
    final ApiResult<StorePurchaseCompletionModel> result =
        await ApiErrorHandler.call<StorePurchaseCompletionModel>(() async {
          final StoreOrderModel order = await _apiService.createOrder(
            CreateStoreOrderPayloadModel(
              packageId: package.id,
              currency: selectedCurrency.value,
              paymentProvider: provider.provider,
              idempotencyKey: _uuid.v4(),
              couponCode: isCouponApplied.value ? couponCode.value : '',
            ),
          );
          final StoreCheckoutResponseModel checkout =
              await _apiService.getCheckout(order.id);
          final StoreProviderOptionModel checkoutMethod =
              checkout.paymentMethods.firstWhere(
                (StoreProviderOptionModel item) =>
                    item.provider == provider.provider,
                orElse: () => provider,
              );

          if (method == CheckoutPaymentMethod.googlePlay) {
            final String productId = checkoutMethod.demoProductId.isNotEmpty
                ? checkoutMethod.demoProductId
                : provider.demoProductId;
            if (productId.isEmpty) {
              throw StateError('Google Play demo product ID is missing.');
            }
            return _apiService.confirmGooglePlayDemo(
              orderId: order.id,
              productId: productId,
              purchaseToken: 'demo_${_uuid.v4()}',
            );
          }
          return _apiService.confirmStripeDemo(
            orderId: order.id,
            paymentIntentId: 'pi_demo_${_uuid.v4().replaceAll('-', '')}',
          );
        });

    isCheckoutLoading.value = false;
    if (!result.isSuccess || result.data == null) {
      checkoutError.value = result.error ?? 'Purchase could not be completed.';
      return;
    }
    completedPurchase.value = result.data;
    balances.value = result.data!.balances;
    _syncUserSessionBalances(result.data!.balances);
    if (Get.isRegistered<UserSessionController>()) {
      await Get.find<UserSessionController>().refreshAiBalances();
    }
    Get.offNamed(AppRoutes.purchaseCompleted);
  }


  void _syncUserSessionBalances(StoreBalancesModel value) {
    if (!Get.isRegistered<UserSessionController>()) return;
    Get.find<UserSessionController>().updateAiBalances(
      voiceSeconds: value.aiVoiceSeconds,
      textTokens: value.aiTextTokens,
    );
  }

  void _selectDefaults() {
    selectedAiPackageId.value = _preferred(aiPackages)?.id ?? '';
    selectedStreakPackageId.value = _preferred(streakPackages)?.id ?? '';
    selectedCvPackageId.value = _preferred(cvPackages)?.id ?? '';
  }

  StorePackageModel? _preferred(List<StorePackageModel> packages) {
    if (packages.isEmpty) return null;
    for (final StorePackageModel item in packages) {
      if (item.marketingBadge == 'most_popular' ||
          item.marketingBadge == 'best_value') {
        return item;
      }
    }
    return packages.first;
  }

  void _selectDefaultPaymentMethod() {
    final List<StoreProviderOptionModel> providers =
        quote.value?.supportedProviders ?? const [];
    for (final StoreProviderOptionModel provider in providers) {
      if (provider.enabled && provider.provider == 'stripe') {
        selectedPaymentMethod.value = provider.method;
        return;
      }
    }
    for (final StoreProviderOptionModel provider in providers) {
      if (provider.enabled) {
        selectedPaymentMethod.value = provider.method;
        return;
      }
    }
  }

  void _resetQuote({bool keepActivePackage = false}) {
    quote.value = null;
    couponTextController.clear();
    couponCode.value = '';
    isCouponApplied.value = false;
    checkoutError.value = '';
    if (!keepActivePackage) activePackage.value = null;
  }

  List<StorePackageModel> _packagesFor(StorePackageType type) {
    switch (type) {
      case StorePackageType.aiBundle:
        return aiPackages;
      case StorePackageType.streakFreeze:
        return streakPackages;
      case StorePackageType.cvCredit:
        return cvPackages;
    }
  }

  StorePackageModel? _findPackage(
    List<StorePackageModel> packages,
    String id,
  ) {
    for (final StorePackageModel item in packages) {
      if (item.id == id) return item;
    }
    return packages.isEmpty ? null : packages.first;
  }

  StorePackageModel _emptyPackage(StorePackageType type) => StorePackageModel(
    id: '',
    type: type,
    name: 'Package',
    description: '',
    priceEur: 0,
    billingModel: 'one_time',
    marketingBadge: 'none',
    aiVoiceMinutes: 0,
    aiVoiceSeconds: 0,
    aiTextTokens: 0,
    cvCredits: 0,
    streakFreezeCount: 0,
    streakProtectionMode: '',
    protectionDurationDays: null,
    couponEnabled: false,
    sortOrder: 0,
  );

  String _compact(int value) {
    if (value < 1000) return value.toString();
    if (value % 1000 == 0) return '${value ~/ 1000}k';
    return '${(value / 1000).toStringAsFixed(1)}k';
  }

  @override
  void onClose() {
    couponTextController.dispose();
    super.onClose();
  }
}
