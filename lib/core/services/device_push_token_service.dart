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

  String get platformValue =>
      Platform.isIOS ? 'ios' : 'android';

  Future<String> getOrCreateDeviceId() async {
    final String existing =
        _storageService
            .readString(_deviceIdStorageKey)
            ?.trim() ??
            '';

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

  Future<void> registerCurrentDevice() async {
    _allowBackendSync = true;

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final String? token =
      await FirebaseMessaging.instance.getToken();

      if (token == null || token.trim().isEmpty) {
        return;
      }

      await _sendTokenToBackend(token.trim());
    } catch (error, stackTrace) {
      dev.log(
        'Failed to register FCM token',
        error: error,
        stackTrace: stackTrace,
        name: 'DevicePushTokenService',
      );
    }
  }

  void listenForTokenRefresh() {
    if (_refreshListenerStarted) {
      return;
    }

    _refreshListenerStarted = true;

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (String newToken) async {
        if (!_allowBackendSync ||
            !_storageService.isLoggedIn) {
          return;
        }

        try {
          await _sendTokenToBackend(newToken.trim());
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

  Future<void> _sendTokenToBackend(
      String fcmToken,
      ) async {
    if (fcmToken.isEmpty) {
      return;
    }

    final String deviceId =
    await getOrCreateDeviceId();

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