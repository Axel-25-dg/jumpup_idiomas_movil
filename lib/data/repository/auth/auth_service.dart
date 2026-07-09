import 'package:dio/dio.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

/// Servicio de autenticación conectado a la API Django en Hetzner.
///
/// Endpoints:
///   POST /api/auth/login/                  → obtiene access + refresh tokens
///   POST /api/auth/register/               → crea cuenta nueva
///   POST /api/auth/password-reset/         → envía email de recuperación con PIN
///   POST /api/auth/password-reset-confirm/ → confirma el PIN y cambia password
///   GET  /api/auth/me/                     → perfil del usuario autenticado
///   POST /api/auth/token/refresh/          → renueva el access token
///   POST /api/auth/biometric/login/        → login por huella dactilar
class AuthService {
  AuthService() : _dio = DioClient.instance.dio;

  final Dio _dio;
  final _client = DioClient.instance;

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<AuthTokenModel> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/login/',
        data: request.toJson(),
      );
      final data = response.data!;
      final tokens = AuthTokenModel.fromJson(_normalizeTokenResponse(data));
      await _client.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo iniciar sesión');
    }
  }

  // ── Login con Google ───────────────────────────────────────────────────────

  /// Envía el ID token de Google al backend para autenticación.
  /// El backend valida con Google y devuelve los JWT propios.
  Future<AuthTokenModel> loginWithGoogle(String googleIdToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/google/',
        data: {'id_token': googleIdToken},
      );
      final data = response.data!;
      final tokens = AuthTokenModel.fromJson(_normalizeTokenResponse(data));
      await _client.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo iniciar sesión con Google');
    }
  }

  // ── Login biométrico ───────────────────────────────────────────────────────

  /// Login por huella dactilar usando el biometric_token guardado en el dispositivo.
  Future<AuthTokenModel> biometricLogin({
    required String deviceId,
    required String biometricToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/biometric/login/',
        data: {
          'device_id': deviceId,
          'biometric_token': biometricToken,
        },
      );
      final data = response.data!;
      final tokens = AuthTokenModel.fromJson(_normalizeTokenResponse(data));
      await _client.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo autenticar con huella dactilar');
    }
  }

  /// Registra el dispositivo para autenticación biométrica.
  Future<String> registerBiometric(String deviceId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/biometric/register/',
        data: {'device_id': deviceId},
      );
      return response.data!['biometric_token'] as String? ?? '';
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo registrar la huella dactilar');
    }
  }

  // ── Registro ───────────────────────────────────────────────────────────────

  Future<AuthTokenModel> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/register/',
        data: request.toJson(),
      );
      final data = response.data!;
      final tokens = AuthTokenModel.fromJson(_normalizeTokenResponse(data));
      await _client.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo completar el registro');
    }
  }

  // ── Recuperar contraseña — Paso 1: Enviar PIN al correo ───────────────────

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _dio.post<dynamic>(
        'auth/password-reset/',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo enviar el correo de recuperación');
    }
  }

  // ── Recuperar contraseña — Paso 2: Confirmar PIN + nueva contraseña ────────

  Future<void> resetPasswordConfirm({
    required String email,
    required String pin,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>(
        'auth/password-reset-confirm/',
        data: {
          'email': email,
          'pin': pin,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo restablecer la contraseña');
    }
  }

  // ── Perfil del usuario autenticado ─────────────────────────────────────────

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('auth/me/');
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo obtener el perfil');
    }
  }

  // ── Refrescar token ────────────────────────────────────────────────────────

  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final data = response.data!;
      final tokens = AuthTokenModel.fromJson(_normalizeTokenResponse(data));
      await _client.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo renovar la sesión');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _client.clearTokens();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Normaliza la respuesta del backend al formato esperado por AuthTokenModel.
  Map<String, dynamic> _normalizeTokenResponse(Map<String, dynamic> data) {
    return {
      'accessToken':
          data['access'] ?? data['accessToken'] ?? data['token'] ?? '',
      'refreshToken': data['refresh'] ?? data['refreshToken'] ?? '',
      'expiresAt': data['expiresAt'],
    };
  }

  ApiException _handle(DioException e, String fallback) {
    final inner = e.error;
    if (inner is ApiException) return inner;
    final body = e.response?.data;
    String msg = fallback;
    if (body is Map) {
      msg = body['detail']?.toString() ??
          body['non_field_errors']?.toString() ??
          body['message']?.toString() ??
          fallback;
    }
    return ApiException(msg, e.response?.statusCode, e);
  }
}
