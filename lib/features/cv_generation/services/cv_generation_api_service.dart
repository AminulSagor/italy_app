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

  Future<CvTemplateListResponseModel> fetchTemplates({
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
  startFactsOnlyEdit(
      String generationId,
      ) {
    return startCvAssistantEdit(
      generationId: generationId,
      editMode: CvAssistantEditMode.factsOnly,
    );
  }

  Future<CvAssistantSessionModel>
  startDesignAndFactsEdit(
      String generationId,
      ) {
    return startCvAssistantEdit(
      generationId: generationId,
      editMode:
      CvAssistantEditMode.designAndFacts,
    );
  }

  Future<CvAssistantSessionModel>
  startCvAssistantEdit({
    required String generationId,
    required CvAssistantEditMode editMode,
  }) async {
    final String normalizedGenerationId =
    generationId.trim();

    if (normalizedGenerationId.isEmpty) {
      throw ArgumentError(
        'Generation ID is required.',
      );
    }

    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/generations/'
          '$normalizedGenerationId/edit',
      data: <String, dynamic>{
        'editMode': editMode.apiValue,
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
    mode ==
        CvAssistantConversationMode
            .allAtOnce
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
    final String normalizedMessage =
    message.trim();

    if (normalizedMessage.isEmpty) {
      throw ArgumentError(
        'Message cannot be empty.',
      );
    }

    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/'
          '$sessionId/messages',
      data: <String, dynamic>{
        'message': normalizedMessage,
      },
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
    final List<String> normalizedReferenceIds =
    (referenceImageFileIds ?? <String>[])
        .map(
          (String item) => item.trim(),
    )
        .where(
          (String item) =>
      item.isNotEmpty,
    )
        .toSet()
        .toList();

    final String? normalizedProfilePhotoId =
    _nullableValue(
      profilePhotoFileId,
    );

    if (normalizedProfilePhotoId == null &&
        normalizedReferenceIds.isEmpty) {
      throw ArgumentError(
        'Provide a profile photo or at least one reference image.',
      );
    }

    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-assistant/sessions/'
          '$sessionId/attachments',
      data: <String, dynamic>{
        if (normalizedProfilePhotoId != null)
          'profilePhotoFileId':
          normalizedProfilePhotoId,
        if (normalizedReferenceIds.isNotEmpty)
          'referenceImageFileIds':
          normalizedReferenceIds,
      },
    );

    return CvAssistantSessionModel.fromJson(
      _responseMap(response),
    );
  }

  Future<String> generateCvFromSession(
      String sessionId,
      ) async {
    final String normalizedSessionId =
    sessionId.trim();

    if (normalizedSessionId.isEmpty) {
      throw ArgumentError(
        'Session ID is required.',
      );
    }

    try {
      final Response<dynamic> response =
      await _apiClient.dio.post<dynamic>(
        '/cv-assistant/sessions/'
            '$normalizedSessionId/generate',
      );

      return _extractGenerationId(
        _responseMap(response),
      );
    } on DioException catch (error) {
      if (!_isConflict(error)) {
        rethrow;
      }

      /*
       * Another request may already have started generation.
       * Refresh the assistant session and reuse the generation
       * ID when the backend has already linked it.
       */
      try {
        final CvAssistantSessionModel session =
        await getCvAssistantSession(
          normalizedSessionId,
        );

        final String generationId =
            session.generationId?.trim() ?? '';

        if (generationId.isNotEmpty) {
          return generationId;
        }
      } catch (_) {
        /*
         * Preserve the original 409 response when refreshing
         * the session also fails.
         */
      }

      throw CvGenerationAlreadyStartedException(
        _extractDioErrorMessage(error) ??
            'CV generation has already started. '
                'Please refresh the session shortly.',
      );
    }
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

  Future<CvGenerationModel> regenerateDesign({
    required String generationId,
    required String designInstruction,
  }) async {
    final String normalizedGenerationId =
    generationId.trim();

    final String normalizedInstruction =
    designInstruction.trim();

    if (normalizedGenerationId.isEmpty) {
      throw ArgumentError(
        'Generation ID is required.',
      );
    }

    if (normalizedInstruction.isEmpty) {
      throw ArgumentError(
        'A design instruction is required.',
      );
    }

    final Response<dynamic> response =
    await _apiClient.dio.post<dynamic>(
      '/cv-generations/'
          '$normalizedGenerationId/regenerate',
      data: <String, dynamic>{
        'designInstruction':
        normalizedInstruction,
      },
    );

    return CvGenerationModel.fromJson(
      _responseMap(response),
    );
  }

  Future<String> uploadCvImage({
    required XFile file,
    required String filePurpose,
  }) async {
    final int sizeBytes =
    await file.length();

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

    final String mimeType =
    _imageMimeType(file);

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
        prepared['storageKey']
            ?.toString()
            .trim() ??
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

    final dynamic rawFile =
    confirmed['file'];

    final String fileId = rawFile is Map
        ? rawFile['id']
        ?.toString()
        .trim() ??
        ''
        : '';

    if (fileId.isEmpty) {
      throw StateError(
        'The image upload could not be confirmed.',
      );
    }

    return fileId;
  }

  String _extractGenerationId(
      Map<String, dynamic> data,
      ) {
    final String directGenerationId =
        data['generationId']
            ?.toString()
            .trim() ??
            '';

    if (directGenerationId.isNotEmpty) {
      return directGenerationId;
    }

    final dynamic rawGeneration =
    data['generation'];

    if (rawGeneration is Map) {
      final String nestedGenerationId =
          rawGeneration['id']
              ?.toString()
              .trim() ??
              '';

      if (nestedGenerationId.isNotEmpty) {
        return nestedGenerationId;
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

  bool _isConflict(
      DioException error,
      ) {
    return error.response?.statusCode == 409;
  }

  String? _extractDioErrorMessage(
      DioException error,
      ) {
    final dynamic rawData =
        error.response?.data;

    if (rawData is String) {
      return _nullableValue(rawData);
    }

    if (rawData is Map) {
      final dynamic rawMessage =
      rawData['message'];

      if (rawMessage is List) {
        final String message = rawMessage
            .map(
              (dynamic item) =>
              item.toString().trim(),
        )
            .where(
              (String item) =>
          item.isNotEmpty,
        )
            .join(' ');

        return _nullableValue(message);
      }

      return _nullableValue(rawMessage);
    }

    return null;
  }

  Map<String, dynamic> _responseMap(
      Response<dynamic> response,
      ) {
    final dynamic rawData =
        response.data;

    if (rawData is! Map) {
      throw StateError(
        'The server returned an invalid response.',
      );
    }

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(rawData);

    final dynamic nestedData =
    map['data'];

    if (nestedData is Map) {
      return Map<String, dynamic>.from(
        nestedData,
      );
    }

    return map;
  }

  String _safeOriginalName(
      XFile file,
      ) {
    final String suppliedName =
    file.name.trim();

    if (suppliedName.isNotEmpty) {
      return suppliedName;
    }

    final List<String> pathParts =
    file.path.split(
      RegExp(r'[\\/]'),
    );

    final String pathName =
    pathParts.isEmpty
        ? ''
        : pathParts.last.trim();

    return pathName.isEmpty
        ? 'cv-image.jpg'
        : pathName;
  }

  String _imageMimeType(
      XFile file,
      ) {
    final String suppliedMimeType =
        file.mimeType
            ?.trim()
            .toLowerCase() ??
            '';

    if (<String>{
      'image/jpeg',
      'image/png',
      'image/webp',
    }.contains(suppliedMimeType)) {
      return suppliedMimeType;
    }

    final String fileName =
    _safeOriginalName(file)
        .toLowerCase();

    if (fileName.endsWith('.png')) {
      return 'image/png';
    }

    if (fileName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }
}

class CvGenerationAlreadyStartedException
    implements Exception {
  const CvGenerationAlreadyStartedException(
      this.message,
      );

  final String message;

  @override
  String toString() {
    return message;
  }
}

String? _nullableValue(
    dynamic value,
    ) {
  final String normalized =
      value?.toString().trim() ?? '';

  return normalized.isEmpty
      ? null
      : normalized;
}