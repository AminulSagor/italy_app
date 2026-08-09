import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import '../../../../../core/services/storage_service.dart';
import 'package:italir_pothe/core/utils/app_logger.dart';


class FullScreenCallPermissionService {
  FullScreenCallPermissionService({StorageService? storageService})
    : _storageService = storageService ?? Get.find<StorageService>();

  static const String _permissionExplanationShownKey =
      'full_screen_call_permission_explanation_shown';

  final StorageService _storageService;

  Future<void> requestWhenStartingFirstCall() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final bool alreadyAllowed =
          await FlutterCallkitIncoming.canUseFullScreenIntent();

      if (alreadyAllowed) {
        return;
      }

      final bool explanationAlreadyShown =
          _storageService.readString(_permissionExplanationShownKey) == 'true';

      if (explanationAlreadyShown) {
        return;
      }

      final bool shouldOpenSettings =
          await Get.dialog<bool>(
            AlertDialog(
              title: Text('full_screen_call_permission_title'.tr),
              content: Text('full_screen_call_permission_description'.tr),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Get.back<bool>(result: false),
                  child: Text('cancel'.tr),
                ),
                FilledButton(
                  onPressed: () => Get.back<bool>(result: true),
                  child: Text('continue'.tr),
                ),
              ],
            ),
            barrierDismissible: false,
          ) ??
          false;

      // Prevent repeatedly asking on every future call.
      await _storageService.writeString(_permissionExplanationShownKey, 'true');

      if (!shouldOpenSettings) {
        return;
      }

      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unable to request full-screen call permission',
        name: 'FullScreenCallPermissionService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
