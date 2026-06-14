import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/api_client.dart';
import '../models/cv_builder_models.dart';

class CvBuilderApiService {
  CvBuilderApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CvTemplateListResponseModel> getTemplates({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/cv-templates',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return CvTemplateListResponseModel.fromJson(_responseMap(response));
  }

  Future<CvDocumentModel> saveCvDocument(CvDocumentPayloadModel payload) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/cv-documents',
      data: payload.toJson(),
    );
    return CvDocumentResponseModel.fromJson(_responseMap(response)).document;
  }

  Future<String> uploadCvPhoto(XFile photoFile) async {
    final String mimeType = _imageMimeType(photoFile);
    final int sizeBytes = await photoFile.length();
    final String originalName = _safeOriginalName(photoFile);

    final CvSignedUploadUrlModel signedUpload = await _createSignedUploadUrl(
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );

    await _uploadToSignedUrl(
      signedUploadUrl: signedUpload.signedUploadUrl,
      photoFile: photoFile,
      mimeType: mimeType,
    );

    final CvConfirmUploadResponseModel confirmedUpload = await _confirmUpload(
      storageKey: signedUpload.storageKey,
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );

    if (confirmedUpload.publicUrl.trim().isNotEmpty) {
      return confirmedUpload.publicUrl;
    }

    return signedUpload.publicUrl;
  }

  Future<CvSignedUploadUrlModel> _createSignedUploadUrl({
    required String originalName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/files/signed-upload-url',
      data: <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': 'cv_photo',
        'visibility': 'public',
      },
    );

    return CvSignedUploadUrlModel.fromJson(_responseMap(response));
  }

  Future<void> _uploadToSignedUrl({
    required String signedUploadUrl,
    required XFile photoFile,
    required String mimeType,
  }) async {
    final Uint8List fileBytes = await photoFile.readAsBytes();
    final Dio uploadDio = Dio();

    await uploadDio.put<dynamic>(
      signedUploadUrl,
      data: fileBytes,
      options: Options(
        headers: <String, String>{'Content-Type': mimeType},
        contentType: mimeType,
        responseType: ResponseType.plain,
      ),
    );
  }

  Future<CvConfirmUploadResponseModel> _confirmUpload({
    required String storageKey,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '/files/confirm-upload',
      data: <String, dynamic>{
        'storageKey': storageKey,
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'filePurpose': 'cv_photo',
        'visibility': 'public',
        'mediaType': 'image',
        'title': originalName,
      },
    );

    return CvConfirmUploadResponseModel.fromJson(_responseMap(response));
  }

  String _safeOriginalName(XFile photoFile) {
    if (photoFile.name.trim().isNotEmpty) return photoFile.name.trim();

    final List<String> pathParts = photoFile.path.split('/');
    final String pathName = pathParts.isNotEmpty ? pathParts.last.trim() : '';
    if (pathName.isNotEmpty) return pathName;

    return 'cv-photo.jpg';
  }

  String _imageMimeType(XFile photoFile) {
    final String? fileMimeType = photoFile.mimeType;
    if (fileMimeType != null && fileMimeType.startsWith('image/')) {
      return fileMimeType;
    }

    final String fileName = _safeOriginalName(photoFile).toLowerCase();
    if (fileName.endsWith('.png')) return 'image/png';
    if (fileName.endsWith('.webp')) return 'image/webp';

    return 'image/jpeg';
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object',
    );
  }
}
