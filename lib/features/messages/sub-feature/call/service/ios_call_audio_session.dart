import 'dart:io';

import 'package:flutter/services.dart';

typedef IosCallAudioSessionEventHandler =
    Future<void> Function(String event, Map<String, dynamic> data);

/// Bridges the call-specific AVAudioSession policy owned by AppDelegate.
///
/// CallKit activates incoming-call audio. Direct Agora calls activate it here.
/// Neither path deactivates merely because Flutter moves to the background.
class IosCallAudioSession {
  IosCallAudioSession._();

  static const MethodChannel _channel = MethodChannel(
    'com.italirpothe/call_audio_session',
  );

  static IosCallAudioSessionEventHandler? _eventHandler;

  static void setEventHandler(IosCallAudioSessionEventHandler? handler) {
    _eventHandler = handler;
    if (!Platform.isIOS) {
      return;
    }
    _channel.setMethodCallHandler((MethodCall call) async {
      final IosCallAudioSessionEventHandler? activeHandler = _eventHandler;
      if (activeHandler == null) {
        return;
      }
      await activeHandler(call.method, _toMap(call.arguments));
    });
  }

  static Future<Map<String, dynamic>> configureCall({
    required bool isVideo,
    required bool callKitManaged,
    required bool speaker,
  }) async {
    if (!Platform.isIOS) {
      return const <String, dynamic>{};
    }
    final dynamic response = await _channel.invokeMethod<dynamic>(
      'configureCall',
      <String, dynamic>{
        'isVideo': isVideo,
        'callKitManaged': callKitManaged,
        'speaker': speaker,
      },
    );
    return _toMap(response);
  }

  static Future<Map<String, dynamic>> setSpeaker(bool enabled) async {
    if (!Platform.isIOS) {
      return const <String, dynamic>{};
    }
    final dynamic response = await _channel.invokeMethod<dynamic>(
      'setSpeaker',
      <String, dynamic>{'enabled': enabled},
    );
    return _toMap(response);
  }

  static Future<Map<String, dynamic>> ensureCallAudio() async {
    if (!Platform.isIOS) {
      return const <String, dynamic>{};
    }
    final dynamic response = await _channel.invokeMethod<dynamic>(
      'ensureCallAudio',
    );
    return _toMap(response);
  }

  static Future<void> endCall() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('endCall');
    }
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}
