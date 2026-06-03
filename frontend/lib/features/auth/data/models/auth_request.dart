import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable(createFactory: false)
class RegisterRequest {
  const RegisterRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GoogleAuthRequest {
  const GoogleAuthRequest({required this.idToken});

  @JsonKey(name: 'id_token')
  final String idToken;

  Map<String, dynamic> toJson() => _$GoogleAuthRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class AppleAuthRequest {
  const AppleAuthRequest({
    required this.identityToken,
    required this.authorizationCode,
  });

  @JsonKey(name: 'identity_token')
  final String identityToken;

  @JsonKey(name: 'authorization_code')
  final String authorizationCode;

  Map<String, dynamic> toJson() => _$AppleAuthRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);
}
