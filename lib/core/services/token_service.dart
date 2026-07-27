import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class TokenService extends GetxService {
  TokenService();

  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const Duration _expiryTolerance = Duration(seconds: 30);

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  String? _accessToken;
  String _tokenType = 'Bearer';

  bool _isInitialized = false;
  Future<TokenService>? _initializationFuture;

  /// Called once during app startup.
  ///
  /// Reads secure storage once and keeps the values in memory.
  Future<TokenService> init() {
    return _initializationFuture ??= _loadFromStorage();
  }

  Future<TokenService> _loadFromStorage() async {
    final List<String?> storedValues = await Future.wait<String?>([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _tokenTypeKey),
    ]);

    final String? storedToken = storedValues[0];
    final String? storedTokenType = storedValues[1];

    final String normalizedToken = storedToken?.trim() ?? '';
    final String normalizedTokenType = storedTokenType?.trim() ?? '';

    _accessToken = normalizedToken.isEmpty ? null : normalizedToken;
    _tokenType =
    normalizedTokenType.isEmpty ? 'Bearer' : normalizedTokenType;

    _isInitialized = true;

    return this;
  }

  /// Synchronous in-memory access for ApiClient.
  String? get accessToken {
    final String token = _accessToken?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  /// Synchronous in-memory access for ApiClient.
  String get tokenType {
    final String type = _tokenType.trim();
    return type.isEmpty ? 'Bearer' : type;
  }

  /// Complete Authorization header from memory.
  String? get authorizationHeader {
    final String? token = accessToken;

    if (token == null) {
      return null;
    }

    return '$tokenType $token';
  }

  bool get isInitialized => _isInitialized;

  Future<void> saveAccessToken(
      String token, {
        String tokenType = 'Bearer',
      }) async {
    final String normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      return;
    }

    final String normalizedTokenType = tokenType.trim().isEmpty
        ? 'Bearer'
        : tokenType.trim();

    // Update memory immediately.
    _accessToken = normalizedToken;
    _tokenType = normalizedTokenType;
    _isInitialized = true;

    // Persist securely in parallel.
    await Future.wait<void>([
      _storage.write(
        key: _accessTokenKey,
        value: normalizedToken,
      ),
      _storage.write(
        key: _tokenTypeKey,
        value: normalizedTokenType,
      ),
    ]);
  }

  /// Existing code can keep using this method.
  ///
  /// After initialization, it returns the in-memory value.
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return accessToken;
  }

  /// Existing code can keep using this method.
  Future<String> getTokenType() async {
    await _ensureInitialized();
    return tokenType;
  }

  Future<void> deleteAccessToken() async {
    // Clear memory immediately.
    _accessToken = null;
    _tokenType = 'Bearer';
    _isInitialized = true;

    await Future.wait<void>([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _tokenTypeKey),
    ]);
  }

  Future<void> clearTokens() async {
    await deleteAccessToken();
  }

  Future<bool> hasToken() async {
    await _ensureInitialized();
    return accessToken != null;
  }

  Future<bool> hasLocallyValidAccessToken() async {
    await _ensureInitialized();

    final String? token = accessToken;

    if (token == null) {
      return false;
    }

    final DateTime? expiresAt = _readJwtExpiry(token);

    if (expiresAt == null) {
      return false;
    }

    return expiresAt.isAfter(
      DateTime.now().add(_expiryTolerance),
    );
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    await init();
  }

  DateTime? _readJwtExpiry(String token) {
    try {
      final List<String> segments = token.split('.');

      if (segments.length != 3) {
        return null;
      }

      final String normalizedPayload =
      base64Url.normalize(segments[1]);

      final dynamic decoded = jsonDecode(
        utf8.decode(
          base64Url.decode(normalizedPayload),
        ),
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