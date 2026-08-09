import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/localization/translation_service.dart';
import '../../../../../core/services/api_client.dart';
import '../../../../../core/utils/otp_resend_cooldown.dart';
import '../../../../../routes/routes.dart';
import '../models/forgot_password_models.dart';
import '../services/forgot_password_service.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({ForgotPasswordService? service})
    : _service =
          service ?? ForgotPasswordService(apiClient: Get.find<ApiClient>());

  final ForgotPasswordService _service;

  final TranslationService _translationService = Get.find<TranslationService>();

  final Rx<ForgotPasswordFormModel> form =
      ForgotPasswordFormModel.initial().obs;

  final Rx<ForgotPasswordOtpUiModel> otpUi =
      ForgotPasswordOtpUiModel.initial().obs;

  final Rx<ResetPasswordFormModel> resetForm =
      ResetPasswordFormModel.initial().obs;

  /*
   * Stores the original forgot-password request so the
   * same email or phone number can be used when resending.
   */
  final Rxn<ForgotPasswordRequestPayloadModel> pendingRequestPayload =
      Rxn<ForgotPasswordRequestPayloadModel>();

  /*
   * Stores only the short-lived reset token returned
   * after the backend successfully verifies the OTP.
   *
   * The actual OTP is not carried to the reset screen.
   */
  final Rxn<ForgotPasswordVerifyOtpUiModel> pendingVerifiedOtp =
      Rxn<ForgotPasswordVerifyOtpUiModel>();

  final OtpResendCooldown resendCooldown = OtpResendCooldown();

  bool get isEmailMode => form.value.isEmailMode;

  late final TextEditingController identifierController;

  late final List<TextEditingController> otpControllers;

  late final List<FocusNode> otpFocusNodes;

  late final TextEditingController newPasswordController;

  late final TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();

    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );

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

  Future<void> setLanguage(String value) async {
    final Future<void> saveFuture = _translationService.setLanguageLabel(value);

    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );

    await saveFuture;
  }

  void setResetMode(String value) {
    if (form.value.isSubmitting) {
      return;
    }

    form.value = form.value.copyWith(selectedResetMode: value, identifier: '');

    identifierController.clear();

    pendingRequestPayload.value = null;
    pendingVerifiedOtp.value = null;

    _clearOtpInputs();
    _clearResetInputs();
  }

  Future<void> onSendResetLinkTap() async {
    final ForgotPasswordFormModel current = form.value;

    if (current.isSubmitting) {
      return;
    }

    final String normalizedIdentifier = _normalizeIdentifier(
      identifier: current.identifier,
      isEmailMode: current.isEmailMode,
    );

    if (normalizedIdentifier.isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_enter_email_or_phone'.tr);
      return;
    }

    if (current.isEmailMode && !GetUtils.isEmail(normalizedIdentifier)) {
      Get.snackbar('snack_invalid_email'.tr, 'snack_enter_valid_email'.tr);
      return;
    }

    if (!current.isEmailMode && !_isSupportedPhone(normalizedIdentifier)) {
      Get.snackbar('snack_invalid_phone'.tr, 'snack_enter_valid_phone'.tr);
      return;
    }

    final ForgotPasswordRequestPayloadModel payload =
        ForgotPasswordRequestPayloadModel(
          identifier: normalizedIdentifier,
          channel: current.isEmailMode ? 'email' : 'phone',
        );

    form.value = current.copyWith(isSubmitting: true);

    try {
      final result = await _service.requestResetCode(payload: payload);

      if (!result.success || result.data == null) {
        Get.snackbar('snack_unable_continue'.tr, 'snack_try_again_moment'.tr);
        return;
      }

      final ForgotPasswordRequestUiModel data = result.data!;

      /*
       * Do not keep a reset token from an older attempt.
       */
      pendingVerifiedOtp.value = null;
      pendingRequestPayload.value = payload;

      otpUi.value = otpUi.value.copyWith(
        maskedIdentifier: data.maskedIdentifier,
        identifier: data.identifier,
        codeDigits: <String>['', '', '', ''],
        isResending: false,
        isVerifying: false,
      );

      _clearOtpInputs();
      _clearResetInputs();

      resendCooldown.start();

      final String? devOtp = data.devOtp;

      if (devOtp != null && devOtp.trim().isNotEmpty) {
        Get.snackbar('otp'.tr, devOtp.trim());
      }

      Get.toNamed(AppRoutes.forgotPasswordOtp);
    } finally {
      if (!isClosed) {
        form.value = form.value.copyWith(isSubmitting: false);
      }
    }
  }

  void onOtpDigitChanged({required int index, required String value}) {
    if (index < 0 || index >= otpControllers.length) {
      return;
    }

    final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    final String digit = digitsOnly.isEmpty
        ? ''
        : digitsOnly[digitsOnly.length - 1];

    /*
     * Keep each input limited to one numeric digit.
     */
    if (otpControllers[index].text != digit) {
      otpControllers[index].value = TextEditingValue(
        text: digit,
        selection: TextSelection.collapsed(offset: digit.length),
      );
    }

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
    resendCooldown.refresh();

    final ForgotPasswordRequestPayloadModel? payload =
        pendingRequestPayload.value;

    if (otpUi.value.isResending || resendCooldown.isActive || payload == null) {
      return;
    }

    otpUi.value = otpUi.value.copyWith(isResending: true);

    try {
      final result = await _service.requestResetCode(payload: payload);

      if (!result.success || result.data == null) {
        Get.snackbar('snack_unable_resend'.tr, 'snack_try_again'.tr);
        return;
      }

      final ForgotPasswordRequestUiModel data = result.data!;

      /*
       * Resending creates a new OTP, therefore any
       * previously issued reset token becomes unusable
       * in the Flutter flow.
       */
      pendingVerifiedOtp.value = null;

      otpUi.value = otpUi.value.copyWith(
        maskedIdentifier: data.maskedIdentifier,
        identifier: data.identifier,
        codeDigits: <String>['', '', '', ''],
      );

      _clearOtpInputs();
      _clearResetInputs();

      resendCooldown.start();

      final String? devOtp = data.devOtp;

      Get.snackbar(
        'snack_code_resent'.tr,
        devOtp != null && devOtp.trim().isNotEmpty
            ? devOtp.trim()
            : 'snack_fresh_code_sent'.tr,
      );
    } finally {
      if (!isClosed) {
        otpUi.value = otpUi.value.copyWith(isResending: false);
      }
    }
  }

  Future<void> onVerifyCodeTap() async {
    final ForgotPasswordOtpUiModel current = otpUi.value;

    if (current.isVerifying) {
      return;
    }

    if (current.identifier.trim().isEmpty) {
      Get.snackbar('snack_session_expired'.tr, 'snack_verify_again'.tr);

      Get.offAllNamed(AppRoutes.forgotPassword);
      return;
    }

    if (!current.isCodeComplete) {
      Get.snackbar('snack_incomplete_code'.tr, 'snack_enter_full_4_digit'.tr);
      return;
    }

    otpUi.value = current.copyWith(isVerifying: true);

    try {
      /*
       * This now calls POST /auth/verify-reset-otp.
       * The backend verifies the real OTP.
       */
      final result = await _service.verifyResetCode(
        payload: ForgotPasswordVerifyOtpPayloadModel(
          identifier: current.identifier,
          otp: current.code,
        ),
      );

      if (!result.success || result.data == null) {
        Get.snackbar(
          'snack_verification_failed'.tr,
          'snack_check_code_retry'.tr,
        );
        return;
      }

      final ForgotPasswordVerifyOtpUiModel verifiedResult = result.data!;

      if (!verifiedResult.isValid) {
        Get.snackbar(
          'snack_verification_failed'.tr,
          'snack_check_code_retry'.tr,
        );
        return;
      }

      /*
       * Store only the reset token, not the OTP.
       */
      pendingVerifiedOtp.value = verifiedResult;

      _clearResetInputs();

      Get.toNamed(AppRoutes.resetPassword);
    } finally {
      if (!isClosed) {
        otpUi.value = otpUi.value.copyWith(isVerifying: false);
      }
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

    final ForgotPasswordVerifyOtpUiModel? verifiedSession =
        pendingVerifiedOtp.value;

    if (current.isSubmitting) {
      return;
    }

    if (verifiedSession == null ||
        !verifiedSession.isValid ||
        verifiedSession.resetToken.trim().isEmpty) {
      Get.snackbar('snack_session_expired'.tr, 'snack_verify_again'.tr);

      Get.offAllNamed(AppRoutes.forgotPassword);
      return;
    }

    if (!current.hasMinimumLength) {
      Get.snackbar('snack_weak_password'.tr, 'snack_password_6_characters'.tr);
      return;
    }

    if (!current.matchesConfirm) {
      Get.snackbar('snack_mismatch'.tr, 'snack_passwords_match'.tr);
      return;
    }

    resetForm.value = current.copyWith(isSubmitting: true);

    bool navigationCompleted = false;

    try {
      final result = await _service.resetPassword(
        payload: ForgotPasswordResetPayloadModel(
          resetToken: verifiedSession.resetToken,
          newPassword: current.newPassword,
        ),
      );

      if (!result.success || result.data == null) {
        final String backendMessage = result.errorCode?.trim() ?? '';

        Get.snackbar(
          'snack_could_not_reset'.tr,
          backendMessage.isNotEmpty ? backendMessage : 'snack_try_again'.tr,
        );

        return;
      }

      /*
       * The reset token is one-time-use. Remove it from
       * memory immediately after a successful reset.
       */
      pendingVerifiedOtp.value = null;
      pendingRequestPayload.value = null;

      resetForm.value = resetForm.value.copyWith(isSubmitting: false);

      navigationCompleted = true;

      Get.snackbar('snack_password_reset'.tr, result.data!.successMessage);

      Get.offNamed(AppRoutes.forgotPasswordSuccess);
    } finally {
      /*
       * Avoid updating the controller after GetX has
       * removed and disposed it during route replacement.
       */
      if (!navigationCompleted && !isClosed) {
        resetForm.value = resetForm.value.copyWith(isSubmitting: false);
      }
    }
  }

  void onBackTap() {
    Get.back();
  }

  void onBackToLoginTap() {
    FocusManager.instance.primaryFocus?.unfocus();

    /*
   * Return to the existing login route instead of
   * deleting it and creating another LoginController.
   */
    Get.until((Route<dynamic> route) => route.settings.name == AppRoutes.login);
  }

  void _onRequestInputChanged() {
    if (isClosed) {
      return;
    }

    form.value = form.value.copyWith(identifier: identifierController.text);
  }

  void _onResetInputChanged() {
    if (isClosed) {
      return;
    }

    resetForm.value = resetForm.value.copyWith(
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }

  void _clearOtpInputs() {
    for (final TextEditingController controller in otpControllers) {
      controller.clear();
    }

    otpUi.value = otpUi.value.copyWith(codeDigits: <String>['', '', '', '']);
  }

  void _clearResetInputs() {
    newPasswordController.clear();
    confirmPasswordController.clear();

    resetForm.value = ResetPasswordFormModel.initial();
  }

  String _normalizeIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    final String normalized = identifier.trim();

    if (isEmailMode) {
      return normalized.toLowerCase();
    }

    if (normalized.startsWith('+')) {
      return normalized;
    }

    final String digitsOnly = normalized.replaceAll(RegExp(r'\D'), '');

    /*
     * Bangladesh local format:
     * 01XXXXXXXXX → +8801XXXXXXXXX
     */
    if (digitsOnly.startsWith('01') && digitsOnly.length == 11) {
      return '+88$digitsOnly';
    }

    /*
     * Bangladesh international format without +.
     */
    if (digitsOnly.startsWith('8801') && digitsOnly.length == 13) {
      return '+$digitsOnly';
    }

    /*
     * Italian international format without +.
     */
    if (digitsOnly.startsWith('39') &&
        digitsOnly.length >= 10 &&
        digitsOnly.length <= 13) {
      return '+$digitsOnly';
    }

    return normalized;
  }

  bool _isSupportedPhone(String phone) {
    return RegExp(r'^(?:\+8801\d{9}|\+39\d{8,11})$').hasMatch(phone);
  }

  @override
  void onClose() {
    identifierController.removeListener(_onRequestInputChanged);

    newPasswordController.removeListener(_onResetInputChanged);

    confirmPasswordController.removeListener(_onResetInputChanged);

    identifierController.dispose();

    for (final TextEditingController controller in otpControllers) {
      controller.dispose();
    }

    for (final FocusNode focusNode in otpFocusNodes) {
      focusNode.dispose();
    }

    newPasswordController.dispose();
    confirmPasswordController.dispose();

    resendCooldown.dispose();

    super.onClose();
  }
}
