import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiTutorTtsService {
  AiTutorTtsService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  static const int _maxChunkLength = 2200;

  final FlutterTts _flutterTts;
  bool _isInitialized = false;
  int _speechRequestId = 0;

  Future<void> speakItalian(String text) async {
    final String cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }

    await _initialize();
    await _flutterTts.stop();
    final int requestId = ++_speechRequestId;
    await _setItalianLanguage();

    for (final String chunk in _splitText(cleanText)) {
      if (requestId != _speechRequestId) {
        return;
      }
      final dynamic result = await _flutterTts.speak(chunk);
      if (result != 1) {
        throw StateError('Italian pronunciation could not be started.');
      }
    }
  }

  Future<void> stop() async {
    _speechRequestId += 1;
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

  List<String> _splitText(String text) {
    if (text.length <= _maxChunkLength) {
      return <String>[text];
    }

    final List<String> chunks = <String>[];
    final Iterable<RegExpMatch> matches =
        RegExp(r'[^.!?।]+[.!?।]*', multiLine: true).allMatches(text);
    final List<String> sentences = matches
        .map((RegExpMatch match) => match.group(0)?.trim() ?? '')
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    String current = '';
    for (final String sentence in sentences) {
      if (sentence.length > _maxChunkLength) {
        if (current.isNotEmpty) {
          chunks.add(current);
          current = '';
        }
        chunks.addAll(_splitLongSentence(sentence));
        continue;
      }

      final String candidate = current.isEmpty ? sentence : '$current $sentence';
      if (candidate.length <= _maxChunkLength) {
        current = candidate;
      } else {
        chunks.add(current);
        current = sentence;
      }
    }

    if (current.isNotEmpty) {
      chunks.add(current);
    }
    return chunks.isEmpty ? _splitLongSentence(text) : chunks;
  }

  List<String> _splitLongSentence(String sentence) {
    final List<String> chunks = <String>[];
    String current = '';
    for (final String word in sentence.split(RegExp(r'\s+'))) {
      if (word.isEmpty) {
        continue;
      }
      final String candidate = current.isEmpty ? word : '$current $word';
      if (candidate.length <= _maxChunkLength) {
        current = candidate;
      } else {
        if (current.isNotEmpty) {
          chunks.add(current);
        }
        current = word.length <= _maxChunkLength
            ? word
            : word.substring(0, _maxChunkLength);
      }
    }
    if (current.isNotEmpty) {
      chunks.add(current);
    }
    return chunks;
  }

  Future<void> dispose() async {
    await stop();
  }
}
