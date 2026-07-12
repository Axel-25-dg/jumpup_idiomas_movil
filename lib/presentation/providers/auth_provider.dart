import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/auth/auth_service.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/core/services/google_auth_service.dart';
import 'package:jumpup_app/core/services/biometric_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool canUseBiometrics;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.canUseBiometrics = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? canUseBiometrics,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._authService, this._tokenStorage)
      : super(const AuthState(status: AuthStatus.loading)) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final hasBiometric = await _tokenStorage.hasBiometricStored();
      
      final hasToken = await _tokenStorage
          .hasToken()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);

      if (!hasToken) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          canUseBiometrics: hasBiometric,
        );
        return;
      }

      final user = await _authService
          .getProfile()
          .timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('timeout');
      });

      state = state.copyWith(
        status: AuthStatus.authenticated, 
        user: user,
        canUseBiometrics: hasBiometric,
      );
    } catch (_) {
      // No limpiamos biometría si falla el refresh, solo el token de sesión
      await _tokenStorage.clearTokens();
      final hasBiometric = await _tokenStorage.hasBiometricStored();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        canUseBiometrics: hasBiometric,
      );
    }
  }

  // ── Login con email/password ───────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      final user = result.user ?? await _authService.getProfile();
      
      // Intentar registrar biométrico si no existe
      await _maybeRegisterBiometric();

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado. Intente de nuevo.',
      );
    }
  }

  Future<void> _maybeRegisterBiometric() async {
    try {
      final isDeviceSupported = await BiometricService.instance.isAvailable();
      if (!isDeviceSupported) return;

      final alreadyHas = await _tokenStorage.hasBiometricStored();
      if (alreadyHas) return;

      final deviceId = await BiometricService.instance.getDeviceId();
      final biometricToken = await _authService.registerBiometric(deviceId);
      
      if (biometricToken.isNotEmpty) {
        await _tokenStorage.saveBiometricData(
          biometricToken: biometricToken,
          deviceId: deviceId,
        );
        state = state.copyWith(canUseBiometrics: true);
      }
    } catch (e) {
      debugPrint('Error registrando biometría: $e');
    }
  }

  // ── Login biométrico ───────────────────────────────────────────────────────

  Future<void> loginWithBiometric() async {
    final storedToken = await _tokenStorage.getBiometricToken();
    final storedDeviceId = await _tokenStorage.getDeviceId();

    if (storedToken == null || storedDeviceId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Biometría no vinculada.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final authenticated = await BiometricService.instance.authenticate();
      if (!authenticated) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
        return;
      }
      
      final result = await _authService.biometricLogin(
        deviceId: storedDeviceId,
        biometricToken: storedToken,
      );
      
      final user = result.user ?? await _authService.getProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error al autenticar con huella dactilar.',
      );
    }
  }

  // ── Registro ───────────────────────────────────────────────────────────────

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String role = 'student',
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.register(
        RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          username: username,
          confirmPassword: password,
          role: role,
        ),
      );
      final user = await _authService.getProfile();
      
      // Intentar registrar biométrico tras registro exitoso
      await _maybeRegisterBiometric();

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado. Intente de nuevo.',
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    await GoogleAuthService.instance.signOut();
    final hasBiometric = await _tokenStorage.hasBiometricStored();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      canUseBiometrics: hasBiometric,
    );
  }

  // ── Limpiar error ──────────────────────────────────────────────────────────

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(
        errorMessage: null,
        status: AuthStatus.unauthenticated,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService(), TokenStorage());
});
