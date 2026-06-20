import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class TokenService extends GetxService {
  TokenService();

  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const Duration _expiryTolerance = Duration(seconds: 30);

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAccessToken(String token, {String tokenType = 'Bearer'}) async {
    final String normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return;
    }

    await _storage.write(key: _accessTokenKey, value: normalizedToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType.trim());
  }

  Future<String?> getAccessToken() async {
    final String? token = await _storage.read(key: _accessTokenKey);
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return token.trim();
  }

  Future<String> getTokenType() async {
    final String? tokenType = await _storage.read(key: _tokenTypeKey);
    if (tokenType == null || tokenType.trim().isEmpty) {
      return 'Bearer';
    }
    return tokenType.trim();
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenTypeKey);
  }

  Future<void> clearTokens() async {
    await deleteAccessToken();
  }

  Future<bool> hasToken() async {
    final String? token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasLocallyValidAccessToken() async {
    final String? token = await getAccessToken();
    if (token == null) {
      return false;
    }

    final DateTime? expiresAt = _readJwtExpiry(token);
    if (expiresAt == null) {
      return false;
    }

    return expiresAt.isAfter(DateTime.now().add(_expiryTolerance));
  }

  DateTime? _readJwtExpiry(String token) {
    try {
      final List<String> segments = token.split('.');
      if (segments.length != 3) {
        return null;
      }

      final String normalizedPayload = base64Url.normalize(segments[1]);
      final dynamic decoded = jsonDecode(
        utf8.decode(base64Url.decode(normalizedPayload)),
      );
      if (decoded is! Map) {
        return null;
      }

      final dynamic rawExpiry = decoded['exp'];
      final int? expirySeconds = rawExpiry is int
          ? rawExpiry
          : int.tryParse(rawExpiry?.toString() ?? '');
      if (expirySeconds == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        expirySeconds * 1000,
        isUtc: true,
      ).toLocal();
    } catch (_) {
      return null;
    }
  }
}
