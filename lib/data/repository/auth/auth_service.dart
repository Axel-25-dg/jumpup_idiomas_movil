import 'package:dio/dio.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

/// Servicio de autenticación conectado a la API Django en Hetzner.
///
/// Endpoints:
///   POST /auth/login/      → obtiene access + refresh tokens
///   POST /auth/register/   → crea cuenta nueva
///   POST /auth/password/reset/  → envía email de recuperación
///   GET  /auth/me/         → perfil del usuario autenticado
///   POST /auth/token/refresh/   → renueva el access token
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

  // ── Recuperar contraseña ───────────────────────────────────────────────────

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _dio.post<dynamic>(
        'auth/password/reset/',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo enviar el correo de recuperación');
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
  /// El backend Django puede devolver: { access, refresh } o { accessToken, refreshToken }
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

    // Extrae el mensaje de error del body de Django (e.g. {"detail": "..."})
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
