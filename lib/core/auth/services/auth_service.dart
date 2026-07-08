import '../../repositories/base_repository.dart';
import '../models/auth_models.dart';

class AuthService extends BaseRepository {
  const AuthService();

  Future<AuthTokenModel> login(LoginRequest request) async {
    return handleRequest<AuthTokenModel>(() async {
      return AuthTokenModel(
        accessToken: 'demo_access_token',
        refreshToken: 'demo_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    }, message: 'No se pudo iniciar sesión');
  }

  Future<AuthTokenModel> register(RegisterRequest request) async {
    return handleRequest<AuthTokenModel>(() async {
      return AuthTokenModel(
        accessToken: 'demo_access_token',
        refreshToken: 'demo_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    }, message: 'No se pudo completar el registro');
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    return handleRequest<bool>(() async {
      return true;
    }, message: 'No se pudo recuperar la contraseña');
  }

  Future<bool> verifyTwoFactor(TwoFactorRequest request) async {
    return handleRequest<bool>(() async {
      return request.code.length >= 4;
    }, message: 'No se pudo verificar el código');
  }
}
