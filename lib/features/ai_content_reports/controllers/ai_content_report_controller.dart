import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ai_content_report_model.dart';
import '../services/ai_content_report_service.dart';

class AiContentReportController extends GetxController {
  AiContentReportController({
    required this.source,
    AiContentReportService? service,
  }) : _service = service ?? AiContentReportService();

  final AiContentReportSource source;
  final AiContentReportService _service;

  final TextEditingController detailsController = TextEditingController();

  final Rxn<AiReportIssue> selectedIssue = Rxn<AiReportIssue>();
  final Rxn<File> screenshot = Rxn<File>();
  final RxBool isSubmitting = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> selectScreenshot() async {
    final XFile? selectedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (selectedFile == null) {
      return;
    }

    screenshot.value = File(selectedFile.path);
  }

  void removeScreenshot() {
    screenshot.value = null;
  }

  Future<bool> submit() async {
    final AiReportIssue? issue = selectedIssue.value;

    if (issue == null) {
      Get.snackbar(
        'ai_report_title'.tr,
        'ai_report_select_issue'.tr,
      );
      return false;
    }

    if (!source.hasAutomaticAttachment) {
      Get.snackbar(
        'ai_report_title'.tr,
        'ai_report_content_missing'.tr,
      );
      return false;
    }

    if (isSubmitting.value) {
      return false;
    }

    isSubmitting.value = true;

    try {
      await _service.submitReport(
        source: source,
        issue: issue,
        details: detailsController.text,
        screenshot: screenshot.value,
      );

      Get.snackbar(
        'ai_report_success_title'.tr,
        'ai_report_success_message'.tr,
      );

      return true;
    } catch (_) {
      Get.snackbar(
        'ai_report_error_title'.tr,
        'ai_report_error_message'.tr,
      );

      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    detailsController.dispose();
    super.onClose();
  }
}