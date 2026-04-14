import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_bootstrap_controller.dart';

class AppBootstrapView extends GetView<AppBootstrapController> {
  const AppBootstrapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}