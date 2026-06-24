import 'dart:developer' as dev;

import 'package:flutter_tts/flutter_tts.dart';

import '../models/important_verb_models.dart';

class ItalianTtsService {
  ItalianTtsService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> speak(ImportantVerbTtsModel tts) async {
    final String text = tts.text.trim();
    if (text.isEmpty) return;

    await _initialize(tts.locale);
    await _flutterTts.stop();
    await _setItalianLanguage(tts.locale);
    final dynamic result = await _flutterTts.speak(text);
    if (result != 1) {
      throw StateError('Italian pronunciation could not be started.');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> _initialize(String requestedLocale) async {
    if (_isInitialized) return;

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _setItalianLanguage(requestedLocale);
    _isInitialized = true;
  }

  Future<void> _setItalianLanguage(String requestedLocale) async {
    final String locale = requestedLocale.trim().isEmpty
        ? 'it-IT'
        : requestedLocale.trim();

    try {
      final dynamic isAvailable = await _flutterTts.isLanguageAvailable(locale);
      final bool available = isAvailable == true || isAvailable == 1;
      await _flutterTts.setLanguage(available ? locale : 'it-IT');
    } catch (error, stackTrace) {
      dev.log(
        'Unable to verify Italian TTS locale. Falling back to it-IT.',
        name: 'ItalianTtsService',
        error: error,
        stackTrace: stackTrace,
      );
      await _flutterTts.setLanguage('it-IT');
    }
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
