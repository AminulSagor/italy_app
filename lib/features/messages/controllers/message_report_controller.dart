import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_models.dart';
import '../services/messages_mock_service.dart';
import '../views/message_report_success_view.dart';
import '../../../routes/app_routes.dart';

class MessageReportController extends GetxController {
  static const List<String> reportReasons = <String>[
    'Spam',
    'Harassment',
    'Inappropriate Content',
    'Fake Profile',
  ];

  final String threadId;
  final MessageUserProfileModel profile;
  final MessagesMockService _messagesMockService;
  final ImagePicker _imagePicker;

  MessageReportController({
    required this.threadId,
    required this.profile,
    required MessagesMockService messagesMockService,
    ImagePicker? imagePicker,
  })  : _messagesMockService = messagesMockService,
        _imagePicker = imagePicker ?? ImagePicker();

  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedReason = reportReasons.first.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<XFile> evidenceImage = Rxn<XFile>();
  final Rxn<MessageReportResultModel> reportResult = Rxn<MessageReportResultModel>();

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> pickEvidenceImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );

    if (image == null) {
      return;
    }

    final int fileSize = await File(image.path).length();
    if (fileSize > 5 * 1024 * 1024) {
      Get.snackbar(
        'File too large',
        'Please select a PNG or JPG under 5MB.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    evidenceImage.value = image;
  }

  void removeEvidenceImage() {
    evidenceImage.value = null;
  }

  Future<void> submitReport() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      final MessageReportResultModel result = await _messagesMockService
          .submitReport(
        MessageReportRequestModel(
          threadId: threadId,
          reason: selectedReason.value,
          description: descriptionController.text.trim(),
          evidencePath: evidenceImage.value?.path,
        ),
      );

      reportResult.value = result;
      Get.to<void>(
        () => const MessageReportSuccessView(),
        transition: Transition.rightToLeft,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void backToMessages() {
    Get.until(
      (route) => route.settings.name == AppRoutes.wrapper || route.isFirst,
    );
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
