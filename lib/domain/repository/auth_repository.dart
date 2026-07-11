import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/domain/model/user_model.dart';

/// Contrato que debe cumplir cualquier implementación de autenticación.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña.
  Future<AuthTokenModel> login(LoginRequest request);

  /// Inicia sesión con un token de Google.
  Future<AuthTokenModel> loginWithGoogle(String googleIdToken);

  /// Inicia sesión mediante autenticación biométrica.
  Future<AuthTokenModel> biometricLogin({
    required String deviceId,
    required String biometricToken,
  });

  /// Registra un nuevo usuario.
  Future<AuthTokenModel> register(RegisterRequest request);

  /// Envía un PIN de recuperación al correo del usuario.
  Future<void> forgotPassword(ForgotPasswordRequest request);

  /// Confirma el PIN de recuperación y establece una nueva contraseña.
  Future<void> resetPasswordConfirm({
    required String email,
    required String pin,
    required String newPassword,
  });

  /// Devuelve el perfil del usuario autenticado.
  Future<UserModel> getProfile();

  /// Renueva el access token usando el refresh token.
  Future<AuthTokenModel> refreshToken(String refreshToken);

  /// Cierra la sesión y limpia los tokens almacenados.
  Future<void> logout();
}
