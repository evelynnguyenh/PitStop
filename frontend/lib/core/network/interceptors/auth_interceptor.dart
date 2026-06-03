import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final storage = _ref.read(secureStorageServiceProvider);
      final token = await storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // proceed without token if storage is unavailable
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final storage = _ref.read(secureStorageServiceProvider);
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken != null) {
          // TODO(backend): perform token refresh via POST /auth/refresh when backend is live
          // On success: save new tokens and retry original request
          // On failure: fall through to logout
        }
      } catch (_) {
        // fall through to logout
      }
      // Clear tokens and let the auth notifier reset state
      try {
        await _ref.read(secureStorageServiceProvider).clearAll();
      } catch (_) {}
    }
    handler.next(err);
  }
}
