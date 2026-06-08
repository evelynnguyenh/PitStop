import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/auth_response.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;

  const factory AuthState.authenticated({
    required AuthResponse user,
  }) = AuthStateAuthenticated;

  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  const factory AuthState.error({
    required String message,
  }) = AuthStateError;
}
