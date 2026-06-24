import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class FinalExamMediaCoordinator {
  final RxBool isAudioPlaying = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool hasRecording = false.obs;
  final RxBool isRecordedAudioPlaying = false.obs;
  final RxInt recordedSeconds = 0.obs;
  final RxString recordedAudioPath = ''.obs;

  final PlayerController listeningWaveController = PlayerController();
  final RecorderController speakingRecorderController = RecorderController();
  PlayerController recordedWaveController = PlayerController();

  Timer? _recordTimer;
  StreamSubscription<PlayerState>? _listeningPlayerSub;
  StreamSubscription<PlayerState>? _recordedPlayerSub;
  bool _isListeningAudioPrepared = false;
  bool _isRecordedAudioPrepared = false;
  bool _isPreparingListeningAudio = false;
  String _preparedListeningUrl = '';

  void initialize() {
    speakingRecorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    _listeningPlayerSub = listeningWaveController.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      isAudioPlaying.value = state == PlayerState.playing;
    });
    _bindRecordedPlayerState();
  }

  void dispose() {
    _recordTimer?.cancel();
    _listeningPlayerSub?.cancel();
    _recordedPlayerSub?.cancel();
    speakingRecorderController.dispose();
    listeningWaveController.dispose();
    recordedWaveController.dispose();
  }

  Future<void> toggleListeningAudio(String url) async {
    if (isAudioPlaying.value) {
      await pauseListeningAudio();
      return;
    }
    await prepareListeningAudio(url);
    if (!_isListeningAudioPrepared) return;
    try {
      await listeningWaveController.startPlayer();
    } catch (_) {
      isAudioPlaying.value = false;
    }
  }

  Future<void> pauseListeningAudio() async {
    try {
      await listeningWaveController.pausePlayer();
    } catch (_) {
      isAudioPlaying.value = false;
    }
  }

  Future<void> stopListeningAudio({required bool reset}) async {
    try {
      await listeningWaveController.stopPlayer();
      if (reset) {
        _isListeningAudioPrepared = false;
        _preparedListeningUrl = '';
      }
    } catch (_) {
      isAudioPlaying.value = false;
    }
  }

  Future<void> prepareListeningAudio(String url) async {
    if (url.isEmpty || _isPreparingListeningAudio) return;
    if (_isListeningAudioPrepared && _preparedListeningUrl == url) return;

    _isPreparingListeningAudio = true;
    try {
      final dio.Response<List<int>> response = await dio.Dio().get<List<int>>(
        url,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );
      final List<int> bytes = response.data ?? <int>[];
      if (bytes.isEmpty) return;

      final File file = File(
        '${Directory.systemTemp.path}/final_exam_listening_${DateTime.now().millisecondsSinceEpoch}.audio',
      );
      await file.writeAsBytes(bytes, flush: true);
      await listeningWaveController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
        noOfSamples: 80,
      );
      _preparedListeningUrl = url;
      _isListeningAudioPrepared = true;
    } finally {
      _isPreparingListeningAudio = false;
    }
  }

  Future<void> startRecording({required int maxDurationSeconds}) async {
    if (isRecording.value) return;

    try {
      final bool hasPermission = await speakingRecorderController
          .checkPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission needed',
          'Please allow microphone permission to record your answer.',
        );
        return;
      }

      await resetRecording(clearPathOnly: false);
      final String path =
          '${Directory.systemTemp.path}/final_exam_speaking_${DateTime.now().millisecondsSinceEpoch}.m4a';
      recordedAudioPath.value = path;
      await speakingRecorderController.record(path: path);
      recordedSeconds.value = 0;
      isRecording.value = true;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (recordedSeconds.value >= maxDurationSeconds) {
          unawaited(stopRecording());
          return;
        }
        recordedSeconds.value += 1;
      });
    } catch (_) {
      isRecording.value = false;
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    try {
      final String? path = await speakingRecorderController.stop();
      if (path != null && path.isNotEmpty) recordedAudioPath.value = path;
      hasRecording.value =
          recordedSeconds.value > 0 && recordedAudioPath.value.isNotEmpty;
    } finally {
      isRecording.value = false;
      _recordTimer?.cancel();
    }
  }

  Future<void> resetRecording({bool clearPathOnly = true}) async {
    if (isRecording.value) await stopRecording();
    await stopRecordedAudio(reset: false);
    hasRecording.value = false;
    isRecordedAudioPlaying.value = false;
    recordedSeconds.value = 0;
    _recordTimer?.cancel();

    if (clearPathOnly && recordedAudioPath.value.isNotEmpty) {
      try {
        final File file = File(recordedAudioPath.value);
        if (await file.exists()) await file.delete();
      } catch (_) {}
      recordedAudioPath.value = '';
    }

    _recordedPlayerSub?.cancel();
    recordedWaveController.dispose();
    recordedWaveController = PlayerController();
    _bindRecordedPlayerState();
    _isRecordedAudioPrepared = false;
  }

  Future<void> toggleRecordedAudio() async {
    if (!hasRecording.value || recordedAudioPath.value.isEmpty) return;
    if (isRecordedAudioPlaying.value) {
      await pauseRecordedAudio();
      return;
    }
    await _prepareRecordedAudio();
    if (!_isRecordedAudioPrepared) return;
    try {
      await recordedWaveController.startPlayer();
    } catch (_) {
      isRecordedAudioPlaying.value = false;
    }
  }

  Future<void> pauseRecordedAudio() async {
    try {
      await recordedWaveController.pausePlayer();
    } catch (_) {
      isRecordedAudioPlaying.value = false;
    }
  }

  Future<void> stopRecordedAudio({required bool reset}) async {
    try {
      await recordedWaveController.stopPlayer();
      if (reset) _isRecordedAudioPrepared = false;
    } catch (_) {
      isRecordedAudioPlaying.value = false;
    }
  }

  void _bindRecordedPlayerState() {
    _recordedPlayerSub?.cancel();
    _recordedPlayerSub = recordedWaveController.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      isRecordedAudioPlaying.value = state == PlayerState.playing;
    });
  }

  Future<void> _prepareRecordedAudio() async {
    if (_isRecordedAudioPrepared || recordedAudioPath.value.isEmpty) return;
    try {
      await recordedWaveController.preparePlayer(
        path: recordedAudioPath.value,
        shouldExtractWaveform: true,
        noOfSamples: 70,
      );
      _isRecordedAudioPrepared = true;
    } catch (_) {
      _isRecordedAudioPrepared = false;
    }
  }
}
