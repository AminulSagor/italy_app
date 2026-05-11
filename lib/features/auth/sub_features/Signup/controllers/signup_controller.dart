import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../../models/auth_models.dart';
import '../models/signup_models.dart';

class SignupController extends GetxController {
  final Rx<SignupFormModel> form = SignupFormModel.initial().obs;
  final Rx<SignupOtpUiModel> otpUi = SignupOtpUiModel.initial().obs;
  final Rx<SignupAccountCreatedUiModel> accountCreatedUi =
      SignupAccountCreatedUiModel.initial().obs;

  final Rxn<SignupPayloadModel> pendingPayload = Rxn<SignupPayloadModel>();
  final Rxn<OtpVerificationPayloadModel> pendingOtpVerificationPayload =
      Rxn<OtpVerificationPayloadModel>();

  late final TextEditingController fullNameController;
  late final TextEditingController identifierController;
  late final TextEditingController passwordController;
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  @override
  void onInit() {
    super.onInit();
    fullNameController = TextEditingController();
    identifierController = TextEditingController();
    passwordController = TextEditingController();
    otpControllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );
    otpFocusNodes = List<FocusNode>.generate(4, (_) => FocusNode());

    fullNameController.addListener(_onFormInputChanged);
    identifierController.addListener(_onFormInputChanged);
    passwordController.addListener(_onFormInputChanged);
  }

  void setLanguage(String value) {
    form.value = form.value.copyWith(selectedLanguage: value);
    final Locale locale = _localeFromLabel(value);
    Get.updateLocale(locale);
  }

  void setSignupMode(String value) {
    form.value = form.value.copyWith(selectedSignupMode: value, identifier: '');
    identifierController.clear();
  }

  void togglePasswordVisibility() {
    form.value = form.value.copyWith(
      obscurePassword: !form.value.obscurePassword,
    );
  }

  void toggleTermsAgreement() {
    form.value = form.value.copyWith(agreedToTerms: !form.value.agreedToTerms);
  }

  Future<void> onCreateAccountTap() async {
    final SignupFormModel current = form.value;

    if (current.isLoading) {
      return;
    }

    if (current.fullName.trim().isEmpty ||
        current.identifier.trim().isEmpty ||
        current.password.trim().isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_fill_required'.tr);
      return;
    }

    if (current.isEmailMode && !GetUtils.isEmail(current.identifier.trim())) {
      Get.snackbar('snack_invalid_email'.tr, 'snack_enter_valid_email'.tr);
      return;
    }

    if (!current.isEmailMode &&
        !GetUtils.isPhoneNumber(current.identifier.trim())) {
      Get.snackbar('snack_invalid_phone'.tr, 'snack_enter_valid_phone'.tr);
      return;
    }

    if (current.password.trim().length < 8) {
      Get.snackbar('snack_weak_password'.tr, 'snack_password_min_8'.tr);
      return;
    }

    if (!current.agreedToTerms) {
      Get.snackbar('snack_terms_required'.tr, 'snack_accept_terms'.tr);
      return;
    }

    final String normalizedFullName = current.fullName.trim();
    final String normalizedIdentifier = current.identifier.trim();
    final String normalizedPassword = current.password.trim();

    final SignupPayloadModel payload = SignupPayloadModel(
      fullName: normalizedFullName,
      password: normalizedPassword,
      language: current.selectedLanguage,
      email: current.isEmailMode ? normalizedIdentifier : null,
      phone: current.isEmailMode ? null : normalizedIdentifier,
    );

    pendingPayload.value = payload;
    accountCreatedUi.value = accountCreatedUi.value.copyWith(
      fullName: normalizedFullName,
      identifier: normalizedIdentifier,
    );
    otpUi.value = otpUi.value.copyWith(
      maskedIdentifier: _maskedIdentifier(
        identifier: normalizedIdentifier,
        isEmailMode: current.isEmailMode,
      ),
      codeDigits: <String>['', '', '', ''],
      isResending: false,
      isVerifying: false,
    );

    _clearOtpInputs();
    form.value = form.value.copyWith(isLoading: true);

    try {
      // Service integration will consume this payload in the next step.
      debugPrint('Signup payload ready: ${payload.toJson()}');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      Get.toNamed(AppRoutes.signupOtp);
    } finally {
      form.value = form.value.copyWith(isLoading: false);
    }
  }

  void onOtpDigitChanged({required int index, required String value}) {
    if (index < 0 || index >= otpControllers.length) {
      return;
    }

    final String digit = value.isEmpty ? '' : value[value.length - 1];
    otpControllers[index].text = digit;

    final List<String> updatedDigits = List<String>.from(
      otpUi.value.codeDigits,
    );
    updatedDigits[index] = digit;
    otpUi.value = otpUi.value.copyWith(codeDigits: updatedDigits);

    if (digit.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    }
  }

  Future<void> onResendOtpTap() async {
    if (otpUi.value.isResending) {
      return;
    }

    otpUi.value = otpUi.value.copyWith(isResending: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _clearOtpInputs();
      Get.snackbar('snack_code_resent'.tr, 'snack_fresh_code_sent'.tr);
    } finally {
      otpUi.value = otpUi.value.copyWith(isResending: false);
    }
  }

  Future<void> onOtpContinueTap() async {
    final SignupOtpUiModel currentOtpUi = otpUi.value;
    if (currentOtpUi.isVerifying) {
      return;
    }

    if (!currentOtpUi.isCodeComplete) {
      Get.snackbar(
        'snack_incomplete_code'.tr,
        'snack_enter_4_digit_verification'.tr,
      );
      return;
    }

    final SignupPayloadModel? payload = pendingPayload.value;
    final String identifier = payload?.email ?? payload?.phone ?? '';
    if (identifier.isEmpty) {
      Get.snackbar('snack_missing_payload'.tr, 'snack_payload_not_ready'.tr);
      return;
    }

    pendingOtpVerificationPayload.value = OtpVerificationPayloadModel(
      code: currentOtpUi.code,
      identifier: identifier,
    );

    otpUi.value = otpUi.value.copyWith(isVerifying: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      Get.toNamed(AppRoutes.accountCreated);
    } finally {
      otpUi.value = otpUi.value.copyWith(isVerifying: false);
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

  Future<void> onStartLearningTap() async {
    if (accountCreatedUi.value.isStarting) {
      return;
    }

    accountCreatedUi.value = accountCreatedUi.value.copyWith(isStarting: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      Get.offAllNamed(AppRoutes.home);
    } finally {
      accountCreatedUi.value = accountCreatedUi.value.copyWith(
        isStarting: false,
      );
    }
  }

  void onLoginTap() {
    Get.offNamed(AppRoutes.login);
  }

  void onBackFromOtp() {
    Get.back();
  }

  void _onFormInputChanged() {
    form.value = form.value.copyWith(
      fullName: fullNameController.text,
      identifier: identifierController.text,
      password: passwordController.text,
    );
  }

  void _clearOtpInputs() {
    for (final TextEditingController otpController in otpControllers) {
      otpController.clear();
    }
    otpUi.value = otpUi.value.copyWith(codeDigits: <String>['', '', '', '']);
  }

  String _maskedIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    if (isEmailMode) {
      final List<String> emailParts = identifier.split('@');
      if (emailParts.length != 2) {
        return identifier;
      }
      final String name = emailParts.first;
      final String domain = emailParts.last;
      if (name.length <= 2) {
        return '$name@$domain';
      }
      final String visiblePrefix = name.substring(0, 2);
      return '$visiblePrefix***@$domain';
    }

    final String digitsOnly = identifier.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 4) {
      return identifier;
    }

    final String prefix = digitsOnly.substring(0, 2);
    final String suffix = digitsOnly.substring(digitsOnly.length - 2);
    return '+$prefix* *** *$suffix';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    for (final TextEditingController otpController in otpControllers) {
      otpController.dispose();
    }
    for (final FocusNode focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
