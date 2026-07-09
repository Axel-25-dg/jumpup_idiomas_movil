import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._();
  static BiometricService get instance => _instance;
  BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría.
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Devuelve los tipos de biometría disponibles.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Solicita la autenticación biométrica al usuario.
  /// Retorna `true` si fue exitosa.
  Future<bool> authenticate({
    String reason = 'Verifica tu identidad para ingresar a JumpUp',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // permite PIN como respaldo
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
