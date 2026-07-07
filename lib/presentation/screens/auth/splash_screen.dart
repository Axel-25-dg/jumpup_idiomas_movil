import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkJwtToken();
  }

  Future<void> _checkJwtToken() async {
    // Simulate JWT check lifecycle and API call: GET /api/auth/me/
    await Future.delayed(const Duration(seconds: 2));
    
    // For now, redirect to login as we simulate no token/expired token
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100), // Animación/Logo simulado de JumpUp UTE
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Verificando sesión...'),
          ],
        ),
      ),
    );
  }
}
