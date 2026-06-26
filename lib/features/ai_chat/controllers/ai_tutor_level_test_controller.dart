import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../data/ai_tutor_level_test_questions.dart';
import '../models/ai_tutor_level_test_models.dart';
import '../services/ai_tutor_api_service.dart';
import '../services/ai_tutor_level_test_recording_service.dart';
import '../services/ai_tutor_preferences_service.dart';
import '../views/ai_tutor_discovery_view.dart';
import '../views/ai_tutor_level_test_question_view.dart';
import '../views/ai_tutor_level_test_result_view.dart';

class AiTutorLevelTestController extends GetxController {
  AiTutorLevelTestController({
    AiTutorApiService? apiService,
    AiTutorPreferencesService? preferencesService,
    AiTutorLevelTestRecordingService? recordingService,
  })  : _apiService = apiService ?? Get.find<AiTutorApiService>(),
        _preferencesService =
            preferencesService ?? Get.find<AiTutorPreferencesService>(),
        _recordingService =
            recordingService ?? AiTutorLevelTestRecordingService();

  final AiTutorApiService _apiService;
  final AiTutorPreferencesService _preferencesService;
  final AiTutorLevelTestRecordingService _recordingService;

  final TextEditingController answerController = TextEditingController();
  final RxInt currentQuestionIndex = 0.obs;
  final RxString answerText = ''.obs;
  final RxnString selectedOption = RxnString();
  final RxBool isSubmitting = false.obs;
  final RxBool isPreparingRecording = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isTranscribing = false.obs;
  final RxInt recordedSeconds = 0.obs;
  final Rxn<AiTutorLearnerProfileModel> resultProfile =
      Rxn<AiTutorLearnerProfileModel>();

  final Map<String, AiTutorLevelAnswerModel> _answers =
      <String, AiTutorLevelAnswerModel>{};
  Timer? _recordingTimer;
  bool _releaseRequestedWhilePreparing = false;

  List<AiTutorLevelQuestionModel> get questions => aiTutorLevelTestQuestions;

  AiTutorLevelQuestionModel get currentQuestion =>
      questions[currentQuestionIndex.value];

  RecorderController get recorderController =>
      _recordingService.recorderController;

  bool get isFirstQuestion => currentQuestionIndex.value == 0;

  bool get isLastQuestion =>
      currentQuestionIndex.value == questions.length - 1;

  bool get isSpeakingQuestion =>
      currentQuestion.skill == AiTutorSkillType.speaking;

  bool get isBusy =>
      isSubmitting.value ||
      isPreparingRecording.value ||
      isRecording.value ||
      isTranscribing.value;

  double get progress =>
      (currentQuestionIndex.value + 1) / questions.length;

  bool get canContinue {
    if (isBusy) {
      return false;
    }
    if (currentQuestion.type == AiTutorQuestionType.singleChoice) {
      return selectedOption.value?.trim().isNotEmpty == true;
    }
    return answerText.value.trim().isNotEmpty;
  }

