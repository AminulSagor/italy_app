import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
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
  bool _voipTokenListenerStarted = false;

  String get platformValue => Platform.isIOS ? 'ios' : 'android';

  Future<String> getOrCreateDeviceId() async {
    final String existing =
        _storageService.readString(_deviceIdStorageKey)?.trim() ?? '';

    if (existing.isNotEmpty) {
      return existing;
    }

    final String newDeviceId = const Uuid().v4();

    await _storageService.writeString(_deviceIdStorageKey, newDeviceId);

    return newDeviceId;
  }

  /// Silently registers Android after notification permission is granted.
  /// iOS always registers its PushKit token because CallKit is independent of
  /// alert-notification permission.
  ///
  /// This method never opens the notification permission popup.
  Future<void> registerCurrentDevice() async {
    try {
      if (Platform.isIOS) {
        // PushKit/CallKit does not depend on alert-notification permission.
        // Also register the FCM token when APNs has made it available so
        // silent call-cancellation updates can reconcile an existing CallKit
        // screen without displaying a notification.
        _allowBackendSync = true;
        await _registerCurrentTokens();
        return;
      }

      final NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (!_isAuthorized(settings.authorizationStatus)) {
        _allowBackendSync = false;
        return;
      }

      _allowBackendSync = true;

      await _registerCurrentTokens();
    } catch (_) {}
  }

  /// Call this only after showing your own explanation and after
  /// the user presses the Enable Notifications button.
  Future<AuthorizationStatus>
  requestPermissionAndRegisterCurrentDevice() async {
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      if (!_isAuthorized(settings.authorizationStatus)) {
        _allowBackendSync = Platform.isIOS;
        return settings.authorizationStatus;
      }

      _allowBackendSync = true;

      await _registerCurrentTokens();

      return settings.authorizationStatus;
    } catch (_) {
      _allowBackendSync = Platform.isIOS;
      return AuthorizationStatus.denied;
    }
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      return _isAuthorized(settings.authorizationStatus);
    } catch (_) {
      return false;
    }
  }

  void listenForTokenRefresh() {
    if (_refreshListenerStarted) {
      return;
    }

    _refreshListenerStarted = true;

    _listenForVoipTokenRefresh();

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if (!_allowBackendSync || !_storageService.isLoggedIn) {
        return;
      }

      final String token = newToken.trim();

      if (token.isEmpty) {
        return;
      }

      try {
        await _sendTokensToBackend(fcmToken: token);
      } catch (_) {}
    });
  }

  void _listenForVoipTokenRefresh() {
    if (!Platform.isIOS || _voipTokenListenerStarted) {
      return;
    }

    _voipTokenListenerStarted = true;

    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event is! CallEventActionDidUpdateDevicePushTokenVoip ||
          !_storageService.isLoggedIn) {
        return;
      }

      try {
        final String voipToken =
            (await FlutterCallkitIncoming.getDevicePushTokenVoIP())?.trim() ??
            '';

        if (voipToken.isEmpty) {
          return;
        }

        _allowBackendSync = true;
        await _sendTokensToBackend(voipToken: voipToken);
      } catch (_) {}
    });
  }

  void disableBackendSync() {
    _allowBackendSync = false;
  }

  Future<void> deleteLocalFcmToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  Future<void> _registerCurrentTokens({bool includeFcmToken = true}) async {
    final String fcmToken = includeFcmToken
        ? await _getFcmTokenWhenReady()
        : '';
    final String voipToken = Platform.isIOS
        ? (await FlutterCallkitIncoming.getDevicePushTokenVoIP())?.trim() ?? ''
        : '';

    if (fcmToken.isEmpty && voipToken.isEmpty) {
      return;
    }

    await _sendTokensToBackend(
      fcmToken: fcmToken.isEmpty ? null : fcmToken,
      voipToken: voipToken.isEmpty ? null : voipToken,
    );
  }

  Future<String> _getFcmTokenWhenReady() async {
    if (Platform.isIOS) {
      // Firebase requires an APNs token before its iOS FCM token APIs are
      // called. APNs registration can complete shortly after app startup, so
      // wait for that native token instead of racing getToken().
      for (int attempt = 0; attempt < 20; attempt++) {
        final String apnsToken =
            (await FirebaseMessaging.instance.getAPNSToken())?.trim() ?? '';
        if (apnsToken.isNotEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }

      final String apnsToken =
          (await FirebaseMessaging.instance.getAPNSToken())?.trim() ?? '';
      if (apnsToken.isEmpty) {
        return '';
      }
    }

    return (await FirebaseMessaging.instance.getToken())?.trim() ?? '';
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _sendTokensToBackend({
    String? fcmToken,
    String? voipToken,
  }) async {
    final String normalizedFcmToken = fcmToken?.trim() ?? '';
    final String normalizedVoipToken = voipToken?.trim() ?? '';

    if (normalizedFcmToken.isEmpty && normalizedVoipToken.isEmpty) {
      return;
    }

    final String deviceId = await getOrCreateDeviceId();

    await _apiClient.dio.post<dynamic>(
      _registerEndpoint,
      data: <String, dynamic>{
        'deviceId': deviceId,
        'platform': platformValue,
        'appState': 'foreground',
        if (normalizedFcmToken.isNotEmpty) 'fcmToken': normalizedFcmToken,
        if (normalizedVoipToken.isNotEmpty) 'voipToken': normalizedVoipToken,
      },
    );
  }
}
