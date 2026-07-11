import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  int _step = 1; // 1=enviar email, 2=ingresar PIN, 3=nueva contraseña
  String _email = '';
  bool _isLoading = false;

  Future<void> _requestPin() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final ok = await _authService.requestPasswordReset(_emailCtrl.text);
      if (ok) {
        setState(() { _email = _emailCtrl.text; _step = 2; });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmPin() async {
    if (_codeCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final ok = await _authService.confirmPasswordReset(
        email: _email, 
        code: _codeCtrl.text,
        password: _passCtrl.text, 
        password2: _pass2Ctrl.text,
      );
      if (ok) {
        setState(() => _step = 3);
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
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
<<<<<<< HEAD
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_reset, size: 80, color: AppTheme.celeste),
              const SizedBox(height: 20),
              const Text('Restablece tu acceso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
              const SizedBox(height: 10),
              const Text('Ingresa tu correo electrónico y te enviaremos las instrucciones.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textoClaro)),
              const SizedBox(height: 40),
              GlassContainer(
                child: TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email, color: AppTheme.celeste),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
=======
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _BlurBlob(color: Colors.blueAccent.withValues(alpha: 0.1), size: 300),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
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
                      _buildGlassContainer(
                        context,
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
                              text: l10n.sendCode,
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
                      _buildGlassContainer(
                        context,
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
                              text: l10n.resetPassword,
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
                        text: l10n.backToStart,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ],
>>>>>>> main
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IconData icon, String title, String subtitle, {Color iconColor = Colors.blueAccent}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: iconColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall.copyWith(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildGlassContainer(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMainButton({required String text, required VoidCallback onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2575FC).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(text, style: AppTextStyles.buttonText.copyWith(color: Colors.white, fontSize: 16)),
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
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black38),
        prefixIcon: Icon(icon, color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45, size: 20),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
