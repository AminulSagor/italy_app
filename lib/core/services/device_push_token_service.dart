import 'dart:developer' as dev;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'storage_service.dart';

class DevicePushTokenService {
  DevicePushTokenService({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient,
        _storageService = storageService;

  final ApiClient _apiClient;
  final StorageService _storageService;

  static const String _deviceIdStorageKey = 'device_id';
  static const String _registerEndpoint = '/devices/register';

  bool _allowBackendSync = false;
  bool _refreshListenerStarted = false;

  String get platformValue => Platform.isIOS ? 'ios' : 'android';

  Future<String> getOrCreateDeviceId() async {
    final String existing =
        _storageService.readString(_deviceIdStorageKey)?.trim() ?? '';

    if (existing.isNotEmpty) {
      return existing;
    }

    final String newDeviceId = const Uuid().v4();

    await _storageService.writeString(
      _deviceIdStorageKey,
      newDeviceId,
    );

    return newDeviceId;
  }

  /// Silently registers the device only when notification permission
  /// has already been granted.
  ///
  /// This method never opens the notification permission popup.
  Future<void> registerCurrentDevice() async {
    try {
      final NotificationSettings settings =
      await FirebaseMessaging.instance.getNotificationSettings();

      if (!_isAuthorized(settings.authorizationStatus)) {
        _allowBackendSync = false;
        return;
      }

      _allowBackendSync = true;

      await _registerCurrentToken();
    } catch (error, stackTrace) {
      dev.log(
        'Failed to register FCM token',
        error: error,
        stackTrace: stackTrace,
        name: 'DevicePushTokenService',
      );
    }
  }

  /// Call this only after showing your own explanation and after
  /// the user presses the Enable Notifications button.
  Future<AuthorizationStatus>
  requestPermissionAndRegisterCurrentDevice() async {
    try {
      final NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!_isAuthorized(settings.authorizationStatus)) {
        _allowBackendSync = false;
        return settings.authorizationStatus;
      }

      _allowBackendSync = true;

      await _registerCurrentToken();

      return settings.authorizationStatus;
    } catch (error, stackTrace) {
      _allowBackendSync = false;

      dev.log(
        'Failed to request notification permission',
        error: error,
        stackTrace: stackTrace,
        name: 'DevicePushTokenService',
      );

      return AuthorizationStatus.denied;
    }
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final NotificationSettings settings =
      await FirebaseMessaging.instance.getNotificationSettings();

      return _isAuthorized(settings.authorizationStatus);
    } catch (error, stackTrace) {
      dev.log(
        'Failed to read notification permission',
        error: error,
        stackTrace: stackTrace,
        name: 'DevicePushTokenService',
      );

      return false;
    }
  }

  void listenForTokenRefresh() {
    if (_refreshListenerStarted) {
      return;
    }

    _refreshListenerStarted = true;

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (String newToken) async {
        if (!_allowBackendSync || !_storageService.isLoggedIn) {
          return;
        }

        final String token = newToken.trim();

        if (token.isEmpty) {
          return;
        }

        try {
          await _sendTokenToBackend(token);
        } catch (error, stackTrace) {
          dev.log(
            'Failed to update refreshed FCM token',
            error: error,
            stackTrace: stackTrace,
            name: 'DevicePushTokenService',
          );
        }
      },
    );
  }

  void disableBackendSync() {
    _allowBackendSync = false;
  }

  Future<void> deleteLocalFcmToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (error, stackTrace) {
      dev.log(
        'Failed to delete local FCM token',
        error: error,
        stackTrace: stackTrace,
        name: 'DevicePushTokenService',
      );
    }
  }

  Future<void> _registerCurrentToken() async {
    final String? rawToken =
    await FirebaseMessaging.instance.getToken();

    final String token = rawToken?.trim() ?? '';

    if (token.isEmpty) {
      return;
    }

    await _sendTokenToBackend(token);
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _sendTokenToBackend(String fcmToken) async {
    if (fcmToken.isEmpty) {
      return;
    }

    final String deviceId = await getOrCreateDeviceId();

    await _apiClient.dio.post(
      _registerEndpoint,
      data: <String, dynamic>{
        'deviceId': deviceId,
        'platform': platformValue,
        'appState': 'foreground',
        'fcmToken': fcmToken,
      },
    );
  }
}