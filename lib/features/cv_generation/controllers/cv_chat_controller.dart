import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_routes.dart';
import '../models/cv_assistant_models.dart';
import '../models/cv_template_model.dart';
import '../services/cv_generation_api_service.dart';
import '../views/cv_generation_view.dart';
import 'cv_generation_controller.dart';
import 'cv_home_controller.dart';

class CvChatController extends GetxController {
  CvChatController({
    required CvGenerationApiService apiService,
    required CvAssistantSessionModel initialSession,
    required this.selectedTemplate,
    ImagePicker? imagePicker,
  })  : _apiService = apiService,
        _imagePicker = imagePicker ?? ImagePicker(),
        session = initialSession.obs {
    displayMessages.assignAll(initialSession.messages);
  }

  final CvGenerationApiService _apiService;
  final ImagePicker _imagePicker;

  final CvTemplateModel? selectedTemplate;

  final Rx<CvAssistantSessionModel> session;

  /// Includes backend messages and temporary optimistic messages.
  final RxList<CvAssistantMessageModel> displayMessages =
      <CvAssistantMessageModel>[].obs;

  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  final RxBool isSending = false.obs;
  final RxBool isAssistantThinking = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isSwitchingMode = false.obs;

  /// The view can use this to show the validation panel.
  final RxBool isValidationPanelVisible = false.obs;

  final Rxn<XFile> localProfilePhoto = Rxn<XFile>();

  final RxList<XFile> localReferenceImages =
      <XFile>[].obs;

  bool _generationRequestLocked = false;

  List<CvAssistantMessageModel> get messages {
    return displayMessages;
  }

  CvAssistantQuestionModel? get currentQuestion {
    return session.value.currentQuestion;
  }

  List<CvPendingSuggestionModel>
  get pendingSuggestions {
    return session.value.pendingSuggestions;
  }

  CvAssistantPhotoDecision get photoDecision {
    return session.value.photoDecision;
  }

  bool get hasTemplate {
    return selectedTemplate != null;
  }

  bool get hasProfilePhoto {
    return session.value.profilePhotoFileId != null;
  }

  bool get hasPendingSuggestion {
    return pendingSuggestions.isNotEmpty;
  }

  bool get hasUnresolvedPhotoDecision {
    return session.value.hasUnresolvedPhotoDecision;
  }

  int get referenceImageCount {
    return session.value.referenceImageFileIds.length;
  }

  bool get isBusy {
    return isSending.value ||
        isUploading.value ||
        isGenerating.value ||
        isSwitchingMode.value;
  }

  bool get canGenerateNow {
    return session.value.isReadyToGenerate &&
        !isBusy &&
        !_generationRequestLocked;
  }

  CvAssistantConversationMode get conversationMode {
    return session.value.conversationMode;
  }

  bool get isOneByOneMode {
    return conversationMode ==
        CvAssistantConversationMode.oneByOne;
  }

  bool get isAllAtOnceMode {
    return conversationMode ==
        CvAssistantConversationMode.allAtOnce;
  }

  /// Uses only blocker information returned by the backend.
  List<String> get backendBlockers {
    final List<String> blockers = <String>[
      ...session.value.generationBlockers,
      ...session.value.missingRequiredFields,
      ...session.value.missingTemplateSections,
      ...session.value.unresolvedOptionalSections,
      ...session.value.qualityIssues,
    ];

    if (session.value.pendingSuggestions.isNotEmpty) {
      blockers.add(
        session.value.pendingSuggestions.length == 1
            ? 'One suggestion needs your response.'
            : '${session.value.pendingSuggestions.length} suggestions need your response.',
      );
    }

    if (session.value.hasUnresolvedPhotoDecision) {
      blockers.add(
        'Choose whether to upload a photo or continue without one.',
      );
    }

    final List<String> uniqueBlockers = <String>[];

    for (final String blocker in blockers) {
      final String normalized = blocker.trim();

      if (normalized.isNotEmpty &&
          !uniqueBlockers.contains(normalized)) {
        uniqueBlockers.add(normalized);
      }
    }

    return uniqueBlockers;
  }

