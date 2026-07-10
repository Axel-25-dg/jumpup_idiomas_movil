import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://guaman-idiomas-ute.online/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          bool refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: 'access_token');
            e.requestOptions.headers['Authorization'] = 'Bearer $token';
            final cloneReq = await _dio.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        'https://guaman-idiomas-ute.online/api/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: response.data['access']);
        return true;
      }
    } catch (e) {
      // Clear storage on failure
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    }
    return false;
  }

  // ==========================================
  // 1. REGISTRO (Envía correo de bienvenida/verificación)
  // ==========================================
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post('auth/register/', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al registrar usuario');
    }
  }

  // ==========================================
  // 2. SOLICITAR PIN DE RECUPERACIÓN (Envía correo con el PIN)
  // ==========================================
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('auth/password-reset/', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al solicitar el código');
    }
  }

  // ==========================================
  // 3. CONFIRMAR NUEVA CONTRASEÑA (Valida el PIN)
  // ==========================================
  Future<void> confirmPasswordReset({
    required String email,
    required String pin,
    required String newPassword,
  }) async {
    try {
      await _dio.post('auth/password-reset-confirm/', data: {
        'email': email,
        'pin': pin,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
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
    }
  }
}
