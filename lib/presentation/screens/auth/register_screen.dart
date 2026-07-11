import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _selectedRole,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Decorative Blobs
          Positioned(
            top: -50,
            left: -50,
            child: _BlurBlob(color: Colors.blueAccent.withValues(alpha: isDark ? 0.1 : 0.05), size: 200),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: _BlurBlob(color: Colors.purpleAccent.withValues(alpha: isDark ? 0.1 : 0.05), size: 300),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person, color: AppTheme.celeste),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email, color: AppTheme.celeste),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, color: AppTheme.celeste),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
=======
                    const SizedBox(height: 20),
                    Text(
                      l10n.joinToday,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createAccountSubtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Glass Form ───────────────────────────────────
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
                              // ── Role Selector ──────────────────────────
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black12,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = 'student'),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == 'student'
                                                ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Estudiante',
                                            style: TextStyle(
                                              color: _selectedRole == 'student' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = 'teacher'),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == 'teacher'
                                                ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Profesor',
                                            style: TextStyle(
                                              color: _selectedRole == 'teacher' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _firstNameCtrl,
                                      hint: l10n.firstName,
                                      icon: Icons.person_outline,
                                      textCapitalization: TextCapitalization.words,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _CustomTextField(
                                      controller: _lastNameCtrl,
                                      hint: l10n.lastName,
                                      icon: Icons.person_outline,
                                      textCapitalization: TextCapitalization.words,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _CustomTextField(
                                controller: _usernameCtrl,
                                hint: l10n.username,
                                icon: Icons.alternate_email,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Requerido';
                                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _CustomTextField(
                                controller: _emailCtrl,
                                hint: l10n.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Requerido';
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
                                  if (v == null || v.isEmpty) return 'Requerido';
                                  if (v.length < 8) return 'Mínimo 8 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _CustomTextField(
                                controller: _confirmPassCtrl,
                                hint: l10n.confirmPassword,
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirm,
                                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requerido';
                                  if (v != _passCtrl.text) return 'No coinciden';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              
                              // ── Register Button ──────────────────────────
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
                                    onPressed: isLoading ? null : _register,
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
                                            l10n.registerButton,
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
>>>>>>> main
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Login Link ──────────────────────────────────
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              l10n.loginLink,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3), fontSize: 14),
        prefixIcon: Icon(icon, color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5), size: 18),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3),
                  size: 18,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}
