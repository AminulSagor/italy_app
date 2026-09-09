import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/user_session_controller.dart';
import '../../../core/services/api_error_handler.dart';
import '../../cv_generation/controllers/cv_home_controller.dart';
import '../../../routes/routes.dart';
import 'controllers/google_play_purchase_controller.dart';
import 'models/google_play_billing_models.dart';
import 'models/shop_models.dart';
import 'models/shop_order_models.dart';
import 'services/google_play_billing_service.dart';
import 'services/shop_api_service.dart';

class OrderHistoryFilterTitles {
  static String get allOrders => 'all_orders'.tr;
  static String get courses => 'courses'.tr;
  static String get aiRefills => 'ai_refills'.tr;
  static String get streakFreezes => 'streak_freezes'.tr;
  static String get cvCredits => 'cv_credits'.tr;
}

class ShopController extends GetxController {
  ShopController({
    required ShopApiService apiService,
    GooglePlayBillingService? billingService,
    GooglePlayPurchaseController? purchaseController,
  }) : _apiService = apiService,
       _billingService = billingService ?? Get.find<GooglePlayBillingService>(),
       _purchaseController =
           purchaseController ?? Get.find<GooglePlayPurchaseController>();
  final ShopApiService _apiService;
  final GooglePlayBillingService _billingService;
  final GooglePlayPurchaseController _purchaseController;
  StreamSubscription<StorePurchaseCompletionModel>? _completionSubscription;
  String _lastHandledOrderId = '';
  final RxBool isLoadingShop = false.obs;
  final RxBool isLoadingQuote = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxBool isRestoringSubscription = false.obs;
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
  String _regularStorePriceText = '';
  String _regularStoreProductId = '';
  CheckoutPaymentMethod get _platformPaymentMethod => Platform.isIOS
      ? CheckoutPaymentMethod.appStore
      : CheckoutPaymentMethod.googlePlay;
  final Rx<CheckoutPaymentMethod> selectedPaymentMethod =
      (Platform.isIOS
              ? CheckoutPaymentMethod.appStore
              : CheckoutPaymentMethod.googlePlay)
          .obs;
  final Rxn<StorePurchaseCompletionModel> completedPurchase =
      Rxn<StorePurchaseCompletionModel>();
  @override
  void onInit() {
    super.onInit();
    _completionSubscription = _purchaseController.completionStream.listen(
      (StorePurchaseCompletionModel completion) =>
          unawaited(_applyPurchaseCompletion(completion)),
    );
    unawaited(_initializeShop());
  }

