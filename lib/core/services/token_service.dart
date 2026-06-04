import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class TokenService extends GetxService {
  TokenService();

  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';

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
    return token;
  }

  Future<String> getTokenType() async {
    final String? tokenType = await _storage.read(key: _tokenTypeKey);
    if (tokenType == null || tokenType.trim().isEmpty) {
      return 'Bearer';
    }
    return tokenType;
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
}
