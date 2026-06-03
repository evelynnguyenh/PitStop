import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'is_new_user') required bool isNewUser,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
