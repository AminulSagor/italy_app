import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_assistant_models.dart';
import '../models/cv_generation_models.dart';
import '../services/cv_generation_api_service.dart';
import '../services/cv_pdf_service.dart';
import '../views/cv_chat_view.dart';
import 'cv_chat_controller.dart';

class CvGenerationController extends GetxController {
  CvGenerationController({
    required CvGenerationApiService apiService,
    required String initialGenerationId,
    CvPdfService? pdfService,
  })  : _apiService = apiService,
        _pdfService = pdfService ?? CvPdfService(),
        _generationId = initialGenerationId.trim();

  static const int _maximumPollAttempts = 120;
  static const Duration _pollInterval =
  Duration(seconds: 2);

  final CvGenerationApiService _apiService;
  final CvPdfService _pdfService;

  String _generationId;

  final Rxn<CvGenerationModel> generation =
  Rxn<CvGenerationModel>();

  final RxBool isLoading = true.obs;
  final RxBool isPolling = false.obs;
  final RxBool isRegenerating = false.obs;
  final RxBool isStartingEdit = false.obs;
  final RxBool isCreatingPdf = false.obs;

  final RxBool isFullScreenPreview = false.obs;
  final RxDouble previewScale = 1.0.obs;

  final RxString errorMessage = ''.obs;
  final RxString editErrorMessage = ''.obs;
  final RxString pdfErrorMessage = ''.obs;

  final TransformationController
  previewTransformationController =
  TransformationController();

  bool _disposed = false;
  int _pollRunId = 0;

  String get generationId => _generationId;

  String? get generatedImageUrl {
    final String value =
        generation.value?.generatedImageUrl?.trim() ?? '';

    return value.isEmpty ? null : value;
  }

  bool get isCompleted {
    return generation.value?.isCompleted == true;
  }

  bool get isFailed {
    return generation.value?.isFailed == true;
  }

  bool get isProcessing {
    return generation.value?.isProcessing == true;
  }

  bool get canEdit {
    return isCompleted &&
        !isStartingEdit.value &&
        !isRegenerating.value &&
        !isCreatingPdf.value;
  }

  bool get canCreatePdf {
    return isCompleted &&
        generatedImageUrl != null &&
        !isCreatingPdf.value;
  }

  bool get canOpenPreview {
    return isCompleted && generatedImageUrl != null;
  }

  @override
  void onInit() {
    super.onInit();

    if (_generationId.isEmpty) {
      isLoading.value = false;
      errorMessage.value =
      'The generation ID is missing.';
      return;
    }

    unawaited(_pollUntilFinished());
  }

  Future<void> retry() async {
    if (isPolling.value) {
      return;
    }

    errorMessage.value = '';
    await _pollUntilFinished();
  }

  Future<void> startFactsOnlyEdit() {
    return _startAssistantEdit(
      CvAssistantEditMode.factsOnly,
    );
  }

  Future<void> startDesignAndFactsEdit() {
    return _startAssistantEdit(
      CvAssistantEditMode.designAndFacts,
    );
  }

