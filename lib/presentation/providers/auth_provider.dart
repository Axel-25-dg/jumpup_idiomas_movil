import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/auth/auth_repository_impl.dart'; // Aunque el archivo se llame auth_repository_impl.dart, la clase adentro es AuthService
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
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

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

      final user = await _getProfileOrFallback();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _secureStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<UserModel?> _getProfileOrFallback() async {
    try {
      return await _authService.getProfile().timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('timeout');
      });
    } catch (_) {
      final decoded = await _secureStorage.decodeAccessToken();
      if (decoded.isEmpty) {
        return null;
      }
      return UserModel.fromJwtPayload(decoded);
    }
  }

  // ── Login con email/password ───────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      // Invalida datos previos antes de intentar un nuevo login 
      // para asegurar un estado limpio si hubo una sesión mal cerrada
      _invalidateAllDataProviders();

      final result = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      // Si el login ya trajo el perfil del usuario, lo usamos directamente
      // sin hacer una segunda llamada a /auth/me/ si no es necesario.
      final user = result.user ?? await _getProfileOrFallback();
      
      // Intentar registrar biometría automáticamente tras un login exitoso por password
      // para que esté disponible la próxima vez.
      registerBiometric();

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
      final user = result.user ?? await _getProfileOrFallback();
      
      // Intentar registrar biometría automáticamente tras un login exitoso por password
      // para que esté disponible la próxima vez.
      registerBiometric();

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

  Future<void> loginWithBiometric() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      // 1. Verificar disponibilidad y autenticar localmente (huella/cara)
      final authenticated = await BiometricService.instance.authenticate();
      if (!authenticated) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Autenticación biométrica cancelada.',
        );
        return;
      }

      // 2. Obtener datos persistidos
      final biometricToken = await _secureStorage.getBiometricToken();
      final deviceId = await _secureStorage.getDeviceId();

      if (biometricToken != null && deviceId != null) {
        // 3. Login contra el servidor usando el token biométrico
        final result = await _authService.biometricLogin(
          deviceId: deviceId,
          biometricToken: biometricToken,
        );
        final user = result.user ?? await _getProfileOrFallback();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        // Fallback: Si no hay token biométrico pero hay token normal (sesión no cerrada)
        final hasToken = await _secureStorage.hasToken();
        if (hasToken) {
          final user = await _getProfileOrFallback();
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } else {
          state = const AuthState(
            status: AuthStatus.error,
            errorMessage: 'La huella no está vinculada. Ingresa con tu clave primero.',
          );
        }
      }
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al procesar la huella dactilar.',
      );
    }
  }

  /// Vincula la huella actual del dispositivo con la cuenta del usuario.
  Future<void> registerBiometric() async {
    try {
      final deviceId = await BiometricService.instance.getDeviceId();
      final biometricToken = await _authService.registerBiometric(deviceId);
      
      await _secureStorage.saveBiometricData(
        biometricToken: biometricToken,
        deviceId: deviceId,
      );
    } catch (e) {
      // Error silencioso o loggear
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
      final user = await _getProfileOrFallback();
      try {
        // ignore: avoid_print
        print('AuthNotifier.register: fetched_user_id=${user?.id}, email=${user?.email}');
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
    try {
      // 1. Notificar al servidor primero (opcional, con timeout corto)
      // Lo hacemos antes de borrar tokens locales para que la petición lleve el Bearer token
      await _authService.logout().timeout(const Duration(seconds: 1)).catchError((_) {});
    } catch (_) {}

    // 2. Limpiar tokens locales inmediatamente
    await _secureStorage.clearTokens();
    
    try {
      // 3. Cerrar sesión en Google si aplica
      if (await GoogleAuthService.instance.isSignedIn()) {
        await GoogleAuthService.instance.signOut();
      }
    } catch (_) {}

    // 4. Actualizar el estado a no autenticado PRIMERO
    // Esto dispara el redireccionamiento del router antes de invalidar datos
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
    );

    // 5. Invalida todos los proveedores de datos después de cambiar el estado
    // De esta forma, las pantallas que dependían de estos datos ya no están activas
    _invalidateAllDataProviders();
  }

  /// Invalida globalmente los proveedores que almacenan datos específicos
  /// del usuario para evitar persistencia de datos al cambiar de cuenta.
  void _invalidateAllDataProviders() {
    // Lista exhaustiva de proveedores a invalidar
    final List<dynamic> providersToInvalidate = [
      // Perfil y Dashboard
      userProfileProvider,
      dashboardSummaryProvider,
      
      // Progreso y XP (Crucial para el sistema de retos)
      localUserStatsProvider,
      userStatsProvider,
      progressSummaryProvider,
      dailyChallengesProvider,
      rankingProvider,
      achievementsProvider,
      myAchievementsProvider,
      progressByLanguageProvider,
      myRankingPositionProvider,

      // Admin/Teacher
      usersProvider,
      classroomsListProvider,
      adminCoursesProvider,
      teacherStatsProvider,
      adminStatsProvider,
      
      // Social y Contenido
      socialFeedProvider,
      notificationsProvider,
      unreadNotificationsProvider,
      adminLanguagesProvider,
      resourcesListProvider,
    ];

    for (final provider in providersToInvalidate) {
      _ref.invalidate(provider);
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
  return AuthNotifier(AuthService(), SecureStorage(), ref);
});
