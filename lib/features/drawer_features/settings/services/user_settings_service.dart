import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/api_client.dart';
import '../models/user_settings_models.dart';

class UserSettingsService {
  UserSettingsService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _settingsEndpoint = '/user-settings';

  Future<UserSettingsProfileModel> getProfile() async {
    final Response<dynamic> response = await _apiClient.dio.get(
      _settingsEndpoint,
    );
    return UserSettingsProfileResponseModel.fromJson(
      _responseMap(response),
    ).profile;
  }

  Future<UserSettingsProfileResponseModel> updateFullName(
    String fullName,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.patch(
      '$_settingsEndpoint/full-name',
      data: <String, dynamic>{'fullName': fullName.trim()},
    );
    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsProfileResponseModel> uploadAvatar(XFile image) async {
    final String originalName = _safeOriginalName(image);
    final String mimeType = _imageMimeType(image);
    final int sizeBytes = await image.length();

    final AvatarUploadPreparationModel prepared = await _prepareAvatarUpload(
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );

    if (prepared.signedUploadUrl.isEmpty || prepared.storageKey.isEmpty) {
      throw StateError('Could not prepare the profile photo upload.');
    }

    if (prepared.maxSizeBytes > 0 && sizeBytes > prepared.maxSizeBytes) {
      throw StateError('Profile photo is larger than the allowed size.');
    }

    final Uint8List bytes = await image.readAsBytes();
    await Dio().put<dynamic>(
      prepared.signedUploadUrl,
      data: bytes,
      options: Options(
        headers: <String, String>{'Content-Type': mimeType},
        contentType: mimeType,
        responseType: ResponseType.plain,
      ),
    );

    final ConfirmAvatarUploadPayloadModel payload =
        ConfirmAvatarUploadPayloadModel(
          storageKey: prepared.storageKey,
          originalName: originalName,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
        );

    final Response<dynamic> response = await _apiClient.dio.post(
      '$_settingsEndpoint/avatar/confirm',
      data: payload.toJson(),
    );

    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsMessageModel> changePassword(
    ChangeUserPasswordPayloadModel payload,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.patch(
      '$_settingsEndpoint/password',
      data: payload.toJson(),
    );

    return UserSettingsMessageModel.fromJson(_responseMap(response));
  }

  Future<AvatarUploadPreparationModel> _prepareAvatarUpload({
    required String originalName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post(
      '$_settingsEndpoint/avatar/upload-url',
      data: <String, dynamic>{
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      },
    );

    return AvatarUploadPreparationModel.fromJson(_responseMap(response));
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object.',
    );
  }

  String _safeOriginalName(XFile image) {
    final String name = image.name.trim();
    if (name.isNotEmpty) return name;

    final List<String> parts = image.path.split(RegExp(r'[\\/]'));
    final String pathName = parts.isEmpty ? '' : parts.last.trim();
    return pathName.isEmpty ? 'profile-avatar.jpg' : pathName;
  }

  String _imageMimeType(XFile image) {
    final String supplied = image.mimeType?.trim().toLowerCase() ?? '';
    if (supplied == 'image/jpeg' ||
        supplied == 'image/png' ||
        supplied == 'image/webp') {
      return supplied;
    }

    final String name = _safeOriginalName(image).toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