  Future<void> sendMessage() async {
    final String message =
    messageController.text.trim();

    if (message.isEmpty || isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    /// Clear immediately because the optimistic bubble appears
    /// immediately in the message list.
    messageController.clear();

    await _sendNaturalLanguageMessage(
      message: message,
      addOptimisticMessage: true,
    );
  }

  Future<void> sendQuickReply(
      String message,
      ) async {
    final String normalized = message.trim();

    if (normalized.isEmpty || isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    await _sendNaturalLanguageMessage(
      message: normalized,
      addOptimisticMessage: true,
    );
  }

  Future<void> acceptSuggestion() {
    return sendQuickReply('Accept');
  }

  Future<void> rejectSuggestion() {
    return sendQuickReply('Reject');
  }

  /// The UI should open an editable field containing the
  /// suggested wording and pass the edited value here.
  Future<void> submitEditedSuggestion(
      String editedText,
      ) async {
    final String normalized = editedText.trim();

    if (normalized.isEmpty) {
      Get.snackbar(
        'Edited suggestion required',
        'Enter the wording you want to use.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await sendQuickReply(normalized);
  }

  Future<void> continueWithoutPhoto() {
    return sendQuickReply(
      'Continue without a photo.',
    );
  }

  Future<void> markCurrentStepDone() {
    return sendQuickReply('Done');
  }

  Future<void> _sendNaturalLanguageMessage({
    required String message,
    required bool addOptimisticMessage,
    String? existingOptimisticId,
  }) async {
    if (isSending.value) {
      return;
    }

    final String optimisticId =
        existingOptimisticId ??
            'local-${DateTime.now().microsecondsSinceEpoch}';

    if (addOptimisticMessage) {
      displayMessages.add(
        CvAssistantMessageModel(
          id: optimisticId,
          role: CvAssistantMessageRole.user,
          text: message,
          questionKey:
          session.value.currentQuestionKey,
          metadata: const <String, dynamic>{
            'localState': 'sending',
          },
          createdAt: DateTime.now(),
        ),
      );
    } else {
      _replaceLocalMessageState(
        messageId: optimisticId,
        state: 'sending',
      );
    }

    isSending.value = true;
    isAssistantThinking.value = true;

    _scrollToBottom();

    try {
      final CvAssistantSessionModel updated =
      await _apiService.sendCvAssistantMessage(
        sessionId: session.value.id,
        message: message,
      );

      _applySession(updated);
    } catch (error) {
      _replaceLocalMessageState(
        messageId: optimisticId,
        state: 'failed',
      );

      _showError(
        'Message not sent',
        error,
      );
    } finally {
      isSending.value = false;
      isAssistantThinking.value = false;
      _scrollToBottom();
    }
  }

  Future<void> retryFailedMessage(
      String messageId,
      ) async {
    if (isBusy) {
      return;
    }

    CvAssistantMessageModel? failedMessage;

    for (final CvAssistantMessageModel message
    in displayMessages) {
      if (message.id == messageId &&
          isMessageFailed(message)) {
        failedMessage = message;
        break;
      }
    }

    if (failedMessage == null ||
        failedMessage.text.trim().isEmpty) {
      return;
    }

    await _sendNaturalLanguageMessage(
      message: failedMessage.text,
      addOptimisticMessage: false,
      existingOptimisticId: failedMessage.id,
    );
  }

  bool isMessagePending(
      CvAssistantMessageModel message,
      ) {
    return message.metadata['localState'] ==
        'sending';
  }

  bool isMessageFailed(
      CvAssistantMessageModel message,
      ) {
    return message.metadata['localState'] ==
        'failed';
  }

  void _replaceLocalMessageState({
    required String messageId,
    required String state,
  }) {
    final int index = displayMessages.indexWhere(
          (CvAssistantMessageModel message) =>
      message.id == messageId,
    );

    if (index < 0) {
      return;
    }

    final CvAssistantMessageModel oldMessage =
    displayMessages[index];

    displayMessages[index] =
        CvAssistantMessageModel(
          id: oldMessage.id,
          role: oldMessage.role,
          text: oldMessage.text,
          questionKey: oldMessage.questionKey,
          metadata: <String, dynamic>{
            ...oldMessage.metadata,
            'localState': state,
          },
          createdAt: oldMessage.createdAt,
        );
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
      await _apiService.attachCvAssistantAssets(
        sessionId: session.value.id,
        profilePhotoFileId: fileId,
      );

      localProfilePhoto.value = image;
      _applySession(updated);
    } catch (error) {
      _showError(
        'Profile photo upload failed',
        error,
      );
    } finally {
      isUploading.value = false;
      _scrollToBottom();
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
      await _apiService.attachCvAssistantAssets(
        sessionId: session.value.id,
        referenceImageFileIds: uploadedFileIds,
      );

      localReferenceImages.addAll(validImages);
      _applySession(updated);
    } catch (error) {
      _showError(
        'Reference image upload failed',
        error,
      );
    } finally {
      isUploading.value = false;
      _scrollToBottom();
    }
  }

  void showGenerationBlockers() {
    isValidationPanelVisible.value = true;
  }

  void hideGenerationBlockers() {
    isValidationPanelVisible.value = false;
  }

  Future<void> generateNow() async {
    if (_generationRequestLocked ||
        isGenerating.value ||
        isSending.value ||
        isUploading.value ||
        isSwitchingMode.value) {
      return;
    }

    if (!session.value.isReadyToGenerate) {
      showGenerationBlockers();

      Get.snackbar(
        'Complete your CV',
        backendBlockers.isEmpty
            ? 'Complete the remaining assistant steps before generating.'
            : backendBlockers.first,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    _generationRequestLocked = true;
    isGenerating.value = true;

    try {
      final String generationId =
      await _apiService.generateCvFromSession(
        session.value.id,
      );

      /*
     * A new CV was successfully started.
     * Refresh the free allowance and purchased-credit
     * balance shown on the CV home page.
     */
      if (Get.isRegistered<CvHomeController>()) {
        unawaited(
          Get.find<CvHomeController>()
              .loadCvAccess(),
        );
      }

      await _openGeneration(
        generationId,
      );
    } on CvCreditRequiredException catch (error) {
      /*
     * The backend returns HTTP 402 when all free CV
     * creations are used and no purchased credit remains.
     */
      await Get.dialog<void>(
        AlertDialog(
          title: Text(
            'cv_credit_required_title'.tr,
          ),
          content: Text(
            error.message,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back<void>();
              },
              child: Text(
                'cancel'.tr,
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Get.back<void>();

                Get.toNamed(
                  AppRoutes.cvCreditStore,
                );
              },
              icon: const Icon(
                Icons.add_card_rounded,
              ),
              label: Text(
                'buy_cv_credits'.tr,
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } on CvGenerationAlreadyStartedException catch (error) {
      final bool recovered =
      await _recoverGenerationAfterConflict();

      if (!recovered) {
        Get.snackbar(
          'Generation already started',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      _showError(
        'CV generation could not start',
        error,
      );
    } finally {
      isGenerating.value = false;
      _generationRequestLocked = false;
    }
  }

  Future<bool>
  _recoverGenerationAfterConflict() async {
    try {
      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      final CvAssistantSessionModel refreshed =
      await _apiService.getCvAssistantSession(
        session.value.id,
      );

      _applySession(refreshed);

      final String generationId =
          refreshed.generationId?.trim() ?? '';

      if (generationId.isEmpty) {
        return false;
      }

      await _openGeneration(generationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openGeneration(
      String generationId,
      ) async {
    final String controllerTag =
        'cv-generation-$generationId';

    await Get.to<void>(
          () => CvGenerationView(
        controllerTag: controllerTag,
      ),
      binding: BindingsBuilder(
            () {
          Get.put<CvGenerationController>(
            CvGenerationController(
              apiService: _apiService,
              initialGenerationId: generationId,
            ),
            tag: controllerTag,
          );
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> switchConversationMode(
      CvAssistantConversationMode mode,
      ) async {
    if (isBusy ||
        session.value.isEditSession ||
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

      _applySession(updated);
    } catch (error) {
      _showError(
        'Conversation mode could not be changed',
        error,
      );
    } finally {
      isSwitchingMode.value = false;
      _scrollToBottom();
    }
  }

  void _applySession(
      CvAssistantSessionModel updated,
      ) {
    session.value = updated;
    displayMessages.assignAll(updated.messages);
    isValidationPanelVisible.value = false;
    _scrollToBottom();
  }

  Future<String?> _validateImage(
      XFile file,
      ) async {
    final String name =
    file.name.trim().toLowerCase();

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

  void _showValidationError(
      String message,
      ) {
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