import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../data/models/auth_response.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late SecureStorageService _storage;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(secureStorageServiceProvider);

    try {
      final token = await _storage.getAccessToken();
      if (token == null) return const AuthState.unauthenticated();
      // TODO(backend): attempt silent token refresh via POST /auth/refresh when backend is live
      return const AuthState.unauthenticated();
    } catch (_) {
      return const AuthState.unauthenticated();
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      // TODO(backend): replace mock when POST /auth/register is live
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final response = AuthResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'mock_user_id',
        email: email,
        isNewUser: true,
      );
      // final response = await ref.read(authApiClientProvider).register(RegisterRequest(email: email, password: password));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AsyncData(AuthState.authenticated(user: response));
    } catch (_) {
      state = const AsyncData(AuthState.error(message: 'Lỗi hệ thống, vui lòng thử lại'));
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      // TODO(backend): replace mock when POST /auth/login is live
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final response = AuthResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'mock_user_id',
        email: email,
        isNewUser: false,
      );
      // final response = await ref.read(authApiClientProvider).login(LoginRequest(email: email, password: password));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AsyncData(AuthState.authenticated(user: response));
    } catch (_) {
      state = const AsyncData(AuthState.error(message: 'Lỗi hệ thống, vui lòng thử lại'));
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      // TODO(backend): replace mock when POST /auth/google is live
      await Future<void>.delayed(const Duration(milliseconds: 800));
      const response = AuthResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'mock_google_user_id',
        email: 'mock@google.com',
        isNewUser: false,
      );
      // final account = await GoogleSignIn(scopes: []).signIn();
      // if (account == null) { state = AsyncData(AuthState.unauthenticated()); return; }
      // final auth = await account.authentication;
      // final response = await ref.read(authApiClientProvider).googleSignIn(GoogleAuthRequest(idToken: auth.idToken!));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = const AsyncData(AuthState.authenticated(user: response));
    } catch (_) {
      state = const AsyncData(AuthState.error(message: 'Đăng nhập Google thất bại, thử lại'));
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      // TODO(backend): replace mock when POST /auth/apple is live
      await Future<void>.delayed(const Duration(milliseconds: 800));
      const response = AuthResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'mock_apple_user_id',
        email: 'mock@apple.com',
        isNewUser: false,
      );
      // final credential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      // );
      // final response = await ref.read(authApiClientProvider).appleSignIn(AppleAuthRequest(
      //   identityToken: credential.identityToken!,
      //   authorizationCode: credential.authorizationCode,
      // ));
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = const AsyncData(AuthState.authenticated(user: response));
    } catch (_) {
      state = const AsyncData(AuthState.error(message: 'Đăng nhập Apple thất bại, thử lại'));
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _storage.clearAll();
      // TODO(backend): GoogleSignIn(scopes: []).signOut() when sign-in is wired up
    } catch (_) {
      // silently clear state regardless of errors
    }
    state = const AsyncData(AuthState.unauthenticated());
  }
}
