import 'package:italir_pothe/core/utils/app_logger.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../features/auth/models/auth_models.dart';
import 'api_client.dart';
import 'device_push_token_service.dart';
import 'storage_service.dart';
import 'token_service.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenService tokenService,
    required StorageService storageService,
    required DevicePushTokenService devicePushTokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _storageService = storageService,
       _devicePushTokenService = devicePushTokenService;

  final ApiClient _apiClient;
  final TokenService _tokenService;
  final StorageService _storageService;
  final DevicePushTokenService _devicePushTokenService;

  static const String _signupEndpoint = '/auth/signup';
  static const String _loginEndpoint = '/auth/login';
  static const String _verifyOtpEndpoint = '/auth/verify-otp';
  static const String _resendOtpEndpoint = '/auth/resend-otp';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _currentUserEndpoint = '/users/me';

  Future<SignupResultModel> signup(SignupPayloadModel payload) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      _signupEndpoint,
      data: payload.toJson(),
    );

    final Map<String, dynamic> data = _responseMap(response);

    final SignupResultModel result = SignupResultModel.fromJson(data);

    if (result.identifier.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'signup_response_missing_identifier'.tr,
      );
    }

    return result;
  }

  Future<AuthTokenResultModel> login(LoginPayloadModel payload) async {
    /*
     * Get the permanent ID belonging to this particular
     * application installation.
     */
    final String deviceId = await _devicePushTokenService.getOrCreateDeviceId();

    final Response<dynamic> response = await _apiClient.dio.post(
      _loginEndpoint,
      data: <String, dynamic>{
        ...payload.toJson(),

        /*
         * The backend uses these values to create a
         * PostgreSQL authentication session.
         */
        'deviceId': deviceId,
        'platform': _devicePushTokenService.platformValue,
      },
    );

    final AuthTokenResultModel result = AuthTokenResultModel.fromJson(
      _responseMap(response),
    );

    await _saveSession(result, response.requestOptions);

    return result;
  }

  Future<AuthTokenResultModel> socialLogin({
    required String provider,
    required String token,
    String? tokenType,
    String? nonce,
    String? displayName,
    String? authorizationCode,
  }) async {
    final String normalizedProvider = provider.trim().toLowerCase();
    if (normalizedProvider != 'google' &&
        normalizedProvider != 'facebook' &&
        normalizedProvider != 'apple') {
      throw ArgumentError.value(provider, 'provider', 'Unsupported provider');
    }

    final String deviceId = await _devicePushTokenService.getOrCreateDeviceId();
    final Response<dynamic> response = await _apiClient.dio.post(
      '/auth/social/$normalizedProvider',
      data: <String, dynamic>{
        'token': token,
        if (tokenType != null) 'tokenType': tokenType,
        if (nonce != null) 'nonce': nonce,
        if (displayName != null) 'displayName': displayName,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
        'deviceId': deviceId,
        'platform': _devicePushTokenService.platformValue,
      },
    );
    final AuthTokenResultModel result = AuthTokenResultModel.fromJson(
      _responseMap(response),
    );
    await _saveSession(result, response.requestOptions);
    return result;
  }

  Future<AuthTokenResultModel> verifyOtp(
    OtpVerificationPayloadModel payload,
  ) async {
    /*
     * OTP verification also creates the user's first
     * authenticated session, so it needs device details.
     */
    final String deviceId = await _devicePushTokenService.getOrCreateDeviceId();

    final Response<dynamic> response = await _apiClient.dio.post(
      _verifyOtpEndpoint,
      data: <String, dynamic>{
        ...payload.toJson(),
        'deviceId': deviceId,
        'platform': _devicePushTokenService.platformValue,
      },
    );

    final AuthTokenResultModel result = AuthTokenResultModel.fromJson(
      _responseMap(response),
    );

    await _saveSession(result, response.requestOptions);

    return result;
  }

  Future<OtpResponseModel> resendOtp({required String identifier}) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      _resendOtpEndpoint,
      data: <String, dynamic>{'identifier': _normalizeIdentifier(identifier)},
    );

    return OtpResponseModel.fromJson(_responseMap(response));
  }

  Future<bool> validateStoredSession() async {
    /*
     * First confirm that the JWT exists locally and has
     * not reached its JWT expiration time.
     */
    if (!await _tokenService.hasLocallyValidAccessToken()) {
      return false;
    }

    try {
      /*
       * This protected request passes through JwtStrategy.
       *
       * The backend checks:
       * JWT signature
       * JWT expiry
       * sid
       * did
       * PostgreSQL authentication-session status
       */
      await _apiClient.dio.get(_currentUserEndpoint);

      await _storageService.setLoggedInData();

      return true;
    } on DioException catch (error) {
      /*
       * A 401 means that the JWT or its server-side
       * authentication session is no longer valid.
       */
      if (error.response?.statusCode == 401) {
        return false;
      }

      /*
       * Do not automatically log the user out because of
       * temporary internet or backend server failures.
       */
      return error.response == null ||
          (error.response?.statusCode ?? 500) >= 500;
    }
  }

  Future<void> logout() async {
    /*
     * Stop Firebase token-refresh events from registering
     * this device again while logout is running.
     */
    _devicePushTokenService.disableBackendSync();

    try {
      /*
       * The JWT must still exist when this request is sent.
       *
       * The backend reads userId, sessionId and deviceId
       * directly from the verified JWT.
       *
       * Do not send deviceId in the request body.
       */
      await _apiClient.dio.post(_logoutEndpoint);
    } on DioException catch (error, stackTrace) {
      /*
       * Local logout must still finish when:
       * - internet is unavailable
       * - the backend is temporarily unavailable
       * - the session was already revoked
       */
      AppLogger.log(
        'Backend logout request failed',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthService',
      );
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unexpected logout error',
        error: error,
        stackTrace: stackTrace,
        name: 'AuthService',
      );
    } finally {
      /*
       * Remove this installation's local Firebase token.
       */
      await _devicePushTokenService.deleteLocalFcmToken();

      /*
       * JWT must be removed only after POST /auth/logout
       * has finished or failed.
       */
      try {
        await _tokenService.clearTokens();
      } finally {
        await _storageService.clearLoggedInData();
      }
    }
  }

  Future<void> clearLocalSessionAfterAccountDeletion() async {
    /*
   * The backend account is already deleted, so do not
   * call POST /auth/logout again.
   */
    _devicePushTokenService.disableBackendSync();

    try {
      await _devicePushTokenService.deleteLocalFcmToken();
    } catch (_) {
      // Local logout must continue even if Firebase fails.
    }

    try {
      await _storageService.clearLoggedInData();
    } catch (_) {
      // Continue clearing the JWT.
    }

    try {
      await _tokenService.clearTokens();
    } catch (_) {
      // Account deletion has already succeeded.
    }
  }

  Future<void> _saveSession(
    AuthTokenResultModel result,
    RequestOptions requestOptions,
  ) async {
    final String accessToken = result.accessToken.trim();

    if (accessToken.isEmpty) {
      throw DioException(
        requestOptions: requestOptions,
        message: 'auth_response_missing_accesstoken'.tr,
      );
    }

    await _tokenService.saveAccessToken(
      accessToken,
      tokenType: result.tokenType,
    );

    await _storageService.setLoggedInData();
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object'.tr,
    );
  }

  String _normalizeIdentifier(String identifier) {
    final String normalized = identifier.trim();

    return normalized.contains('@') ? normalized.toLowerCase() : normalized;
  }
}
