import 'package:dio/dio.dart';
import 'package:jumpup_app/core/auth/services/token_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/core/error/api_exception.dart';

/// Cliente Dio singleton con interceptor JWT automático.
///
/// Uso:
///   final dio = DioClient.instance;
///   final response = await dio.get('/notifications/');
class DioClient {
  DioClient._();

  static final DioClient _singleton = DioClient._();
  static DioClient get instance => _singleton;

  final TokenStorage _tokenStorage = TokenStorage();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        // Lee la URL desde el .env  → https://guaman-idiomas-ute.online/api/
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptor JWT ──────────────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Convierte DioException en ApiException para uniformidad en la app.
          final statusCode = error.response?.statusCode;
          final message = _messageFromStatus(statusCode, error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException(message, statusCode, error),
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );

    // Log en modo debug (se puede quitar en producción)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: false, // no loguear cuerpos con contraseñas
        responseBody: false,
        error: true,
      ),
    );

    return dio;
  }

  static String _messageFromStatus(int? code, DioException err) {
    switch (code) {
      case 400:
        return 'Solicitud inválida (400)';
      case 401:
        return 'No autorizado. Inicie sesión nuevamente (401)';
      case 403:
        return 'Acceso denegado (403)';
      case 404:
        return 'Recurso no encontrado (404)';
      case 500:
        return 'Error interno del servidor (500)';
      default:
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout) {
          return 'Tiempo de espera agotado. Verifique su conexión.';
        }
        return 'Error de red: ${err.message}';
    }
  }

  /// Guarda los tokens tras un login exitoso.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Elimina los tokens al cerrar sesión.
  Future<void> clearTokens() => _tokenStorage.clearTokens();
}
