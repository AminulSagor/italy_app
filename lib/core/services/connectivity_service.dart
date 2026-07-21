import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService extends GetxService
    with WidgetsBindingObserver {
  final InternetConnection _connection = InternetConnection();

  final RxBool isOnline = true.obs;
  final RxBool isChecking = false.obs;

  StreamSubscription<InternetStatus>? _subscription;

  bool get isOffline => !isOnline.value;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    _subscription = _connection.onStatusChange
        .distinct()
        .listen(_handleStatusChange);

    await checkNow();
  }

  void _handleStatusChange(InternetStatus status) {
    isOnline.value = status == InternetStatus.connected;
  }

  Future<void> checkNow() async {
    if (isChecking.value) {
      return;
    }

    isChecking.value = true;

    try {
      isOnline.value = await _connection.hasInternetAccess;
    } catch (_) {
      isOnline.value = false;
    } finally {
      isChecking.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(checkNow());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    final StreamSubscription<InternetStatus>? subscription =
        _subscription;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    super.onClose();
  }
}