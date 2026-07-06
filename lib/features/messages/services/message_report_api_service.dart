import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/message_models.dart';

class MessageReportApiService {
  MessageReportApiService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MessageReportResultModel> submitReport(
    MessageReportRequestModel request,
  ) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'reportedUserId': request.reportedUserId,
        'reasonId': request.reasonId,
        'description': request.description,
      };
      if (request.clientReportId?.isNotEmpty ?? false) {
        payload['clientReportId'] = request.clientReportId;
      }

      if (request.evidenceFileId?.isNotEmpty ?? false) {
        payload['evidenceFileId'] = request.evidenceFileId;
        return _createReport(payload);
      }

      if (request.evidencePath?.isNotEmpty ?? false) {
        final String? fileId = await _uploadEvidence(request.evidencePath!);
        if (fileId != null) {
          payload['evidenceFileId'] = fileId;
          return _createReport(payload);
        }
      }

      return await _createMultipartReport(request);
    } catch (_) {
      throw Exception('Failed to submit report');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReportReasons() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/user-reports/reasons',
      );
      final dynamic data = response.data;
      if (data is List) return _mapList(data);
      if (data is Map && data['data'] is List) {
        return _mapList(data['data'] as List<dynamic>);
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<String?> _uploadEvidence(String path) async {
    try {
      final File file = File(path);
      final int sizeBytes = await file.length();
      final String originalName = _fileNameFromPath(path);
      final String mimeType = _guessMimeType(path);
      final Response<dynamic> signedResponse = await _apiClient.dio.post(
        '/files/signed-upload-url',
        data: <String, dynamic>{
          'originalName': originalName,
          'mimeType': mimeType,
          'sizeBytes': sizeBytes,
          'filePurpose': 'report_evidence',
        },
      );

      final Map<String, dynamic> signedData = _unwrapMap(signedResponse.data);
      final String signedUrl =
          signedData['signedUploadUrl']?.toString() ??
          signedData['uploadUrl']?.toString() ??
          '';
      if (signedUrl.isEmpty) return null;

      final Map<String, dynamic> headers = signedData['headers'] is Map
          ? Map<String, dynamic>.from(signedData['headers'] as Map)
          : <String, dynamic>{};
      headers.putIfAbsent('Content-Type', () => mimeType);

      await Dio().put<void>(
        signedUrl,
        data: Stream<List<int>>.fromIterable(<List<int>>[
          await file.readAsBytes(),
        ]),
        options: Options(
          headers: headers,
          contentType: headers['Content-Type']?.toString() ?? mimeType,
        ),
      );

      final Map<String, dynamic> confirmPayload = <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': 'report_evidence',
      };
      final String storageKey = signedData['storageKey']?.toString() ?? '';
      if (storageKey.isNotEmpty) confirmPayload['storageKey'] = storageKey;

      final Response<dynamic> confirmResponse = await _apiClient.dio.post(
        '/files/confirm-upload',
        data: confirmPayload,
      );
      final Map<String, dynamic> confirmed = _unwrapMap(confirmResponse.data);
      if (confirmed['file'] is Map) {
        return (confirmed['file'] as Map)['id']?.toString();
      }
      return confirmed['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<MessageReportResultModel> _createMultipartReport(
    MessageReportRequestModel request,
  ) async {
    final Map<String, dynamic> fields = <String, dynamic>{
      'reportedUserId': request.reportedUserId,
      'reasonId': request.reasonId,
      'description': request.description,
    };
    if (request.clientReportId?.isNotEmpty ?? false) {
      fields['clientReportId'] = request.clientReportId;
    }
    if (request.evidencePath?.isNotEmpty ?? false) {
      fields['evidenceImage'] = await MultipartFile.fromFile(
        request.evidencePath!,
        filename: _fileNameFromPath(request.evidencePath!),
      );
    }
    final Response<dynamic> response = await _apiClient.dio.post(
      '/user-reports',
      data: FormData.fromMap(fields),
    );
    return _resultFrom(response.data);
  }

  Future<MessageReportResultModel> _createReport(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/user-reports',
      data: payload,
    );
    return _resultFrom(response.data);
  }

  MessageReportResultModel _resultFrom(dynamic responseData) {
    final Map<String, dynamic> data = _unwrapMap(responseData);
    return MessageReportResultModel(
      referenceId:
          data['ticketId']?.toString() ?? data['id']?.toString() ?? '#N/A',
      statusLabel:
          data['status']?.toString() ??
          data['statusLabel']?.toString() ??
          'Under Review',
      reviewSteps: data['reviewSteps'] is List
          ? (data['reviewSteps'] as List<dynamic>)
                .map((dynamic item) => item.toString())
                .toList(growable: false)
          : const <String>[
              'Our team has been notified',
              'Manual review is in progress',
              'You will be notified once a decision is made',
            ],
    );
  }

  Map<String, dynamic> _unwrapMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    if (map['data'] is Map) return Map<String, dynamic>.from(map['data'] as Map);
    return map;
  }

  List<Map<String, dynamic>> _mapList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String _fileNameFromPath(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }

  String _guessMimeType(String path) {
    final String normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalized.endsWith('.webp')) return 'image/webp';
    return 'application/octet-stream';
  }
}
