import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../quiz/controllers/quiz_controller.dart';
import '../../quiz/services/quiz_mock_service.dart';
import '../models/final_exam_models.dart';
import '../services/final_exam_mock_service.dart';

class FinalExamController extends GetxController {
  final String controllerTag;
  final FinalExamMockService _finalExamMockService;

  FinalExamController({
    required this.controllerTag,
    required FinalExamMockService finalExamMockService,
  }) : _finalExamMockService = finalExamMockService;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isAudioPlaying = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool hasRecording = false.obs;
  final RxBool isRecordedAudioPlaying = false.obs;
  final RxBool teacherReviewComplete = false.obs;
  final RxBool resultComplete = false.obs;
  final RxInt selectedListeningOption = 0.obs;
  final RxInt recordedSeconds = 0.obs;
  final RxString referenceId = '#EXAM-A1-4922'.obs;
  final RxString recordedAudioPath = ''.obs;

  final Rxn<FinalExamOverviewModel> overview = Rxn<FinalExamOverviewModel>();
  final Rxn<FinalExamListeningModel> listeningTask =
      Rxn<FinalExamListeningModel>();
  final Rxn<FinalExamWritingModel> writingTask = Rxn<FinalExamWritingModel>();
  final Rxn<FinalExamSpeakingModel> speakingTask =
      Rxn<FinalExamSpeakingModel>();
  final Rxn<FinalExamResultModel> result = Rxn<FinalExamResultModel>();

  final TextEditingController writingController = TextEditingController();

  final PlayerController listeningWaveController = PlayerController();
  final RecorderController speakingRecorderController = RecorderController();
  PlayerController recordedWaveController = PlayerController();

  Timer? _recordTimer;
  Timer? _teacherTimer;
  Timer? _resultTimer;
  StreamSubscription<PlayerState>? _listeningPlayerSub;
  StreamSubscription<PlayerState>? _recordedPlayerSub;
  bool _isListeningAudioPrepared = false;
  bool _isRecordedAudioPrepared = false;
  bool _isPreparingListeningAudio = false;
  String? _listeningAudioPath;

  @override
  void onInit() {
    super.onInit();
    _configureRecorder();
    _listenToPlayerState();
    unawaited(_prepareListeningAudio());
    loadOverview();
  }

  @override
  void onClose() {
    _recordTimer?.cancel();
    _teacherTimer?.cancel();
    _resultTimer?.cancel();
    _listeningPlayerSub?.cancel();
    _recordedPlayerSub?.cancel();
    speakingRecorderController.dispose();
    listeningWaveController.dispose();
    recordedWaveController.dispose();
    writingController.dispose();
    super.onClose();
  }

