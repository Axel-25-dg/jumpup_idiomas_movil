import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/core/services/biometric_service.dart';

import 'package:jumpup_app/widgets/glass_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _biometricAvailable = false;

  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  Future<void> _checkBiometric() async {
    final available = await BiometricService.instance.isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Cerrar teclado para evitar saltos de UI
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    await ref.read(authProvider.notifier).login(email, pass);
  }

  Future<void> _loginWithBiometric() async {
    await ref.read(authProvider.notifier).loginWithBiometric();
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        final route = routeForRole(next.user!.role);
        _safeGo(context, route);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          ref.read(authProvider.notifier).clearError();
        }
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Decorative Animated Blobs
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (20 * _blobController.value),
                      right: -50 + (30 * _blobController.value),
                      child: _BlurBlob(
                        color: const Color(0xFF6A11CB).withValues(alpha: isDark ? 0.25 : 0.15),
                        size: 320,
                      ),
                    ),
                    Positioned(
                      bottom: -50 - (20 * _blobController.value),
                      left: -50 - (30 * _blobController.value),
                      child: _BlurBlob(
                        color: const Color(0xFF2575FC).withValues(alpha: isDark ? 0.2 : 0.1),
                        size: 300,
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo ──────────────────────────────────────────────
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.purpleAccent, Colors.blueAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.translate_rounded,
                              size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.welcome,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Glass Card ───────────────────────────────────
                        GlassContainer(
                          blur: 24,
                          opacity: isDark ? 0.06 : 0.1,
                          borderRadius: BorderRadius.circular(32),
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              _CustomTextField(
                                controller: _emailCtrl,
                                hint: l10n.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!v.contains('@')) return 'Invalid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _CustomTextField(
                                controller: _passCtrl,
                                hint: l10n.password,
                                icon: Icons.lock_outline,
                                obscureText: _obscurePass,
                                onToggleObscure: () =>
                                    setState(() => _obscurePass = !_obscurePass),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF2575FC),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Main Button ──────────────────────────────
                              Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2575FC)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2.5),
                                        )
                                      : Text(
                                          l10n.loginButton.toUpperCase(),
                                          style: AppTextStyles.buttonText.copyWith(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Alternative Login ──────────────────────────────
                        if (_biometricAvailable && authState.canUseBiometrics) ...[
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.white10)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or use biometrics',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.white10)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: _BiometricButton(
                              onTap: isLoading ? null : _loginWithBiometric,
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 40),

                        // ── Register Link ──────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.register),
                              child: Text(
                                l10n.registerHere,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
            color: color.withValues(alpha: 0.5),
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _BiometricButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _BiometricButton({this.onTap, this.isLoading = false});

  @override
  State<_BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<_BiometricButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2575FC).withValues(alpha: 0.2 + (0.1 * _pulseController.value)),
                  const Color(0xFF6A11CB).withValues(alpha: 0.05 + (0.05 * _pulseController.value)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF2575FC).withValues(alpha: 0.3 + (0.2 * _pulseController.value)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2575FC).withValues(alpha: 0.15 + (0.15 * _pulseController.value)),
                  blurRadius: 15 + (10 * _pulseController.value),
                  spreadRadius: 1 + (2 * _pulseController.value),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                        )
                      : ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Colors.blueAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5), size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3),
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
