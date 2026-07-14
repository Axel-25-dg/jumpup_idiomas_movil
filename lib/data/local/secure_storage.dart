import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Almacena y recupera el JWT de forma segura en el Keychain / Keystore del SO.
class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyAccess = 'jumpup_access_token';
  static const _keyRefresh = 'jumpup_refresh_token';
  static const _keyBiometricToken = 'jumpup_biometric_token';
  static const _keyDeviceId = 'jumpup_device_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccess, value: accessToken),
      _storage.write(key: _keyRefresh, value: refreshToken),
    ]);
  }

  Future<void> saveBiometricData({
    required String biometricToken,
    required String deviceId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyBiometricToken, value: biometricToken),
      _storage.write(key: _keyDeviceId, value: deviceId),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccess);

  Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);

  Future<String?> getBiometricToken() => _storage.read(key: _keyBiometricToken);

  Future<String?> getDeviceId() => _storage.read(key: _keyDeviceId);

  Future<Map<String, dynamic>> decodeAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return {};
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return {};
    }
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccess),
      _storage.delete(key: _keyRefresh),
    ]);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasBiometricStored() async {
    final token = await getBiometricToken();
    return token != null && token.isNotEmpty;
  }
}
