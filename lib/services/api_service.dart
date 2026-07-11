import 'package:dio/dio.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';

/// Wrapper de compatibilidad sobre DioClient.
/// Todas las pantallas que aún usen ApiService() ahora usan
/// el mismo Dio y el mismo TokenStorage que DioClient.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final TokenStorage _tokenStorage = TokenStorage();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
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
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await _tokenStorage.getRefreshToken();
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final resp = await Dio(BaseOptions(baseUrl: AppConfig.baseUrl))
                  .post<Map<String, dynamic>>(
                'auth/token/refresh/',
                data: {'refresh': refresh},
              );
              final newAccess = resp.data?['access'] as String?;
              final newRefresh = resp.data?['refresh'] as String?;
              if (newAccess != null) {
                await _tokenStorage.saveTokens(
                  accessToken: newAccess,
                  refreshToken: newRefresh ?? refresh,
                );
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retry = await _dio.fetch<dynamic>(e.requestOptions);
                return handler.resolve(retry);
              }
            } catch (_) {
              // No limpiar tokens aquí — solo propagar el error 401
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  // ── Solicitar PIN de recuperación ──────────────────────────────────────────
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('auth/password-reset/', data: {'email': email});
    } on DioException catch (e) {
      final detail = e.response?.data;
      final msg = detail is Map
          ? (detail['detail']?.toString() ?? 'Error al solicitar el código')
          : 'Error al solicitar el código';
      throw Exception(msg);
    }
  }

  // ── Confirmar PIN y nueva contraseña ───────────────────────────────────────
  Future<void> confirmPasswordReset({
    required String email,
    required String pin,
    required String newPassword,
  }) async {
    try {
      await _dio.post('auth/password-reset-confirm/', data: {
        'email': email,
        'code': pin,         // El backend usa "code" según la documentación
        'password': newPassword,
      });
    } on DioException catch (e) {
<<<<<<< HEAD
      throw Exception(e.response?.data['detail'] ?? 'PIN incorrecto o expirado');
    }
  }

  // ==========================================
  // 4. HISTORIAL DE NOTIFICACIONES
  // ==========================================
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('notifications/');
      return response.data; 
    } on DioException {
      throw Exception('Error al cargar notificaciones');
=======
      final detail = e.response?.data;
      final msg = detail is Map
          ? (detail['detail']?.toString() ?? 'PIN incorrecto o expirado')
          : 'PIN incorrecto o expirado';
      throw Exception(msg);
>>>>>>> main
    }
  }
}
