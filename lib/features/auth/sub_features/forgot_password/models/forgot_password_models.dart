class ForgotPasswordFormModel {
  const ForgotPasswordFormModel({
    required this.selectedLanguage,
    required this.selectedResetMode,
    required this.identifier,
    required this.isSubmitting,
  });

  final String selectedLanguage;
  final String selectedResetMode;
  final String identifier;
  final bool isSubmitting;

  bool get isEmailMode => selectedResetMode == 'email';

  ForgotPasswordFormModel copyWith({
    String? selectedLanguage,
    String? selectedResetMode,
    String? identifier,
    bool? isSubmitting,
  }) {
    return ForgotPasswordFormModel(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedResetMode: selectedResetMode ?? this.selectedResetMode,
      identifier: identifier ?? this.identifier,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  factory ForgotPasswordFormModel.initial() {
    return const ForgotPasswordFormModel(
      selectedLanguage: 'EN',
      selectedResetMode: 'email',
      identifier: '',
      isSubmitting: false,
    );
  }
}

class ForgotPasswordOtpUiModel {
  const ForgotPasswordOtpUiModel({
    required this.maskedIdentifier,
    required this.identifier,
    required this.codeDigits,
    required this.isResending,
    required this.isVerifying,
  });

  /*
   * Used only for displaying the destination.
   *
   * Example:
   * am***@gmail.com
   */
  final String maskedIdentifier;

  /*
   * Real normalized email address or phone number.
   *
   * This is sent to:
   * POST /auth/verify-reset-otp
   */
  final String identifier;

  final List<String> codeDigits;
  final bool isResending;
  final bool isVerifying;

  bool get isCodeComplete {
    return codeDigits.length == 4 &&
        codeDigits.every(
          (String digit) => RegExp(r'^\d$').hasMatch(digit.trim()),
        );
  }

  String get code => codeDigits.join().trim();

  ForgotPasswordOtpUiModel copyWith({
    String? maskedIdentifier,
    String? identifier,
    List<String>? codeDigits,
    bool? isResending,
    bool? isVerifying,
  }) {
    return ForgotPasswordOtpUiModel(
      maskedIdentifier: maskedIdentifier ?? this.maskedIdentifier,
      identifier: identifier ?? this.identifier,
      codeDigits: codeDigits ?? this.codeDigits,
      isResending: isResending ?? this.isResending,
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }

  factory ForgotPasswordOtpUiModel.initial() {
    return const ForgotPasswordOtpUiModel(
      maskedIdentifier: '',
      identifier: '',
      codeDigits: <String>['', '', '', ''],
      isResending: false,
      isVerifying: false,
    );
  }
}

class ResetPasswordFormModel {
  const ResetPasswordFormModel({
    required this.newPassword,
    required this.confirmPassword,
    required this.obscureNewPassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
  });

  final String newPassword;
  final String confirmPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;

  bool get hasMinimumLength => newPassword.length >= 6;

  bool get isStrongPassword => hasMinimumLength;

  bool get matchesConfirm {
    return confirmPassword.isNotEmpty && newPassword == confirmPassword;
  }

  ResetPasswordFormModel copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? isSubmitting,
  }) {
    return ResetPasswordFormModel(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  factory ResetPasswordFormModel.initial() {
    return const ResetPasswordFormModel(
      newPassword: '',
      confirmPassword: '',
      obscureNewPassword: true,
      obscureConfirmPassword: true,
      isSubmitting: false,
    );
  }
}

class ForgotPasswordRequestPayloadModel {
  const ForgotPasswordRequestPayloadModel({
    required this.identifier,
    required this.channel,
  });

  final String identifier;
  final String channel;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identifier': _normalizeIdentifier(identifier),
      'channel': channel,
    };
  }
}

class ForgotPasswordRequestUiModel {
  const ForgotPasswordRequestUiModel({
    required this.maskedIdentifier,
    required this.identifier,
    required this.message,
    this.devOtp,
  });

  final String maskedIdentifier;

  /*
   * The real normalized email address or phone number.
   *
   * This replaces the old fake requestToken value.
   */
  final String identifier;

  final String message;
  final String? devOtp;

  factory ForgotPasswordRequestUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestUiModel(
      maskedIdentifier: (json['maskedIdentifier'] ?? '').toString().trim(),
      identifier: _normalizeIdentifier((json['identifier'] ?? '').toString()),
      message: (json['message'] ?? 'Reset code sent successfully.')
          .toString()
          .trim(),
      devOtp: _optionalString(json['devOtp']),
    );
  }
}

class ForgotPasswordVerifyOtpPayloadModel {
  const ForgotPasswordVerifyOtpPayloadModel({
    required this.identifier,
    required this.otp,
  });

  final String identifier;
  final String otp;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identifier': _normalizeIdentifier(identifier),
      'otp': otp.trim(),
    };
  }
}

class ForgotPasswordVerifyOtpUiModel {
  const ForgotPasswordVerifyOtpUiModel({
    required this.resetToken,
    required this.expiresInSeconds,
  });

  /*
   * One-time token returned by:
   *
   * POST /auth/verify-reset-otp
   *
   * The OTP itself is no longer stored for the
   * final password-reset request.
   */
  final String resetToken;
  final int expiresInSeconds;

  bool get isValid {
    return resetToken.trim().isNotEmpty && expiresInSeconds > 0;
  }

  factory ForgotPasswordVerifyOtpUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordVerifyOtpUiModel(
      resetToken: (json['resetToken'] ?? '').toString().trim().toLowerCase(),
      expiresInSeconds: _toInt(json['expiresInSeconds']),
    );
  }
}

class ForgotPasswordResetPayloadModel {
  const ForgotPasswordResetPayloadModel({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resetToken': resetToken.trim().toLowerCase(),
      'newPassword': newPassword.trim(),
    };
  }
}

class ForgotPasswordResetUiModel {
  const ForgotPasswordResetUiModel({required this.successMessage});

  final String successMessage;

  factory ForgotPasswordResetUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResetUiModel(
      successMessage:
          (json['successMessage'] ??
                  json['message'] ??
                  'Password has been successfully updated.')
              .toString()
              .trim(),
    );
  }
}

String _normalizeIdentifier(String identifier) {
  final String normalized = identifier.trim();

  return normalized.contains('@') ? normalized.toLowerCase() : normalized;
}

String? _optionalString(dynamic value) {
  if (value == null) {
    return null;
  }

  final String normalized = value.toString().trim();

  return normalized.isEmpty ? null : normalized;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