  Future<void> _initializeShop() async {
    await loadShop();

    final StorePurchaseCompletionModel? recovered = _purchaseController
        .takeLastCompletion();

    if (recovered != null) {
      await _applyPurchaseCompletion(recovered);
    }
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

  bool get hasActiveMonthlyStreakProtection =>
      balances.value?.unlimitedProtectionActive ?? false;

  DateTime? get monthlyStreakProtectionExpiresAt =>
      balances.value?.unlimitedProtectionExpiresAt;

  StoreActiveSubscriptionModel? get activeMonthlyStreakSubscription =>
      balances.value?.activeStreakSubscription;

  String get activeMonthlyProductId =>
      activeMonthlyStreakSubscription?.productId ?? '';

  bool isActiveMonthlyStreakPackage(StorePackageModel package) {
    final StoreActiveSubscriptionModel? subscription =
        activeMonthlyStreakSubscription;

    return package.isUnlimitedStreak &&
        subscription != null &&
        subscription.packageId == package.id;
  }

  bool isMonthlyPurchaseBlocked(StorePackageModel package) {
    return package.isUnlimitedStreak &&
        hasActiveMonthlyStreakProtection &&
        !isActiveMonthlyStreakPackage(package);
  }

  int get cvCreditBalance => balances.value?.cvCredits ?? 0;

  /// Total free CV creations configured by admin.
  int get freeCvGenerationsLimit => balances.value?.freeCvGenerationsLimit ?? 3;

  /// Free CV creations the user still has.
  int get freeCvGenerationsRemaining =>
      balances.value?.freeCvGenerationsRemaining ?? 0;

  /// Whether at least one free CV creation remains.
  bool get hasCvFreeAllowance => freeCvGenerationsRemaining > 0;

  /// Whether all free CV creations have been used.
  bool get cvFreeLimitEnded => balances.value?.freeCvLimitExhausted ?? true;

  /// Free CV creations plus purchased credits.
  int get totalCvGenerationsAvailable =>
      balances.value?.totalCvGenerationsAvailable ?? 0;

  /// Whether the user can create another new CV.
  bool get canCreateCv => balances.value?.canCreateCv ?? false;

  /// Possible values: free, credit, none.
  String get nextCvGenerationUses =>
      balances.value?.nextCvGenerationUses ?? 'none';

  /// Whether CV editing and regeneration are free.
  bool get allowCvEditingWithoutCredit =>
      balances.value?.allowCvEditingWithoutCredit ?? false;

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
    try {
      final ApiResult<List<Object>> result =
          await ApiErrorHandler.call<List<Object>>(() async {
            return Future.wait<Object>(<Future<Object>>[
              _apiService.getShop(),
              _apiService.getPackages(packageType: StorePackageType.aiBundle),
              _apiService.getPackages(
                packageType: StorePackageType.streakFreeze,
              ),
              _apiService.getPackages(packageType: StorePackageType.cvCredit),
            ]);
          }, showError: false);
      if (!result.isSuccess || result.data == null) {
        shopError.value = result.error ?? 'could_not_load_the_shop'.tr;

        return;
      }
      final List<Object> data = result.data!;
      final StoreShopModel shopData = data[0] as StoreShopModel;
      shop.value = shopData;
      balances.value = shopData.balances;
      _syncUserSessionBalances(shopData.balances);
      aiPackages.assignAll((data[1] as StorePackageListResponseModel).items);
      streakPackages.assignAll(
        (data[2] as StorePackageListResponseModel).items,
      );
      cvPackages.assignAll((data[3] as StorePackageListResponseModel).items);
      _selectDefaults();
      await _billingService.prepareProducts(
        <StorePackageModel>[...aiPackages, ...streakPackages, ...cvPackages]
            .map((StorePackageModel item) => item.storeProduct)
            .whereType<StoreProviderProductModel>(),
      );
    } finally {
      isLoadingShop.value = false;
    }
  }

  Future<void> refreshBalances() async {
    final ApiResult<StoreBalancesModel> result =
        await ApiErrorHandler.call<StoreBalancesModel>(
          _apiService.getBalances,
          showError: false,
        );
    if (result.isSuccess && result.data != null) {
      applyBalances(result.data!);

      final StorePackageModel? selected = selectedStreakPackage;

      if (selected != null &&
          selected.isUnlimitedStreak &&
          hasActiveMonthlyStreakProtection) {
        _selectDefaultStreakPackage();
      }
    }
  }

  Future<void> restoreAppStoreSubscription(StorePackageModel package) async {
    if (!Platform.isIOS || isRestoringSubscription.value) return;
    isRestoringSubscription.value = true;
    try {
      final GooglePlayPurchaseOutcome outcome = await _purchaseController
          .restoreAppStoreSubscription(package);
      if (outcome.status == GooglePlayPurchaseOutcomeStatus.completed) {
        if (outcome.completion != null) {
          await _applyPurchaseCompletion(outcome.completion!);
        }
        await refreshBalances();
      }
      Get.snackbar(
        outcome.status == GooglePlayPurchaseOutcomeStatus.completed
            ? 'Restored'
            : 'Restore Purchases',
        outcome.message,
      );
    } finally {
      isRestoringSubscription.value = false;
    }
  }

  Future<void> restoreMonthlyStreakSubscription(StorePackageModel package) =>
      restoreAppStoreSubscription(package);

  void applyBalances(StoreBalancesModel value) {
    balances.value = value;
    _syncUserSessionBalances(value);
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
    final String price =
        _billingService.localizedPrice(package.storeProduct) ??
        '€${package.priceEur.toStringAsFixed(2)}';

    if (!package.isMonthly) {
      return price;
    }

    return 'price_per_month'.trParams(<String, String>{'price': price});
  }

  bool get isStorePaymentSelected =>
      selectedPaymentMethod.value == _platformPaymentMethod;
  bool get canChangeCurrency => !isStorePaymentSelected;
  bool get canUseCoupon => activePackage.value?.couponEnabled ?? false;
  bool get hasDiscount => isCouponApplied.value && discountAmount > 0;
  Future<void> selectCurrency(RefillCurrency currency) async {
    if (!canChangeCurrency || selectedCurrency.value == currency) return;
    selectedCurrency.value = currency;
    await _loadQuote(coupon: isCouponApplied.value ? couponCode.value : '');
  }

