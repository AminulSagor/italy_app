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
  })  : _apiClient = apiClient,
        _storageService = storageService;

  final ApiClient _apiClient;
  final StorageService _storageService;

  static const String _deviceIdStorageKey = 'device_id';
  static const String _registerEndpoint = '/chat/devices/register';

  Future<void> registerCurrentDevice() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        dev.log(
          'FCM token is empty. Device registration skipped.',
          name: 'DevicePushTokenService',
        );
        return;
      }

      await _sendTokenToBackend(fcmToken);
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
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      try {
        await _sendTokenToBackend(newToken);
      } catch (error, stackTrace) {
        dev.log(
          'Failed to update refreshed FCM token',
          error: error,
          stackTrace: stackTrace,
          name: 'DevicePushTokenService',
        );
      }
    });
  }

  Future<void> _sendTokenToBackend(String fcmToken) async {
    final String deviceId = await _getOrCreateDeviceId();

    await _apiClient.dio.post(
      _registerEndpoint,
      data: <String, dynamic>{
        'deviceId': deviceId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'appState': 'foreground',
        'fcmToken': fcmToken,
      },
    );
  }

  Future<String> _getOrCreateDeviceId() async {
    final String? existingDeviceId =
    _storageService.readString(_deviceIdStorageKey);

    if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
      return existingDeviceId;
    }

    final String newDeviceId = const Uuid().v4();
    await _storageService.writeString(_deviceIdStorageKey, newDeviceId);
    return newDeviceId;
  }
}