import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/core/services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
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
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    await ref.read(authProvider.notifier).login(email, pass);
  }

  Future<void> _loginWithBiometric() async {
    final authenticated = await BiometricService.instance.authenticate();
    if (!authenticated) return;

    final deviceId = 'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
    await ref.read(authProvider.notifier).loginWithBiometric(deviceId: deviceId, biometricToken: '');
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
<<<<<<< HEAD
        backgroundColor: AppTheme.grisClaro,
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──────────────────────────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.celeste, Color(0xFF0082C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.celeste.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.language, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'JumpUp UTE',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Inicia sesión para continuar aprendiendo',
                  style: TextStyle(fontSize: 14, color: AppTheme.textoClaro),
                ),
                const SizedBox(height: 36),

                // ── Campos de Login ───────────────────────────────────
                GlassContainer(
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.celeste),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.celeste),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textoClaro),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Olvidaste contraseña ──────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppTheme.celeste)),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Botón principal ───────────────────────────────────
                isLoading
                    ? const CircularProgressIndicator(color: AppTheme.celeste)
                    : NeonButton(
                        text: 'Iniciar Sesión',
                        onPressed: _login,
                      ),
                const SizedBox(height: 20),

                // ── Divisor ───────────────────────────────────────────
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textoClaro)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('o continúa con', style: TextStyle(color: AppTheme.textoClaro, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: AppTheme.textoClaro)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Botón Google ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                    ),
                    label: const Text('Continuar con Google', style: TextStyle(color: AppTheme.textoOscuro, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.celeste),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: isLoading ? null : _loginWithGoogle,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Crear cuenta ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? ', style: TextStyle(color: AppTheme.textoClaro)),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.register),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(color: AppTheme.celeste, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
=======
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Decorative Blobs
            Positioned(
              top: -100,
              right: -50,
              child: _BlurBlob(color: Colors.purple.withValues(alpha: isDark ? 0.15 : 0.08), size: 300),
>>>>>>> main
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _BlurBlob(color: Colors.blue.withValues(alpha: isDark ? 0.1 : 0.05), size: 250),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _CustomTextField(
                                    controller: _emailCtrl,
                                    hint: l10n.email,
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Ingresa tu correo';
                                      }
                                      if (!v.contains('@')) return 'Correo inválido';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _CustomTextField(
                                    controller: _passCtrl,
                                    hint: l10n.password,
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePass,
                                    onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.push(AppRoutes.forgotPassword),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blueAccent,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 30),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        l10n.forgotPassword,
                                        style: AppTextStyles.labelMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // ── Main Button ──────────────────────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                    color: Colors.white, strokeWidth: 2),
                                              )
                                            : Text(
                                                l10n.loginButton,
                                                style: AppTextStyles.buttonText.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Alternative Login ──────────────────────────────
                        if (_biometricAvailable) ...[
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.white10)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o usa biometría',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.white10)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          IconButton(
                            onPressed: isLoading ? null : _loginWithBiometric,
                            icon: const Icon(Icons.fingerprint_rounded, size: 48, color: Colors.blueAccent),
                            padding: EdgeInsets.zero,
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
