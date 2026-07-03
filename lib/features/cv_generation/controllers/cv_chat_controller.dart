import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_error_handler.dart';
import '../models/cv_assistant_models.dart';
import '../models/cv_template_model.dart';
import '../services/cv_generation_api_service.dart';
import '../views/cv_generation_view.dart';
import 'cv_generation_controller.dart';

class CvChatController extends GetxController {
  CvChatController({
    required CvGenerationApiService apiService,
    required CvAssistantSessionModel initialSession,
    required this.selectedTemplate,
    ImagePicker? imagePicker,
  }) : _apiService = apiService,
        _imagePicker = imagePicker ?? ImagePicker(),
        session = initialSession.obs;

  final CvGenerationApiService _apiService;
  final ImagePicker _imagePicker;

  final CvTemplateModel? selectedTemplate;

  final Rx<CvAssistantSessionModel> session;
  final RxBool isSwitchingMode = false.obs;

  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  final RxBool isSending = false.obs;
  final RxBool isSkipping = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isGenerating = false.obs;

  final Rxn<XFile> localProfilePhoto =
  Rxn<XFile>();

  final RxList<XFile> localReferenceImages =
      <XFile>[].obs;

  List<CvAssistantMessageModel> get messages =>
      session.value.messages;

  CvAssistantQuestionModel? get currentQuestion =>
      session.value.currentQuestion;

  bool get hasTemplate =>
      selectedTemplate != null;

  bool get hasProfilePhoto =>
      session.value.profilePhotoFileId != null;

  int get referenceImageCount =>
      session.value.referenceImageFileIds.length;

  bool get isBusy =>
      isSending.value ||
          isSkipping.value ||
          isUploading.value ||
          isGenerating.value ||
          isSwitchingMode.value;

  CvAssistantConversationMode
  get conversationMode =>
      session.value.conversationMode;

  bool get isOneByOneMode =>
      conversationMode ==
          CvAssistantConversationMode.oneByOne;

  bool get isAllAtOnceMode =>
      conversationMode ==
          CvAssistantConversationMode.allAtOnce;

  Future<void> sendMessage() async {
    final String message =
    messageController.text.trim();

    if (message.isEmpty || isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isSending.value = true;

    try {
      final CvAssistantSessionModel updated =
      await _apiService.sendCvAssistantMessage(
        sessionId: session.value.id,
        message: message,
      );

      messageController.clear();
      session.value = updated;

      _scrollToBottom();
    } catch (error) {
      _showError(
        'Message not sent',
        error,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> skipCurrentQuestion() async {
    if (isBusy) {
      return;
    }

    isSkipping.value = true;

    try {
      final CvAssistantSessionModel updated =
      await _apiService
          .skipCvAssistantQuestion(
        session.value.id,
      );

      session.value = updated;
      _scrollToBottom();
    } catch (error) {
      _showError(
        'Question could not be skipped',
        error,
      );
    } finally {
      isSkipping.value = false;
    }
  }

  Future<void> pickProfilePhoto() async {
    if (isBusy) {
      return;
    }

    final XFile? image =
    await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1800,
    );

    if (image == null) {
      return;
    }

    final String? validationError =
    await _validateImage(image);

    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    isUploading.value = true;

    try {
      final String fileId =
      await _apiService.uploadCvImage(
        file: image,
        filePurpose: 'cv_photo',
      );

      final CvAssistantSessionModel updated =
      await _apiService
          .attachCvAssistantAssets(
        sessionId: session.value.id,
        profilePhotoFileId: fileId,
      );

      localProfilePhoto.value = image;
      session.value = updated;
      _scrollToBottom();
    } catch (error) {
      _showError(
        'Profile photo upload failed',
        error,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> pickReferenceImages() async {
    if (isBusy) {
      return;
    }

    final List<XFile> selectedImages =
    await _imagePicker.pickMultiImage(
      imageQuality: 90,
      maxWidth: 2000,
    );

    if (selectedImages.isEmpty) {
      return;
    }

    final int remainingSlots =
        6 - referenceImageCount;

    if (remainingSlots <= 0) {
      _showValidationError(
        'You can upload a maximum of 6 reference images.',
      );
      return;
    }

    final List<XFile> validImages = <XFile>[];

    for (final XFile image
    in selectedImages.take(remainingSlots)) {
      final String? validationError =
      await _validateImage(image);

      if (validationError == null) {
        validImages.add(image);
      }
    }

    if (validImages.isEmpty) {
      _showValidationError(
        'Select JPG, PNG, or WebP images under 5 MB.',
      );
      return;
    }

    isUploading.value = true;

    try {
      final List<String> uploadedFileIds =
      <String>[];

      for (final XFile image in validImages) {
        final String fileId =
        await _apiService.uploadCvImage(
          file: image,
          filePurpose: 'cv_reference_image',
        );

        uploadedFileIds.add(fileId);
      }

      final CvAssistantSessionModel updated =
      await _apiService
          .attachCvAssistantAssets(
        sessionId: session.value.id,
        referenceImageFileIds:
        uploadedFileIds,
      );

      localReferenceImages.addAll(validImages);
      session.value = updated;
      _scrollToBottom();
    } catch (error) {
      _showError(
        'Reference image upload failed',
        error,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> generateNow() async {
    if (isBusy) {
      return;
    }

    isGenerating.value = true;

    try {
      final String generationId =
      await _apiService.generateCvFromSession(
        session.value.id,
      );

      if (Get.isRegistered<
          CvGenerationController>()) {
        await Get.delete<CvGenerationController>(
          force: true,
        );
      }

      await Get.to<void>(
            () => const CvGenerationView(),
        binding: BindingsBuilder(() {
          Get.put<CvGenerationController>(
            CvGenerationController(
              apiService: _apiService,
              initialGenerationId:
              generationId,
            ),
          );
        }),
        transition: Transition.rightToLeft,
      );
    } catch (error) {
      _showError(
        'CV generation could not start',
        error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<String?> _validateImage(
      XFile file,
      ) async {
    final String name = file.name
        .trim()
        .toLowerCase();

    final bool supported =
        name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.webp');

    if (!supported) {
      return 'Only JPG, PNG, and WebP images are supported.';
    }

    final int sizeBytes = await file.length();

    if (sizeBytes > 5 * 1024 * 1024) {
      return 'Each image must not exceed 5 MB.';
    }

    return null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!scrollController.hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration:
          const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      },
    );
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Invalid image',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showError(
      String title,
      Object error,
      ) {
    Get.snackbar(
      title,
      ApiErrorHandler.getErrorMessage(error),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> switchConversationMode(
      CvAssistantConversationMode mode,
      ) async {
    if (isBusy ||
        session.value.conversationMode == mode) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isSwitchingMode.value = true;

    try {
      final CvAssistantSessionModel updated =
      await _apiService
          .changeCvAssistantConversationMode(
        sessionId: session.value.id,
        mode: mode,
      );

      session.value = updated;
      _scrollToBottom();
    } catch (error) {
      _showError(
        'Conversation mode could not be changed',
        error,
      );
    } finally {
      isSwitchingMode.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _scrollToBottom();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}