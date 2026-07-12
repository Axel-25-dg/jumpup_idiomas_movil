import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._();
  static BiometricService get instance => _instance;
  BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Verifica si el dispositivo soporta biometría.
  Future<bool> isAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  /// Obtiene un ID único del dispositivo para vincular la huella.
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown_device';
      }
    } catch (e) {
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
    return 'unknown_device';
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
      final bool available = await isAvailable();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true, // Forzamos huella/cara para ser "biométrico" real
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        // El usuario no tiene biometría configurada en el sistema
      }
      return false;
    }
  }
}
