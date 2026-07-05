import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/controllers/user_session_controller.dart';
import '../../../../../core/localization/translation_service.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/device_push_token_service.dart';
import '../../../../../core/services/learning_activity_tracker_service.dart';
import '../../../../../features/messages/services/chat_socket_service.dart';
import '../../../../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../../../../routes/routes.dart';
import '../../../models/auth_models.dart';
import '../models/login_models.dart';

class LoginController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();
  final AuthService _authService = Get.find<AuthService>();

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
    _syncSelectedLanguageWithLocale();
  }

  void setLanguage(String value) {
    _translationService.setLanguageLabel(value);
    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );
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
    final String normalizedIdentifier = _normalizeIdentifier(
      identifier: current.identifier,
      isEmailMode: current.isEmailMode,
    );
    final String normalizedPassword = current.password.trim();

    if (normalizedIdentifier.isEmpty || normalizedPassword.isEmpty) {
      Get.snackbar('snack_missing_info'.tr, 'snack_fill_both_fields'.tr);
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

    try {
      final ApiResult<AuthTokenResultModel> result = await ApiErrorHandler.call(
        () => _authService.login(payload),
        showError: false,
      );

      if (!result.isSuccess) {
        Get.snackbar(
          'Error',
          result.error ?? 'Unable to log in. Please try again.',
        );
        return;
      }

      // Refresh socket connection with the new token after successful login
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          final ChatSocketService socketService = Get.find<ChatSocketService>();
          await socketService.refreshConnectionAfterLogin();
        }
      } catch (_) {
        // Socket refresh failure should not prevent navigation
      }

      await Get.find<DevicePushTokenService>().registerCurrentDevice();
      if (Get.isRegistered<UserSessionController>()) {
        await Get.find<UserSessionController>().loadUser(forceRefresh: true);
      }
      if (Get.isRegistered<LearningActivityTrackerService>()) {
        await Get.find<LearningActivityTrackerService>().startSession();
      }
      if (Get.isRegistered<IncomingCallCoordinator>()) {
        try {
          await Get.find<IncomingCallCoordinator>().reconnectAfterLogin();
        } catch (_) {
          // The REST fallback still allows background call actions.
        }
      }

      Get.offAllNamed(AppRoutes.wrapper);

      if (Get.isRegistered<IncomingCallCoordinator>()) {
        unawaited(
          Future<void>(() async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
            await Get.find<IncomingCallCoordinator>()
                .restorePendingAcceptedCall();
          }),
        );
      }
    } finally {
      form.value = form.value.copyWith(isLoading: false);
    }
  }

  void _syncSelectedLanguageWithLocale() {
    form.value = form.value.copyWith(
      selectedLanguage: _translationService.selectedLabel.value,
    );
  }

  void _onFormInputChanged() {
    form.value = form.value.copyWith(
      identifier: identifierController.text,
      password: passwordController.text,
    );
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

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
