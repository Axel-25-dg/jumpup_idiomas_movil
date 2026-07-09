import 'package:dio/dio.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/core/error/api_exception.dart';

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
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.startsWith('/')) {
            options.path = options.path.substring(1);
          }
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final response = await Dio(
                  BaseOptions(baseUrl: AppConfig.baseUrl),
                ).post<Map<String, dynamic>>(
                  'auth/token/refresh/',
                  data: {'refresh': refreshToken},
                );
                final data = response.data!;
                final newAccess = data['access'] as String?;
                final newRefresh = data['refresh'] as String?;
                if (newAccess != null) {
                  await _tokenStorage.saveTokens(
                    accessToken: newAccess,
                    refreshToken: newRefresh ?? refreshToken,
                  );
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';
                  final retryResponse = await Dio(
                    BaseOptions(baseUrl: AppConfig.baseUrl),
                  ).fetch<dynamic>(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {}
            }
          }

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

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearTokens() => _tokenStorage.clearTokens();
}
