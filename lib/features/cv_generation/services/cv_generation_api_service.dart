import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_client.dart';
import '../models/cv_assistant_models.dart';
import '../models/cv_generation_models.dart';
import '../models/cv_template_model.dart';

class CvGenerationApiService {
  CvGenerationApiService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CvTemplateListResponseModel>
  fetchTemplates({
    int page = 1,
    int limit = 9,
    String search = '',
  }) async {
    final Response<dynamic> response =
    await _apiClient.dio.get<dynamic>(
      '/cv-templates',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return CvTemplateListResponseModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvAssistantSessionModel>
  createCvAssistantSession({
    String? templateId,
    CvAssistantConversationMode conversationMode =
        CvAssistantConversationMode.oneByOne,
  }) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions',
      data: <String, dynamic>{
        if (templateId != null &&
            templateId.trim().isNotEmpty)
          'templateId': templateId.trim(),

        'conversationMode':
        conversationMode.apiValue,
      },
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvAssistantSessionModel>
  changeCvAssistantConversationMode({
    required String sessionId,
    required CvAssistantConversationMode mode,
  }) {
    final String command =
    mode == CvAssistantConversationMode.allAtOnce
        ? 'Ask me all questions at once.'
        : 'Ask me one by one.';

    return sendCvAssistantMessage(
      sessionId: sessionId,
      message: command,
    );
  }

  Future<CvAssistantSessionModel>
  getCvAssistantSession(
      String sessionId,
      ) async {
    final Response<dynamic> response =
    await _apiClient.dio.get<dynamic>(
      '/cv-assistant/sessions/$sessionId',
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvAssistantSessionModel>
  sendCvAssistantMessage({
    required String sessionId,
    required String message,
  }) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/$sessionId/messages',
      data: <String, dynamic>{
        'message': message.trim(),
      },
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvAssistantSessionModel>
  skipCvAssistantQuestion(
      String sessionId,
      ) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/$sessionId/skip',
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvAssistantSessionModel>
  attachCvAssistantAssets({
    required String sessionId,
    String? profilePhotoFileId,
    List<String>? referenceImageFileIds,
  }) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/$sessionId/attachments',
      data: <String, dynamic>{
        if (profilePhotoFileId != null &&
            profilePhotoFileId.trim().isNotEmpty)
          'profilePhotoFileId':
          profilePhotoFileId.trim(),
        if (referenceImageFileIds != null &&
            referenceImageFileIds.isNotEmpty)
          'referenceImageFileIds':
          referenceImageFileIds,
      },
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<String> generateCvFromSession(
      String sessionId,
      ) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/$sessionId/generate',
    );

    final Map<String, dynamic> data =
    _responseMap(response);

    final String directGenerationId =
        data['generationId']?.toString().trim() ??
            '';

    if (directGenerationId.isNotEmpty) {
      return directGenerationId;
    }

    final dynamic generation = data['generation'];

    if (generation is Map) {
      final String nestedId =
          generation['id']?.toString().trim() ?? '';

      if (nestedId.isNotEmpty) {
        return nestedId;
      }
    }

    final String directId =
        data['id']?.toString().trim() ?? '';

    if (directId.isNotEmpty) {
      return directId;
    }

    throw StateError(
      'The server did not return a generation ID.',
    );
  }

  Future<CvGenerationModel> fetchGeneration(
      String generationId,
      ) async {
    final Response<dynamic> response =
    await _apiClient.dio.get<dynamic>(
      '/cv-generations/$generationId',
    );

    return CvGenerationModel.fromJson(
      _responseMap(response),
    );
  }

  Future<CvGenerationModel> regenerate(
      String generationId,
      ) async {
    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-generations/$generationId/regenerate',
    );

    return CvGenerationModel.fromJson(
      _responseMap(response),
    );
  }

  Future<String> uploadCvImage({
    required XFile file,
    required String filePurpose,
  }) async {
    final int sizeBytes = await file.length();

    if (sizeBytes <= 0) {
      throw StateError(
        'The selected image is empty.',
      );
    }

    if (sizeBytes > 5 * 1024 * 1024) {
      throw StateError(
        'The image must not exceed 5 MB.',
      );
    }

    final String originalName =
    _safeOriginalName(file);

    final String mimeType = _imageMimeType(file);

    final Response<dynamic> prepareResponse =
    await _apiClient.dio.post<dynamic>(
      '/files/signed-upload-url',
      data: <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': filePurpose,
        'visibility': 'private',
      },
    );

    final Map<String, dynamic> prepared =
    _responseMap(prepareResponse);

    final String signedUploadUrl =
        prepared['signedUploadUrl']
            ?.toString()
            .trim() ??
            '';

    final String storageKey =
        prepared['storageKey']?.toString().trim() ??
            '';

    if (signedUploadUrl.isEmpty ||
        storageKey.isEmpty) {
      throw StateError(
        'Could not prepare the image upload.',
      );
    }

    final Uint8List bytes =
    await file.readAsBytes();

    await Dio().put<dynamic>(
      signedUploadUrl,
      data: bytes,
      options: Options(
        headers: <String, String>{
          'Content-Type': mimeType,
        },
        contentType: mimeType,
        responseType: ResponseType.plain,
      ),
    );

    final Response<dynamic> confirmResponse =
    await _apiClient.dio.post<dynamic>(
      '/files/confirm-upload',
      data: <String, dynamic>{
        'storageKey': storageKey,
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': filePurpose,
        'visibility': 'private',
        'mediaType': 'image',
        'title': originalName,
      },
    );

    final Map<String, dynamic> confirmed =
    _responseMap(confirmResponse);

    final dynamic rawFile = confirmed['file'];

    final String fileId = rawFile is Map
        ? rawFile['id']?.toString().trim() ?? ''
        : '';

    if (fileId.isEmpty) {
      throw StateError(
        'The image upload could not be confirmed.',
      );
    }

    return fileId;
  }

  Map<String, dynamic> _responseMap(
      Response<dynamic> response,
      ) {
    final dynamic rawData = response.data;

    if (rawData is! Map) {
      throw StateError(
        'The server returned an invalid response.',
      );
    }

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(rawData);

    final dynamic nestedData = map['data'];

    if (nestedData is Map) {
      return Map<String, dynamic>.from(
        nestedData,
      );
    }

    return map;
  }

  String _safeOriginalName(XFile file) {
    final String suppliedName = file.name.trim();

    if (suppliedName.isNotEmpty) {
      return suppliedName;
    }

    final List<String> pathParts =
    file.path.split(RegExp(r'[\\/]'));

    final String pathName = pathParts.isEmpty
        ? ''
        : pathParts.last.trim();

    return pathName.isEmpty
        ? 'cv-image.jpg'
        : pathName;
  }

  String _imageMimeType(XFile file) {
    final String suppliedMimeType =
        file.mimeType?.trim().toLowerCase() ?? '';

    if (<String>{
      'image/jpeg',
      'image/png',
      'image/webp',
    }.contains(suppliedMimeType)) {
      return suppliedMimeType;
    }

    final String fileName =
    _safeOriginalName(file).toLowerCase();

    if (fileName.endsWith('.png')) {
      return 'image/png';
    }

    if (fileName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }
}