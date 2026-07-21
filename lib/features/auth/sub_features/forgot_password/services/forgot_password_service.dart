import 'package:dio/dio.dart';

import '../../../../../core/services/api_client.dart';
import '../../../../../core/services/api_error_handler.dart';
import '../models/forgot_password_models.dart';

class ForgotPasswordService {
  ForgotPasswordService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _forgotPasswordEndpoint =
      '/auth/forgot-password';

  static const String _verifyResetOtpEndpoint =
      '/auth/verify-reset-otp';

  static const String _resetPasswordEndpoint =
      '/auth/reset-password';

  Future<
      ApiHandledResponse<
          ForgotPasswordRequestUiModel>>
  requestResetCode({
    required ForgotPasswordRequestPayloadModel
    payload,
  }) {
    return ApiErrorHandler.handle<
        ForgotPasswordRequestUiModel>(
      request: () async {
        final String identifier =
        _normalizeIdentifier(
          payload.identifier,
        );

        final Response<dynamic> response =
        await _apiClient.dio.post(
          _forgotPasswordEndpoint,
          data: <String, dynamic>{
            'identifier': identifier,
          },
        );

        final Map<String, dynamic> data =
        _responseMap(response);

        return ForgotPasswordRequestUiModel
            .fromJson(
          <String, dynamic>{
            ...data,
            'identifier': identifier,
            'maskedIdentifier':
            _maskedIdentifier(
              identifier: identifier,
              isEmailMode:
              payload.channel == 'email',
            ),
          },
        );
      },
      fallbackErrorCode:
      'forgot_request_failed',
    );
  }

  Future<
      ApiHandledResponse<
          ForgotPasswordVerifyOtpUiModel>>
  verifyResetCode({
    required ForgotPasswordVerifyOtpPayloadModel
    payload,
  }) {
    return ApiErrorHandler.handle<
        ForgotPasswordVerifyOtpUiModel>(
      request: () async {
        final Response<dynamic> response =
        await _apiClient.dio.post(
          _verifyResetOtpEndpoint,
          data: payload.toJson(),
        );

        return ForgotPasswordVerifyOtpUiModel
            .fromJson(
          _responseMap(response),
        );
      },
      fallbackErrorCode:
      'forgot_verify_failed',
    );
  }

  Future<
      ApiHandledResponse<
          ForgotPasswordResetUiModel>>
  resetPassword({
    required ForgotPasswordResetPayloadModel
    payload,
  }) {
    return ApiErrorHandler.handle<
        ForgotPasswordResetUiModel>(
      request: () async {
        final Response<dynamic> response =
        await _apiClient.dio.post(
          _resetPasswordEndpoint,
          data: payload.toJson(),
        );

        return ForgotPasswordResetUiModel
            .fromJson(
          _responseMap(response),
        );
      },
      fallbackErrorCode:
      'forgot_reset_failed',
    );
  }

  Map<String, dynamic> _responseMap(
      Response<dynamic> response,
      ) {
    final dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(
        data,
      );
    }

    throw DioException(
      requestOptions:
      response.requestOptions,
      message:
      'Response is not a valid JSON object',
    );
  }

  String _normalizeIdentifier(
      String identifier,
      ) {
    final String normalized =
    identifier.trim();

    return normalized.contains('@')
        ? normalized.toLowerCase()
        : normalized;
  }

  String _maskedIdentifier({
    required String identifier,
    required bool isEmailMode,
  }) {
    if (isEmailMode) {
      final List<String> parts =
      identifier.split('@');

      if (parts.length != 2) {
        return identifier;
      }

      final String localName =
          parts.first;
      final String domain = parts.last;

      if (localName.length <= 2) {
        return '$localName@$domain';
      }

      return '${localName.substring(0, 2)}***@$domain';
    }

    final String digitsOnly =
    identifier.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digitsOnly.length < 5) {
      return identifier;
    }

    final String prefix =
    digitsOnly.substring(0, 2);

    final String suffix =
    digitsOnly.substring(
      digitsOnly.length - 2,
    );

    return '+$prefix* *** *$suffix';
  }
}