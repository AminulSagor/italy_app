import 'dart:convert';

import '../../../core/services/storage_service.dart';

class HomeDashboardCacheEntry {
  const HomeDashboardCacheEntry({
    required this.json,
    required this.cachedAt,
  });

  final Map<String, dynamic> json;
  final DateTime cachedAt;
}

class HomeDashboardCacheService {
  HomeDashboardCacheService({
    required StorageService storageService,
  }) : _storageService = storageService;

  static const String _keyPrefix =
      'home_dashboard_cache_v1';

  static const Duration _maximumAge =
  Duration(days: 1);

  final StorageService _storageService;

  Future<HomeDashboardCacheEntry?> read({
    required String userId,
  }) async {
    final String normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return null;
    }

    final String key = _cacheKey(normalizedUserId);
    final String? storedValue =
    _storageService.readString(key);

    if (storedValue == null || storedValue.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(storedValue);

      if (decoded is! Map) {
        await _storageService.remove(key);
        return null;
      }

      final Map<String, dynamic> root =
      Map<String, dynamic>.from(decoded);

      final DateTime? cachedAt = DateTime.tryParse(
        root['cachedAt']?.toString() ?? '',
      );

      if (cachedAt == null ||
          DateTime.now().difference(cachedAt) >
              _maximumAge) {
        await _storageService.remove(key);
        return null;
      }

      final dynamic dashboardValue = root['dashboard'];

      if (dashboardValue is! Map) {
        await _storageService.remove(key);
        return null;
      }

      return HomeDashboardCacheEntry(
        json: Map<String, dynamic>.from(
          dashboardValue,
        ),
        cachedAt: cachedAt,
      );
    } catch (_) {
      await _storageService.remove(key);
      return null;
    }
  }

  Future<void> write({
    required String userId,
    required Map<String, dynamic> json,
  }) async {
    final String normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return;
    }

    final Map<String, dynamic> payload =
    <String, dynamic>{
      'cachedAt': DateTime.now().toIso8601String(),
      'dashboard': json,
    };

    await _storageService.writeString(
      _cacheKey(normalizedUserId),
      jsonEncode(payload),
    );
  }

  Future<void> clear({
    required String userId,
  }) async {
    final String normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return;
    }

    await _storageService.remove(
      _cacheKey(normalizedUserId),
    );
  }

  String _cacheKey(String userId) {
    final String safeUserId = base64Url.encode(
      utf8.encode(userId),
    );

    return '$_keyPrefix.$safeUserId';
  }
}