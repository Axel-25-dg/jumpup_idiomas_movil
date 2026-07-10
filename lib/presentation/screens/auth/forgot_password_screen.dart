import 'dart:ui';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                        Icons.lock_reset_rounded,
                        '¿Olvidaste tu contraseña?',
                        'Ingresa tu correo electrónico para recibir un código de recuperación.',
                      ),
                      const SizedBox(height: 32),
                      _buildGlassContainer(
                        child: Column(
                          children: [
                            _CustomTextField(
                              controller: _emailCtrl,
                              hint: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            _buildMainButton(
                              text: 'Enviar Código',
                              onPressed: _requestPin,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_step == 2) ...[
                      _buildHeader(
                        Icons.mark_email_read_rounded,
                        'Verifica tu correo',
                        'Hemos enviado un código a $_email. Ingrésalo junto con tu nueva contraseña.',
                      ),
                      const SizedBox(height: 32),
                      _buildGlassContainer(
                        child: Column(
                          children: [
                            _CustomTextField(
                              controller: _codeCtrl,
                              hint: 'Código de 6 dígitos',
                              icon: Icons.pin_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _CustomTextField(
                              controller: _passCtrl,
                              hint: 'Nueva contraseña',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            _CustomTextField(
                              controller: _pass2Ctrl,
                              hint: 'Confirmar contraseña',
                              icon: Icons.lock_reset_rounded,
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            _buildMainButton(
                              text: 'Restablecer Contraseña',
                              onPressed: _confirmPin,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_step == 3) ...[
                      _buildHeader(
                        Icons.check_circle_outline_rounded,
                        '¡Todo listo!',
                        'Tu contraseña ha sido actualizada exitosamente.',
                        iconColor: Colors.greenAccent,
                      ),
                      const SizedBox(height: 40),
                      _buildMainButton(
                        text: 'Volver al Inicio',
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

  Widget _buildHeader(IconData icon, String title, String subtitle, {Color iconColor = Colors.blueAccent}) {
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
          style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
