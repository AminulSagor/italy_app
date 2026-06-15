import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'token_service.dart';

class ApiClient {
  ApiClient({required TokenService tokenService}) : _tokenService = tokenService {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          final String? token = await _tokenService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            final String tokenType = await _tokenService.getTokenType();
            options.headers['Authorization'] = '$tokenType $token';
          }
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenService.clearTokens();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  static const String _baseUrlEnvKey = 'API_BASE_URL';
  final TokenService _tokenService;
  late final Dio _dio;

  Dio get dio => _dio;

  String get _baseUrl {
    final String baseUrl = dotenv.env[_baseUrlEnvKey]?.trim() ?? '';
    if (baseUrl.isEmpty) {
      throw StateError('API_BASE_URL is missing from .env');
    }
    return baseUrl;
  }
}
