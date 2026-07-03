import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_generation_models.dart';
import '../services/cv_generation_api_service.dart';

class CvGenerationController
    extends GetxController {
  CvGenerationController({
    required CvGenerationApiService apiService,
    required String initialGenerationId,
  }) : _apiService = apiService,
        _generationId = initialGenerationId;

  final CvGenerationApiService _apiService;

  String _generationId;

  final Rxn<CvGenerationModel> generation =
  Rxn<CvGenerationModel>();

  final RxBool isLoading = true.obs;
  final RxBool isRegenerating = false.obs;
  final RxString errorMessage = ''.obs;

  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(_pollUntilFinished());
  }

  Future<void> retry() async {
    errorMessage.value = '';
    isLoading.value = true;

    await _pollUntilFinished();
  }

  Future<void> regenerate() async {
    if (isRegenerating.value) {
      return;
    }

    isRegenerating.value = true;
    errorMessage.value = '';

    try {
      final CvGenerationModel created =
      await _apiService.regenerate(
        _generationId,
      );

      _generationId = created.id;
      generation.value = created;

      await _pollUntilFinished();
    } catch (error) {
      errorMessage.value =
          ApiErrorHandler.getErrorMessage(error);
    } finally {
      isRegenerating.value = false;
    }
  }

  Future<void> _pollUntilFinished() async {
    isLoading.value = true;

    for (int attempt = 0;
    attempt < 120;
    attempt++) {
      if (_disposed) {
        return;
      }

      try {
        final CvGenerationModel updated =
        await _apiService.fetchGeneration(
          _generationId,
        );

        generation.value = updated;

        if (updated.isCompleted) {
          isLoading.value = false;
          return;
        }

        if (updated.isFailed) {
          isLoading.value = false;
          errorMessage.value =
              updated.errorMessage ??
                  'CV generation failed.';
          return;
        }
      } catch (error) {
        if (attempt == 119) {
          isLoading.value = false;
          errorMessage.value =
              ApiErrorHandler.getErrorMessage(error);
          return;
        }
      }

      await Future<void>.delayed(
        const Duration(seconds: 2),
      );
    }

    isLoading.value = false;
    errorMessage.value =
    'The CV is taking longer than expected.';
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}