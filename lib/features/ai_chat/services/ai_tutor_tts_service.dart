import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiTutorTtsService {
  AiTutorTtsService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> speakItalian(String text) async {
    final String cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }

    await _initialize();
    await _flutterTts.stop();
    await _setItalianLanguage();

    final dynamic result = await _flutterTts.speak(cleanText);
    if (result != 1) {
      throw StateError('Italian pronunciation could not be started.');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> _initialize() async {
    if (_isInitialized) {
      return;
    }

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _setItalianLanguage();
    _isInitialized = true;
  }

  Future<void> _setItalianLanguage() async {
    const String locale = 'it-IT';

    try {
      final dynamic isAvailable = await _flutterTts.isLanguageAvailable(locale);
      final bool available = isAvailable == true || isAvailable == 1;
      if (!available) {
        throw StateError('Italian TTS language is not installed.');
      }
      await _flutterTts.setLanguage(locale);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        dev.log(
          'Unable to configure the Italian TTS voice.',
          name: 'AiTutorTtsService',
          error: error,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
