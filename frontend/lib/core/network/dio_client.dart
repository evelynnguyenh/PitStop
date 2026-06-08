import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'interceptors/auth_interceptor.dart';

part 'dio_client.g.dart';

const _defaultBaseUrl = 'http://localhost:8000/api/v1';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);

  final instance = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  instance.interceptors.add(AuthInterceptor(ref));

  return instance;
}
