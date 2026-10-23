import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/services/api_client.dart';
import '../../../core/controllers/user_session_controller.dart';
import '../models/course_device_access_models.dart';

class CourseDeviceAccessService {
  CourseDeviceAccessService({
    required ApiClient apiClient,
    required UserSessionController userSessionController,
  }) : // Keep public dependency names for bindings and tests.
       // ignore: prefer_initializing_formals
       _apiClient = apiClient,
       // ignore: prefer_initializing_formals
       _userSessionController = userSessionController;

  static const MethodChannel _channel = MethodChannel(
    'italir_pothe/course_device_integrity',
  );
  final ApiClient _apiClient;
  final UserSessionController _userSessionController;

  Future<CourseDeviceAccessResult> verifyCourse(String courseId) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Course device verification requires Android or iOS.',
      );
    }

    final user =
        _userSessionController.user.value ??
        await _userSessionController.loadUser(forceRefresh: true);
    final String keyNamespace = user?.id.trim() ?? '';
    if (keyNamespace.isEmpty) {
      throw StateError('The signed-in user could not be resolved.');
    }
    final Map<String, dynamic> identity = _map(
      await _channel.invokeMapMethod<String, dynamic>(
        'getIdentity',
        <String, dynamic>{'keyNamespace': keyNamespace},
      ),
    );
    final String deviceKeyId = _required(identity, 'deviceKeyId');
    final String deviceLabel = _required(identity, 'deviceLabel');
    final String platform = _required(identity, 'platform');

    final Response<dynamic> challengeResponse = await _apiClient.dio.post(
      '/course-device-access/courses/$courseId/challenge',
      data: <String, dynamic>{
        'platform': platform,
        'deviceKeyId': deviceKeyId,
        'deviceLabel': deviceLabel,
      },
    );
    final Map<String, dynamic> challenge = _map(challengeResponse.data);
    if (challenge['enforcementEnabled'] == false) {
      _apiClient.clearCourseDeviceProof(courseId: courseId);
      return CourseDeviceAccessResult(
        authorized: true,
        deviceKeyId: deviceKeyId,
        requestedDeviceLabel: deviceLabel,
      );
    }
    final Map<String, dynamic> proofArguments = <String, dynamic>{
      'clientDataBase64': _required(challenge, 'clientDataBase64'),
      'requiresAttestation': challenge['requiresAttestation'] == true,
      'keyNamespace': keyNamespace,
    };

    if (Platform.isAndroid) {
      final String configured =
          dotenv.env['PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER']?.trim() ?? '';
      final int? projectNumber = int.tryParse(configured);
      if (projectNumber == null || projectNumber <= 0) {
        throw StateError(
          'PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER must be the numeric project '
          'number of the existing Italir Pothe Google Cloud project.',
        );
      }
      proofArguments['cloudProjectNumber'] = projectNumber;
    }

    final Map<String, dynamic> proof = _map(
      await _channel.invokeMapMethod<String, dynamic>(
        'createProof',
        proofArguments,
      ),
    );
    final Response<dynamic> verificationResponse = await _apiClient.dio.post(
      '/course-device-access/courses/$courseId/verify',
      data: <String, dynamic>{
        'challengeId': _required(challenge, 'challengeId'),
        'deviceKeyId': deviceKeyId,
        if (proof['publicKeyPem'] != null)
          'publicKeyPem': proof['publicKeyPem'],
        if (proof['attestationToken'] != null)
          'attestationToken': proof['attestationToken'],
        if (proof['assertionBase64'] != null)
          'assertionBase64': proof['assertionBase64'],
        if (proof['signatureBase64'] != null)
          'signatureBase64': proof['signatureBase64'],
      },
    );
    final Map<String, dynamic> verified = _map(verificationResponse.data);
    final bool authorized = verified['authorized'] == true;
    if (authorized) {
      _apiClient.setCourseDeviceProof(
        courseId: courseId,
        deviceKeyId: deviceKeyId,
        accessToken: _required(verified, 'accessToken'),
      );
    } else {
      _apiClient.clearCourseDeviceProof(courseId: courseId);
    }
    return CourseDeviceAccessResult(
      authorized: authorized,
      deviceKeyId: deviceKeyId,
      requestedDeviceLabel:
          verified['requestedDeviceLabel']?.toString() ?? deviceLabel,
      currentDeviceLabel: verified['currentDeviceLabel']?.toString(),
      requestStatus: verified['requestStatus']?.toString(),
    );
  }

  Future<void> requestAccess({
    required String courseId,
    required String deviceKeyId,
  }) async {
    await _apiClient.dio.post(
      '/course-device-access/courses/$courseId/requests',
      data: <String, dynamic>{'deviceKeyId': deviceKeyId},
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('The device verification response is invalid.');
  }

  String _required(Map<String, dynamic> value, String key) {
    final String result = value[key]?.toString().trim() ?? '';
    if (result.isEmpty) {
      throw FormatException('Device verification field $key is missing.');
    }
    return result;
  }
}
