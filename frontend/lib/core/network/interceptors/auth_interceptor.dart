import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor(this._ref);

  final Ref _ref;

  static const _retryKey = 'auth_retry';

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
      // Proceed without token if storage is unavailable.
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final canRefresh = err.response?.statusCode == 401 &&
        request.extra[_retryKey] != true &&
        !_isRefreshRequest(request);

    if (!canRefresh) {
      handler.next(err);
      return;
    }

    try {
      final storage = _ref.read(secureStorageServiceProvider);
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        await storage.clearAll();
        handler.next(err);
        return;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: request.baseUrl,
          connectTimeout: request.connectTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final body = refreshResponse.data!;
      final accessToken = body['access_token'] as String;
      final rotatedRefreshToken = body['refresh_token'] as String;
      await storage.saveTokens(
        accessToken: accessToken,
        refreshToken: rotatedRefreshToken,
      );

      final retryOptions = _copyForRetry(request, accessToken);
      final retryDio = Dio();
      final retryResponse = await retryDio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      try {
        await _ref.read(secureStorageServiceProvider).clearAll();
      } catch (_) {}
      handler.next(err);
    }
  }

  bool _isRefreshRequest(RequestOptions request) {
    final uri = request.uri;
    return uri.path.endsWith('/auth/refresh') ||
        request.path == '/auth/refresh';
  }

  RequestOptions _copyForRetry(RequestOptions request, String accessToken) {
    final headers = Map<String, dynamic>.from(request.headers)
      ..['Authorization'] = 'Bearer $accessToken';
    final extra = Map<String, dynamic>.from(request.extra)..[_retryKey] = true;

    return request.copyWith(headers: headers, extra: extra);
  }
}
