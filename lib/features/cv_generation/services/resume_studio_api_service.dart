import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_client.dart';
import '../models/cv_library_model.dart';
import '../models/cv_template_model.dart';
import '../models/resume_studio_models.dart';

class ResumeStudioApiService {
  ResumeStudioApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CvHomeBootstrapModel> fetchHomeBootstrap({
    int page = 1,
    int limit = 12,
    String search = '',
    String category = '',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates/bootstrap',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category.trim().isNotEmpty) 'category': category.trim(),
      },
    );

    return CvHomeBootstrapModel.fromJson(_responseMap(response));
  }

  Future<CvLibraryResponseModel> fetchCvLibrary({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/documents/library',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );

    return CvLibraryResponseModel.fromJson(_responseMap(response));
  }

  Future<CvTemplateModel> fetchTemplate(String templateId) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates/${templateId.trim()}',
    );

    return CvTemplateModel.fromJson(_responseMap(response));
  }

  Future<CvTemplatePreviewModel> fetchTemplatePreview(String templateId) async {
    final String normalizedId = templateId.trim();
    if (normalizedId.isEmpty) {
      throw StateError('cvb_template_id_missing'.tr);
    }

    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates/$normalizedId/preview',
    );

    return CvTemplatePreviewModel.fromJson(_responseMap(response));
  }

  Future<CvTemplateListResponseModel> fetchTemplates({
    int page = 1,
    int limit = 12,
    String search = '',
    String category = '',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category.trim().isNotEmpty) 'category': category.trim(),
      },
    );

    return CvTemplateListResponseModel.fromJson(_responseMap(response));
  }

  Future<List<CvTemplateCategoryModel>> fetchCategories() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates/categories',
    );

    final dynamic rawData = _unwrap(response.data);
    if (rawData is! List) return const <CvTemplateCategoryModel>[];

    return rawData
        .whereType<Map>()
        .map(
          (Map item) =>
              CvTemplateCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((CvTemplateCategoryModel item) => item.category.isNotEmpty)
        .toList();
  }

  Future<CvBuilderContractModel> fetchBuilderContract() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/templates/builder-contract',
    );

    return CvBuilderContractModel.fromJson(_responseMap(response));
  }

  Future<ResumeDocumentModel> fetchDocument(String documentId) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/documents/${documentId.trim()}',
    );

    return ResumeDocumentModel.fromJson(_responseMap(response));
  }

  Future<ResumeDocumentModel> createDocument({
    required String title,
    String? templateId,
    Map<String, dynamic>? data,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/resume-studio/documents',
      data: <String, dynamic>{
        'title': title.trim().isEmpty ? 'cvb_my_cv'.tr : title.trim(),
        if (templateId?.trim().isNotEmpty == true)
          'templateId': templateId!.trim(),
        if (data != null) 'data': data,
      },
    );

    return ResumeDocumentModel.fromJson(_responseMap(response));
  }

  Future<ResumeDocumentModel> autosaveDocument({
    required String documentId,
    required int expectedRevision,
    required String title,
    required Map<String, dynamic> data,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.put<dynamic>(
      '/resume-studio/documents/${documentId.trim()}',
      data: <String, dynamic>{
        'title': title.trim().isEmpty ? 'cvb_my_cv'.tr : title.trim(),
        'data': data,
        'expectedRevision': expectedRevision,
      },
    );

    return ResumeDocumentModel.fromJson(_responseMap(response));
  }

  Future<ResumeGenerationModel> fetchGeneration(String generationId) async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      '/resume-studio/documents/generations/${generationId.trim()}',
    );

    return ResumeGenerationModel.fromJson(_responseMap(response));
  }

  Future<ResumeGenerationModel> renderDocument({
    required String documentId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/resume-studio/documents/${documentId.trim()}/render',
      data: const <String, dynamic>{},
    );

    return ResumeGenerationModel.fromJson(_responseMap(response));
  }

  Future<ResumeAiSuggestionsModel> suggestField({
    required String assistType,
    required String targetRole,
    required List<String> skills,
    required List<String> experienceHighlights,
    String currentText = '',
    List<String> existingItems = const <String>[],
    String itemTitle = '',
    String organization = '',
    String language = 'English',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/resume-studio/ai/field-suggestions',
      data: <String, dynamic>{
        'assistType': assistType,
        if (currentText.trim().isNotEmpty) 'currentText': currentText.trim(),
        if (existingItems.isNotEmpty)
          'existingItems': existingItems.take(40).toList(),
        if (targetRole.trim().isNotEmpty) 'targetRole': targetRole.trim(),
        if (itemTitle.trim().isNotEmpty) 'itemTitle': itemTitle.trim(),
        if (organization.trim().isNotEmpty) 'organization': organization.trim(),
        if (skills.isNotEmpty) 'skills': skills.take(30).toList(),
        if (experienceHighlights.isNotEmpty)
          'experienceHighlights': experienceHighlights.take(12).toList(),
        'language': language,
      },
    );

    return ResumeAiSuggestionsModel.fromJson(_responseMap(response));
  }

  Future<ResumeSummarySuggestionsModel> suggestSummary({
    required String currentSummary,
    required String targetRole,
    required List<String> skills,
    required List<String> experienceHighlights,
    String tone = 'professional',
    String language = 'English',
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '/resume-studio/ai/summary-suggestions',
      data: <String, dynamic>{
        if (currentSummary.trim().isNotEmpty)
          'currentSummary': currentSummary.trim(),
        if (targetRole.trim().isNotEmpty) 'targetRole': targetRole.trim(),
        if (skills.isNotEmpty) 'skills': skills.take(30).toList(),
        if (experienceHighlights.isNotEmpty)
          'experienceHighlights': experienceHighlights.take(12).toList(),
        'tone': tone,
        'language': language,
      },
    );

    return ResumeSummarySuggestionsModel.fromJson(_responseMap(response));
  }

  Future<String> uploadResumePhoto({
    required XFile file,
    required CvBuilderContractModel contract,
  }) async {
    final int sizeBytes = await file.length();
    if (sizeBytes <= 0) {
      throw StateError('cvb_photo_empty'.tr);
    }
    if (sizeBytes > contract.photoMaxBytes) {
      final double maxMb = contract.photoMaxBytes / (1024 * 1024);
      throw StateError(
        'cvb_photo_too_large'.trParams(<String, String>{
          'size': maxMb.toStringAsFixed(0),
        }),
      );
    }

    final String originalName = _safeOriginalName(file);
    final String mimeType = _imageMimeType(file);

    if (!contract.allowedPhotoMimeTypes.contains(mimeType)) {
      throw StateError('cvb_photo_type_invalid'.tr);
    }

    final Response<dynamic> prepareResponse = await _apiClient.dio
        .post<dynamic>(
          '/files/signed-upload-url',
          data: <String, dynamic>{
            'originalName': originalName,
            'mimeType': mimeType,
            'sizeBytes': sizeBytes,
            'filePurpose': contract.photoFilePurpose,
            'visibility': 'private',
          },
        );

    final Map<String, dynamic> prepared = _responseMap(prepareResponse);
    final String signedUploadUrl =
        prepared['signedUploadUrl']?.toString().trim() ?? '';
    final String storageKey = prepared['storageKey']?.toString().trim() ?? '';

    if (signedUploadUrl.isEmpty || storageKey.isEmpty) {
      throw StateError('cvb_photo_prepare_failed'.tr);
    }

    final Uint8List bytes = await file.readAsBytes();

    await Dio().put<dynamic>(
      signedUploadUrl,
      data: bytes,
      options: Options(
        headers: <String, String>{'Content-Type': mimeType},
        contentType: mimeType,
        responseType: ResponseType.plain,
      ),
    );

    final Response<dynamic> confirmResponse = await _apiClient.dio
        .post<dynamic>(
          '/files/confirm-upload',
          data: <String, dynamic>{
            'storageKey': storageKey,
            'originalName': originalName,
            'mimeType': mimeType,
            'sizeBytes': sizeBytes,
            'filePurpose': contract.photoFilePurpose,
            'visibility': 'private',
            'mediaType': 'image',
            'title': originalName,
          },
        );

    final Map<String, dynamic> confirmed = _responseMap(confirmResponse);
    final dynamic rawFile = confirmed['file'];
    final String fileId = rawFile is Map
        ? rawFile['id']?.toString().trim() ?? ''
        : '';

    if (fileId.isEmpty) {
      throw StateError('cvb_photo_confirm_failed'.tr);
    }

    return fileId;
  }

  Future<Uint8List> downloadPdf(String pdfUrl) async {
    final String normalizedUrl = pdfUrl.trim();
    if (normalizedUrl.isEmpty) {
      throw StateError('cvb_pdf_url_missing'.tr);
    }

    final Response<List<int>> response = await Dio().get<List<int>>(
      normalizedUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    final List<int>? rawBytes = response.data;
    if (rawBytes == null || rawBytes.isEmpty) {
      throw StateError('cvb_pdf_download_failed'.tr);
    }

    return Uint8List.fromList(rawBytes);
  }

  dynamic _unwrap(dynamic rawData) {
    if (rawData is! Map) {
      return rawData;
    }

    final bool isApiEnvelope =
        rawData.containsKey('data') &&
        !rawData.containsKey('id') &&
        (rawData.containsKey('success') ||
            rawData.containsKey('message') ||
            rawData.length == 1);

    return isApiEnvelope ? rawData['data'] : rawData;
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic rawData = _unwrap(response.data);
    if (rawData is! Map) {
      throw StateError('cvb_invalid_response'.tr);
    }
    return Map<String, dynamic>.from(rawData);
  }

  String _safeOriginalName(XFile file) {
    final String suppliedName = file.name.trim();
    if (suppliedName.isNotEmpty) return suppliedName;

    final List<String> parts = file.path.split(RegExp(r'[\\/]'));
    final String pathName = parts.isEmpty ? '' : parts.last.trim();
    return pathName.isEmpty ? 'cv-photo.jpg' : pathName;
  }

  String _imageMimeType(XFile file) {
    final String suppliedMime = file.mimeType?.trim().toLowerCase() ?? '';
    if (<String>{
      'image/jpeg',
      'image/png',
      'image/webp',
    }.contains(suppliedMime)) {
      return suppliedMime;
    }

    final String name = _safeOriginalName(file).toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
