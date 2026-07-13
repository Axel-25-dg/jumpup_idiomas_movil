import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/data/repository/auth/auth_repository_impl.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _validateAndRedirect();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    try {
      final authRepo = AuthService();
      final user = await authRepo.getProfile();
      if (!mounted) return;
      context.go(routeForRole(user.role));
    } catch (_) {
      if (!mounted) return;
      await SecureStorage().clearTokens();
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1A0533), const Color(0xFF0F111A)]
              : [const Color(0xFFF5F7FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              top: -100,
              right: -50,
              child: _BlurBlob(color: Colors.purple.withValues(alpha: isDark ? 0.2 : 0.1), size: 300),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _BlurBlob(color: Colors.blue.withValues(alpha: isDark ? 0.15 : 0.08), size: 250),
            ),
            
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final scale = 1.0 + (_pulseCtrl.value * 0.12);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.purpleAccent, Colors.blueAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(alpha: 0.5),
                                blurRadius: 30 * scale,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'JUMPUP',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Idiomas al siguiente nivel',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Iniciando experiencia...',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
