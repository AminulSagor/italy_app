import 'package:dio/dio.dart';

import '../../features/auth/models/auth_models.dart';
import 'api_client.dart';
import 'storage_service.dart';
import 'token_service.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenService tokenService,
    required StorageService storageService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _storageService = storageService;

  final ApiClient _apiClient;
  final TokenService _tokenService;
  final StorageService _storageService;

  static const String _signupEndpoint = '/auth/signup';
  static const String _loginEndpoint = '/auth/login';
  static const String _verifyOtpEndpoint = '/auth/verify-otp';
  static const String _resendOtpEndpoint = '/auth/resend-otp';

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
        message: 'Signup response missing identifier',
      );
    }

    return result;
  }

  Future<AuthTokenResultModel> login(LoginPayloadModel payload) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      _loginEndpoint,
      data: payload.toJson(),
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
    final Response<dynamic> response = await _apiClient.dio.post(
      _verifyOtpEndpoint,
      data: payload.toJson(),
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

  Future<void> logout() async {
    await _tokenService.clearTokens();
    await _storageService.clearLoggedInData();
  }

  Future<void> _saveSession(
    AuthTokenResultModel result,
    RequestOptions requestOptions,
  ) async {
    if (result.accessToken.trim().isEmpty) {
      throw DioException(
        requestOptions: requestOptions,
        message: 'Auth response missing accessToken',
      );
    }

    await _tokenService.saveAccessToken(
      result.accessToken,
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
      message: 'Response is not a valid JSON object',
    );
  }

  String _normalizeIdentifier(String identifier) {
    final String normalized = identifier.trim();
    return normalized.contains('@') ? normalized.toLowerCase() : normalized;
  }
}
