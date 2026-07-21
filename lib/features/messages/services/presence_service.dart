import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/token_service.dart';
import '../models/presence_model.dart';
import 'chat_socket_service.dart';

class PresenceService extends GetxService with WidgetsBindingObserver {
  PresenceService();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final RxMap<String, MessagePresenceModel> presenceMap =
      <String, MessagePresenceModel>{}.obs;

  String _deviceId = '';

  String get deviceId => _deviceId;

  @override
  void onInit() {
    super.onInit();
    _initDeviceId();
    WidgetsBinding.instance.addObserver(this);

    // Ensure we attach the presence listener even if the socket service
    // isn't registered yet (race at startup). Retry briefly if needed.
    _attachPresenceListenerWhenAvailable();
  }

  /// Try to attach `updatePresenceFromSocket` to the global
  /// `ChatSocketService` when it becomes available. This handles the
  /// startup ordering race where PresenceService may be created before
  /// ChatSocketService is registered.
  void _attachPresenceListenerWhenAvailable() async {
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        Get.find<ChatSocketService>().addPresenceListener(
          updatePresenceFromSocket,
        );
        return;
      }
    } catch (_) {}

    // Retry for up to ~500ms (10 * 50ms) to give bootstrap routines a chance
    // to register the socket service.
    for (int i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          Get.find<ChatSocketService>().addPresenceListener(
            updatePresenceFromSocket,
          );
          return;
        }
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_connectIfAuthenticated());
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (Get.isRegistered<ChatSocketService>()) {
        unawaited(
          Get.find<ChatSocketService>().disconnect(),
        );
      }
    }
  }

  Future<void> _connectIfAuthenticated() async {
    if (!Get.isRegistered<TokenService>() ||
        !Get.isRegistered<ChatSocketService>()) {
      return;
    }

    final bool hasToken =
    await Get.find<TokenService>().hasToken();

    if (!hasToken) {
      return;
    }

    if (_deviceId.isEmpty) {
      await _initDeviceId();
    }

    await Get.find<ChatSocketService>().connect(
      deviceId: _deviceId,
    );
  }

  Future<void> clearForLogout() async {
    presenceMap.clear();

    if (Get.isRegistered<ChatSocketService>()) {
      await Get.find<ChatSocketService>().disconnect();
    }
  }

  Future<void> _initDeviceId() async {
    const String key = 'presence_device_id';
    String? id = await _storage.read(key: key);
    if (id == null || id.isEmpty) {
      id =
          'dev_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond)}';
      await _storage.write(key: key, value: id);
    }
    _deviceId = id;
  }

  /// Poll batch status for given user IDs.
  /// Note: HTTP presence endpoints removed; if the backend supports a
  /// socket-based batch request, `ChatSocketService.requestPresenceBatch`
  /// will be used. Otherwise this is a no-op and presence updates arrive
  /// via socket `user_presence_change` / `presence:update` events.
  Future<void> fetchBatchStatus(List<String> userIds) async {
    if (userIds.isEmpty) return;
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        try {
          Get.find<ChatSocketService>().requestPresenceBatch(userIds);
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Update a single presence entry (e.g. from a socket event)
  void updatePresenceFromSocket(Map<String, dynamic> data) {
    try {
      final MessagePresenceModel p = MessagePresenceModel.fromJson(data);
      if (p.userId.isNotEmpty) {
        presenceMap[p.userId] = p;
      }
    } catch (_) {}
  }
}
