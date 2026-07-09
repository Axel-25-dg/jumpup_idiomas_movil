import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/core/auth/services/token_storage.dart';
import 'package:jumpup_app/core/models/user_model.dart';
import 'package:jumpup_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:jumpup_app/features/auth/presentation/loading_screen.dart';
import 'package:jumpup_app/features/auth/presentation/login_screen.dart';
import 'package:jumpup_app/features/auth/presentation/register_screen.dart';
import 'package:jumpup_app/features/auth/presentation/splash_screen.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/create_classroom_screen.dart';
import 'package:jumpup_app/features/social_media/presentation/social_media_shell.dart';

/// Rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const splash = '/';
  static const loading = '/loading';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const adminDashboard = '/admin';
  static const teacherDashboard = '/teacher';
  static const studentDashboard = '/student';
}

/// Router principal de JumpUp.
///
/// Flujo de navegación:
///   Splash → Loading → ¿token? → NO → Login
///                               → SÍ → ¿rol?
///                                      admin   → /admin
///                                      teacher → /teacher
///                                      student → /student (home)
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.loading,
        name: 'loading',
        builder: (_, __) => const LoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Home (Programador 1: módulo comunicación ya construido) ────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const SocialMediaShell(),
      ),

      // ── Placeholders para dashboards (Programadores 2, 3, 4) ──────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin',
        builder: (_, __) => const _PlaceholderScreen(
          title: 'Panel Administrador',
          subtitle: 'Módulo del Programador 2',
          color: Colors.deepPurple,
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacher',
        builder: (_, __) => const CreateClassroomScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDashboard,
        name: 'student',
        builder: (_, __) => const SocialMediaShell(), // home del estudiante
      ),
    ],
  );
}

/// Determina la ruta de destino según el rol del usuario.
String routeForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.teacher:
      return AppRoutes.teacherDashboard;
    case UserRole.student:
    case UserRole.unknown:
      return AppRoutes.home;
  }
}

/// Verifica si hay token guardado. Lo usa SplashScreen y LoadingScreen.
Future<bool> hasValidToken() async {
  return TokenStorage().hasToken();
}

// ── Placeholder temporal para dashboards de otros programadores ───────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.withValues(alpha: 0.05),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 64, color: color),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
