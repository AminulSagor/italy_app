import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../models/ai_content_report_model.dart';

class AiContentReportService {
  AiContentReportService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  static const String _endpoint = '/api/v1/ai-content-reports';

  Future<void> submitReport({
    required AiContentReportSource source,
    required AiReportIssue issue,
    String? details,
    File? screenshot,
  }) async {
    if (!source.hasAutomaticAttachment) {
      throw StateError('The reported AI content is missing.');
    }

    final String normalizedDetails = details?.trim() ?? '';

    final Map<String, dynamic> fields = <String, dynamic>{
      'featureType': source.featureType.apiValue,
      'issue': issue.apiValue,
      'clientReportId': const Uuid().v4(),
    };

    if (normalizedDetails.isNotEmpty) {
      fields['details'] = normalizedDetails;
    }

    if (source.aiContentText?.trim().isNotEmpty ?? false) {
      fields['aiContentText'] = source.aiContentText!.trim();
    }

    if (source.aiContentFileId?.trim().isNotEmpty ?? false) {
      fields['aiContentFileId'] = source.aiContentFileId!.trim();
    }

    if (source.aiContentUrl?.trim().isNotEmpty ?? false) {
      fields['aiContentUrl'] = source.aiContentUrl!.trim();
    }

    if (source.sourceReference?.trim().isNotEmpty ?? false) {
      fields['sourceReference'] = source.sourceReference!.trim();
    }

    if (source.messageReference?.trim().isNotEmpty ?? false) {
      fields['messageReference'] = source.messageReference!.trim();
    }

    if (screenshot != null) {
      fields['screenshot'] = await MultipartFile.fromFile(
        screenshot.path,
        filename: screenshot.uri.pathSegments.last,
      );
    }

    final FormData formData = FormData.fromMap(fields);

    // Connect this call to the existing Dio instance inside ApiClient.
    await _apiClient.dio.post<void>(
      _endpoint,
      data: formData,
    );
  }
}