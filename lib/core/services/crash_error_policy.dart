class CrashErrorPolicy {
  const CrashErrorPolicy._();

  /// Network and embedded-media failures can happen during normal use and
  /// should be reported to Crashlytics without marking the app as crashed.
  static bool isRecoverable(Object error, StackTrace stackTrace) {
    final String details = '${error.runtimeType}: $error\n$stackTrace'
        .toLowerCase();

    return details.contains('networkimageloadexception') ||
        details.contains('http request failed, statuscode:') ||
        details.contains('httpexception: connection closed') ||
        details.contains('socketexception:') ||
        details.contains('handshakeexception:') ||
        details.contains('websocketconnectionclosed') ||
        (details.contains('timeoutexception:') &&
            details.contains('youtube player failed to initialize'));
  }
}
