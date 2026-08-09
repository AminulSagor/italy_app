import 'package:italir_pothe/core/utils/app_logger.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'device_push_token_service.dart';
import 'storage_service.dart';

class NotificationPermissionService {
  NotificationPermissionService({
    StorageService? storageService,
    DevicePushTokenService? devicePushTokenService,
  }) : _storageService = storageService ?? Get.find<StorageService>(),
       _devicePushTokenService =
           devicePushTokenService ?? Get.find<DevicePushTokenService>();

  static const String _permissionPromptHandledKey =
      'notification_permission_prompt_handled';

  final StorageService _storageService;
  final DevicePushTokenService _devicePushTokenService;

  bool _requestInProgress = false;

  Future<void> requestAfterHomeShown() async {
    if ((!Platform.isAndroid && !Platform.isIOS) || _requestInProgress) {
      return;
    }

    _requestInProgress = true;

    try {
      // Let the Home screen appear before showing the explanation.
      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (!_storageService.isLoggedIn) {
        return;
      }

      // Permission already exists, so silently register the FCM token.
      if (await _devicePushTokenService.hasNotificationPermission()) {
        await _devicePushTokenService.registerCurrentDevice();
        return;
      }

      final bool promptAlreadyHandled =
          _storageService.readString(_permissionPromptHandledKey) == 'true';

      if (promptAlreadyHandled || Get.context == null) {
        return;
      }

      final bool shouldEnableNotifications =
          await Get.dialog<bool>(
            AlertDialog(
              title: Text('notification_permission_title'.tr),
              content: Text('notification_permission_description'.tr),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.back<bool>(result: false);
                  },
                  child: Text('notification_permission_not_now'.tr),
                ),
                FilledButton(
                  onPressed: () {
                    Get.back<bool>(result: true);
                  },
                  child: Text('notification_permission_enable'.tr),
                ),
              ],
            ),
            barrierDismissible: false,
          ) ??
          false;

      // Prevent this explanation from interrupting the user repeatedly.
      await _storageService.writeString(_permissionPromptHandledKey, 'true');

      if (!shouldEnableNotifications) {
        return;
      }

      // The OS permission popup appears only after the user presses Enable.
      await _devicePushTokenService.requestPermissionAndRegisterCurrentDevice();
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unable to complete notification permission flow',
        error: error,
        stackTrace: stackTrace,
        name: 'NotificationPermissionService',
      );
    } finally {
      _requestInProgress = false;
    }
  }
}