  Future<void> _startAssistantEdit(
      CvAssistantEditMode editMode,
      ) async {
    if (!canEdit) {
      return;
    }

    isStartingEdit.value = true;
    editErrorMessage.value = '';

    try {
      final CvAssistantSessionModel session;

      switch (editMode) {
        case CvAssistantEditMode.factsOnly:
          session =
          await _apiService.startFactsOnlyEdit(
            _generationId,
          );

        case CvAssistantEditMode.designAndFacts:
          session = await _apiService
              .startDesignAndFactsEdit(
            _generationId,
          );
      }

      await _openAssistantEdit(session);
    } catch (error) {
      editErrorMessage.value =
          ApiErrorHandler.getErrorMessage(error);

      Get.snackbar(
        'Unable to start editing',
        editErrorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isStartingEdit.value = false;
    }
  }

  Future<void> _openAssistantEdit(
      CvAssistantSessionModel session,
      ) async {
    final String controllerTag =
        'cv-chat-edit-${session.id}-${DateTime.now().microsecondsSinceEpoch}';

    await Get.to<void>(
          () => CvChatView(
        controllerTag: controllerTag,
      ),
      binding: BindingsBuilder(
            () {
          Get.put<CvChatController>(
            CvChatController(
              apiService: _apiService,
              initialSession: session,
              selectedTemplate: null,
            ),
            tag: controllerTag,
          );
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> regenerateDesign(
      String designInstruction,
      ) async {
    final String instruction =
    designInstruction.trim();

    if (instruction.isEmpty) {
      Get.snackbar(
        'Design instruction required',
        'Describe how you want the CV design to change.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isRegenerating.value ||
        isStartingEdit.value ||
        isCreatingPdf.value) {
      return;
    }

    isRegenerating.value = true;
    errorMessage.value = '';

    try {
      /*
       * Invalidates any existing polling loop before changing
       * to the newly created generation.
       */
      _pollRunId++;

      final CvGenerationModel created =
      await _apiService.regenerateDesign(
        generationId: _generationId,
        designInstruction: instruction,
      );

      _generationId = created.id;
      generation.value = created;

      resetZoom();

      await _pollUntilFinished();
    } catch (error) {
      errorMessage.value =
          ApiErrorHandler.getErrorMessage(error);
    } finally {
      isRegenerating.value = false;
    }
  }

  Future<void> createPdf() async {
    if (!canCreatePdf ||
        isCreatingPdf.value) {
      return;
    }

    final String imageUrl =
        generatedImageUrl?.trim() ?? '';

    if (imageUrl.isEmpty) {
      Get.snackbar(
        'PDF unavailable',
        'The generated CV image is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isCreatingPdf.value = true;
    pdfErrorMessage.value = '';

    try {
      final String savedLocation =
      await _pdfService.createAndSaveA4Pdf(
        imageUrl: imageUrl,
        fileName:
        'cv-$_generationId.pdf',
      );

      Get.snackbar(
        'PDF downloaded',
        'Saved to $savedLocation',
        snackPosition:
        SnackPosition.BOTTOM,
        duration:
        const Duration(seconds: 5),
      );
    } catch (error) {
      pdfErrorMessage.value =
          ApiErrorHandler.getErrorMessage(
            error,
          );

      Get.snackbar(
        'PDF download failed',
        pdfErrorMessage.value,
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      isCreatingPdf.value = false;
    }
  }

  void openFullScreenPreview() {
    if (!canOpenPreview) {
      return;
    }

    isFullScreenPreview.value = true;
  }

  void closeFullScreenPreview() {
    isFullScreenPreview.value = false;
    resetZoom();
  }

  void toggleFullScreenPreview() {
    if (isFullScreenPreview.value) {
      closeFullScreenPreview();
    } else {
      openFullScreenPreview();
    }
  }

  void zoomIn() {
    _setPreviewScale(
      previewScale.value * 1.35,
    );
  }

  void zoomOut() {
    _setPreviewScale(
      previewScale.value / 1.35,
    );
  }

  void resetZoom() {
    previewScale.value = 1;
    previewTransformationController.value =
        Matrix4.identity();
  }

  void syncPreviewScale() {
    final double scale =
    previewTransformationController.value
        .getMaxScaleOnAxis();

    previewScale.value =
        scale.clamp(1.0, 5.0).toDouble();
  }

  void _setPreviewScale(
      double requestedScale,
      ) {
    final double scale =
    requestedScale.clamp(1.0, 5.0).toDouble();

    previewScale.value = scale;

    previewTransformationController.value =
    Matrix4.identity()
      ..scale(
        scale,
        scale,
        1,
      );
  }

  Future<void> _pollUntilFinished() async {
    final int currentRunId = ++_pollRunId;

    isLoading.value = true;
    isPolling.value = true;
    errorMessage.value = '';

    for (
    int attempt = 0;
    attempt < _maximumPollAttempts;
    attempt++
    ) {
      if (_disposed ||
          currentRunId != _pollRunId) {
        return;
      }

      try {
        final CvGenerationModel updated =
        await _apiService.fetchGeneration(
          _generationId,
        );

        if (_disposed ||
            currentRunId != _pollRunId) {
          return;
        }

        generation.value = updated;

        if (updated.isCompleted) {
          isLoading.value = false;
          isPolling.value = false;
          return;
        }

        if (updated.isFailed) {
          isLoading.value = false;
          isPolling.value = false;

          errorMessage.value =
              updated.errorMessage ??
                  'CV generation failed.';
          return;
        }
      } catch (error) {
        if (attempt ==
            _maximumPollAttempts - 1) {
          isLoading.value = false;
          isPolling.value = false;

          errorMessage.value =
              ApiErrorHandler.getErrorMessage(
                error,
              );
          return;
        }
      }

      await Future<void>.delayed(
        _pollInterval,
      );
    }

    if (_disposed ||
        currentRunId != _pollRunId) {
      return;
    }

    isLoading.value = false;
    isPolling.value = false;
    errorMessage.value =
    'The CV is taking longer than expected.';
  }

  @override
  void onClose() {
    _disposed = true;
    _pollRunId++;

    previewTransformationController.dispose();

    super.onClose();
  }
}