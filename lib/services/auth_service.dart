import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.dio.post('auth/login/', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: response.data['access']);
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
        
        // Save current timestamp for biometrics expiration (30 days logic)
        final now = DateTime.now().toIso8601String();
        await _storage.write(key: 'biometric_enabled_date', value: now);
        
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _api.dio.post('auth/register/', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final savedDateStr = await _storage.read(key: 'biometric_enabled_date');
      if (savedDateStr == null) return false;

      final savedDate = DateTime.parse(savedDateStr);
      if (DateTime.now().difference(savedDate).inDays > 30) {
        // Biometrics expired after 30 days
        return false;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Inicia sesión con biometría para continuar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Solicitar PIN de restablecimiento de contraseña
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _api.dio.post('auth/password-reset/', data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Confirmar PIN
  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _api.dio.post('auth/password-reset-confirm/', data: {
        'email': email,
        'code': code,
        'password': password,
        'password2': password2,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Refresh token
  Future<String?> refreshToken(String refresh) async {
    try {
      final response = await _api.dio.post('auth/token/refresh/', data: {'refresh': refresh});
      if (response.statusCode == 200) {
        return response.data['access'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Actualizar idiomas de aprendizaje
  Future<bool> updateLearningLanguages(String token, List<int> languageIds) async {
    try {
      final response = await _api.dio.patch(
        'auth/profile/update-languages/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'languages_learning': languageIds},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
