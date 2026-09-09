import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/services/crash_error_policy.dart';

void main() {
  group('CrashErrorPolicy', () {
    test('treats reported image failures as recoverable', () {
      expect(
        CrashErrorPolicy.isRecoverable(
          Exception('HTTP request failed, statusCode: 403'),
          StackTrace.fromString('NetworkImage._loadAsync'),
        ),
        isTrue,
      );
      expect(
        CrashErrorPolicy.isRecoverable(
          Exception('HttpException: Connection closed before full header'),
          StackTrace.fromString('NetworkImage._loadAsync'),
        ),
        isTrue,
      );
      expect(
        CrashErrorPolicy.isRecoverable(
          Exception('HttpException: Connection closed while receiving data'),
          StackTrace.fromString('NetworkImage._loadAsync'),
        ),
        isTrue,
      );
    });

    test('treats socket disconnect and YouTube timeout as recoverable', () {
      expect(
        CrashErrorPolicy.isRecoverable(
          Exception('WebSocketConnectionClosed: Connection Closed'),
          StackTrace.fromString('IOWebSocket.close'),
        ),
        isTrue,
      );
      expect(
        CrashErrorPolicy.isRecoverable(
          Exception(
            'TimeoutException: YouTube player failed to initialize within 30 seconds',
          ),
          StackTrace.fromString('JsBridge._waitReady'),
        ),
        isTrue,
      );
    });

    test('keeps programming errors fatal', () {
      expect(
        CrashErrorPolicy.isRecoverable(
          StateError('Bad state'),
          StackTrace.fromString('QuizController.submitAnswer'),
        ),
        isFalse,
      );
    });
  });
}
