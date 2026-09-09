import 'dart:async';

import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../utils/app_logger.dart';

/// Keeps the display awake only while the attached video is actively playing.
class VideoPlaybackWakelock {
  VideoPlayerController? _controller;
  bool _isEnabled = false;

  void attach(VideoPlayerController controller) {
    if (identical(_controller, controller)) {
      _syncWithPlayback();
      return;
    }

    _controller?.removeListener(_syncWithPlayback);
    _controller = controller;
    controller.addListener(_syncWithPlayback);
    _syncWithPlayback();
  }

  void detach() {
    _controller?.removeListener(_syncWithPlayback);
    _controller = null;
    _setEnabled(false);
  }

  void dispose() {
    detach();
  }

  void _syncWithPlayback() {
    final VideoPlayerController? controller = _controller;
    final bool shouldStayAwake =
        controller != null &&
        controller.value.isInitialized &&
        controller.value.isPlaying;
    _setEnabled(shouldStayAwake);
  }

  void _setEnabled(bool enabled) {
    if (_isEnabled == enabled) {
      return;
    }

    _isEnabled = enabled;
    unawaited(_apply(enabled));
  }

  Future<void> _apply(bool enabled) async {
    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unable to update video playback wakelock',
        name: 'VideoPlayback',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
