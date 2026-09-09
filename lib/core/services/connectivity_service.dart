import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService extends GetxService with WidgetsBindingObserver {
  static const Duration _offlineGracePeriod = Duration(milliseconds: 1500);
  static const Duration _offlineConfirmationDelay = Duration(milliseconds: 350);

  final InternetConnection _connection = InternetConnection();

  final RxBool isOnline = true.obs;
  final RxBool isChecking = false.obs;

  StreamSubscription<InternetStatus>? _subscription;
  Timer? _offlineTimer;
  int _statusRevision = 0;

  bool get isOffline => !isOnline.value;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    _subscription = _connection.onStatusChange.distinct().listen(
      _handleStatusChange,
    );

    await checkNow();
  }

  void _handleStatusChange(InternetStatus status) {
    if (status == InternetStatus.connected) {
      _statusRevision += 1;
      _offlineTimer?.cancel();
      isOnline.value = true;
      return;
    }

    _scheduleOfflineConfirmation();
  }

  Future<void> checkNow() async {
    if (isChecking.value) {
      return;
    }

    isChecking.value = true;
    _offlineTimer?.cancel();
    final int revision = ++_statusRevision;

    try {
      await _checkConnection(revision);
    } finally {
      isChecking.value = false;
    }
  }

  void _scheduleOfflineConfirmation() {
    _offlineTimer?.cancel();
    final int revision = ++_statusRevision;
    _offlineTimer = Timer(
      _offlineGracePeriod,
      () => unawaited(_checkConnection(revision)),
    );
  }

  Future<void> _checkConnection(int revision) async {
    final bool? firstCheck = await _hasInternetAccess();
    if (revision != _statusRevision || firstCheck == null) return;

    if (firstCheck) {
      _offlineTimer?.cancel();
      isOnline.value = true;
      return;
    }

    await Future<void>.delayed(_offlineConfirmationDelay);
    if (revision != _statusRevision) return;

    final bool? secondCheck = await _hasInternetAccess();
    if (revision != _statusRevision || secondCheck == null) return;

    isOnline.value = secondCheck;
  }

  Future<bool?> _hasInternetAccess() async {
    try {
      return await _connection.hasInternetAccess;
    } catch (_) {
      // A temporary checker failure is an unknown state, not proof that the
      // device is offline. Preserve the last confirmed connectivity state.
      return null;
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
    _offlineTimer?.cancel();

    final StreamSubscription<InternetStatus>? subscription = _subscription;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    super.onClose();
  }
}
