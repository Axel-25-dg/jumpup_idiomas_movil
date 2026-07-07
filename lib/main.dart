import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/two_factor_screen.dart';

void main() {
  runApp(const JumpUpApp());
}

class JumpUpApp extends StatelessWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JumpUp Idiomas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.twoFactor: (context) => const TwoFactorScreen(),
      },
    );
  }
}
