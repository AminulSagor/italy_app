class UserSettingsProfileModel {
  const UserSettingsProfileModel({
    required this.id,
    required this.fullName,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.canChangeEmail,
    required this.canChangePhone,
    required this.streakFreezeCount,
    required this.learnerLevel,
    this.email,
    this.phone,
    this.profilePhotoFileId,
    this.avatarUrl,
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
  final String learnerLevel;

  factory UserSettingsProfileModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
      profilePhotoFileId: _nullableString(json['profilePhotoFileId']),
      avatarUrl: _nullableString(json['avatarUrl']),
      canChangeEmail: json['canChangeEmail'] != false,
      canChangePhone: json['canChangePhone'] != false,
      streakFreezeCount: _asInt(json['streakFreezeCount']),
      learnerLevel: _stringOrDefault(json['learnerLevel'], 'A1'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      'learnerLevel': learnerLevel,
    };
  }

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
      learnerLevel: learnerLevel ?? this.learnerLevel,
    );
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringOrDefault(dynamic value, String fallback) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
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
    final dynamic rawProfile = json['profile'];
    final Map<String, dynamic> profileJson = rawProfile is Map
        ? Map<String, dynamic>.from(rawProfile)
        : <String, dynamic>{};

    return UserSettingsProfileResponseModel(
      profile: UserSettingsProfileModel.fromJson(profileJson),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      'profile': profile.toJson(),
    };
  }
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
    return ContactOtpResponseModel(
      message: json['message']?.toString() ?? 'Verification code sent.',
      contactType: json['contactType']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      devOtp: _nullableString(json['devOtp']),
    );
  }

  static String? _nullableString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class AvatarUploadPreparationModel {
  const AvatarUploadPreparationModel({
    required this.storageKey,
    required this.signedUploadUrl,
    required this.publicUrl,
    required this.maxSizeBytes,
  });

  final String storageKey;
  final String signedUploadUrl;
  final String publicUrl;
  final int maxSizeBytes;

  factory AvatarUploadPreparationModel.fromJson(Map<String, dynamic> json) {
    return AvatarUploadPreparationModel(
      storageKey: json['storageKey']?.toString() ?? '',
      signedUploadUrl: json['signedUploadUrl']?.toString() ?? '',
      publicUrl: json['publicUrl']?.toString() ?? '',
      maxSizeBytes: _asInt(json['maxSizeBytes']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storageKey': storageKey,
      'signedUploadUrl': signedUploadUrl,
      'publicUrl': publicUrl,
      'maxSizeBytes': maxSizeBytes,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storageKey': storageKey,
      'originalName': originalName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }

  ConfirmAvatarUploadPayloadModel copyWith({
    String? storageKey,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
  }) {
    return ConfirmAvatarUploadPayloadModel(
      storageKey: storageKey ?? this.storageKey,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };
  }

  ChangeUserPasswordPayloadModel copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
  }) {
    return ChangeUserPasswordPayloadModel(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
    );
  }
}

class UserSettingsMessageModel {
  const UserSettingsMessageModel({required this.message});

  final String message;

  factory UserSettingsMessageModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsMessageModel(
      message: json['message']?.toString() ?? 'Request completed successfully.',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'message': message};
}
