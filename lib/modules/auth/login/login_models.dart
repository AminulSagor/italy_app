class LoginFormModel {
  const LoginFormModel({
    required this.selectedLanguage,
    required this.selectedLoginMode,
    required this.identifier,
    required this.password,
    required this.obscurePassword,
    required this.isLoading,
  });

  final String selectedLanguage;
  final String selectedLoginMode;
  final String identifier;
  final String password;
  final bool obscurePassword;
  final bool isLoading;

  bool get isEmailMode => selectedLoginMode == 'email';

  LoginFormModel copyWith({
    String? selectedLanguage,
    String? selectedLoginMode,
    String? identifier,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
  }) {
    return LoginFormModel(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedLoginMode: selectedLoginMode ?? this.selectedLoginMode,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory LoginFormModel.initial() {
    return const LoginFormModel(
      selectedLanguage: 'EN',
      selectedLoginMode: 'email',
      identifier: '',
      password: '',
      obscurePassword: true,
      isLoading: false,
    );
  }
}
