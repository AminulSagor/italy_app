import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiHandledResponse<T> {
  const ApiHandledResponse({
    required this.data,
    required this.success,
    required this.errorCode,
  });

  final T? data;
  final bool success;
  final String? errorCode;
}

class ApiResult<T> {
  const ApiResult._({this.data, this.error, required this.isSuccess});

  final T? data;
  final String? error;
  final bool isSuccess;

  factory ApiResult.success(T data) {
    return ApiResult<T>._(data: data, isSuccess: true);
  }

  factory ApiResult.failure(String error) {
    return ApiResult<T>._(error: error, isSuccess: false);
  }

  T dataOr(T fallback) {
    return isSuccess && data != null ? data as T : fallback;
  }
}

class ApiErrorHandler {
  const ApiErrorHandler._();

  static Future<ApiResult<T>> call<T>(
    Future<T> Function() apiCall, {
    bool showError = true,
    String errorTitle = 'Error',
  }) async {
    try {
      final T data = await apiCall();
      return ApiResult<T>.success(data);
    } catch (error) {
      final String message = getErrorMessage(error);
      final bool isUnauthorized =
          error is DioException && error.response?.statusCode == 401;
      if (showError && !isUnauthorized) {
        _showErrorSnackbar(errorTitle, message);
      }
      return ApiResult<T>.failure(message);
    }
  }

  static Future<ApiHandledResponse<T>> handle<T>({
    required Future<T> Function() request,
    String fallbackErrorCode = 'unknown_error',
  }) async {
    final ApiResult<T> result = await call<T>(
      request,
      showError: false,
      errorTitle: fallbackErrorCode,
    );

    return ApiHandledResponse<T>(
      data: result.data,
      success: result.isSuccess,
      errorCode: result.isSuccess ? null : result.error ?? fallbackErrorCode,
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _parseDioError(error);
    }
    return error.toString();
  }

  static String _parseDioError(DioException error) {
    final dynamic data = error.response?.data;
    if (data is Map) {
      final dynamic message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.map((dynamic item) => item.toString()).join('\n');
      }
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
      final dynamic errorMessage = data['error'];
      if (errorMessage != null && errorMessage.toString().trim().isNotEmpty) {
        return errorMessage.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate.';
      case DioExceptionType.badResponse:
        return _httpMessage(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
      case DioExceptionType.unknown:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  static String _httpMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden.';
      case 404:
        return 'Not found.';
      case 409:
        return 'Already exists.';
      case 422:
        return 'Validation failed.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'HTTP error. Please try again.';
    }
  }

  static void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(title.tr, message);
  }
}
