import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void log(
      String message, {
        DateTime? time,
        int? sequenceNumber,
        int level = 0,
        String name = '',
        Zone? zone,
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (!kDebugMode) {
      return;
    }

    dev.log(
      message,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}