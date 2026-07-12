import 'package:dio/dio.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/domain/repository/auth_repository.dart';

/// Servicio de autenticación conectado a la API Django en Hetzner.
///
/// Endpoints:
///   POST /api/auth/login/                  → obtiene access + refresh tokens
///   POST /api/auth/register/               → crea cuenta nueva
///   POST /api/auth/password-reset/         → envía email de recuperación con PIN
///   POST /api/auth/password-reset-confirm/ → confirma el PIN y cambia password
///   GET  /api/auth/me/                     → perfil del usuario autenticado
///   POST /api/auth/token/refresh/          → renueva el access token
///   POST /api/auth/2fa/verify/             → verifica código 2FA
///   POST /api/auth/biometric/login/        → login por huella dactilar
class AuthService implements AuthRepository {
  AuthService() : _dio = DioClient.instance.dio;

  final Dio _dio;
  final _client = DioClient.instance;

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Inicia sesión. Si el backend requiere 2FA devuelve [AuthTokenModel] con
  /// [requires2FA] = true y sin tokens. Si va directo, incluye tokens + user.
  @override
  Future<AuthTokenModel> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/login/',
        data: request.toJson(),
      );
      final data = response.data!;

      // Caso 2FA: el backend devuelve { requires_2fa: true, message: "..." }
      if (data['requires_2fa'] == true) {
        return AuthTokenModel.fromJson(data);
      }

      final token = AuthTokenModel.fromJson(data);
      if (token.accessToken.isNotEmpty) {
        await _client.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );
      }
      return token;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo iniciar sesión');
    }
  }

  // ── Login con Google ───────────────────────────────────────────────────────

  @override
  Future<AuthTokenModel> loginWithGoogle(String googleIdToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/google/',
        data: {'id_token': googleIdToken},
      );
      final data = response.data!;
      final token = AuthTokenModel.fromJson(data);
      await _client.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      return token;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo iniciar sesión con Google');
    }
  }

  // ── Login biométrico ───────────────────────────────────────────────────────

  @override
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
      final token = AuthTokenModel.fromJson(data);
      await _client.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      return token;
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

  @override
  Future<AuthTokenModel> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/register/',
        data: request.toJson(),
      );
      final data = response.data!;
      final token = AuthTokenModel.fromJson(data);
      try {
        // ignore: avoid_print
        print('AuthService.register: token_user_id=${token.user?.id ?? 'null'}');
      } catch (_) {}
      if (token.accessToken.isNotEmpty) {
        await _client.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );
      }
      return token;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo completar el registro');
    }
  }

  // ── Recuperar contraseña — Paso 1: Enviar PIN al correo ───────────────────

  @override
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

  @override
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
          'code': pin,        // el backend espera "code"
          'password': newPassword, // el backend espera "password"
        },
      );
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo restablecer la contraseña');
    }
  }

  // ── Perfil del usuario autenticado ─────────────────────────────────────────

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('auth/me/');
      try {
        // ignore: avoid_print
        print('AuthService.getProfile: raw=${response.data}');
      } catch (_) {}
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo obtener el perfil');
    }
  }

  // ── Refrescar token ────────────────────────────────────────────────────────

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final data = response.data!;
      final token = AuthTokenModel.fromJson(data);
      await _client.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      return token;
    } on DioException catch (e) {
      throw _handle(e, 'No se pudo renovar la sesión');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _client.clearTokens();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ApiException _handle(DioException e, String fallback) {
    final inner = e.error;
    if (inner is ApiException) return inner;
    final body = e.response?.data;
    String msg = fallback;
    if (body is Map) {
      msg = body['detail']?.toString() ??
          body['non_field_errors']?.toString() ??
          body['message']?.toString() ??
          _extractFieldErrors(body) ??
          fallback;
    }
    return ApiException(msg, e.response?.statusCode, e);
  }

  String? _extractFieldErrors(Map body) {
    final errors = <String>[];
    body.forEach((key, value) {
      if (key != 'detail' && key != 'non_field_errors' && key != 'message') {
        if (value is List) {
          for (final e in value) {
            errors.add(e.toString());
          }
        } else if (value is String) {
          errors.add(value);
        }
      }
    });
    return errors.isEmpty ? null : errors.join('\n');
  }
}
