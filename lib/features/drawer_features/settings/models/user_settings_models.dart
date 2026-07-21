class UserSettingsProfileModel {
  const UserSettingsProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.profilePhotoFileId,
    required this.avatarUrl,
    required this.canChangeEmail,
    required this.canChangePhone,
    required this.streakFreezeCount,
    required this.currentStreakDays,
    required this.learnerLevel,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profilePhotoFileId;
  final String? avatarUrl;
  final bool canChangeEmail;
  final bool canChangePhone;
  final int streakFreezeCount;
  final int currentStreakDays;
  final String learnerLevel;

  factory UserSettingsProfileModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsProfileModel(
      id: _string(json['id']),
      fullName: _string(json['fullName']),
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
      profilePhotoFileId: _nullableString(json['profilePhotoFileId']),
      avatarUrl: _nullableString(json['avatarUrl']),
      canChangeEmail: json['canChangeEmail'] != false,
      canChangePhone: json['canChangePhone'] != false,
      streakFreezeCount: _asInt(json['streakFreezeCount']),
      currentStreakDays: _asInt(json['currentStreakDays']),
      learnerLevel: _string(json['learnerLevel']).isEmpty
          ? 'A1'
          : _string(json['learnerLevel']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'isEmailVerified': isEmailVerified,
        'isPhoneVerified': isPhoneVerified,
        'profilePhotoFileId': profilePhotoFileId,
        'avatarUrl': avatarUrl,
        'canChangeEmail': canChangeEmail,
        'canChangePhone': canChangePhone,
        'streakFreezeCount': streakFreezeCount,
        'currentStreakDays': currentStreakDays,
        'learnerLevel': learnerLevel,
      };

  UserSettingsProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profilePhotoFileId,
    String? avatarUrl,
    bool? canChangeEmail,
    bool? canChangePhone,
    int? streakFreezeCount,
    int? currentStreakDays,
    String? learnerLevel,
  }) {
    return UserSettingsProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profilePhotoFileId: profilePhotoFileId ?? this.profilePhotoFileId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      canChangeEmail: canChangeEmail ?? this.canChangeEmail,
      canChangePhone: canChangePhone ?? this.canChangePhone,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      learnerLevel: learnerLevel ?? this.learnerLevel,
    );
  }
}

class UserSettingsProfileResponseModel {
  const UserSettingsProfileResponseModel({
    required this.profile,
    this.message,
  });

  final UserSettingsProfileModel profile;
  final String? message;

  factory UserSettingsProfileResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawProfile = json['profile'] ?? json['user'] ?? json['data'];
    if (rawProfile is! Map) {
      throw const FormatException('Profile response is missing profile data.');
    }

    return UserSettingsProfileResponseModel(
      profile: UserSettingsProfileModel.fromJson(
        Map<String, dynamic>.from(rawProfile),
      ),
      message: _nullableString(json['message']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (message != null) 'message': message,
        'profile': profile.toJson(),
      };
}

class ContactOtpResponseModel {
  const ContactOtpResponseModel({
    required this.message,
    required this.contactType,
    required this.destination,
    this.devOtp,
  });

  final String message;
  final String contactType;
  final String destination;
  final String? devOtp;

  factory ContactOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final String explicitType = _string(json['contactType']).toLowerCase();
    final String email = _string(json['email']);
    final String phone = _string(json['phone']);
    final String type = explicitType == 'phone' || explicitType == 'email'
        ? explicitType
        : phone.isNotEmpty
            ? 'phone'
            : 'email';
    final String destination = _string(json['destination']).isNotEmpty
        ? _string(json['destination'])
        : type == 'phone'
            ? phone
            : email;

    if (destination.isEmpty) {
      throw const FormatException('OTP response is missing its destination.');
    }

    return ContactOtpResponseModel(
      message: _string(json['message']),
      contactType: type,
      destination: destination,
      devOtp: _nullableString(json['devOtp']),
    );
  }
}

class AvatarUploadPreparationModel {
  const AvatarUploadPreparationModel({
    required this.storageKey,
    required this.signedUploadUrl,
    required this.publicUrl,
    required this.method,
    required this.headers,
    required this.expiresInSeconds,
    required this.maxSizeBytes,
  });

  final String storageKey;
  final String signedUploadUrl;
  final String publicUrl;
  final String method;
  final Map<String, String> headers;
  final int expiresInSeconds;
  final int maxSizeBytes;

  factory AvatarUploadPreparationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawHeaders = json['headers'];
    final Map<String, String> headers = <String, String>{};
    if (rawHeaders is Map) {
      for (final MapEntry<dynamic, dynamic> entry in rawHeaders.entries) {
        headers[entry.key.toString()] = entry.value.toString();
      }
    }

    return AvatarUploadPreparationModel(
      storageKey: _string(json['storageKey']),
      signedUploadUrl: _string(json['signedUploadUrl']),
      publicUrl: _string(json['publicUrl']),
      method: _string(json['method']).isEmpty
          ? 'PUT'
          : _string(json['method']).toUpperCase(),
      headers: headers,
      expiresInSeconds: _asInt(json['expiresInSeconds']),
      maxSizeBytes: _asInt(json['maxSizeBytes']),
    );
  }
}

class ConfirmAvatarUploadPayloadModel {
  const ConfirmAvatarUploadPayloadModel({
    required this.storageKey,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String storageKey;
  final String originalName;
  final String mimeType;
  final int sizeBytes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'storageKey': storageKey,
        'originalName': originalName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      };
}

class ChangeUserPasswordPayloadModel {
  const ChangeUserPasswordPayloadModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

class UserSettingsMessageModel {
  const UserSettingsMessageModel({required this.message});

  final String message;

  factory UserSettingsMessageModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsMessageModel(message: _string(json['message']));
  }
}

String _string(dynamic value) => value?.toString().trim() ?? '';

String? _nullableString(dynamic value) {
  final String text = _string(value);
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
