import 'dart:async';

import 'package:get/get.dart';

class OtpResendCooldown {
  OtpResendCooldown({this.cooldownSeconds = 180});

  final int cooldownSeconds;
  final RxInt remainingSeconds = 0.obs;

  DateTime? _availableAt;
  Timer? _timer;

  bool get isActive => remainingSeconds.value > 0;

  String get remainingLabel {
    final int safeSeconds = remainingSeconds.value
        .clamp(0, cooldownSeconds)
        .toInt();
    final int minutes = safeSeconds ~/ 60;
    final int seconds = safeSeconds % 60;
    final String secondText = seconds.toString().padLeft(2, '0');
    return '$minutes:$secondText';
  }

  void start() {
    restore(DateTime.now().add(Duration(seconds: cooldownSeconds)));
  }

  void restore(DateTime availableAt) {
    _availableAt = availableAt;
    _syncRemaining();
    _timer?.cancel();
    if (_availableAt == null) {
      return;
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncRemaining(),
    );
  }

  void refresh() {
    _syncRemaining();
  }

  void reset() {
    _availableAt = null;
    remainingSeconds.value = 0;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void _syncRemaining() {
    final DateTime? availableAt = _availableAt;
    if (availableAt == null) {
      remainingSeconds.value = 0;
      _timer?.cancel();
      _timer = null;
      return;
    }

    final int seconds = availableAt.difference(DateTime.now()).inSeconds;
    if (seconds <= 0) {
      remainingSeconds.value = 0;
      _availableAt = null;
      _timer?.cancel();
      _timer = null;
      return;
    }

    remainingSeconds.value = seconds;
  }
}
