import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../models/forgot_password_models.dart';
import '../services/forgot_password_service.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({ForgotPasswordService? service})
    : _service = service ?? ForgotPasswordService();

  final ForgotPasswordService _service;

  final Rx<ForgotPasswordFormModel> form =
      ForgotPasswordFormModel.initial().obs;
  final Rx<ForgotPasswordOtpUiModel> otpUi =
      ForgotPasswordOtpUiModel.initial().obs;
  final Rx<ResetPasswordFormModel> resetForm =
      ResetPasswordFormModel.initial().obs;

  final Rxn<ForgotPasswordRequestPayloadModel> pendingRequestPayload =
      Rxn<ForgotPasswordRequestPayloadModel>();
  final Rxn<ForgotPasswordVerifyOtpUiModel> pendingVerifiedOtp =
      Rxn<ForgotPasswordVerifyOtpUiModel>();

  bool get isEmailMode => form.value.isEmailMode;

  late final TextEditingController identifierController;
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    identifierController = TextEditingController();
    otpControllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );
    otpFocusNodes = List<FocusNode>.generate(4, (_) => FocusNode());
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    identifierController.addListener(_onRequestInputChanged);
    newPasswordController.addListener(_onResetInputChanged);
    confirmPasswordController.addListener(_onResetInputChanged);
  }

  void setLanguage(String value) {
    form.value = form.value.copyWith(selectedLanguage: value);
    final Locale locale = _localeFromLabel(value);
    Get.updateLocale(locale);
  }

  void setResetMode(String value) {
    form.value = form.value.copyWith(selectedResetMode: value, identifier: '');
    identifierController.clear();
  }

  Future<void> onSendResetLinkTap() async {
    final ForgotPasswordFormModel current = form.value;
    final String normalizedIdentifier = current.identifier.trim();

    if (current.isSubmitting) {
      return;
    }

    if (normalizedIdentifier.isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_enter_email_or_phone'.tr);
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

    final ForgotPasswordRequestPayloadModel payload =
        ForgotPasswordRequestPayloadModel(
          identifier: normalizedIdentifier,
          channel: current.isEmailMode ? 'email' : 'phone',
        );

    form.value = current.copyWith(isSubmitting: true);
    pendingRequestPayload.value = payload;

    try {
      final result = await _service.requestResetCode(payload: payload);
      if (!result.success || result.data == null) {
        Get.snackbar('snack_unable_continue'.tr, 'snack_try_again_moment'.tr);
        return;
      }

      pendingVerifiedOtp.value = null;
      otpUi.value = otpUi.value.copyWith(
        maskedIdentifier: result.data!.maskedIdentifier,
        requestToken: result.data!.requestToken,
        codeDigits: <String>['', '', '', ''],
        isResending: false,
        isVerifying: false,
      );
      _clearOtpInputs();
      Get.toNamed(AppRoutes.forgotPasswordOtp);
    } finally {
      form.value = form.value.copyWith(isSubmitting: false);
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

  Future<void> onResendCodeTap() async {
    final ForgotPasswordRequestPayloadModel? payload =
        pendingRequestPayload.value;
    if (otpUi.value.isResending || payload == null) {
      return;
    }

    otpUi.value = otpUi.value.copyWith(isResending: true);
    try {
      final result = await _service.requestResetCode(payload: payload);
      if (!result.success || result.data == null) {
        Get.snackbar('snack_unable_resend'.tr, 'snack_try_again'.tr);
        return;
      }

      otpUi.value = otpUi.value.copyWith(
        maskedIdentifier: result.data!.maskedIdentifier,
        requestToken: result.data!.requestToken,
      );
      _clearOtpInputs();
      Get.snackbar('snack_code_resent'.tr, 'snack_fresh_code_sent'.tr);
    } finally {
      otpUi.value = otpUi.value.copyWith(isResending: false);
    }
  }

  Future<void> onVerifyCodeTap() async {
    final ForgotPasswordOtpUiModel currentOtpUi = otpUi.value;
    if (currentOtpUi.isVerifying) {
      return;
    }

    if (!currentOtpUi.isCodeComplete) {
      Get.snackbar('snack_incomplete_code'.tr, 'snack_enter_full_4_digit'.tr);
      return;
    }

    otpUi.value = currentOtpUi.copyWith(isVerifying: true);
    try {
      final result = await _service.verifyResetCode(
        payload: ForgotPasswordVerifyOtpPayloadModel(
          requestToken: currentOtpUi.requestToken,
          code: currentOtpUi.code,
        ),
      );

      if (!result.success || result.data == null) {
        Get.snackbar(
          'snack_verification_failed'.tr,
          'snack_check_code_retry'.tr,
        );
        return;
      }

      pendingVerifiedOtp.value = result.data;
      Get.toNamed(AppRoutes.resetPassword);
    } finally {
      otpUi.value = otpUi.value.copyWith(isVerifying: false);
    }
  }

  void toggleNewPasswordVisibility() {
    resetForm.value = resetForm.value.copyWith(
      obscureNewPassword: !resetForm.value.obscureNewPassword,
    );
  }

  void toggleConfirmPasswordVisibility() {
    resetForm.value = resetForm.value.copyWith(
      obscureConfirmPassword: !resetForm.value.obscureConfirmPassword,
    );
  }

  Future<void> onResetPasswordTap() async {
    final ResetPasswordFormModel current = resetForm.value;
    final ForgotPasswordVerifyOtpUiModel? verifiedOtp =
        pendingVerifiedOtp.value;

    if (current.isSubmitting) {
      return;
    }

    if (verifiedOtp == null || verifiedOtp.resetToken.isEmpty) {
      Get.snackbar('snack_session_expired'.tr, 'snack_verify_again'.tr);
      Get.offNamedUntil(AppRoutes.forgotPassword, (route) => route.isFirst);
      return;
    }

    if (!current.hasMinLength) {
      Get.snackbar('snack_weak_password'.tr, 'snack_password_min_8'.tr);
      return;
    }

    if (!current.hasUppercaseAndNumber) {
      Get.snackbar('snack_weak_password'.tr, 'snack_need_upper_number'.tr);
      return;
    }

    if (!current.matchesConfirm) {
      Get.snackbar('snack_mismatch'.tr, 'snack_passwords_match'.tr);
      return;
    }

    resetForm.value = current.copyWith(isSubmitting: true);
    try {
      final result = await _service.resetPassword(
        payload: ForgotPasswordResetPayloadModel(
          resetToken: verifiedOtp.resetToken,
          newPassword: current.newPassword.trim(),
        ),
      );

      if (!result.success || result.data == null) {
        Get.snackbar('snack_could_not_reset'.tr, 'snack_try_again'.tr);
        return;
      }

      Get.snackbar('snack_password_reset'.tr, result.data!.successMessage);
      Get.offNamed(AppRoutes.forgotPasswordSuccess);
    } finally {
      resetForm.value = resetForm.value.copyWith(isSubmitting: false);
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

  void onBackTap() {
    Get.back();
  }

  void onBackToLoginTap() {
    Get.offNamed(AppRoutes.login);
  }

  void _onRequestInputChanged() {
    form.value = form.value.copyWith(identifier: identifierController.text);
  }

  void _onResetInputChanged() {
    resetForm.value = resetForm.value.copyWith(
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }

  void _clearOtpInputs() {
    for (final TextEditingController otpController in otpControllers) {
      otpController.clear();
    }

    otpUi.value = otpUi.value.copyWith(codeDigits: <String>['', '', '', '']);
  }

  @override
  void onClose() {
    identifierController.dispose();
    for (final TextEditingController otpController in otpControllers) {
      otpController.dispose();
    }
    for (final FocusNode focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
