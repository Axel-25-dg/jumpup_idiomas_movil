import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BiometricService {
  static const String baseUrl = 'https://guaman-idiomas-ute.online/api';
  static final _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  static Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    final androidInfo = await info.androidInfo;
    return androidInfo.id; // Android ID único
  }

  // Registrar biométrico (después del primer login)
  static Future<String?> registerBiometric(String jwtToken) async {
    final deviceId = await getDeviceId();
    final r = await http.post(
      Uri.parse('$baseUrl/auth/biometric/register/'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'device_id': deviceId}),
    );
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body);
      return data['biometric_token']; // Guardar localmente
    }
    return null;
  }

  // Login biométrico
  static Future<Map?> biometricLogin() async {
    final bool authenticated = await _localAuth.authenticate(
      localizedReason: 'Usa tu huella para iniciar sesión',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (!authenticated) return null;

    final deviceId = await getDeviceId();
    // Recuperar biometric_token guardado localmente
    final biometricToken = await _getStoredBiometricToken();
    if (biometricToken == null) return null;

    final r = await http.post(
      Uri.parse('$baseUrl/auth/biometric/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'biometric_token': biometricToken,
      }),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body); // { access, refresh, user }
    }
    return null;
  }

  // Guardar/recuperar token biométrico localmente
  static Future<void> _storeBiometricToken(String token) async {
    // Usar SharedPreferences o flutter_secure_storage
  }

  static Future<String?> _getStoredBiometricToken() async {
    // Recuperar de SharedPreferences o flutter_secure_storage
    return null;
  }
}
