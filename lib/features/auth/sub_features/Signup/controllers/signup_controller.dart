import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/localization/translation_service.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/services/course_purchase_recovery_service.dart';
import '../../../../../core/services/learning_activity_tracker_service.dart';
import '../../../../../core/utils/otp_resend_cooldown.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../features/messages/services/chat_socket_service.dart';
import '../../../../../core/services/device_push_token_service.dart';
import '../../../../../routes/routes.dart';
import '../../../models/auth_models.dart';
import '../models/signup_models.dart';

class SignupController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();
  final AuthService _authService = Get.find<AuthService>();

  final Rx<SignupFormModel> form = SignupFormModel.initial().obs;
  final Rx<SignupOtpUiModel> otpUi = SignupOtpUiModel.initial().obs;
  final Rx<SignupAccountCreatedUiModel> accountCreatedUi =
      SignupAccountCreatedUiModel.initial().obs;

  final Rxn<SignupPayloadModel> pendingPayload = Rxn<SignupPayloadModel>();
  final Rxn<OtpVerificationPayloadModel> pendingOtpVerificationPayload =
      Rxn<OtpVerificationPayloadModel>();
  final OtpResendCooldown resendCooldown = OtpResendCooldown();

  late final TextEditingController fullNameController;
  late final TextEditingController identifierController;
  late final TextEditingController passwordController;
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  static final Uri _termsAndConditionsUrl = Uri.parse(
    'https://www.italirpothe.com/terms-and-conditions',
  );

  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://www.italirpothe.com/privacy-policy',
  );

  @override
  void onInit() {
    super.onInit();
    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );
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

  Future<void> setLanguage(String value) async {
    final Future<void> saveFuture = _translationService.setLanguageLabel(value);

    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );

    await saveFuture;
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

  Future<void> openTermsAndConditions() async {
    await _openExternalUrl(_termsAndConditionsUrl);
  }

  Future<void> openPrivacyPolicy() async {
    await _openExternalUrl(_privacyPolicyUrl);
  }

  Future<void> _openExternalUrl(Uri uri) async {
    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        Get.snackbar('Unable to open link', 'Please try again.');
      }
    } catch (_) {
      Get.snackbar(
        'Unable to open link',
        'Please check your internet connection.',
      );
    }
  }

  void toggleTermsAgreement() {
    form.value = form.value.copyWith(agreedToTerms: !form.value.agreedToTerms);
  }

  Future<void> onCreateAccountTap() async {
    final SignupFormModel current = form.value;

    if (current.isLoading) {
      return;
    }

    final String normalizedFullName = current.fullName.trim();
    final String normalizedIdentifier = _normalizeIdentifier(
      identifier: current.identifier,
      isEmailMode: current.isEmailMode,
    );
    final String normalizedPassword = current.password;

    if (normalizedFullName.isEmpty ||
        normalizedIdentifier.isEmpty ||
        normalizedPassword.isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_fill_required'.tr);
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

    if (!_isValidPassword(normalizedPassword)) {
      Get.snackbar('snack_weak_password'.tr, 'snack_password_6_characters'.tr);
      return;
    }

    if (!current.agreedToTerms) {
      Get.snackbar('snack_terms_required'.tr, 'snack_accept_terms'.tr);
      return;
    }

    final SignupPayloadModel payload = SignupPayloadModel(
      fullName: normalizedFullName,
      password: normalizedPassword,
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
      final ApiResult<SignupResultModel> result = await ApiErrorHandler.call(
        () => _authService.signup(payload),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final SignupResultModel signupResult = result.data!;
      pendingPayload.value = payload.copyWith(
        email: current.isEmailMode ? signupResult.identifier : null,
        phone: current.isEmailMode ? null : signupResult.identifier,
      );
      accountCreatedUi.value = accountCreatedUi.value.copyWith(
        identifier: signupResult.identifier,
      );
      otpUi.value = otpUi.value.copyWith(
        maskedIdentifier: _maskedIdentifier(
          identifier: signupResult.identifier,
          isEmailMode: current.isEmailMode,
        ),
      );

      resendCooldown.start();
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
    resendCooldown.refresh();
    if (otpUi.value.isResending || resendCooldown.isActive) {
      return;
    }

    final SignupPayloadModel? payload = pendingPayload.value;
    final String identifier = payload?.email ?? payload?.phone ?? '';
    if (identifier.isEmpty) {
      Get.snackbar('snack_unable_resend'.tr, 'snack_payload_not_ready'.tr);
      return;
    }

    otpUi.value = otpUi.value.copyWith(isResending: true);
    try {
      final ApiResult<OtpResponseModel> result = await ApiErrorHandler.call(
        () => _authService.resendOtp(identifier: identifier),
      );

      if (!result.isSuccess) {
        return;
      }

      _clearOtpInputs();
      resendCooldown.start();
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

    final OtpVerificationPayloadModel verifyPayload =
        OtpVerificationPayloadModel(
          code: currentOtpUi.code,
          identifier: identifier,
        );
    pendingOtpVerificationPayload.value = verifyPayload;

    otpUi.value = otpUi.value.copyWith(isVerifying: true);
    try {
      final ApiResult<AuthTokenResultModel> result = await ApiErrorHandler.call(
        () => _authService.verifyOtp(verifyPayload),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      _applyVerifiedAccountInfo(result.data!.user);

      // Refresh socket connection with the new token after successful verification
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          final ChatSocketService socketService = Get.find<ChatSocketService>();
          await socketService.refreshConnectionAfterLogin();
        }
      } catch (_) {
        // Socket refresh failure should not prevent navigation
      }

      await Get.find<DevicePushTokenService>().registerCurrentDevice();
      Get.toNamed(AppRoutes.accountCreated);
    } finally {
      otpUi.value = otpUi.value.copyWith(isVerifying: false);
    }
  }

  Future<void> onStartLearningTap() async {
    if (accountCreatedUi.value.isStarting) {
      return;
    }

    accountCreatedUi.value = accountCreatedUi.value.copyWith(isStarting: true);
    try {
      // Ensure socket is connected with the latest token before navigating to wrapper
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          final ChatSocketService socketService = Get.find<ChatSocketService>();
          await socketService.refreshConnectionAfterLogin();
        }
      } catch (_) {
        // Socket refresh failure should not prevent navigation
      }

      if (Get.isRegistered<UserSessionController>()) {
        await Get.find<UserSessionController>().loadUser(forceRefresh: true);
      }
      if (Get.isRegistered<CoursePurchaseRecoveryService>()) {
        await Get.find<CoursePurchaseRecoveryService>()
            .recoverPendingPurchase();
      }
      if (Get.isRegistered<LearningActivityTrackerService>()) {
        await Get.find<LearningActivityTrackerService>().startSession();
      }
      Get.offAllNamed(AppRoutes.wrapper);
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

  void prepareExistingAccountOtp({
    required String identifier,
    required bool isEmailMode,
    String? devOtp,
  }) {
    final String normalizedIdentifier = _normalizeIdentifier(
      identifier: identifier,
      isEmailMode: isEmailMode,
    );

    pendingPayload.value = SignupPayloadModel(
      fullName: '',
      password: '',
      email: isEmailMode ? normalizedIdentifier : null,
      phone: isEmailMode ? null : normalizedIdentifier,
    );
    accountCreatedUi.value = accountCreatedUi.value.copyWith(
      fullName: '',
      identifier: normalizedIdentifier,
    );
    pendingOtpVerificationPayload.value = null;
    otpUi.value = otpUi.value.copyWith(
      maskedIdentifier: _maskedIdentifier(
        identifier: normalizedIdentifier,
        isEmailMode: isEmailMode,
      ),
      codeDigits: <String>['', '', '', ''],
      isResending: false,
      isVerifying: false,
    );
    _clearOtpInputs();
    resendCooldown.start();
  }

  void _applyVerifiedAccountInfo(AuthUserModel user) {
    final String fallbackIdentifier =
        pendingPayload.value?.email ?? pendingPayload.value?.phone ?? '';
    final bool isEmailIdentifier = user.email?.trim().isNotEmpty == true;
    final String verifiedIdentifier = isEmailIdentifier
        ? user.email!.trim()
        : (user.phone?.trim().isNotEmpty == true
              ? user.phone!.trim()
              : fallbackIdentifier);

    accountCreatedUi.value = accountCreatedUi.value.copyWith(
      fullName: user.fullName.trim().isNotEmpty
          ? user.fullName.trim()
          : accountCreatedUi.value.fullName,
      identifier: verifiedIdentifier.trim().isNotEmpty
          ? verifiedIdentifier.trim()
          : accountCreatedUi.value.identifier,
    );
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

  String _normalizeIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    final String normalized = identifier.trim();
    if (isEmailMode || normalized.startsWith('+')) {
      return isEmailMode ? normalized.toLowerCase() : normalized;
    }

    final String digitsOnly = normalized.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('01') && digitsOnly.length == 11) {
      return '+88$digitsOnly';
    }

    if (digitsOnly.startsWith('8801') && digitsOnly.length == 13) {
      return '+$digitsOnly';
    }

    if (digitsOnly.startsWith('39') && digitsOnly.length >= 10) {
      return '+$digitsOnly';
    }

    return normalized;
  }

  bool _isSupportedPhone(String phone) {
    return RegExp(r'^(?:\+8801\d{9}|\+39\d{8,11})$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  String _maskedIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    return identifier.trim();
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
    resendCooldown.dispose();
    super.onClose();
  }
}
