import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/neon_button.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos'), backgroundColor: Colors.orange),
      );
      return;
    }
    await ref.read(authProvider.notifier).login(email, pass);
  }

  Future<void> _loginWithGoogle() async {
    await ref.read(authProvider.notifier).loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // Mostrar error si existe
    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return PopScope(
      canPop: false, // Bloquea el botón físico de regreso en el Login
      child: Scaffold(
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
            ),
          ),
        ),
      ),
    ), // PopScope
  );
  }
}
