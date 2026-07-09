import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/neon_button.dart';
import '../../../services/api_service.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String email; // Email que viene de ForgotPasswordScreen

  const ConfirmPinScreen({super.key, required this.email});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  final _pin3 = TextEditingController();
  final _pin4 = TextEditingController();
  final _pin5 = TextEditingController();
  final _pin6 = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String get _fullPin =>
      '${_pin1.text}${_pin2.text}${_pin3.text}${_pin4.text}${_pin5.text}${_pin6.text}';

  // Mueve el foco al siguiente campo automáticamente
  void _onPinChanged(String value, FocusNode current, FocusNode? next) {
    if (value.length == 1 && next != null) {
      next.requestFocus();
    }
  }

  Future<void> _confirmReset() async {
    final pin = _fullPin;
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (pin.length < 6) {
      _showSnack('Ingresa el código completo de 6 dígitos', Colors.orange);
      return;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Completa los campos de contraseña', Colors.orange);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack('Las contraseñas no coinciden', Colors.red);
      return;
    }
    if (newPassword.length < 8) {
      _showSnack('La contraseña debe tener al menos 8 caracteres', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.confirmPasswordReset(
        email: widget.email,
        pin: pin,
        newPassword: newPassword,
      );

      if (!mounted) return;
      _showSnack('¡Contraseña actualizada con éxito!', AppTheme.celeste);

      // Regresar al Login
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    _pin3.dispose();
    _pin4.dispose();
    _pin5.dispose();
    _pin6.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focus1 = FocusNode();
    final focus2 = FocusNode();
    final focus3 = FocusNode();
    final focus4 = FocusNode();
    final focus5 = FocusNode();
    final focus6 = FocusNode();

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Verificar Código')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Ícono y título
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.celeste.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read, size: 44, color: AppTheme.celeste),
            ),
            const SizedBox(height: 20),
            const Text(
              'Revisa tu correo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro),
            ),
            const SizedBox(height: 8),
            Text(
              'Te enviamos un código de 6 dígitos a:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textoClaro, height: 1.5),
            ),

            const SizedBox(height: 36),

            // ── Cajas de PIN ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PinBox(controller: _pin1, focusNode: focus1, nextFocus: focus2, onChange: _onPinChanged),
                _PinBox(controller: _pin2, focusNode: focus2, nextFocus: focus3, onChange: _onPinChanged),
                _PinBox(controller: _pin3, focusNode: focus3, nextFocus: focus4, onChange: _onPinChanged),
                _PinBox(controller: _pin4, focusNode: focus4, nextFocus: focus5, onChange: _onPinChanged),
                _PinBox(controller: _pin5, focusNode: focus5, nextFocus: focus6, onChange: _onPinChanged),
                _PinBox(controller: _pin6, focusNode: focus6, nextFocus: null, onChange: _onPinChanged),
              ],
            ),

            const SizedBox(height: 36),

            // ── Nueva contraseña ──────────────────────────────────────
            GlassContainer(
              child: Column(
                children: [
                  TextField(
                    controller: _newPasswordCtrl,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.celeste),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: AppTheme.textoClaro),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock, color: AppTheme.celeste),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppTheme.textoClaro),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Botón de confirmación ────────────────────────────────
            _isLoading
                ? const CircularProgressIndicator(color: AppTheme.celeste)
                : NeonButton(
                    text: 'Cambiar Contraseña',
                    onPressed: _confirmReset,
                  ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Widget auxiliar: caja individual de PIN ──────────────────────────────────
class _PinBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final Function(String, FocusNode, FocusNode?) onChange;

  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.nextFocus,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.celeste, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.celeste, width: 2.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onChanged: (value) => onChange(value, focusNode, nextFocus),
      ),
    );
  }
}
