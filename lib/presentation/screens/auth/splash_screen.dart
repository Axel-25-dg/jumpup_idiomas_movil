import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _shimmerController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;
  bool _navigated = false;
  bool _hasCheckedInitialState = false;

  /// Safety timeout: if auth takes too long, go to login anyway.
  static const _maxWait = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuart),
      ),
    );

    _ctrl.forward();

    // Check initial state once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_navigated && !_hasCheckedInitialState) {
        _hasCheckedInitialState = true;
        final currentState = ref.read(authProvider);
        _navigate(currentState);
      }
    });

    // Safety net: if auth is still pending after _maxWait, send to login.
    Future.delayed(_maxWait, () {
      if (mounted && !_navigated) {
        _navigated = true;
        _safeGo(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shimmerController.dispose();
    super.dispose();
  }


  void _safeGo(BuildContext context, String route) {
    if (mounted) {
      try {
        context.go(route);
      } catch (e) {
        debugPrint('Navigation error: $e');
      }
    }
  }

  void _navigate(AuthState authState) {
    if (_navigated || !mounted) return;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      _navigated = true;
      _safeGo(context, routeForRole(authState.user!.role));
    } else if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      _navigated = true;
      _safeGo(context, AppRoutes.login);
    }
    // status == loading | initial → wait
  }

  @override
  Widget build(BuildContext context) {
    // Listen to future changes
    ref.listen<AuthState>(authProvider, (_, next) {
      if (mounted && !_navigated) {
        _navigate(next);
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0F111A), // Dark Deep Background
        ),
        child: Stack(
          children: [
            // Background Blobs
            Positioned(
              top: -100,
              right: -50,
              child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.25), size: 400),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.2), size: 350),
            ),
            
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return _LogoWidget(shimmerValue: _shimmerController.value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            Text(
                              'JumpUp',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'APRENDE IDIOMAS SIN LÍMITES',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 3,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'UNIVERSIDAD UTE',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white24,
                              letterSpacing: 4,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
            color: color.withValues(alpha: 0.4),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  final double shimmerValue;
  const _LogoWidget({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/JumpUp_Logo.png',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          // Shimmer Effect
          Positioned.fill(
            child: ClipOval(
              child: Transform.translate(
                offset: Offset(280 * (shimmerValue - 0.5), 0),
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
