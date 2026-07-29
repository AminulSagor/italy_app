import 'package:proximity_screen_lock/proximity_screen_lock.dart';

class CallProximityService {
  bool _isEnabled = false;

  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;

    try {
      final bool isSupported =
      await ProximityScreenLock.isProximityLockSupported();

      if (!isSupported) return;

      await ProximityScreenLock.setActive(enabled);
      _isEnabled = enabled;
    } catch (_) {
      // Some devices may not have a usable proximity sensor.
    }
  }

  Future<void> disable() async {
    await setEnabled(false);
  }
}