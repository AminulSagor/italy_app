class SignupFormModel {
  const SignupFormModel({
    required this.selectedLanguage,
    required this.selectedSignupMode,
    required this.fullName,
    required this.identifier,
    required this.password,
    required this.agreedToTerms,
    required this.obscurePassword,
    required this.isLoading,
  });

  final String selectedLanguage;
  final String selectedSignupMode;
  final String fullName;
  final String identifier;
  final String password;
  final bool agreedToTerms;
  final bool obscurePassword;
  final bool isLoading;

  bool get isEmailMode => selectedSignupMode == 'email';

  SignupFormModel copyWith({
    String? selectedLanguage,
    String? selectedSignupMode,
    String? fullName,
    String? identifier,
    String? password,
    bool? agreedToTerms,
    bool? obscurePassword,
    bool? isLoading,
  }) {
    return SignupFormModel(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedSignupMode: selectedSignupMode ?? this.selectedSignupMode,
      fullName: fullName ?? this.fullName,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory SignupFormModel.initial() {
    return const SignupFormModel(
      selectedLanguage: 'EN',
      selectedSignupMode: 'email',
      fullName: '',
      identifier: '',
      password: '',
      agreedToTerms: false,
      obscurePassword: true,
      isLoading: false,
    );
  }
}

class SignupOtpUiModel {
  const SignupOtpUiModel({
    required this.maskedIdentifier,
    required this.codeDigits,
    required this.isResending,
    required this.isVerifying,
  });

  final String maskedIdentifier;
  final List<String> codeDigits;
  final bool isResending;
  final bool isVerifying;

  bool get isCodeComplete =>
      codeDigits.every((String digit) => digit.isNotEmpty);

  String get code => codeDigits.join();

  SignupOtpUiModel copyWith({
    String? maskedIdentifier,
    List<String>? codeDigits,
    bool? isResending,
    bool? isVerifying,
  }) {
    return SignupOtpUiModel(
      maskedIdentifier: maskedIdentifier ?? this.maskedIdentifier,
      codeDigits: codeDigits ?? this.codeDigits,
      isResending: isResending ?? this.isResending,
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }

  factory SignupOtpUiModel.initial() {
    return const SignupOtpUiModel(
      maskedIdentifier: '',
      codeDigits: <String>['', '', '', ''],
      isResending: false,
      isVerifying: false,
    );
  }
}

class SignupAccountCreatedUiModel {
  const SignupAccountCreatedUiModel({
    required this.fullName,
    required this.identifier,
    required this.isStarting,
  });

  final String fullName;
  final String identifier;
  final bool isStarting;

  SignupAccountCreatedUiModel copyWith({
    String? fullName,
    String? identifier,
    bool? isStarting,
  }) {
    return SignupAccountCreatedUiModel(
      fullName: fullName ?? this.fullName,
      identifier: identifier ?? this.identifier,
      isStarting: isStarting ?? this.isStarting,
    );
  }

  factory SignupAccountCreatedUiModel.initial() {
    return const SignupAccountCreatedUiModel(
      fullName: '',
      identifier: '',
      isStarting: false,
    );
  }
}
