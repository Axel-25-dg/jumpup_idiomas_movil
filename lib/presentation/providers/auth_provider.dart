import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/auth/auth_service.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/domain/model/auth_models.dart';
import 'package:jumpup_app/core/error/api_exception.dart';

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
      : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _authService.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _tokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _authService.login(
        LoginRequest(email: email, password: password),
      );
      final user = await _authService.getProfile();
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

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
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
        ),
      );
      final user = await _authService.getProfile();
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

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(
          errorMessage: null, status: AuthStatus.unauthenticated);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService(), TokenStorage());
});
