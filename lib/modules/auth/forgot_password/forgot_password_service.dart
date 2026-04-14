import 'package:flutter/foundation.dart';

import '../../../core/services/api_error_handler.dart';
import 'forgot_password_models.dart';

class ForgotPasswordService {
  Future<ApiHandledResponse<ForgotPasswordRequestUiModel>> requestResetCode({
    required ForgotPasswordRequestPayloadModel payload,
  }) {
    return ApiErrorHandler.handle<ForgotPasswordRequestUiModel>(
      request: () async {
        await Future<void>.delayed(const Duration(milliseconds: 650));

        final Map<String, dynamic> response = <String, dynamic>{
          'maskedIdentifier': _maskedIdentifier(
            identifier: payload.identifier,
            isEmailMode: payload.channel == 'email',
          ),
          'requestToken': _buildToken('request', payload.identifier),
        };

        debugPrint('Forgot request payload: ${payload.toJson()}');
        return ForgotPasswordRequestUiModel.fromJson(response);
      },
      fallbackErrorCode: 'forgot_request_failed',
    );
  }

  Future<ApiHandledResponse<ForgotPasswordVerifyOtpUiModel>> verifyResetCode({
    required ForgotPasswordVerifyOtpPayloadModel payload,
  }) {
    return ApiErrorHandler.handle<ForgotPasswordVerifyOtpUiModel>(
      request: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));

        final Map<String, dynamic> response = <String, dynamic>{
          'resetToken': _buildToken('reset', payload.requestToken),
        };

        debugPrint('Forgot verify payload: ${payload.toJson()}');
        return ForgotPasswordVerifyOtpUiModel.fromJson(response);
      },
      fallbackErrorCode: 'forgot_verify_failed',
    );
  }

  Future<ApiHandledResponse<ForgotPasswordResetUiModel>> resetPassword({
    required ForgotPasswordResetPayloadModel payload,
  }) {
    return ApiErrorHandler.handle<ForgotPasswordResetUiModel>(
      request: () async {
        await Future<void>.delayed(const Duration(milliseconds: 700));

        final Map<String, dynamic> response = <String, dynamic>{
          'successMessage': 'Your password has been reset successfully.',
        };

        debugPrint('Forgot reset payload: ${payload.toJson()}');
        return ForgotPasswordResetUiModel.fromJson(response);
      },
      fallbackErrorCode: 'forgot_reset_failed',
    );
  }

  String _buildToken(String prefix, String seed) {
    return '${prefix}_${seed.hashCode.abs()}';
  }

  String _maskedIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    if (isEmailMode) {
      final List<String> parts = identifier.split('@');
      if (parts.length != 2) {
        return identifier;
      }

      final String localName = parts.first;
      final String domain = parts.last;
      if (localName.length <= 2) {
        return '$localName@$domain';
      }

      return '${localName.substring(0, 2)}***@$domain';
    }

    final String digitsOnly = identifier.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 5) {
      return identifier;
    }

    final String prefix = digitsOnly.substring(0, 2);
    final String suffix = digitsOnly.substring(digitsOnly.length - 2);
    return '+$prefix* *** *$suffix';
  }
}
