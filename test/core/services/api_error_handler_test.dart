import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/services/api_error_handler.dart';
import 'package:italir_pothe/core/services/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('returns an API failure without opening an offline snackbar', () async {
    final ConnectivityService connectivity = Get.put<ConnectivityService>(
      ConnectivityService(),
    );
    connectivity.isOnline.value = false;

    final ApiResult<void> result = await ApiErrorHandler.call<void>(
      () async => throw StateError('network unavailable'),
      errorTitle: 'Quiz',
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('network unavailable'));
    expect(Get.isSnackbarOpen, isFalse);
  });

  test('returns an API failure safely when no overlay is mounted', () async {
    final ApiResult<void> result = await ApiErrorHandler.call<void>(
      () async => throw StateError('request failed'),
      errorTitle: 'Quiz',
    );

    expect(result.isSuccess, isFalse);
    expect(Get.isSnackbarOpen, isFalse);
  });
}
