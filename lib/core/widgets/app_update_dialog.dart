import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/app_update_configuration.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    required this.configuration,
    required this.requiredUpdate,
    required this.onUpdate,
    super.key,
  });

  final AppUpdateConfiguration configuration;
  final bool requiredUpdate;
  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !requiredUpdate,
      child: AlertDialog(
        title: Text(configuration.title),
        content: Text(configuration.message),
        actions: <Widget>[
          if (!requiredUpdate)
            TextButton(onPressed: Get.back<void>, child: const Text('Later')),
          FilledButton(onPressed: onUpdate, child: const Text('Update Now')),
        ],
      ),
    );
  }
}
