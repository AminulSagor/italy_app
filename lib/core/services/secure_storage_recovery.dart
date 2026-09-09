import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';

class SecureStorageRecovery {
  SecureStorageRecovery._();

  static Future<void> reportHandledFailure({
    required String scope,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    AppLogger.log(
      'Recovered from a secure-storage failure in $scope',
      name: 'SecureStorage',
      error: error,
      stackTrace: stackTrace,
    );

    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Handled secure-storage failure in $scope',
        fatal: false,
      );
    } catch (reportingError, reportingStackTrace) {
      AppLogger.log(
        'Unable to report handled secure-storage failure',
        name: 'SecureStorage',
        error: reportingError,
        stackTrace: reportingStackTrace,
      );
    }
  }

  static Future<void> deleteKeys({
    required FlutterSecureStorage storage,
    required Iterable<String> keys,
    required String scope,
  }) async {
    for (final String key in keys) {
      try {
        await storage.delete(key: key);
      } catch (error, stackTrace) {
        await reportHandledFailure(
          scope: '$scope cleanup',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
