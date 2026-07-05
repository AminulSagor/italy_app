import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../routes/app_routes.dart';
import 'storage_service.dart';
import 'token_service.dart';

class ApiClient {
  ApiClient({
    required TokenService tokenService,
    required StorageService storageService,
  }) : _tokenService = tokenService,
       _storageService = storageService {
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
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          final String? token = await _tokenService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            final String tokenType = await _tokenService.getTokenType();
            options.headers['Authorization'] = '$tokenType $token';
          }
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (_isAuthenticatedUnauthorized(error)) {
            await _handleUnauthorizedSession();
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
  final StorageService _storageService;
  late final Dio _dio;
  bool _isHandlingUnauthorized = false;

  Dio get dio => _dio;

  String get _baseUrl {
    final String baseUrl = dotenv.env[_baseUrlEnvKey]?.trim() ?? '';
    if (baseUrl.isEmpty) {
      throw StateError('API_BASE_URL is missing from .env');
    }
    return baseUrl;
  }

  bool _isAuthenticatedUnauthorized(DioException error) {
    if (error.response?.statusCode != 401) {
      return false;
    }

    final dynamic authorization = error.requestOptions.headers['Authorization'];
    return authorization != null && authorization.toString().trim().isNotEmpty;
  }

  Future<void> _handleUnauthorizedSession() async {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      await Future.wait<void>(<Future<void>>[
        _tokenService.clearTokens(),
        _storageService.clearLoggedInData(),
      ]);

      if (Get.currentRoute != AppRoutes.login) {
        await Future<void>.delayed(Duration.zero);
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _isHandlingUnauthorized = false;
    }
  }
}