  AiTutorLearnerProfileModel? get latestProfile =>
      resultProfile.value ?? _preferencesService.learnerProfile.value;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshProfile(showError: false));
  }

  Future<void> refreshProfile({bool showError = true}) async {
    final ApiResult<AiTutorLevelProfileResponseModel> result =
        await ApiErrorHandler.call<AiTutorLevelProfileResponseModel>(
      _apiService.getLevelTestProfile,
      showError: showError,
    );
    if (!result.isSuccess || result.data == null) {
      return;
    }

    final AiTutorLearnerProfileModel? profile = result.data!.profile;
    if (profile == null) {
      _preferencesService.clearProfile();
      return;
    }
    _preferencesService.setProfile(profile);
  }

  void startTest() {
    _resetTest();
    Get.to<void>(
      () => const AiTutorLevelTestQuestionView(),
      transition: Transition.rightToLeft,
    );
  }

  void selectOption(String option) {
    if (isBusy) {
      return;
    }
    selectedOption.value = option;
  }

  void onAnswerChanged(String value) {
    answerText.value = value;
  }

  Future<void> startSpeakingAnswer() async {
    if (!isSpeakingQuestion || isBusy) {
      return;
    }

    _releaseRequestedWhilePreparing = false;
    isPreparingRecording.value = true;
    try {
      final String? path = await _recordingService.start();
      if (path == null) {
        Get.snackbar(
          'Microphone permission required',
          'Please allow microphone access to answer speaking questions.',
        );
        return;
      }

      recordedSeconds.value = 0;
      isRecording.value = true;
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordedSeconds.value += 1;
      });
    } catch (_) {
      await _recordingService.cancel();
      Get.snackbar(
        'Recording failed',
        'Unable to start the microphone. Please try again.',
      );
    } finally {
      isPreparingRecording.value = false;
    }

    if (_releaseRequestedWhilePreparing && isRecording.value) {
      await stopSpeakingAnswer();
    }
  }

  Future<void> stopSpeakingAnswer() async {
    if (isPreparingRecording.value && !isRecording.value) {
      _releaseRequestedWhilePreparing = true;
      return;
    }
    if (!isRecording.value) {
      return;
    }

    isRecording.value = false;
    _recordingTimer?.cancel();

    String? path;
    try {
      path = await _recordingService.stop();
    } catch (_) {
      await _recordingService.cancel();
    }
    if (path == null || path.trim().isEmpty) {
      Get.snackbar(
        'Recording failed',
        'Please hold the microphone and try again.',
      );
      return;
    }

    isTranscribing.value = true;
    try {
      final ApiResult<AiTutorLevelTranscriptionResponseModel> result =
          await ApiErrorHandler.call<AiTutorLevelTranscriptionResponseModel>(
        () => _apiService.transcribeLevelTestAnswer(
          question: currentQuestion.prompt,
          audioPath: path!,
        ),
      );
      final String transcript = result.data?.transcript.trim() ?? '';
      if (!result.isSuccess || transcript.isEmpty) {
        return;
      }

      answerText.value = transcript;
      _answers[currentQuestion.id] = AiTutorLevelAnswerModel(
        questionId: currentQuestion.id,
        skill: currentQuestion.skill,
        question: currentQuestion.prompt,
        answer: transcript,
      );
    } finally {
      isTranscribing.value = false;
      recordedSeconds.value = 0;
      await _recordingService.deleteFile(path);
    }
  }

  Future<void> submitCurrentAnswer() async {
    if (!canContinue) {
      Get.snackbar(
        'Answer required',
        isSpeakingQuestion
            ? 'Hold the microphone and speak your answer before continuing.'
            : 'Please answer this question before continuing.',
      );
      return;
    }

    _saveCurrentAnswer();
    if (!isLastQuestion) {
      currentQuestionIndex.value += 1;
      _restoreCurrentAnswer();
      return;
    }

    await _evaluateAnswers();
  }

  Future<void> handleBack() async {
    if (isBusy) {
      return;
    }
    if (isFirstQuestion) {
      Get.back<void>();
      return;
    }
    goToPreviousQuestion();
  }

  void goToPreviousQuestion() {
    if (isFirstQuestion || isBusy) {
      return;
    }
    _saveCurrentAnswer(allowEmpty: true);
    currentQuestionIndex.value -= 1;
    _restoreCurrentAnswer();
  }

  void retakeTest() {
    _resetTest();
    Get.off<void>(
      () => const AiTutorLevelTestQuestionView(),
      transition: Transition.rightToLeft,
    );
  }

  void continueToAiChat() {
    Get.off<void>(
      () => const AiTutorDiscoveryView(),
      transition: Transition.rightToLeft,
    );
  }

  void _saveCurrentAnswer({bool allowEmpty = false}) {
    final AiTutorLevelQuestionModel question = currentQuestion;
    final String answer = question.type == AiTutorQuestionType.singleChoice
        ? selectedOption.value?.trim() ?? ''
        : isSpeakingQuestion
            ? answerText.value.trim()
            : answerController.text.trim();
    if (answer.isEmpty && !allowEmpty) {
      return;
    }
    if (answer.isEmpty) {
      _answers.remove(question.id);
      return;
    }

    _answers[question.id] = AiTutorLevelAnswerModel(
      questionId: question.id,
      skill: question.skill,
      question: question.prompt,
      answer: answer,
    );
  }

  void _restoreCurrentAnswer() {
    final AiTutorLevelQuestionModel question = currentQuestion;
    final String answer = _answers[question.id]?.answer ?? '';
    recordedSeconds.value = 0;
    if (question.type == AiTutorQuestionType.singleChoice) {
      selectedOption.value = answer.isEmpty ? null : answer;
      answerController.clear();
      answerText.value = '';
      return;
    }

    selectedOption.value = null;
    answerText.value = answer;
    if (question.skill == AiTutorSkillType.speaking) {
      answerController.clear();
      return;
    }
    answerController.text = answer;
    answerController.selection = TextSelection.collapsed(
      offset: answerController.text.length,
    );
  }

  Future<void> _evaluateAnswers() async {
    final List<AiTutorLevelAnswerModel> answers = questions
        .map((AiTutorLevelQuestionModel item) => _answers[item.id])
        .whereType<AiTutorLevelAnswerModel>()
        .toList(growable: false);
    if (answers.length != questions.length) {
      Get.snackbar('Test incomplete', 'Please answer all ten questions.');
      return;
    }

    isSubmitting.value = true;
    try {
      final ApiResult<AiTutorLevelTestResponseModel> result =
          await ApiErrorHandler.call<AiTutorLevelTestResponseModel>(
        () => _apiService.evaluateLevelTest(answers: answers),
      );
      if (!result.isSuccess || result.data == null) {
        return;
      }

      final AiTutorLearnerProfileModel profile = result.data!.profile;
      _preferencesService.setProfile(profile);
      resultProfile.value = profile;
      Get.off<void>(
        () => const AiTutorLevelTestResultView(),
        transition: Transition.rightToLeft,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetTest() {
    _answers.clear();
    currentQuestionIndex.value = 0;
    answerController.clear();
    answerText.value = '';
    selectedOption.value = null;
    isSubmitting.value = false;
    isPreparingRecording.value = false;
    isRecording.value = false;
    isTranscribing.value = false;
    recordedSeconds.value = 0;
    resultProfile.value = null;
    _releaseRequestedWhilePreparing = false;
    _recordingTimer?.cancel();
    unawaited(_recordingService.cancel());
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    unawaited(_recordingService.cancel());
    _recordingService.dispose();
    answerController.dispose();
    super.onClose();
  }
}
