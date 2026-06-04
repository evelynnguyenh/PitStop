import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../data/auth_api_client.dart';
import '../data/models/auth_request.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  static Future<void>? _googleInitialization;

  late SecureStorageService _storage;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(secureStorageServiceProvider);

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return const AuthState.unauthenticated();

      final response = await ref
          .read(authApiClientProvider)
          .refreshToken(RefreshRequest(refreshToken: refreshToken));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return AuthState.authenticated(user: response);
    } catch (_) {
      await _storage.clearAll();
      return const AuthState.unauthenticated();
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authApiClientProvider).register(
            RegisterRequest(email: email, password: password),
          );
      await _storage.clearAll();
      state = const AsyncData(AuthState.unauthenticated());
    } on DioException catch (error) {
      state = AsyncData(AuthState.error(message: _emailAuthMessage(error)));
    } catch (_) {
      state = const AsyncData(
        AuthState.error(message: 'Lỗi hệ thống, vui lòng thử lại'),
      );
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(authApiClientProvider).login(
            LoginRequest(email: email, password: password),
          );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AsyncData(AuthState.authenticated(user: response));
    } on DioException catch (error) {
      state = AsyncData(AuthState.error(message: _emailAuthMessage(error)));
    } catch (_) {
      state = const AsyncData(
        AuthState.error(message: 'Lỗi hệ thống, vui lòng thử lại'),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        state = const AsyncData(
          AuthState.error(message: 'Google không trả về mã đăng nhập'),
        );
        return;
      }

      final response = await ref
          .read(authApiClientProvider)
          .googleSignIn(GoogleAuthRequest(idToken: idToken));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AsyncData(AuthState.authenticated(user: response));
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted ||
          error.code == GoogleSignInExceptionCode.uiUnavailable) {
        state = const AsyncData(AuthState.unauthenticated());
        return;
      }
      state = const AsyncData(
        AuthState.error(message: 'Google chưa được cấu hình đúng'),
      );
    } on DioException catch (error) {
      state = AsyncData(AuthState.error(message: _googleBackendMessage(error)));
    } catch (_) {
      state = const AsyncData(
        AuthState.error(message: 'Đăng nhập Google thất bại, thử lại'),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncData(
      AuthState.error(message: 'Đăng nhập Apple chưa được hỗ trợ'),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _storage.clearAll();
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Keep logout local even if Google sign-out fails.
    }
    state = const AsyncData(AuthState.unauthenticated());
  }

  void clearError() {
    if (state.valueOrNull is AuthStateError) {
      state = const AsyncData(AuthState.unauthenticated());
    }
  }

  Future<void> _ensureGoogleInitialized() {
    final clientId = const String.fromEnvironment('GOOGLE_CLIENT_ID');
    final serverClientId =
        const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    return _googleInitialization ??= GoogleSignIn.instance.initialize(
      clientId: clientId.isEmpty ? null : clientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
  }

  String _emailAuthMessage(DioException error) {
    if (_isConnectionError(error)) {
      return 'Không kết nối được máy chủ';
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'Email hoặc mật khẩu không đúng';
      case 409:
        return 'Email này đã được đăng ký';
      case 422:
        return 'Thông tin đăng nhập không hợp lệ';
      default:
        return 'Lỗi hệ thống, vui lòng thử lại';
    }
  }

  String _googleBackendMessage(DioException error) {
    if (_isConnectionError(error)) {
      return 'Không kết nối được máy chủ';
    }
    if (error.response?.statusCode == 503) {
      return 'Google chưa được cấu hình trên backend';
    }
    if (error.response?.statusCode == 401) {
      return 'Mã đăng nhập Google không hợp lệ';
    }
    return 'Đăng nhập Google thất bại, thử lại';
  }

  bool _isConnectionError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
