import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../routes/app_routes.dart';
import '../controllers/user_session_controller.dart';
import '../models/account_restriction_details.dart';
import 'storage_service.dart';
import 'token_service.dart';

class ApiClient {
  ApiClient({
    required TokenService tokenService,
    required StorageService storageService,
  }) : // Keep public dependency names for bindings and tests.
       // ignore: prefer_initializing_formals
       _tokenService = tokenService,
       // ignore: prefer_initializing_formals
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
          // Marks this build as supporting explicit AI-data consent. The
          // backend uses it to distinguish this build from the already
          // published legacy Android app during the compatibility rollout.
          'X-Italir-Client-Capabilities': 'ai-consent-v1',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final String? authorizationHeader = _tokenService.authorizationHeader;

          if (authorizationHeader != null) {
            options.headers['Authorization'] = authorizationHeader;
          }

          if (!options.path.contains('/course-device-access/')) {
            final _CourseDeviceProof? proof = _courseDeviceProofFor(
              options.path,
            );
            if (proof != null) {
              options.headers['X-Course-Device-Key-Id'] = proof.deviceKeyId;
              options.headers['X-Course-Device-Access-Token'] =
                  proof.accessToken;
            }
          }

          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final AccountRestrictionDetails? restriction =
              AccountRestrictionDetails.tryFromResponseData(
                error.response?.data,
              );

          if (restriction != null) {
            await _handleBannedSession(restriction);
          } else if (_isAuthenticatedUnauthorized(error)) {
            await _handleUnauthorizedSession();
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: false,
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
  bool _isHandlingSessionFailure = false;
  final Map<String, _CourseDeviceProof> _courseDeviceProofs =
      <String, _CourseDeviceProof>{};
  String? _activeCourseDeviceProofCourseId;

  Dio get dio => _dio;

  void setCourseDeviceProof({
    required String courseId,
    required String deviceKeyId,
    required String accessToken,
  }) {
    _courseDeviceProofs[courseId] = _CourseDeviceProof(
      deviceKeyId: deviceKeyId,
      accessToken: accessToken,
    );
    _activeCourseDeviceProofCourseId = courseId;
  }

  void clearCourseDeviceProof({String? courseId}) {
    if (courseId == null) {
      _courseDeviceProofs.clear();
      _activeCourseDeviceProofCourseId = null;
      return;
    }

    _courseDeviceProofs.remove(courseId);
    if (_activeCourseDeviceProofCourseId == courseId) {
      _activeCourseDeviceProofCourseId = null;
    }
  }

  _CourseDeviceProof? _courseDeviceProofFor(String requestPath) {
    final List<String> pathSegments = Uri.parse(requestPath).pathSegments;
    for (final MapEntry<String, _CourseDeviceProof> entry
        in _courseDeviceProofs.entries) {
      if (pathSegments.contains(entry.key)) return entry.value;
    }

    final String? activeCourseId = _activeCourseDeviceProofCourseId;
    return activeCourseId == null ? null : _courseDeviceProofs[activeCourseId];
  }

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

  Future<void> _handleBannedSession(
    AccountRestrictionDetails restriction,
  ) async {
    if (_isHandlingSessionFailure) {
      return;
    }

    _isHandlingSessionFailure = true;

    try {
      await _clearLocalSession();

      if (Get.currentRoute != AppRoutes.accountSuspended) {
        await Future<void>.delayed(Duration.zero);

        Get.offAllNamed(AppRoutes.accountSuspended, arguments: restriction);
      }
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      _isHandlingSessionFailure = false;
    }
  }

  Future<void> _handleUnauthorizedSession() async {
    if (_isHandlingSessionFailure) {
      return;
    }

    _isHandlingSessionFailure = true;

    try {
      await _clearLocalSession();

      if (Get.currentRoute != AppRoutes.login &&
          Get.currentRoute != AppRoutes.accountSuspended) {
        await Future<void>.delayed(Duration.zero);

        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      _isHandlingSessionFailure = false;
    }
  }

  Future<void> _clearLocalSession() async {
    clearCourseDeviceProof();
    await Future.wait<void>(<Future<void>>[
      _tokenService.clearTokens(),
      _storageService.clearLoggedInData(),
    ]);

    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().clear();
    }
  }
}

class _CourseDeviceProof {
  const _CourseDeviceProof({
    required this.deviceKeyId,
    required this.accessToken,
  });

  final String deviceKeyId;
  final String accessToken;
}
