import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/services/ai_data_consent_service.dart';

class _ConsentAdapter implements HttpClientAdapter {
  _ConsentAdapter(this.payload);

  Map<String, dynamic> payload;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'publishes current account consent state to active AI features',
    () async {
      final _ConsentAdapter adapter = _ConsentAdapter(<String, dynamic>{
        'granted': true,
        'version': AiDataConsentService.currentVersion,
      });
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final AiDataConsentService service = AiDataConsentService.withDio(dio);
      final List<bool> states = <bool>[];
      service.addStateHandler((bool granted) async => states.add(granted));

      expect(await service.hasCurrentConsent(), isTrue);

      adapter.payload = <String, dynamic>{
        'granted': false,
        'version': AiDataConsentService.currentVersion,
      };
      expect(await service.hasCurrentConsent(), isFalse);
      expect(states, <bool>[true, false]);
    },
  );
}
