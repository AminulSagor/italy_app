import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/api_client.dart';
import '../models/settings_localization.dart';
import '../models/user_settings_models.dart';

class UserSettingsService {
  UserSettingsService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _settingsEndpoint = '/user-settings';
  static const int _fallbackMaximumAvatarBytes = 5 * 1024 * 1024;

  Future<UserSettingsProfileModel> getProfile() async {
    final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
      _settingsEndpoint,
    );
    return UserSettingsProfileResponseModel.fromJson(
      _responseMap(response),
    ).profile;
  }

  Future<UserSettingsProfileResponseModel> updateFullName(
    String fullName,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.patch<dynamic>(
      '$_settingsEndpoint/full-name',
      data: <String, dynamic>{'fullName': fullName.trim()},
    );
    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<ContactOtpResponseModel> requestEmailChangeOtp(String email) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '$_settingsEndpoint/email/request-otp',
      data: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
    return ContactOtpResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsProfileResponseModel> verifyEmailChangeOtp({
    required String email,
    required String otp,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '$_settingsEndpoint/email/verify-otp',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );
    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<ContactOtpResponseModel> requestPhoneChangeOtp(String phone) async {
    final String normalizedPhone = normalizePhone(phone);
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '$_settingsEndpoint/phone/request-otp',
      data: <String, dynamic>{'phone': normalizedPhone},
    );
    return ContactOtpResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsProfileResponseModel> verifyPhoneChangeOtp({
    required String phone,
    required String otp,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '$_settingsEndpoint/phone/verify-otp',
      data: <String, dynamic>{
        'phone': normalizePhone(phone),
        'otp': otp.trim(),
      },
    );
    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsProfileResponseModel> uploadAvatar(XFile image) async {
    final String originalName = _safeOriginalName(image);
    final String mimeType = _imageMimeType(image);
    final int sizeBytes = await image.length();

    if (sizeBytes <= 0) {
      throw StateError(SettingsL10n.text('choose_photo_first'));
    }
    if (sizeBytes > _fallbackMaximumAvatarBytes) {
      throw StateError(SettingsL10n.text('photo_too_large'));
    }

    final AvatarUploadPreparationModel prepared = await _prepareAvatarUpload(
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );

    if (prepared.signedUploadUrl.isEmpty || prepared.storageKey.isEmpty) {
      throw StateError(SettingsL10n.text('request_failed'));
    }
    if (prepared.method != 'PUT') {
      throw StateError(SettingsL10n.text('request_failed'));
    }
    if (prepared.maxSizeBytes > 0 && sizeBytes > prepared.maxSizeBytes) {
      throw StateError(SettingsL10n.text('photo_too_large'));
    }

    final Uint8List bytes = await image.readAsBytes();
    final Map<String, String> headers = <String, String>{
      ...prepared.headers,
      'Content-Type': mimeType,
    };

    await Dio().put<dynamic>(
      prepared.signedUploadUrl,
      data: bytes,
      options: Options(
        headers: headers,
        contentType: mimeType,
        responseType: ResponseType.plain,
        sendTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
      ),
    );

    final ConfirmAvatarUploadPayloadModel payload =
        ConfirmAvatarUploadPayloadModel(
          storageKey: prepared.storageKey,
          originalName: originalName,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
        );

    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
      '$_settingsEndpoint/avatar/confirm',
      data: payload.toJson(),
    );

    return UserSettingsProfileResponseModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsMessageModel> changePassword(
    ChangeUserPasswordPayloadModel payload,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.patch<dynamic>(
      '$_settingsEndpoint/password',
      data: payload.toJson(),
    );
    return UserSettingsMessageModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsMessageModel> setPassword(
    SetUserPasswordPayloadModel payload,
  ) async {
    final Response<dynamic> response = await _apiClient.dio.patch<dynamic>(
      '$_settingsEndpoint/password/set',
      data: payload.toJson(),
    );
    return UserSettingsMessageModel.fromJson(_responseMap(response));
  }

  Future<UserSettingsMessageModel> deleteAccount(String fullName) async {
    final Response<dynamic> response = await _apiClient.dio.delete<dynamic>(
      '$_settingsEndpoint/account',
      data: <String, dynamic>{'fullName': fullName.trim()},
    );
    return UserSettingsMessageModel.fromJson(_responseMap(response));
  }

  Future<AvatarUploadPreparationModel> _prepareAvatarUpload({
    required String originalName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
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
      message: SettingsL10n.text('request_failed'),
    );
  }

  String _safeOriginalName(XFile image) {
    final String suppliedName = image.name.trim();
    final String pathName = image.path.split(RegExp(r'[\\/]')).last.trim();
    final String candidate = suppliedName.isNotEmpty ? suppliedName : pathName;
    if (candidate.isEmpty) {
      throw StateError(SettingsL10n.text('unsupported_photo'));
    }
    return candidate;
  }

  String _imageMimeType(XFile image) {
    final String supplied = image.mimeType?.trim().toLowerCase() ?? '';
    if (supplied == 'image/jpeg' ||
        supplied == 'image/png' ||
        supplied == 'image/webp') {
      return supplied;
    }

    final String name = _safeOriginalName(image).toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';

    throw StateError(SettingsL10n.text('unsupported_photo'));
  }

  static String normalizePhone(String value) {
    String phone = value.trim().replaceAll(RegExp(r'[\s()\-]'), '');
    if (phone.startsWith('00')) phone = '+${phone.substring(2)}';
    if (RegExp(r'^01\d{9}$').hasMatch(phone)) {
      phone = '+88$phone';
    }
    if (RegExp(r'^8801\d{9}$').hasMatch(phone)) {
      phone = '+$phone';
    }
    if (RegExp(r'^39\d{8,11}$').hasMatch(phone)) {
      phone = '+$phone';
    }
    return phone;
  }
}
