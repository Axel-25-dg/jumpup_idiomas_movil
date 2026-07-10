import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String email;

  const ConfirmPinScreen({super.key, required this.email});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String get _fullPin => _pinControllers.map((c) => c.text).join();

  void _onPinChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _pinControllers[i].text = digits[i];
      }
      _focusNodes[5].unfocus();
      setState(() {});
    }
  }

  Future<void> _confirmReset() async {
    final pin = _fullPin;
    final newPassword = _newPasswordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (pin.length < 6) {
      _showSnack('Ingresa el código completo de 6 dígitos', AppColors.warning);
      return;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Completa los campos de contraseña', AppColors.warning);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack('Las contraseñas no coinciden', AppColors.error);
      return;
    }
    if (newPassword.length < 8) {
      _showSnack('La contraseña debe tener al menos 8 caracteres', AppColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DioClient.instance.dio.post('auth/password-reset-confirm/', data: {
        'email': widget.email,
        'code': pin,
        'password': newPassword,
      });

      if (!mounted) return;
      _showSnack('¡Contraseña actualizada!', AppColors.success);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      String msg = 'No se pudo restablecer la contraseña';
      if (e is DioException) {
        final body = e.response?.data;
        if (body is Map) {
          msg = body['detail']?.toString() ??
              body['non_field_errors']?.toString() ??
              msg;
        }
      }
      _showSnack(msg, AppColors.error);
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
    for (final c in _pinControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verificar Código',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Ícono
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Revisa tu correo',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Te enviamos un código de 6 dígitos a:\n${widget.email}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 36),

            // ── 6 cajas de PIN ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (i) => _PinBox(
                  controller: _pinControllers[i],
                  focusNode: _focusNodes[i],
                  index: i,
                  onChange: _onPinChanged,
                  onPaste: _handlePaste,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Nueva contraseña ──────────────────────────────────
            TextFormField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNew,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Nueva contraseña',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Confirmar contraseña',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.lock,
                    color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _confirmReset,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.shadow,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Cambiar Contraseña',
                        style: AppTextStyles.buttonText
                            .copyWith(color: Colors.white),
                      ),
              ),
            ),
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
  final int index;
  final Function(String, int) onChange;
  final Function(String) onPaste;

  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.onChange,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        cursorColor: AppColors.primary,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.0,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.divider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 2.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
        ),
        onChanged: (value) {
          if (value.length > 1) {
            onPaste(value);
            return;
          }
          onChange(value, index);
        },
      ),
    );
  }
}
