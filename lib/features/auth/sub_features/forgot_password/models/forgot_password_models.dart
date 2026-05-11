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
    required this.requestToken,
    required this.codeDigits,
    required this.isResending,
    required this.isVerifying,
  });

  final String maskedIdentifier;
  final String requestToken;
  final List<String> codeDigits;
  final bool isResending;
  final bool isVerifying;

  bool get isCodeComplete =>
      codeDigits.every((String digit) => digit.trim().isNotEmpty);

  String get code => codeDigits.join();

  ForgotPasswordOtpUiModel copyWith({
    String? maskedIdentifier,
    String? requestToken,
    List<String>? codeDigits,
    bool? isResending,
    bool? isVerifying,
  }) {
    return ForgotPasswordOtpUiModel(
      maskedIdentifier: maskedIdentifier ?? this.maskedIdentifier,
      requestToken: requestToken ?? this.requestToken,
      codeDigits: codeDigits ?? this.codeDigits,
      isResending: isResending ?? this.isResending,
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }

  factory ForgotPasswordOtpUiModel.initial() {
    return const ForgotPasswordOtpUiModel(
      maskedIdentifier: '',
      requestToken: '',
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

  bool get hasMinLength => newPassword.trim().length >= 8;

  bool get hasUppercaseAndNumber {
    final String value = newPassword.trim();
    final bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final bool hasNumber = RegExp(r'\d').hasMatch(value);
    return hasUppercase && hasNumber;
  }

  bool get matchesConfirm =>
      confirmPassword.trim().isNotEmpty &&
      newPassword.trim() == confirmPassword.trim();

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
    return <String, dynamic>{'identifier': identifier, 'channel': channel};
  }
}

class ForgotPasswordRequestUiModel {
  const ForgotPasswordRequestUiModel({
    required this.maskedIdentifier,
    required this.requestToken,
  });

  final String maskedIdentifier;
  final String requestToken;

  factory ForgotPasswordRequestUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestUiModel(
      maskedIdentifier: (json['maskedIdentifier'] ?? '').toString(),
      requestToken: (json['requestToken'] ?? '').toString(),
    );
  }
}

class ForgotPasswordVerifyOtpPayloadModel {
  const ForgotPasswordVerifyOtpPayloadModel({
    required this.requestToken,
    required this.code,
  });

  final String requestToken;
  final String code;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'requestToken': requestToken, 'code': code};
  }
}

class ForgotPasswordVerifyOtpUiModel {
  const ForgotPasswordVerifyOtpUiModel({required this.resetToken});

  final String resetToken;

  factory ForgotPasswordVerifyOtpUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordVerifyOtpUiModel(
      resetToken: (json['resetToken'] ?? '').toString(),
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
      'resetToken': resetToken,
      'newPassword': newPassword,
    };
  }
}

class ForgotPasswordResetUiModel {
  const ForgotPasswordResetUiModel({required this.successMessage});

  final String successMessage;

  factory ForgotPasswordResetUiModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResetUiModel(
      successMessage: (json['successMessage'] ?? '').toString(),
    );
  }
}
