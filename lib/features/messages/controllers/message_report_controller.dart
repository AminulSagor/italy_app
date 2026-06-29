import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_models.dart';
import '../services/messages_service.dart';
import '../views/message_report_success_view.dart';
import '../../../routes/app_routes.dart';

class MessageReportController extends GetxController {
  final String threadId;
  final MessageUserProfileModel profile;
  final MessagesMockService _messagesMockService;
  final ImagePicker _imagePicker;

  MessageReportController({
    required this.threadId,
    required this.profile,
    required MessagesMockService messagesMockService,
    ImagePicker? imagePicker,
  }) : _messagesMockService = messagesMockService,
       _imagePicker = imagePicker ?? ImagePicker();

  final TextEditingController descriptionController = TextEditingController();
  final RxList<Map<String, dynamic>> reportReasons =
      <Map<String, dynamic>>[].obs;
  final RxString selectedReasonId = ''.obs;
  final RxBool isLoadingReasons = false.obs;
  final RxBool hasReasonsError = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<XFile> evidenceImage = Rxn<XFile>();
  final Rxn<MessageReportResultModel> reportResult =
      Rxn<MessageReportResultModel>();

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool _isUuid(String s) => _uuidRegExp.hasMatch(s);

  void selectReason(String reasonId) {
    selectedReasonId.value = reasonId;
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

    final String ext = image.path.toLowerCase();
    if (!(ext.endsWith('.png') ||
        ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.webp'))) {
      Get.snackbar(
        'Unsupported file',
        'Please select a PNG, JPG or WEBP image.',
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

    final String reasonId = selectedReasonId.value.trim();

    if (reasonId.isEmpty) {
      Get.snackbar(
        'Select reason',
        'Please choose a reason for the report.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Enforce that reasonId is always a server UUID.
    // If the loaded reasons list doesn't map to a UUID for this selection,
    // block submission and ask the user to reload reasons.
    if (!_isUuid(reasonId)) {
      // Attempt to resolve it from the currently loaded reasons list.
      final String? resolvedUuid = _resolveToUuid(reasonId, reportReasons);
      if (resolvedUuid != null) {
        selectedReasonId.value = resolvedUuid;
      } else {
        // UUID not found locally — try fetching fresh reasons.
        Get.snackbar(
          'Reason unavailable',
          'Could not resolve reason. Please tap "Reload reasons" and try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    final String desc = descriptionController.text.trim();
    if (desc.length > 500) {
      Get.snackbar(
        'Description too long',
        'Description must be 500 characters or less.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final String clientReportId =
          'report-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecondsSinceEpoch}';

      final MessageReportRequestModel req = MessageReportRequestModel(
        reportedUserId: threadId,
        reasonId: selectedReasonId.value.trim(),
        description: desc,
        evidencePath: evidenceImage.value?.path,
        clientReportId: clientReportId,
      );

      final MessageReportResultModel result = await _messagesMockService
          .submitReport(req);
      reportResult.value = result;
      Get.to<void>(
        () => const MessageReportSuccessView(),
        transition: Transition.rightToLeft,
      );
    } catch (e) {
      Get.snackbar(
        'Report failed',
        'Could not submit report. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Returns the UUID `id` for a given [value] (which may itself already be a
  /// UUID, or a title/name string) by searching [reasons].
  String? _resolveToUuid(
    String value,
    List<Map<String, dynamic>> reasons,
  ) {
    for (final Map<String, dynamic> r in reasons) {
      final String id = r['id']?.toString() ?? '';
      final String title = r['title']?.toString() ?? '';
      final String name = r['name']?.toString() ?? '';
      if (id == value || id.toLowerCase() == value.toLowerCase()) {
        return _isUuid(id) ? id : null;
      }
      if (title.toLowerCase() == value.toLowerCase() ||
          name.toLowerCase() == value.toLowerCase()) {
        return _isUuid(id) ? id : null;
      }
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadReportReasons();
  }

  /// Public so the UI can offer a "Reload reasons" retry button.
  Future<void> retryLoadReasons() => _loadReportReasons();

  Future<void> _loadReportReasons() async {
    isLoadingReasons.value = true;
    hasReasonsError.value = false;
    try {
      final List<Map<String, dynamic>> reasons =
          await _messagesMockService.fetchReportReasons();

      if (reasons.isNotEmpty) {
        // Only keep reasons that have a valid UUID id so we never accidentally
        // send a free-text key to the backend.
        final List<Map<String, dynamic>> valid = reasons
            .where((Map<String, dynamic> r) => _isUuid(r['id']?.toString() ?? ''))
            .toList();

        if (valid.isNotEmpty) {
          reportReasons.assignAll(valid);
          // Pre-select the first valid reason.
          selectedReasonId.value = valid.first['id']!.toString();
        } else {
          // Server returned reasons but none had UUID ids — show all and let
          // the submit guard catch it.
          reportReasons.assignAll(reasons);
          selectedReasonId.value = '';
          hasReasonsError.value = true;
        }
      } else {
        // Network returned nothing — do NOT fall back to hardcoded non-UUID ids.
        reportReasons.clear();
        selectedReasonId.value = '';
        hasReasonsError.value = true;
      }
    } catch (_) {
      reportReasons.clear();
      selectedReasonId.value = '';
      hasReasonsError.value = true;
    } finally {
      isLoadingReasons.value = false;
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
