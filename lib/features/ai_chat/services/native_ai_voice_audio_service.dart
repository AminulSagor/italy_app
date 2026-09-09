import 'dart:async';

import 'package:flutter/services.dart';

class NativeAiVoiceAudioService {
  static const MethodChannel _methodChannel = MethodChannel(
    'italir_pothe/ai_voice_audio',
  );
  static const EventChannel _eventChannel = EventChannel(
    'italir_pothe/ai_voice_audio_events',
  );

  StreamSubscription<dynamic>? _eventSubscription;

  Future<void> start({
    required void Function(Uint8List audio) onMicrophoneAudio,
    required void Function() onPlaybackStarted,
    required void Function() onPlaybackEnded,
    required void Function(String message) onError,
  }) async {
    await stop();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((
      dynamic event,
    ) {
      if (event is! Map) return;
      final String type = event['type']?.toString() ?? '';
      switch (type) {
        case 'microphone':
          final dynamic data = event['data'];
          if (data is Uint8List && data.isNotEmpty) {
            onMicrophoneAudio(data);
          }
          break;
        case 'playback_started':
          onPlaybackStarted();
          break;
        case 'playback_ended':
          onPlaybackEnded();
          break;
        case 'error':
          onError(event['message']?.toString() ?? 'Native audio error');
          break;
      }
    }, onError: (Object error) => onError(error.toString()));
    await _methodChannel.invokeMethod<void>('start', <String, dynamic>{
      'inputSampleRate': 16000,
      'outputSampleRate': 24000,
      'inputChunkMs': 40,
      'initialPlaybackBufferMs': 300,
      'maxPlaybackBufferMs': 600,
    });
  }

  Future<void> enqueuePlayback(Uint8List audio) async {
    if (audio.isEmpty) return;
    await _methodChannel.invokeMethod<void>('enqueuePlayback', audio);
  }

  Future<void> finishPlaybackTurn() {
    return _methodChannel.invokeMethod<void>('finishPlaybackTurn');
  }

  Future<void> interruptPlayback() {
    return _methodChannel.invokeMethod<void>('interruptPlayback');
  }

  Future<void> setMuted(bool muted) {
    return _methodChannel.invokeMethod<void>('setMuted', muted);
  }

  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // The native engine has not been registered on unsupported platforms.
    }
    await _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
