import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import 'models/auth_request.dart';
import 'models/auth_response.dart';


part 'auth_api_client.g.dart';

@Riverpod(keepAlive: true)
AuthApiClient authApiClient(AuthApiClientRef ref) {
  return AuthApiClient(ref.watch(dioProvider));
}

class AuthApiClient {
  AuthApiClient(this._dio);

  final Dio _dio;

  Future<AuthResponse> register(RegisterRequest body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: body.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> login(LoginRequest body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: body.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> googleSignIn(GoogleAuthRequest body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: body.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> appleSignIn(AppleAuthRequest body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/apple',
      data: body.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> refreshToken(RefreshRequest body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: body.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }
}
