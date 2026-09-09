import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:italir_pothe/core/utils/app_logger.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/important_verb_models.dart';

class ItalianTtsUnavailableException implements Exception {
  const ItalianTtsUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ItalianTtsService {
  ItalianTtsService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  bool _isInitialized = false;

  // Existing Important Verbs functionality.
  Future<bool> speak(ImportantVerbTtsModel tts) async {
    return speakText(tts.text, locale: tts.locale);
  }

  Future<bool> speakText(String text, {String locale = 'it-IT'}) async {
    final String normalizedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedText.isEmpty) {
      return false;
    }

    try {
      await _initialize(locale);
      await _flutterTts.stop();
      await _setItalianLanguage(locale);
      final dynamic result = await _flutterTts.speak(normalizedText);
      if (result == 1) return true;

      await _reportHandledFailure(
        const ItalianTtsUnavailableException(
          'The Android TTS engine refused to start speech.',
        ),
        StackTrace.current,
      );
      return false;
    } catch (error, stackTrace) {
      _isInitialized = false;
      await _reportHandledFailure(error, stackTrace);
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (error, stackTrace) {
      await _reportHandledFailure(error, stackTrace);
    }
  }

  Future<void> _initialize(String requestedLocale) async {
    if (_isInitialized) {
      return;
    }

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
      final dynamic availability = await _flutterTts.isLanguageAvailable(
        locale,
      );

      final bool isAvailable = availability == true || availability == 1;

      await _flutterTts.setLanguage(isAvailable ? locale : 'it-IT');
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unable to verify Italian TTS locale. '
        'Falling back to it-IT.',
        name: 'ItalianTtsService',
        error: error,
        stackTrace: stackTrace,
      );

      await _flutterTts.setLanguage('it-IT');
    }
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> _reportHandledFailure(
    Object error,
    StackTrace stackTrace,
  ) async {
    AppLogger.log(
      'Italian pronunciation was unavailable.',
      name: 'ItalianTtsService',
      error: error,
      stackTrace: stackTrace,
    );
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Handled Italian TTS failure',
        fatal: false,
      );
    } catch (_) {
      // Diagnostics must never make TTS failure fatal.
    }
  }
}
