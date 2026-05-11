import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxString selectedLanguage = 'EN'.obs;

  static const int totalPages = 4;

  bool get isFirstPage => currentPage.value == 0;
  bool get isLastPage => currentPage.value == totalPages - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> onPrimaryButtonTap() async {
    if (isLastPage) {
      _goToLogin();
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
    selectedLanguage.value = value;
    Get.updateLocale(_localeFromLabel(value));
  }

  Locale _localeFromLabel(String label) {
    switch (label) {
      case 'IT':
        return const Locale('it', 'IT');
      case 'বাং':
        return const Locale('bn', 'BD');
      case 'EN':
      default:
        return const Locale('en', 'US');
    }
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
