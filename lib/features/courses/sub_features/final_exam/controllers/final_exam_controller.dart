import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../quiz/models/quiz_models.dart';
import '../helpers/final_exam_flow_mapper.dart';
import '../models/final_exam_api_models.dart';
import '../models/final_exam_models.dart';
import '../services/final_exam_api_service.dart';
import 'final_exam_media_coordinator.dart';

class FinalExamController extends GetxController {
  final String controllerTag;
  final String courseId;
  final String? initialAttemptId;
  final bool loadOverviewOnInit;
  final FinalExamApiService _finalExamApiService;
  final FinalExamMediaCoordinator _media = FinalExamMediaCoordinator();

  FinalExamController({
    required this.controllerTag,
    required this.courseId,
    required FinalExamApiService finalExamApiService,
    this.initialAttemptId,
    this.loadOverviewOnInit = true,
  }) : _finalExamApiService = finalExamApiService;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool teacherReviewComplete = false.obs;
  final RxBool resultComplete = false.obs;
  final RxInt selectedListeningOption = (-1).obs;
  final RxString referenceId = ''.obs;
  final RxString estimatedResult = ''.obs;
  final RxBool retakeAvailable = false.obs;
  final RxBool certificateAvailable = false.obs;

  final RxString resultCourseId = ''.obs;

  RxBool get isAudioPlaying => _media.isAudioPlaying;
  RxBool get isRecording => _media.isRecording;
  RxBool get hasRecording => _media.hasRecording;
  RxBool get isRecordedAudioPlaying => _media.isRecordedAudioPlaying;
  RxInt get recordedSeconds => _media.recordedSeconds;
  RxString get recordedAudioPath => _media.recordedAudioPath;
  PlayerController get listeningWaveController =>
      _media.listeningWaveController;
  RecorderController get speakingRecorderController =>
      _media.speakingRecorderController;
  PlayerController get recordedWaveController => _media.recordedWaveController;

  final Rxn<FinalExamOverviewModel> overview = Rxn<FinalExamOverviewModel>();
  final Rxn<FinalExamGatewayModel> gateway = Rxn<FinalExamGatewayModel>();
  final Rxn<FinalExamAttemptModel> attempt = Rxn<FinalExamAttemptModel>();
  final Rxn<FinalExamListeningModel> listeningTask =
      Rxn<FinalExamListeningModel>();
  final Rxn<FinalExamWritingModel> writingTask = Rxn<FinalExamWritingModel>();
  final Rxn<FinalExamSpeakingModel> speakingTask =
      Rxn<FinalExamSpeakingModel>();
  final Rxn<FinalExamResultModel> result = Rxn<FinalExamResultModel>();

  final TextEditingController writingController = TextEditingController();

  Timer? _resultPollTimer;
  int _activeSectionIndex = -1;
  DateTime? _attemptStartedAt;

  @override
  void onInit() {
    super.onInit();
    _media.initialize();

    final String existingAttemptId =
        initialAttemptId?.trim() ?? '';

    if (existingAttemptId.isNotEmpty) {
      unawaited(
        loadResultByAttemptId(
          attemptId: existingAttemptId,
        ),
      );
      return;
    }

    if (loadOverviewOnInit) {
      unawaited(loadOverview());
    }
  }

  @override
  void onClose() {
    _resultPollTimer?.cancel();
    _media.dispose();
    writingController.dispose();
    super.onClose();
  }

  Future<void> loadOverview() async {
    if (overview.value != null || isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<FinalExamGatewayModel> result =
          await ApiErrorHandler.call<FinalExamGatewayModel>(
        () => _finalExamApiService.fetchGateway(courseId: courseId),
        errorTitle: 'gen_final_exam'.tr,
      );
      if (!result.isSuccess || result.data == null) return;

      gateway.value = result.data;
      overview.value = FinalExamFlowMapper.overviewFromGateway(result.data!);
    } finally {
      isLoading.value = false;
    }
  }
  void _applyResultMetadata(
      FinalExamResultResponseModel data,
      ) {
    resultCourseId.value = data.courseId;
    retakeAvailable.value = data.canRetake;
    certificateAvailable.value =
        data.certificateAvailable;
  }

