import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';

class AiTutorLevelTestRecordingService {
  AiTutorLevelTestRecordingService() {
    recorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  final RecorderController recorderController = RecorderController();
  String? _activePath;
  bool _isRecording = false;

  Future<String?> start() async {
    final bool hasPermission = await recorderController.checkPermission();
    if (!hasPermission) {
      return null;
    }

    await cancel();
    final String path =
        '${Directory.systemTemp.path}/ai_tutor_level_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _activePath = path;
    try {
      await recorderController.record(path: path);
      _isRecording = true;
      return path;
    } catch (_) {
      _activePath = null;
      await deleteFile(path);
      rethrow;
    }
  }

  Future<String?> stop() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final String? stoppedPath = await recorderController.stop();
      return stoppedPath?.trim().isNotEmpty == true
          ? stoppedPath
          : _activePath;
    } finally {
      _isRecording = false;
      _activePath = null;
    }
  }

  Future<void> cancel() async {
    final String? path = _activePath;
    try {
      if (_isRecording) {
        await recorderController.stop();
      }
    } catch (_) {
      // Best-effort cleanup when the platform recorder has already stopped.
    } finally {
      _isRecording = false;
      _activePath = null;
    }
    await deleteFile(path);
  }

  Future<void> deleteFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }
    try {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Temporary recording cleanup must not block the test flow.
    }
  }

  void dispose() {
    recorderController.dispose();
  }
}
