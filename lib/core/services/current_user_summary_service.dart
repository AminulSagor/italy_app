import 'package:dio/dio.dart';

import '../models/current_user_summary.dart';
import 'api_client.dart';

class CurrentUserSummaryService {
  CurrentUserSummaryService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CurrentUserSummary> getCurrentUser() async {
    final List<Response<dynamic>> responses =
        await Future.wait(<Future<Response<dynamic>>>[
      _apiClient.dio.get('/user-settings'),
      _apiClient.dio.get('/package-store/balances'),
    ]);

    final Map<String, dynamic> settings = _responseMap(responses[0]);
    final Map<String, dynamic> balances = _responseMap(responses[1]);
    final Map<String, dynamic> profile = _jsonMap(settings['profile']);
    final Map<String, dynamic> ai = _jsonMap(balances['ai']);

    return CurrentUserSummary.fromJson(<String, dynamic>{
      ...profile,
      'aiVoiceSeconds': _voiceSeconds(ai),
      'aiTextTokens': ai['textTokens'],
    });
  }

  Future<Map<String, int>> getAiBalances() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/package-store/balances',
    );
    final Map<String, dynamic> ai = _jsonMap(_responseMap(response)['ai']);
    return <String, int>{
      'voiceSeconds': _voiceSeconds(ai),
      'textTokens': _intValue(ai['textTokens']),
    };
  }

  int _voiceSeconds(Map<String, dynamic> ai) {
    final int exact = _intValue(ai['voiceSeconds']);
    if (exact > 0 || ai.containsKey('voiceSeconds')) return exact;
    final double minutes = double.tryParse(ai['voiceMinutes']?.toString() ?? '') ?? 0;
    return (minutes * 60).round();
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object.',
    );
  }

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }
}
