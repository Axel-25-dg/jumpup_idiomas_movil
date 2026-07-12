import 'package:dio/dio.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/core/error/api_exception.dart';

/// Interceptor de autenticación JWT.
///
/// Responsabilidades:
///   1. Adjunta el `Authorization: Bearer <token>` en cada request.
///   2. Si recibe un 401, intenta renovar el token usando el refresh token.
///   3. Si el refresh falla, limpia la sesión y propaga el error.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  // ── onRequest ──────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Eliminar slash inicial para evitar doble barra con la baseUrl
    if (options.path.startsWith('/')) {
      options.path = options.path.substring(1);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  // ── onError ────────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio(
            BaseOptions(baseUrl: AppConfig.baseUrl),
          );

          final response = await refreshDio.post<Map<String, dynamic>>(
            'auth/token/refresh/',
            data: {'refresh': refreshToken},
          );

          final data = response.data!;
          final newAccess = data['access'] as String?;
          final newRefresh = data['refresh'] as String?;

          if (newAccess != null) {
            await _secureStorage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh ?? refreshToken,
            );

            // Reintentar el request original con el nuevo token
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccess';

            final retryDio = Dio(
              BaseOptions(baseUrl: AppConfig.baseUrl),
            );

            final retryResponse =
                await retryDio.fetch<dynamic>(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // El refresh falló — limpiar sesión
          await _secureStorage.clearTokens();
        }
      }
    }

    // Transformar DioException en ApiException con mensaje legible
    final statusCode = err.response?.statusCode;
    final message = _messageFromStatus(statusCode, err);

    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(message, statusCode, err),
        response: err.response,
        type: err.type,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
}
