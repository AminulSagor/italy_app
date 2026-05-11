import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../routes/routes.dart';
import '../../../models/auth_models.dart';
import '../models/login_models.dart';

class LoginController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<LoginFormModel> form = LoginFormModel.initial().obs;
  final Rxn<LoginPayloadModel> pendingPayload = Rxn<LoginPayloadModel>();

  late final TextEditingController identifierController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    _syncSelectedLanguageWithLocale();
    identifierController = TextEditingController();
    passwordController = TextEditingController();

    identifierController.addListener(_onFormInputChanged);
    passwordController.addListener(_onFormInputChanged);
  }

  @override
  void onReady() {
    super.onReady();
    // Re-sync in case locale changed before this route became active.
    _syncSelectedLanguageWithLocale();
  }

  void setLanguage(String value) {
    final Locale locale = _localeFromLabel(value);
    form.value = form.value.copyWith(
      selectedLanguage: _labelFromLocale(locale),
    );
    Get.updateLocale(locale);
  }

  void setLoginMode(String value) {
    form.value = form.value.copyWith(selectedLoginMode: value, identifier: '');
    identifierController.clear();
  }

  void togglePasswordVisibility() {
    form.value = form.value.copyWith(
      obscurePassword: !form.value.obscurePassword,
    );
  }

  Future<void> onLoginTap() async {
    final LoginFormModel current = form.value;
    final String normalizedIdentifier = current.identifier.trim();
    final String normalizedPassword = current.password.trim();

    if (normalizedIdentifier.isEmpty || normalizedPassword.isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_fill_both_fields'.tr);
      return;
    }

    if (current.isEmailMode && !GetUtils.isEmail(normalizedIdentifier)) {
      Get.snackbar('snack_invalid_email'.tr, 'snack_enter_valid_email'.tr);
      return;
    }

    if (!current.isEmailMode && !GetUtils.isPhoneNumber(normalizedIdentifier)) {
      Get.snackbar('snack_invalid_phone'.tr, 'snack_enter_valid_phone'.tr);
      return;
    }

    if (current.isLoading) {
      return;
    }

    final LoginPayloadModel payload = LoginPayloadModel(
      password: normalizedPassword,
      email: current.isEmailMode ? normalizedIdentifier : null,
      phone: current.isEmailMode ? null : normalizedIdentifier,
    );

    pendingPayload.value = payload;
    form.value = form.value.copyWith(isLoading: true);

    // Simulate a login process (replace with actual API call)
    try {
      await Future.delayed(const Duration(seconds: 2));
      // For demonstration, we assume the login is always successful and return a dummy token
      const String dummyToken = 'dummy_auth_token';
      await _storageService.setLoggedInData(dummyToken);
      // Navigate to the home screen or dashboard after successful login
      Get.offAllNamed(AppRoutes.wrapper);
    } finally {
      form.value = form.value.copyWith(isLoading: false);
    }
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

  String _labelFromLocale(Locale locale) {
    if (locale.languageCode == 'it') {
      return 'IT';
    }

    if (locale.languageCode == 'bn') {
      return 'বাং';
    }

    return 'EN';
  }

  void _syncSelectedLanguageWithLocale() {
    final Locale locale =
        Get.locale ?? Get.deviceLocale ?? const Locale('en', 'US');
    form.value = form.value.copyWith(
      selectedLanguage: _labelFromLocale(locale),
    );
  }

  void _onFormInputChanged() {
    form.value = form.value.copyWith(
      identifier: identifierController.text,
      password: passwordController.text,
    );
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
