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

class ApiErrorHandler {
  const ApiErrorHandler._();

  static Future<ApiHandledResponse<T>> handle<T>({
    required Future<T> Function() request,
    String fallbackErrorCode = 'unknown_error',
  }) async {
    try {
      final T result = await request();
      return ApiHandledResponse<T>(
        data: result,
        success: true,
        errorCode: null,
      );
    } catch (_) {
      return ApiHandledResponse<T>(
        data: null,
        success: false,
        errorCode: fallbackErrorCode,
      );
    }
  }
}