  void onCouponChanged(String value) {
    couponCode.value = value.trim();
    checkoutError.value = '';
    if (isCouponApplied.value) isCouponApplied.value = false;
  }

  Future<void> applyCoupon() async {
    if (!canUseCoupon) {
      Get.snackbar(
        'coupon_unavailable'.tr,
        'coupon_not_available_for_package'.tr,
      );

      return;
    }

    final String code = couponTextController.text.trim();

    if (code.isEmpty) {
      Get.snackbar('coupon_required'.tr, 'please_enter_a_coupon_code'.tr);

      return;
    }

    final bool loaded = await _loadQuote(coupon: code);

    if (loaded) {
      checkoutError.value = '';
      couponCode.value = code;
      couponTextController.text = code;
      isCouponApplied.value = true;

      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      checkoutError.value = '';

      Get.snackbar(
        'invalid_coupon'.tr,
        'coupon_invalid_for_item'.tr,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> clearCoupon() async {
    couponTextController.clear();
    couponCode.value = '';
    isCouponApplied.value = false;
    checkoutError.value = '';
    if (activePackage.value != null) await _loadQuote();
  }

  String formatPrice(double value) {
    final bool eur = selectedCurrency.value == RefillCurrency.eur;
    return eur
        ? '€${value.toStringAsFixed(2)}'
        : '৳${value.toStringAsFixed(0)}';
  }

  StoreQuotePricingModel? get pricing => quote.value?.pricing;
  double get currentBasePrice =>
      pricing?.originalAmount ?? activePackage.value?.priceEur ?? 0;
  double get discountAmount => pricing?.discountAmount ?? 0;
  double get payableAmount => pricing?.payableAmount ?? currentBasePrice;
  String get originalPriceText => formatPrice(currentBasePrice);
  String get payablePriceText =>
      _checkoutStorePrice ?? formatPrice(payableAmount);
  String get savedAmountText =>
      'YOU SAVED ${_storeSavedAmountText ?? formatPrice(discountAmount)}';
  String get orderSummaryPrice => payablePriceText;
  String get checkoutOriginalPriceText =>
      hasDiscount && _regularStorePriceText.isNotEmpty
      ? _regularStorePriceText
      : originalPriceText;
  String get checkoutPayablePriceText => payablePriceText;
  String get checkoutSavedAmountText => savedAmountText;
  String get streakFreezeOriginalPriceText => checkoutOriginalPriceText;
  String get streakFreezePayablePriceText => payablePriceText;
  String get streakFreezeSavedAmountText => savedAmountText;
  String get cvCreditOriginalPriceText => checkoutOriginalPriceText;
  String get cvCreditPayablePriceText => payablePriceText;
  String get cvCreditSavedAmountText => savedAmountText;
  String? get _checkoutStorePrice =>
      _billingService.localizedPurchasePrice(quote.value?.storeProduct);
  String? get _storeSavedAmountText {
    if (!hasDiscount || _regularStorePriceText.isEmpty) return null;
    final String? discounted = _checkoutStorePrice;
    if (discounted == null || discounted.isEmpty) return null;
    return _formatLocalizedSaving(
      regularPriceText: _regularStorePriceText,
      discountedPriceText: discounted,
    );
  }

  StorePackageModel? get checkoutPackage =>
      activePackage.value ?? selectedAiPackage;
  String get selectedPlanTitle => checkoutPackage?.name ?? 'package'.tr;
  String get selectedPlanSubtitle => checkoutPackage?.entitlementSummary ?? '';
  String get checkoutBillingLabel =>
      checkoutPackage?.isMonthly == true ? '/ month' : '/ one-time';
  bool get isAppStoreSubscriptionCheckout =>
      Platform.isIOS &&
      checkoutPackage?.isMonthly == true &&
      quote.value?.storeProduct.isSubscription == true;
  String get appStoreSubscriptionTitle =>
      _billingService.localizedTitle(quote.value?.storeProduct) ??
      selectedPlanTitle;
  String get appStoreSubscriptionPrice => _checkoutStorePrice?.trim() ?? '';
  bool get hasAppStoreSubscriptionPrice =>
      !isAppStoreSubscriptionCheckout || appStoreSubscriptionPrice.isNotEmpty;
  bool get canConfirmCheckout =>
      !isCheckoutLoading.value && hasAppStoreSubscriptionPrice;
  String get appStoreSubscriptionBillingDuration {
    final StoreBillingPeriod? period = _billingService.subscriptionPeriod(
      quote.value?.storeProduct,
    );
    final int count = period?.count ?? 1;
    final String unit = period?.unit ?? 'month';
    final String suffix = count == 1 ? 'one' : 'many';
    return 'subscription_period_${unit}_$suffix'.trParams(<String, String>{
      'count': '$count',
    });
  }

  Future<void> restoreCurrentAppStoreSubscription() async {
    final StorePackageModel? package = checkoutPackage;
    if (package == null || !package.isMonthly) return;
    await restoreAppStoreSubscription(package);
  }

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
    await _openPackageList(
      StorePackageType.streakFreeze,
      AppRoutes.streakFreeze,
    );
  }

  Future<void> onCvCreditTap() async {
    await _openPackageList(StorePackageType.cvCredit, AppRoutes.cvCreditStore);
  }

  Future<void> confirmPurchase() async {
    await _openSummary(selectedAiPackage, AppRoutes.orderSummary);
  }

  Future<void> goToStreakFreezeOrderSummary() async {
    final StorePackageModel? package = selectedStreakPackage;

    if (package == null) {
      Get.snackbar('select_a_package'.tr, 'please_select_a_package_first'.tr);

      return;
    }

    if (package.isUnlimitedStreak && hasActiveMonthlyStreakProtection) {
      Get.snackbar(
        'monthly_protection_active'.tr,
        'active_monthly_plan_already_exists'.tr,
      );

      return;
    }

    await _openSummary(package, AppRoutes.streakFreezeOrderSummary);
  }

  void showMonthlyPlanAlreadyActive() {
    Get.snackbar(
      'monthly_protection_active'.tr,
      'active_monthly_plan_already_exists'.tr,
    );
  }

  Future<void> goToCvCreditOrderSummary() async {
    await _openSummary(selectedCvPackage, AppRoutes.cvCreditOrderSummary);
  }

  Future<void> buySelectedPlan() async {
    if (quote.value == null && !await _loadQuote()) return;
    selectedPaymentMethod.value = _platformPaymentMethod;
    Get.toNamed(AppRoutes.checkout);
  }

  List<CheckoutPaymentMethod> get availablePaymentMethods =>
      <CheckoutPaymentMethod>[_platformPaymentMethod];
  StoreProviderOptionModel? paymentOption(CheckoutPaymentMethod method) {
    for (final StoreProviderOptionModel option
        in quote.value?.supportedProviders ?? const []) {
      if (option.method != method) continue;
      final StoreProviderProductModel product = quote.value!.storeProduct;
      final bool storeReady =
          _billingService.isAvailable.value &&
          _billingService.hasProduct(product);
      return StoreProviderOptionModel(
        provider: option.provider,
        enabled: option.enabled && storeReady,
        productId: option.productId,
        productType: option.productType,
        basePlanId: option.basePlanId,
        offerId: option.offerId,
        offerType: option.offerType,
        developmentVerification: option.developmentVerification,
        promotionalOffer: option.promotionalOffer,
        label: option.label,
        unavailableReason: storeReady
            ? option.unavailableReason
            : _billingService.lastError.value.isNotEmpty
            ? _billingService.lastError.value
            : 'this_payment_method_is_unavailable'.tr,
      );
    }
    return null;
  }

  bool isPaymentMethodSelected(CheckoutPaymentMethod method) =>
      selectedPaymentMethod.value == method;
  void selectPaymentMethod(CheckoutPaymentMethod method) {
    final StoreProviderOptionModel? option = paymentOption(method);
    if (option == null || !option.enabled) {
      Get.snackbar(
        'payment_unavailable'.tr,
        option?.unavailableReason.isNotEmpty == true
            ? option!.unavailableReason
            : 'this_payment_method_is_unavailable'.tr,
      );
      return;
    }
    selectedPaymentMethod.value = method;
    checkoutError.value = '';
  }

  String paymentMethodTitle(CheckoutPaymentMethod method) =>
      method == CheckoutPaymentMethod.appStore ? 'App Store' : 'google_play'.tr;
  Future<void> confirmCheckout() async {
    if (!hasAppStoreSubscriptionPrice) {
      checkoutError.value = 'app_store_price_unavailable'.tr;
      return;
    }
    await _completeSelectedPurchase();
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
    if (value == null) return 'your_purchase_is_now_active'.tr;
    switch (value.packageType) {
      case StorePackageType.aiBundle:
        return "Your '${value.packageName}' bundle is active. Voice minutes and AI tokens were added to your balance.";
      case StorePackageType.streakFreeze:
        return "Your '${value.packageName}' protection is active and ready to protect your streak.";
      case StorePackageType.cvCredit:
        return "Your '${value.packageName}' credits are active and ready for CV generation.";
    }
  }

  String get completedOrderId => completedPurchase.value?.orderNumber ?? '';
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
        return 'gen_voice_interaction'.tr;
      case StorePackageType.streakFreeze:
        return 'protection_added'.tr;
      case StorePackageType.cvCredit:
        return 'cv_credits_added'.tr;
      case null:
        return 'credits_added'.tr;
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
    return completedPurchase.value?.packageType == StorePackageType.aiBundle
        ? 'gen_ai_smart_tokens'.tr
        : 'current_balance'.tr;
  }

  void closePurchaseCompleted() {
    _resetCompletedPurchase();
    Get.back();
  }

  void startLearningNow() {
    _resetCompletedPurchase();
    Get.offAllNamed(AppRoutes.wrapper);
  }

  void prepareForShopExit() {
    _resetCompletedPurchase();
    _purchaseController.resetTransientState(cancelActivePurchase: true);
  }

  void onOrderHistoryTap() => Get.toNamed(AppRoutes.orderHistory);
  Future<void> _openPackageList(StorePackageType type, String route) async {
    if (_packagesFor(type).isEmpty) await loadShop();
    if (_packagesFor(type).isEmpty) {
      Get.snackbar('unavailable'.tr, 'no_published_packages_are_available'.tr);
      return;
    }
    _resetQuote();
    Get.toNamed(route);
  }

  Future<void> _openSummary(StorePackageModel? package, String route) async {
    if (package == null) {
      Get.snackbar('select_a_package'.tr, 'please_select_a_package_first'.tr);
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
    try {
      final ApiResult<StoreQuoteResponseModel> result =
          await ApiErrorHandler.call<StoreQuoteResponseModel>(
            () => _apiService.getQuote(
              packageId: package.id,
              currency: selectedCurrency.value,
              couponCode: coupon,
            ),
            showError: coupon.trim().isEmpty,
          );
      if (!result.isSuccess || result.data == null) {
        if (coupon.trim().isNotEmpty) {
          checkoutError.value = '';
        }

        return false;
      }
      checkoutError.value = '';
      final StoreQuoteResponseModel loadedQuote = result.data!;
      final List<StoreProviderProductModel> productsToPrepare =
          <StoreProviderProductModel>[
            if (package.storeProduct != null) package.storeProduct!,
            loadedQuote.storeProduct,
          ];
      await _billingService.prepareProducts(productsToPrepare);
      _syncRegularStorePrice(package, coupon: coupon);
      quote.value = loadedQuote;
      balances.value = loadedQuote.balances;
      _syncUserSessionBalances(loadedQuote.balances);
      selectedPaymentMethod.value = _platformPaymentMethod;
      _syncCurrencyFromGooglePlay(loadedQuote.storeProduct);
      return true;
    } finally {
      isLoadingQuote.value = false;
    }
  }

  Future<void> _completeSelectedPurchase() async {
    if (isCheckoutLoading.value) return;
    final StorePackageModel? package = activePackage.value;
    final StoreQuoteResponseModel? currentQuote = quote.value;
    if (package == null || currentQuote == null) {
      checkoutError.value = 'please_select_a_package_first'.tr;
      return;
    }
    isCheckoutLoading.value = true;
    checkoutError.value = '';
    try {
      final GooglePlayPurchaseOutcome outcome = await _purchaseController
          .startPurchase(
            package: package,
            storeProduct: currentQuote.storeProduct,
            currency: selectedCurrency.value,
            couponCode: isCouponApplied.value ? couponCode.value : '',
          );
      switch (outcome.status) {
        case GooglePlayPurchaseOutcomeStatus.completed:
          if (outcome.completion != null) {
            await _applyPurchaseCompletion(outcome.completion!);
          }
          return;
        case GooglePlayPurchaseOutcomeStatus.pending:
          Get.snackbar('processing'.tr, outcome.message);
          return;
        case GooglePlayPurchaseOutcomeStatus.cancelled:
          Get.snackbar('request_cancelled'.tr, outcome.message);
          return;
        case GooglePlayPurchaseOutcomeStatus.failed:
          checkoutError.value = outcome.message;
          return;
      }
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  Future<void> _applyPurchaseCompletion(
    StorePurchaseCompletionModel completion,
  ) async {
    if (_lastHandledOrderId == completion.orderId) return;
    _lastHandledOrderId = completion.orderId;
    completedPurchase.value = completion;
    _purchaseController.takeLastCompletion();
    balances.value = completion.balances;
    _syncUserSessionBalances(completion.balances);
    if (Get.isRegistered<UserSessionController>()) {
      await Get.find<UserSessionController>().refreshAiBalances();
    }
    if (completion.packageType == StorePackageType.cvCredit &&
        Get.isRegistered<CvHomeController>() &&
        !Get.isPrepared<CvHomeController>()) {
      await Get.find<CvHomeController>().loadHomeBootstrap(
        showBlockingLoading: false,
      );
    }
    if (Get.currentRoute != AppRoutes.purchaseCompleted) {
      Get.offNamed(AppRoutes.purchaseCompleted);
    }
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

    _selectDefaultStreakPackage();

    selectedCvPackageId.value = _preferred(cvPackages)?.id ?? '';
  }

  void _selectDefaultStreakPackage() {
    final List<StorePackageModel> purchasablePackages = streakPackages
        .where(
          (StorePackageModel package) =>
              !(package.isUnlimitedStreak && hasActiveMonthlyStreakProtection),
        )
        .toList(growable: false);

    selectedStreakPackageId.value = _preferred(purchasablePackages)?.id ?? '';
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

  void _resetQuote({bool keepActivePackage = false}) {
    quote.value = null;
    _resetCouponState();
    checkoutError.value = '';
    if (!keepActivePackage) activePackage.value = null;
  }

  void _resetCouponState() {
    couponTextController.clear();
    couponCode.value = '';
    isCouponApplied.value = false;
    _regularStorePriceText = '';
    _regularStoreProductId = '';
  }

  void _syncRegularStorePrice(
    StorePackageModel package, {
    required String coupon,
  }) {
    final StoreProviderProductModel? regularProduct = package.storeProduct;
    if (regularProduct == null) return;

    final String localizedRegular =
        _billingService.localizedPrice(regularProduct) ?? '';
    if (localizedRegular.isEmpty) return;

    if (coupon.trim().isEmpty ||
        _regularStorePriceText.isEmpty ||
        _regularStoreProductId != regularProduct.productId) {
      _regularStorePriceText = localizedRegular;
      _regularStoreProductId = regularProduct.productId;
    }
  }

  String? _formatLocalizedSaving({
    required String regularPriceText,
    required String discountedPriceText,
  }) {
    final double? regular = _parseLocalizedAmount(regularPriceText);
    final double? discounted = _parseLocalizedAmount(discountedPriceText);
    if (regular == null || discounted == null || regular <= discounted) {
      return null;
    }

    final double saving = regular - discounted;
    return '${_localizedPricePrefix(regularPriceText)}${saving.toStringAsFixed(2)}';
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

  void _syncCurrencyFromGooglePlay(StoreProviderProductModel product) {
    final String currency =
        (_billingService.localizedCurrencyCode(product) ?? '').toUpperCase();
    if (currency == RefillCurrency.bdt.apiValue) {
      selectedCurrency.value = RefillCurrency.bdt;
    } else if (currency == RefillCurrency.eur.apiValue) {
      selectedCurrency.value = RefillCurrency.eur;
    }
  }

  void _resetCompletedPurchase() {
    completedPurchase.value = null;
    _lastHandledOrderId = '';
    _purchaseController.resetTransientState();
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

  StorePackageModel? _findPackage(List<StorePackageModel> packages, String id) {
    if (id.isEmpty) {
      return null;
    }

    for (final StorePackageModel item in packages) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
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
    prepareForShopExit();
    unawaited(_completionSubscription?.cancel());
    couponTextController.dispose();
    super.onClose();
  }
}
