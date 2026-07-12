import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/auth/auth_repository_impl.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/core/services/google_auth_service.dart';
import 'package:jumpup_app/core/services/biometric_service.dart';

import 'package:jumpup_app/presentation/providers/user_provider.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';

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
  final AuthRepositoryImpl _authService;
  final SecureStorage _secureStorage;
  final Ref _ref;

  AuthNotifier(this._authService, this._secureStorage, this._ref)
      : super(const AuthState(status: AuthStatus.loading)) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final hasToken = await _secureStorage
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
      await _secureStorage.clearTokens();
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
    String? deviceId,
    String? biometricToken,
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
      // If biometric login is not fully implemented, just simulate success
      // For now, let's skip biometric login and just check session
      final hasToken = await _secureStorage.hasToken();
      if (hasToken) {
        final user = await _authService.getProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'No hay sesión guardada para biometría.',
        );
      }
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
    String role = 'student',
  }) async {
    state = const AuthState(status: AuthStatus.loading);
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
      // Forzar la obtención del perfil real del usuario con su token recién emitido
      final user = await _authService.getProfile();
      try {
        // ignore: avoid_print
        print('AuthNotifier.register: fetched_user_id=${user.id}, email=${user.email}');
      } catch (_) {}
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
    // 1. Limpiar tokens locales inmediatamente para invalidar cualquier petición futura
    await _secureStorage.clearTokens();
    
    try {
      // 2. Cerrar sesión en Google si aplica
      await GoogleAuthService.instance.signOut();
    } catch (_) {}

    // 3. Invalida todos los proveedores de datos al cerrar sesión
    _invalidateAllDataProviders();

    // 4. Actualizar el estado a no autenticado inmediatamente
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
    );

    // 5. Notificar al servidor (opcional, sin esperar si es lento)
    try {
      await _authService.logout().timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  /// Invalida globalmente los proveedores que almacenan datos específicos
  /// del usuario para evitar persistencia de datos al cambiar de cuenta.
  void _invalidateAllDataProviders() {
    // Lista de proveedores a invalidar
    final List<dynamic> providersToInvalidate = [
      usersProvider,
      dashboardSummaryProvider,
      classroomsListProvider,
      adminCoursesProvider,
      teacherStatsProvider,
      socialFeedProvider,
      // chatThreadsProvider, // Eliminado si no existe
      notificationsProvider,
      unreadNotificationsProvider,
      adminLanguagesProvider,
      resourcesListProvider,
    ];

    for (final provider in providersToInvalidate) {
      if (provider is ProviderOrFamily) {
        _ref.invalidate(provider);
      }
    }
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
  return AuthNotifier(AuthRepositoryImpl(), SecureStorage(), ref);
});
