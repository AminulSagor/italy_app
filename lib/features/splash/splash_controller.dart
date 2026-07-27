import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_service.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();

  final StorageService _storageService = Get.find<StorageService>();

  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  late final RxString selectedLanguage;

  static const int totalPages = 3;

  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();

    selectedLanguage = _translationService.selectedLabel;
  }

  bool get isFirstPage => currentPage.value == 0;

  bool get isLastPage => currentPage.value == totalPages - 1;

  void onPageChanged(int index) {
    if (index < 0 || index >= totalPages) {
      return;
    }

    currentPage.value = index;
  }

  Future<void> onPrimaryButtonTap() async {
    if (_isNavigating) {
      return;
    }

    if (isLastPage) {
      await _finishOnboardingAndNavigate(AppRoutes.signup);
      return;
    }

    if (!pageController.hasClients) {
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> onSkipTap() async {
    await _finishOnboardingAndNavigate(AppRoutes.login);
  }

  Future<void> onAlreadyHaveAccountTap() async {
    await _finishOnboardingAndNavigate(AppRoutes.login);
  }

  Future<void> setLanguage(String value) async {
    await _translationService.setLanguageLabel(value);
  }

  Future<void> _finishOnboardingAndNavigate(String routeName) async {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    try {
      /*
       * The onboarding/splash screen should appear only
       * on the first installation.
       */
      await _storageService.setFirstTimeUser(false);

      Get.offAllNamed(routeName);
    } catch (_) {
      /*
       * Allow the user to try again if saving the
       * first-time state unexpectedly fails.
       */
      _isNavigating = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
