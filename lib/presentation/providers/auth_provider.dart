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

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
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
      // FlutterSecureStorage can hang on first access on some Android devices.
      // Wrap with a timeout to guarantee we always exit loading state.
      final hasToken = await _tokenStorage
          .hasToken()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);

      if (!hasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // We have a token — try to verify it with the server.
      // Timeout so the splash never hangs indefinitely.
      final user = await _authService
          .getProfile()
          .timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('timeout');
      });

      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _tokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // ── Login con email/password ───────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final result = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      // Si el login ya trajo el perfil del usuario, lo usamos directamente
      // sin hacer una segunda llamada a /auth/me/
      final user = result.user ?? await _authService.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado. Intente de nuevo.',
      );
    }
  }

  // ── Login con Google ───────────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final idToken = await GoogleAuthService.instance.signIn();
      if (idToken == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final result = await _authService.loginWithGoogle(idToken);
      final user = result.user ?? await _authService.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'No se pudo iniciar sesión con Google.',
      );
    }
  }

  // ── Login biométrico ───────────────────────────────────────────────────────

  Future<void> loginWithBiometric({
    required String deviceId,
    required String biometricToken,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final authenticated = await BiometricService.instance.authenticate();
      if (!authenticated) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Autenticación biométrica cancelada.',
        );
        return;
      }
      final result = await _authService.biometricLogin(
        deviceId: deviceId,
        biometricToken: biometricToken,
      );
      final user = result.user ?? await _authService.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = const AuthState(
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
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final result = await _authService.register(
        RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          username: username,
          confirmPassword: password,
        ),
      );
      final user = result.user ?? await _authService.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado. Intente de nuevo.',
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    await GoogleAuthService.instance.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
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
