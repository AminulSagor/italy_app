//payload models will be updated according to api contract.
// for now, these are just placeholders to allow development of UI
// and flow without waiting for backend integration.
class SignupPayloadModel {
  const SignupPayloadModel({
    required this.fullName,
    required this.password,
    required this.language,
    this.email,
    this.phone,
  });

  final String fullName;
  final String password;
  final String language;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'password': password,
      'language': language,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

class LoginPayloadModel {
  const LoginPayloadModel({required this.password, this.email, this.phone});

  final String password;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'password': password,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
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
    return <String, dynamic>{'code': code, 'identifier': identifier};
  }
}
