import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  int _step = 1; // 1=enviar email, 2=ingresar PIN, 3=nueva contraseña
  String _email = '';
  bool _isLoading = false;

  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _requestPin() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final result = await _authService.requestPasswordReset(_emailCtrl.text.trim());
      if (result['ok'] == true) {
        setState(() { _email = _emailCtrl.text.trim(); _step = 2; });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']?.toString() ?? 'Error al enviar el correo'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmPin() async {
    if (_codeCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    if (_passCtrl.text != _pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 8 caracteres'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await _authService.confirmPasswordReset(
        email: _email,
        code: _codeCtrl.text.trim(),
        password: _passCtrl.text,
        password2: _pass2Ctrl.text,
      );
      if (result['ok'] == true) {
        setState(() => _step = 3);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']?.toString() ?? 'Código o contraseña incorrectos'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_step == 1) ...[
                      _buildHeader(
                        context,
                        Icons.lock_reset_rounded,
                        l10n.forgotPasswordTitle,
                        l10n.forgotPasswordInstructions,
                      ),
                      const SizedBox(height: 32),
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
                            ),
                            const SizedBox(height: 24),
                            _buildMainButton(
                              text: l10n.sendCode.toUpperCase(),
                              onPressed: _requestPin,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_step == 2) ...[
                      _buildHeader(
                        context,
                        Icons.mark_email_read_rounded,
                        l10n.verifyEmail,
                        l10n.verifyEmailInstructions(_email),
                      ),
                      const SizedBox(height: 32),
                      GlassContainer(
                        blur: 24,
                        opacity: isDark ? 0.06 : 0.1,
                        borderRadius: BorderRadius.circular(32),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            _CustomTextField(
                              controller: _codeCtrl,
                              hint: l10n.sixDigitCode,
                              icon: Icons.pin_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _CustomTextField(
                              controller: _passCtrl,
                              hint: l10n.newPassword,
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            _CustomTextField(
                              controller: _pass2Ctrl,
                              hint: l10n.confirmPassword,
                              icon: Icons.lock_reset_rounded,
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            _buildMainButton(
                              text: l10n.resetPassword.toUpperCase(),
                              onPressed: _confirmPin,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_step == 3) ...[
                      _buildHeader(
                        context,
                        Icons.check_circle_outline_rounded,
                        l10n.allDone,
                        l10n.passwordUpdated,
                        iconColor: Colors.greenAccent,
                      ),
                      const SizedBox(height: 40),
                      _buildMainButton(
                        text: l10n.backToStart.toUpperCase(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IconData icon, String title, String subtitle, {Color? iconColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? const Color(0xFF2575FC);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  // Removed _buildGlassContainer as we now use the standard GlassContainer widget

  Widget _buildMainButton({required String text, required VoidCallback onPressed, bool isLoading = false}) {
    return Container(
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
            color: const Color(0xFF2575FC).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
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
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5), size: 20),
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
      ),
    );
  }
}
