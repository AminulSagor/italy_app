class SignupPayloadModel {
  const SignupPayloadModel({
    required this.fullName,
    required this.password,
    this.email,
    this.phone,
  });

  final String fullName;
  final String password;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName.trim(),
      'password': password,
      if (email != null && email!.trim().isNotEmpty)
        'email': email!.trim().toLowerCase(),
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
    };
  }

  SignupPayloadModel copyWith({
    String? fullName,
    String? password,
    String? email,
    String? phone,
  }) {
    return SignupPayloadModel(
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class LoginPayloadModel {
  const LoginPayloadModel({required this.password, this.email, this.phone});

  final String password;
  final String? email;
  final String? phone;

  String get identifier => (email ?? phone ?? '').trim();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identifier': email != null ? identifier.toLowerCase() : identifier,
      'password': password,
    };
  }

  LoginPayloadModel copyWith({String? password, String? email, String? phone}) {
    return LoginPayloadModel(
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class OtpVerificationPayloadModel {
  const OtpVerificationPayloadModel({
    required this.code,
    required this.identifier,
  });

  final String code;
  final String identifier;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identifier': identifier.trim().contains('@')
          ? identifier.trim().toLowerCase()
          : identifier.trim(),
      'otp': code.trim(),
    };
  }

  OtpVerificationPayloadModel copyWith({String? code, String? identifier}) {
    return OtpVerificationPayloadModel(
      code: code ?? this.code,
      identifier: identifier ?? this.identifier,
    );
  }
}

class SignupResultModel {
  const SignupResultModel({
    required this.message,
    required this.identifier,
    this.devOtp,
  });

  final String message;
  final String identifier;
  final String? devOtp;

  factory SignupResultModel.fromJson(Map<String, dynamic> json) {
    return SignupResultModel(
      message: json['message']?.toString() ?? 'Account created successfully.',
      identifier: json['identifier']?.toString() ?? '',
      devOtp: json['devOtp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'identifier': identifier,
      if (devOtp != null) 'devOtp': devOtp,
    };
  }

  SignupResultModel copyWith({
    String? message,
    String? identifier,
    String? devOtp,
  }) {
    return SignupResultModel(
      message: message ?? this.message,
      identifier: identifier ?? this.identifier,
      devOtp: devOtp ?? this.devOtp,
    );
  }
}

class OtpResponseModel {
  const OtpResponseModel({required this.message, this.devOtp});

  final String message;
  final String? devOtp;

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message']?.toString() ?? 'Verification code sent.',
      devOtp: json['devOtp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      if (devOtp != null) 'devOtp': devOtp,
    };
  }

  OtpResponseModel copyWith({String? message, String? devOtp}) {
    return OtpResponseModel(
      message: message ?? this.message,
      devOtp: devOtp ?? this.devOtp,
    );
  }
}

class AuthTokenResultModel {
  const AuthTokenResultModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    this.message,
  });

  final String accessToken;
  final String tokenType;
  final AuthUserModel user;
  final String? message;

  factory AuthTokenResultModel.fromJson(Map<String, dynamic> json) {
    final Object? rawUser = json['user'];
    return AuthTokenResultModel(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      message: json['message']?.toString(),
      user: rawUser is Map
          ? AuthUserModel.fromJson(Map<String, dynamic>.from(rawUser))
          : AuthUserModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'tokenType': tokenType,
      if (message != null) 'message': message,
      'user': user.toJson(),
    };
  }

  AuthTokenResultModel copyWith({
    String? accessToken,
    String? tokenType,
    AuthUserModel? user,
    String? message,
  }) {
    return AuthTokenResultModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }
}

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isVerified,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.email,
    this.phone,
    this.profilePhotoFileId,
    this.hapticsEnabled,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool isVerified;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profilePhotoFileId;
  final bool? hapticsEnabled;

  factory AuthUserModel.empty() {
    return const AuthUserModel(
      id: '',
      fullName: '',
      role: 'user',
      isVerified: false,
      isEmailVerified: false,
      isPhoneVerified: false,
    );
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'user',
      isVerified: json['isVerified'] == true,
      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
      profilePhotoFileId: json['profilePhotoFileId']?.toString(),
      hapticsEnabled: json['hapticsEnabled'] is bool
          ? json['hapticsEnabled'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'profilePhotoFileId': profilePhotoFileId,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  AuthUserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    bool? isVerified,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profilePhotoFileId,
    bool? hapticsEnabled,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profilePhotoFileId: profilePhotoFileId ?? this.profilePhotoFileId,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
