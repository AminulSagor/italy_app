import 'dart:async';

class MessageCallDurationTracker {
  Timer? _timer;
  DateTime? _startedAt;

  void start(void Function(String value) onTick) {
    if (_timer != null) {
      return;
    }

    _startedAt = DateTime.now();
    onTick('00:00');

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime? startedAt = _startedAt;
      if (startedAt == null) {
        return;
      }

      final Duration duration = DateTime.now().difference(startedAt);
      final String hours = duration.inHours.toString().padLeft(2, '0');
      final String minutes = duration.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      final String seconds = duration.inSeconds
          .remainder(60)
          .toString()
          .padLeft(2, '0');

      onTick(
        duration.inHours > 0
            ? '$hours:$minutes:$seconds'
            : '$minutes:$seconds',
      );
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
  }
}
