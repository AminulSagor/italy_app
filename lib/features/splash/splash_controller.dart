import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  late final RxString selectedLanguage;

  static const int totalPages = 4;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage = _translationService.selectedLabel;
  }

  bool get isFirstPage => currentPage.value == 0;
  bool get isLastPage => currentPage.value == totalPages - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> onPrimaryButtonTap() async {
    if (isLastPage) {
      _goToSignup();
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void onSkipTap() {
    _goToLogin();
  }

  void onAlreadyHaveAccountTap() {
    _goToLogin();
  }

  void setLanguage(String value) {
    _translationService.setLanguageLabel(value);
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  void _goToSignup() {
    Get.offAllNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