  Future<void> startExam() async {
    final FinalExamOverviewModel? currentOverview = overview.value;
    if (isSubmitting.value || currentOverview == null) return;
    if (!currentOverview.canStart) {
      Get.snackbar('gen_final_exam'.tr, currentOverview.startMessage);
      return;
    }

    isSubmitting.value = true;
    FinalExamAttemptModel? startedAttempt;
    try {
      final ApiResult<FinalExamAttemptModel> result =
          await ApiErrorHandler.call<FinalExamAttemptModel>(
        () => _finalExamApiService.startAttempt(courseId: courseId),
        errorTitle: 'start_final_exam'.tr,
      );
      if (!result.isSuccess || result.data == null) return;

      final FinalExamAttemptModel data = result.data!;
      startedAttempt = data;
      attempt.value = data;
      referenceId.value = data.referenceCode;
      _attemptStartedAt = data.startedAt ?? DateTime.now();
    } finally {
      isSubmitting.value = false;
    }

    if (startedAttempt != null) {
      await _openSectionAt(0);
    }
  }

  Future<void> _openSectionAt(int index) async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    if (currentAttempt == null) return;
    if (index >= currentAttempt.sections.length) {
      await _submitAttemptAndOpenSuccess();
      return;
    }

    final FinalExamSectionModel section = currentAttempt.sections[index];
    if (section.questions.isEmpty) {
      await _openSectionAt(index + 1);
      return;
    }

