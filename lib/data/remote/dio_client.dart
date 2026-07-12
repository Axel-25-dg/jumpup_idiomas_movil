import 'package:dio/dio.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/data/remote/interceptor/auth_interceptor.dart';
import 'package:jumpup_app/core/config/app_config.dart';

/// Cliente HTTP centralizado.
///
/// Registra [AuthInterceptor] para manejo automático de token JWT,
/// renovación silenciosa con refresh token y logs de red.
class DioClient {
  DioClient._();

  static final DioClient _singleton = DioClient._();
  static DioClient get instance => _singleton;

  final SecureStorage _secureStorage = SecureStorage();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptores ──────────────────────────────────────────────────────
    // 1. Auth: adjunta Bearer token, maneja 401 y renueva con refresh token
    dio.interceptors.add(AuthInterceptor(_secureStorage));

    // 2. Log: visible solo en modo debug
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );

    return dio;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearTokens() => _secureStorage.clearTokens();
}