  Future<void> loadOverview() async {
    if (overview.value != null || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      overview.value = await _finalExamMockService.fetchOverview();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadListeningTask() async {
    if (listeningTask.value != null || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      listeningTask.value = await _finalExamMockService.fetchListeningTask();
      await _prepareListeningAudio();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWritingTask() async {
    if (writingTask.value != null || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      writingTask.value = await _finalExamMockService.fetchWritingTask();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSpeakingTask() async {
    if (speakingTask.value != null || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      speakingTask.value = await _finalExamMockService.fetchSpeakingTask();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadResult() async {
    if (result.value != null || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      result.value = await _finalExamMockService.fetchResult();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startExam() async {
    final int questionCount = 6 + Random().nextInt(15);
    final String quizTag =
        'final_exam_quiz_${DateTime.now().millisecondsSinceEpoch}';

    final Object? quizResult = await Get.toNamed(
      AppRoutes.quiz,
      arguments: QuizRouteArguments(
        controllerTag: quizTag,
        isExamMode: true,
        questionCount: questionCount,
      ),
    );

    if (Get.isRegistered<QuizController>(tag: quizTag)) {
      Get.delete<QuizController>(tag: quizTag, force: true);
    }
    if (Get.isRegistered<QuizMockService>(tag: quizTag)) {
      Get.delete<QuizMockService>(tag: quizTag, force: true);
    }

    if (quizResult == true) {
      await openListeningLab();
    }
  }

  Future<void> openListeningLab() async {
    await loadListeningTask();
    await Get.toNamed(
      AppRoutes.finalExamListening,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> submitListeningAnswer() async {
    await _stopListeningAudio(reset: true);
    await loadWritingTask();
    await Get.toNamed(
      AppRoutes.finalExamWriting,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> submitWritingAnswer() async {
    await loadSpeakingTask();
    await Get.toNamed(
      AppRoutes.finalExamSpeaking,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> submitSpeakingAnswer() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      await _stopRecordedAudio(reset: true);
      referenceId.value = await _finalExamMockService.submitExam();
      startEvaluationSimulation();
      await Get.offNamed(
        AppRoutes.finalExamSuccess,
        arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> openResult() async {
    await loadResult();
    await Get.toNamed(
      AppRoutes.finalExamResult,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> openCertificate() async {
    final String tag =
        'course_certificate_${DateTime.now().millisecondsSinceEpoch}';
    await Get.toNamed(
      AppRoutes.courseCertificate,
      arguments: CourseCertificateRouteArguments(controllerTag: tag),
    );
  }

  void toggleListeningAudio() {
    unawaited(_toggleListeningAudio());
  }

  void selectListeningOption(int index) {
    selectedListeningOption.value = index;
  }

  void startRecording() {
    unawaited(_startRecording());
  }

  void stopRecording() {
    unawaited(_stopRecording());
  }

  void resetRecording() {
    unawaited(_resetRecording());
  }

  void toggleRecordedAudio() {
    unawaited(_toggleRecordedAudio());
  }

  void startEvaluationSimulation() {
    teacherReviewComplete.value = false;
    resultComplete.value = false;
    _teacherTimer?.cancel();
    _resultTimer?.cancel();
    _teacherTimer = Timer(const Duration(seconds: 10), () {
      teacherReviewComplete.value = true;
    });
    _resultTimer = Timer(const Duration(seconds: 20), () {
      resultComplete.value = true;
    });
  }

  void _configureRecorder() {
    speakingRecorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _listenToPlayerState() {
    _listeningPlayerSub = listeningWaveController.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      isAudioPlaying.value = state == PlayerState.playing;
    });

    _bindRecordedPlayerState();
  }

  void _bindRecordedPlayerState() {
    _recordedPlayerSub?.cancel();
    _recordedPlayerSub = recordedWaveController.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      isRecordedAudioPlaying.value = state == PlayerState.playing;
    });
  }

  Future<void> _toggleListeningAudio() async {
    if (isAudioPlaying.value) {
      await _pauseListeningAudio();
      return;
    }

    await _prepareListeningAudio();
    if (!_isListeningAudioPrepared) {
      return;
    }

    isAudioPlaying.value = true;
    try {
      await listeningWaveController.seekTo(0);
      await listeningWaveController.startPlayer();
    } catch (_) {
      isAudioPlaying.value = false;
    }
  }

  Future<void> _pauseListeningAudio() async {
    isAudioPlaying.value = false;
    try {
      await listeningWaveController.pausePlayer();
    } catch (_) {}
  }

  Future<void> _stopListeningAudio({required bool reset}) async {
    isAudioPlaying.value = false;
    try {
      await listeningWaveController.stopPlayer();
      if (reset && _listeningAudioPath != null) {
        _isListeningAudioPrepared = false;
        await listeningWaveController.preparePlayer(
          path: _listeningAudioPath!,
          shouldExtractWaveform: true,
          noOfSamples: 80,
        );
        _isListeningAudioPrepared = true;
      }
    } catch (_) {}
  }

  Future<void> _prepareListeningAudio() async {
    if (_isListeningAudioPrepared || _isPreparingListeningAudio) {
      return;
    }

    _isPreparingListeningAudio = true;
    try {
      final File file = await _createSilentWavFile(
        fileName: 'final_exam_listening_mock.wav',
        seconds: 4,
      );
      _listeningAudioPath = file.path;
      await listeningWaveController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
        noOfSamples: 80,
      );
      _isListeningAudioPrepared = true;
    } catch (_) {
      _isListeningAudioPrepared = false;
    } finally {
      _isPreparingListeningAudio = false;
    }
  }

  Future<void> _startRecording() async {
    if (isRecording.value) {
      return;
    }

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

      await _resetRecording(clearPathOnly: false);
      final String path =
          '${Directory.systemTemp.path}/final_exam_speaking_${DateTime.now().millisecondsSinceEpoch}.m4a';
      recordedAudioPath.value = path;
      await speakingRecorderController.record(path: path);
      recordedSeconds.value = 0;
      isRecording.value = true;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (recordedSeconds.value < 60) {
          recordedSeconds.value += 1;
        }
      });
    } catch (_) {
      isRecording.value = false;
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording.value) {
      return;
    }

    try {
      final String? path = await speakingRecorderController.stop();
      if (path != null && path.isNotEmpty) {
        recordedAudioPath.value = path;
      }
      hasRecording.value =
          recordedSeconds.value > 0 && recordedAudioPath.value.isNotEmpty;
    } finally {
      isRecording.value = false;
      _recordTimer?.cancel();
    }
  }

  Future<void> _resetRecording({bool clearPathOnly = true}) async {
    if (isRecording.value) {
      await _stopRecording();
    }

    await _stopRecordedAudio(reset: false);
    hasRecording.value = false;
    isRecordedAudioPlaying.value = false;
    recordedSeconds.value = 0;
    _recordTimer?.cancel();

    if (clearPathOnly && recordedAudioPath.value.isNotEmpty) {
      try {
        final File file = File(recordedAudioPath.value);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      recordedAudioPath.value = '';
    }

    _recordedPlayerSub?.cancel();
    recordedWaveController.dispose();
    recordedWaveController = PlayerController();
    _bindRecordedPlayerState();
    _isRecordedAudioPrepared = false;
  }

  Future<void> _toggleRecordedAudio() async {
    if (!hasRecording.value || recordedAudioPath.value.isEmpty) {
      return;
    }

    if (isRecordedAudioPlaying.value) {
      await _pauseRecordedAudio();
      return;
    }

    await _prepareRecordedAudio();
    if (!_isRecordedAudioPrepared) {
      return;
    }

    isRecordedAudioPlaying.value = true;
    try {
      await recordedWaveController.seekTo(0);
      await recordedWaveController.startPlayer();
    } catch (_) {
      isRecordedAudioPlaying.value = false;
    }
  }

  Future<void> _pauseRecordedAudio() async {
    isRecordedAudioPlaying.value = false;
    try {
      await recordedWaveController.pausePlayer();
    } catch (_) {}
  }

  Future<void> _stopRecordedAudio({required bool reset}) async {
    isRecordedAudioPlaying.value = false;
    try {
      await recordedWaveController.stopPlayer();
      if (reset) {
        _isRecordedAudioPrepared = false;
      }
    } catch (_) {}
  }

  Future<void> _prepareRecordedAudio() async {
    if (_isRecordedAudioPrepared || recordedAudioPath.value.isEmpty) {
      return;
    }

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

  Future<File> _createSilentWavFile({
    required String fileName,
    required int seconds,
  }) async {
    final File file = File('${Directory.systemTemp.path}/$fileName');
    if (await file.exists()) {
      return file;
    }

    const int sampleRate = 44100;
    const int channels = 1;
    const int bitsPerSample = 16;
    const int bytesPerSample = bitsPerSample ~/ 8;
    final int dataSize = sampleRate * seconds * channels * bytesPerSample;
    final int byteRate = sampleRate * channels * bytesPerSample;
    final BytesBuilder builder = BytesBuilder();

    void addString(String value) => builder.add(ascii.encode(value));
    void addInt16(int value) {
      final ByteData data = ByteData(2)..setInt16(0, value, Endian.little);
      builder.add(data.buffer.asUint8List());
    }

    void addInt32(int value) {
      final ByteData data = ByteData(4)..setInt32(0, value, Endian.little);
      builder.add(data.buffer.asUint8List());
    }

    addString('RIFF');
    addInt32(36 + dataSize);
    addString('WAVE');
    addString('fmt ');
    addInt32(16);
    addInt16(1);
    addInt16(channels);
    addInt32(sampleRate);
    addInt32(byteRate);
    addInt16(channels * bytesPerSample);
    addInt16(bitsPerSample);
    addString('data');
    addInt32(dataSize);
    builder.add(Uint8List(dataSize));

    await file.writeAsBytes(builder.toBytes(), flush: true);
    return file;
  }
}