    _activeSectionIndex = index;
    switch (section.type) {
      case FinalExamSectionType.coreQuiz:
      case FinalExamSectionType.listeningLab:
        await _openAutoGradedSection(section, index);
        return;
      case FinalExamSectionType.writingTask:
        writingTask.value = FinalExamFlowMapper.writingTask(section);
        writingController.clear();
        await Get.toNamed(
          AppRoutes.finalExamWriting,
          arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
        );
        return;
      case FinalExamSectionType.speakingLab:
        speakingTask.value = FinalExamFlowMapper.speakingTask(section);
        await _media.resetRecording();
        await Get.toNamed(
          AppRoutes.finalExamSpeaking,
          arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
        );
        return;
      case FinalExamSectionType.unknown:
        await _openSectionAt(index + 1);
    }
  }

  Future<void> _openAutoGradedSection(
    FinalExamSectionModel section,
    int sectionIndex,
  ) async {
    final List<QuizQuestionModel> questions = section.questions
        .map(
          (FinalExamQuestionModel question) =>
              FinalExamFlowMapper.quizQuestion(section, question),
        )
        .toList(growable: false);
    if (questions.isEmpty) {
      await _openSectionAt(sectionIndex + 1);
      return;
    }

    final String quizTag =
        'final_exam_${section.id}_${DateTime.now().millisecondsSinceEpoch}';
    final Object? routeResult = await Get.toNamed(
      AppRoutes.quiz,
      arguments: QuizRouteArguments(
        controllerTag: quizTag,
        isExamMode: true,
        questionCount: questions.length,
        initialQuestions: questions,
        externalAnswerHandler: submitQuizAnswer,
      ),
    );

    if (routeResult == true) {
      // Allow the previous route's closing animation to finish.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _openSectionAt(sectionIndex + 1);
    }
  }



  Future<QuizExternalAnswerResult> submitQuizAnswer(
    QuizQuestionModel question,
    QuizAnswerInput input,
  ) async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    final FinalExamQuestionModel? examQuestion = _findQuestion(question.id);
    if (currentAttempt == null || examQuestion == null) {
      throw StateError('Final exam question was not found.');
    }

    final ApiResult<FinalExamAnswerResultModel> response =
        await ApiErrorHandler.call<FinalExamAnswerResultModel>(
      () => _finalExamApiService.submitAnswer(
        attemptId: currentAttempt.id,
        payload: FinalExamFlowMapper.answerPayload(
          examQuestion,
          question,
          input,
        ),
      ),
      errorTitle: 'final_exam_answer'.tr,
    );
    if (!response.isSuccess || response.data == null) {
      throw StateError('Final exam answer could not be submitted.');
    }

    final FinalExamAnswerResultModel result = response.data!;
    return QuizExternalAnswerResult(
      isCorrect: result.isCorrect ?? true,
      correctAnswer: result.correctAnswer,
      meaning: examQuestion.promptBn,
    );
  }

  Future<void> loadListeningTask() async {
    final FinalExamSectionModel? section = _sectionAt(_activeSectionIndex);
    if (section == null || section.questions.isEmpty) return;
    listeningTask.value = FinalExamFlowMapper.listeningTask(section);
    await _media.prepareListeningAudio(listeningTask.value!.audioUrl);
  }

  Future<void> loadWritingTask() async {
    final FinalExamSectionModel? section = _sectionAt(_activeSectionIndex);
    if (section != null) {
      writingTask.value = FinalExamFlowMapper.writingTask(section);
    }
  }

  Future<void> loadSpeakingTask() async {
    final FinalExamSectionModel? section = _sectionAt(_activeSectionIndex);
    if (section != null) {
      speakingTask.value = FinalExamFlowMapper.speakingTask(section);
    }
  }

  Future<void> submitListeningAnswer() async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    final FinalExamListeningModel? task = listeningTask.value;
    if (currentAttempt == null || task == null || isSubmitting.value) return;
    if (selectedListeningOption.value < 0 ||
        selectedListeningOption.value >= task.optionIds.length) {
      Get.snackbar('gen_listening'.tr, 'please_select_an_answer'.tr);
      return;
    }

    bool submitted = false;
    isSubmitting.value = true;
    try {
      final ApiResult<FinalExamAnswerResultModel> result =
          await ApiErrorHandler.call<FinalExamAnswerResultModel>(
        () => _finalExamApiService.submitAnswer(
          attemptId: currentAttempt.id,
          payload: <String, dynamic>{
            'sectionId': task.sectionId,
            'questionId': task.questionId,
            'answerType': 'single_option',
            'selectedOptionId': task.optionIds[selectedListeningOption.value],
          },
        ),
        errorTitle: 'gen_listening'.tr,
      );
      submitted = result.isSuccess;
    } finally {
      isSubmitting.value = false;
    }

    if (!submitted) return;
    await _media.stopListeningAudio(reset: true);
    Get.back<void>();
    await _openSectionAt(_activeSectionIndex + 1);
  }

  Future<void> submitWritingAnswer() async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    final FinalExamWritingModel? task = writingTask.value;
    if (currentAttempt == null || task == null || isSubmitting.value) return;

    final String answer = writingController.text.trim();
    final int words = answer.isEmpty ? 0 : answer.split(RegExp(r'\s+')).length;
    if (answer.isEmpty) {
      Get.snackbar('writing_task'.tr, 'please_write_your_answer_first'.tr);
      return;
    }
    if (task.minWords > 0 && words < task.minWords) {
      Get.snackbar(
        'writing_task_1'.tr,
        'Please write at least ${task.minWords} words.',
      );
      return;
    }

    bool submitted = false;
    isSubmitting.value = true;
    try {
      final ApiResult<FinalExamAnswerResultModel> result =
          await ApiErrorHandler.call<FinalExamAnswerResultModel>(
        () => _finalExamApiService.submitAnswer(
          attemptId: currentAttempt.id,
          payload: <String, dynamic>{
            'sectionId': task.sectionId,
            'questionId': task.questionId,
            'answerType': 'text',
            'textAnswer': answer,
          },
        ),
        errorTitle: 'writing_task'.tr,
      );
      submitted = result.isSuccess;
    } finally {
      isSubmitting.value = false;
    }

    if (!submitted) return;
    Get.back<void>();
    await _openSectionAt(_activeSectionIndex + 1);
  }

  Future<void> submitSpeakingAnswer() async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    final FinalExamSpeakingModel? task = speakingTask.value;
    if (currentAttempt == null || task == null || isSubmitting.value) return;

    if (isRecording.value) await _media.stopRecording();
    if (!hasRecording.value || recordedAudioPath.value.isEmpty) {
      Get.snackbar('speaking_task'.tr, 'please_record_your_answer_first'.tr);
      return;
    }

    bool submitted = false;
    isSubmitting.value = true;
    try {
      await _media.stopRecordedAudio(reset: true);
      final ApiResult<String> uploadResult = await ApiErrorHandler.call<String>(
        () => _finalExamApiService.uploadSpeakingAudio(
          filePath: recordedAudioPath.value,
          durationSeconds: recordedSeconds.value,
        ),
        errorTitle: 'speaking_audio'.tr,
      );
      if (!uploadResult.isSuccess || uploadResult.data == null) return;

      final ApiResult<FinalExamAnswerResultModel> result =
          await ApiErrorHandler.call<FinalExamAnswerResultModel>(
        () => _finalExamApiService.submitAnswer(
          attemptId: currentAttempt.id,
          payload: <String, dynamic>{
            'sectionId': task.sectionId,
            'questionId': task.questionId,
            'answerType': 'audio',
            'audioFileId': uploadResult.data,
            'durationSeconds': recordedSeconds.value,
          },
        ),
        errorTitle: 'speaking_task'.tr,
      );
      submitted = result.isSuccess;
    } finally {
      isSubmitting.value = false;
    }

    if (!submitted) return;
    Get.back<void>();
    await _openSectionAt(_activeSectionIndex + 1);
  }

  Future<void> _submitAttemptAndOpenSuccess() async {
    final FinalExamAttemptModel? currentAttempt = attempt.value;
    if (currentAttempt == null || isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      final int durationSeconds = DateTime.now()
          .difference(_attemptStartedAt ?? DateTime.now())
          .inSeconds;
      final ApiResult<FinalExamSubmissionModel> result =
          await ApiErrorHandler.call<FinalExamSubmissionModel>(
        () => _finalExamApiService.submitAttempt(
          attemptId: currentAttempt.id,
          totalDurationSeconds: durationSeconds,
        ),
        errorTitle: 'submit_final_exam'.tr,
      );
      if (!result.isSuccess || result.data == null) return;

      referenceId.value = result.data!.referenceCode;
      estimatedResult.value = result.data!.estimatedResult;
      teacherReviewComplete.value = result.data!.status == 'evaluated';
      resultComplete.value = result.data!.status == 'evaluated';
      _startResultPolling();
      await Get.toNamed(
        AppRoutes.finalExamSuccess,
        arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> loadResultByAttemptId({
    required String attemptId,
    bool showPendingMessage = true,
  }) async {
    final String normalizedAttemptId = attemptId.trim();

    if (normalizedAttemptId.isEmpty || isLoading.value) {
      return false;
    }

    isLoading.value = true;

    try {
      final ApiResult<FinalExamResultResponseModel> response =
      await ApiErrorHandler.call<
          FinalExamResultResponseModel>(
            () => _finalExamApiService.fetchResult(
          attemptId: normalizedAttemptId,
        ),
        showError: showPendingMessage,
        errorTitle: 'gen_final_exam_result'.tr,
      );

      if (!response.isSuccess || response.data == null) {
        return false;
      }

      final FinalExamResultResponseModel data =
      response.data!;
      _applyResultMetadata(data);

      referenceId.value = data.referenceCode;
      resultComplete.value = data.resultReady;
      teacherReviewComplete.value = data.resultReady;

      if (!data.resultReady) {
        result.value = null;

        if (showPendingMessage) {
          Get.snackbar(
            'gen_final_exam_result'.tr,
            data.message,
          );
        }

        return false;
      }

      result.value = FinalExamResultModel.fromReview(
        data.review,
        writingTaskEnabled: data.writingTaskEnabled,
      );

      _resultPollTimer?.cancel();

      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadResult({
    bool showPendingMessage = true,
    String? existingAttemptId,
  }) async {
    if (isLoading.value) return;

    final String attemptId = existingAttemptId?.trim().isNotEmpty == true
        ? existingAttemptId!.trim()
        : attempt.value?.id.trim() ?? '';

    if (attemptId.isEmpty) {
      if (showPendingMessage) {
        Get.snackbar(
          'gen_final_exam_result'.tr,
          'Result attempt was not found.',
        );
      }
      return;
    }

    isLoading.value = true;

    try {
      final ApiResult<FinalExamResultResponseModel> response =
      await ApiErrorHandler.call<FinalExamResultResponseModel>(
            () => _finalExamApiService.fetchResult(
          attemptId: attemptId,
        ),
        showError: showPendingMessage,
        errorTitle: 'gen_final_exam_result'.tr,
      );

      if (!response.isSuccess || response.data == null) {
        return;
      }

      final FinalExamResultResponseModel data = response.data!;
      _applyResultMetadata(data);

      referenceId.value = data.referenceCode;
      resultComplete.value = data.resultReady;
      teacherReviewComplete.value = data.resultReady;

      if (!data.resultReady) {
        result.value = null;

        if (showPendingMessage) {
          Get.snackbar(
            'gen_final_exam_result'.tr,
            data.message,
          );
        }

        return;
      }

      result.value = FinalExamResultModel.fromReview(
        data.review,
        writingTaskEnabled: data.writingTaskEnabled,
      );

      _resultPollTimer?.cancel();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startRetake() async {
    if (isSubmitting.value) {
      return;
    }

    if (!retakeAvailable.value) {
      Get.snackbar(
        'gen_final_exam'.tr,
        'A new exam attempt is not available.',
      );
      return;
    }

    final String resolvedCourseId =
    courseId.trim().isNotEmpty
        ? courseId.trim()
        : resultCourseId.value.trim();

    if (resolvedCourseId.isEmpty) {
      Get.snackbar(
        'gen_final_exam'.tr,
        'The course for this exam could not be found.',
      );
      return;
    }

    FinalExamAttemptModel? startedAttempt;

    isSubmitting.value = true;

    try {
      final ApiResult<FinalExamAttemptModel> response =
      await ApiErrorHandler.call<
          FinalExamAttemptModel>(
            () => _finalExamApiService.startAttempt(
          courseId: resolvedCourseId,
        ),
        errorTitle: 'gen_final_exam'.tr,
      );

      if (!response.isSuccess ||
          response.data == null) {
        return;
      }

      final FinalExamAttemptModel data =
      response.data!;

      startedAttempt = data;

      _resultPollTimer?.cancel();

      attempt.value = data;
      referenceId.value = data.referenceCode;
      resultCourseId.value = resolvedCourseId;

      _attemptStartedAt =
          data.startedAt ?? DateTime.now();

      _activeSectionIndex = -1;

      selectedListeningOption.value = -1;

      listeningTask.value = null;
      writingTask.value = null;
      speakingTask.value = null;

      writingController.clear();

      await _media.stopListeningAudio(
        reset: true,
      );

      await _media.stopRecordedAudio(
        reset: true,
      );

      await _media.resetRecording();

      result.value = null;
      resultComplete.value = false;
      teacherReviewComplete.value = false;

      estimatedResult.value = '';

      retakeAvailable.value = false;
      certificateAvailable.value = false;
    } finally {
      isSubmitting.value = false;
    }

    if (startedAttempt != null) {
      await _openSectionAt(0);
    }
  }

  Future<void> openResult() async {
    await loadResult();
    if (result.value == null) return;
    await Get.toNamed(
      AppRoutes.finalExamResult,
      arguments: ControllerTagRouteArguments(controllerTag: controllerTag),
    );
  }

  Future<void> openCertificate() async {
    if (!certificateAvailable.value) {
      Get.snackbar(
        'Certificate unavailable',
        'No certificate is available for this exam result.',
      );
      return;
    }

    final String currentAttemptId =
        attempt.value?.id.trim() ?? '';

    final String notificationAttemptId =
        initialAttemptId?.trim() ?? '';

    final String resolvedAttemptId =
    currentAttemptId.isNotEmpty
        ? currentAttemptId
        : notificationAttemptId;

    if (resolvedAttemptId.isEmpty) {
      Get.snackbar(
        'Certificate unavailable',
        'Final exam attempt was not found.',
      );
      return;
    }

    final String tag =
        'course_certificate_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.courseCertificate,
      arguments: CourseCertificateRouteArguments(
        controllerTag: tag,
        attemptId: resolvedAttemptId,
      ),
    );
  }

  void _startResultPolling() {
    _resultPollTimer?.cancel();
    unawaited(loadResult(showPendingMessage: false));
    _resultPollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(loadResult(showPendingMessage: false));
    });
  }

  FinalExamQuestionModel? _findQuestion(String questionId) {
    for (final FinalExamSectionModel section in
        attempt.value?.sections ?? const <FinalExamSectionModel>[]) {
      for (final FinalExamQuestionModel question in section.questions) {
        if (question.id == questionId) return question;
      }
    }
    return null;
  }

  FinalExamSectionModel? _sectionAt(int index) {
    final List<FinalExamSectionModel> sections =
        attempt.value?.sections ?? const <FinalExamSectionModel>[];
    if (index < 0 || index >= sections.length) return null;
    return sections[index];
  }

  void toggleListeningAudio() {
    unawaited(_media.toggleListeningAudio(listeningTask.value?.audioUrl ?? ''));
  }

  void selectListeningOption(int index) {
    selectedListeningOption.value = index;
  }

  void startRecording() {
    unawaited(
      _media.startRecording(
        maxDurationSeconds: speakingTask.value?.maxDurationSeconds ?? 60,
      ),
    );
  }

  void stopRecording() => unawaited(_media.stopRecording());
  void resetRecording() => unawaited(_media.resetRecording());
  void toggleRecordedAudio() => unawaited(_media.toggleRecordedAudio());
}
