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
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _api.dio.post('auth/password-reset/', data: {'email': email});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'ok': true};
      }
      return {'ok': false, 'error': 'Error del servidor (${response.statusCode})'};
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = 'Error al enviar el correo';
      if (data is Map) {
        final vals = data.values.toList();
        if (vals.isNotEmpty) {
          final first = vals.first;
          errorMsg = first is List ? first.first.toString() : first.toString();
        }
      } else if (data is String) {
        errorMsg = data;
      }
      return {'ok': false, 'error': errorMsg};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Confirmar PIN y establecer nueva contraseña
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  }) async {
    // Intentamos el esquema principal primero
    final payloads = [
      {
        'email': email,
        'code': code,
        'new_password': password,
        'new_password2': password2,
      },
      {
        'email': email,
        'code': code,
        'password': password,
        'password2': password2,
      },
      {
        'email': email,
        'token': code,
        'new_password': password,
        'new_password2': password2,
      },
      {
        'email': email,
        'otp': code,
        'new_password': password,
        'new_password2': password2,
      },
    ];

    dynamic lastError;
    for (final payload in payloads) {
      try {
        final response = await _api.dio.post('auth/password-reset-confirm/', data: payload);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'ok': true};
        }
      } on DioException catch (e) {
        lastError = e;
        // Si el error no es 400 (validación) ya no tiene sentido probar otros campos
        if (e.response?.statusCode != 400) break;
      } catch (e) {
        lastError = e;
        break;
      }
    }

    // Extraer mensaje del último error
    String errorMsg = 'Código o contraseña incorrectos';
    if (lastError is DioException) {
      final data = lastError.response?.data;
      if (data is Map) {
        final vals = data.values.toList();
        if (vals.isNotEmpty) {
          final first = vals.first;
          errorMsg = first is List ? first.first.toString() : first.toString();
        }
      } else if (data is String) {
        errorMsg = data;
      }
    }
    return {'ok': false, 'error': errorMsg};
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
