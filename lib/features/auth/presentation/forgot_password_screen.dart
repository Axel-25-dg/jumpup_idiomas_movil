import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/core/auth/models/auth_models.dart';
import 'package:jumpup_app/core/auth/services/auth_service.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/core/theme/app_theme.dart';
import 'package:jumpup_app/core/utils/validators.dart';
import 'package:jumpup_app/features/auth/widgets/auth_header.dart';
import 'package:jumpup_app/features/auth/widgets/branded_text_field.dart';
import 'package:jumpup_app/features/auth/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String? _errorMessage;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPassword(
        ForgotPasswordRequest(email: _emailCtrl.text.trim()),
      );
      if (mounted)
        setState(() {
          _sent = true;
          _loading = false;
        });
    } on ApiException catch (e) {
      if (mounted)
        setState(() {
          _errorMessage = e.message;
          _loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _errorMessage = 'Error inesperado. Intente de nuevo.';
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: _sent
              ? _SuccessView(email: _emailCtrl.text)
              : _FormView(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  loading: _loading,
                  errorMessage: _errorMessage,
                  onSend: _sendReset,
                ),
        ),
      ),
    );
  }
}

// ── Vista del formulario ──────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSend,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const AuthHeader(
            title: 'Recuperar contraseña',
            subtitle:
                'Ingresa tu correo y te enviaremos las instrucciones para restablecer tu contraseña.',
          ),
          const SizedBox(height: 40),
          BrandedTextField(
            controller: emailCtrl,
            label: 'Correo electrónico',
            hint: 'usuario@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSend(),
            validator: Validators.email,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 24),
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            label: 'Enviar instrucciones',
            loading: loading,
            onPressed: onSend,
            icon: Icons.send_outlined,
          ),
        ],
      ),
    );
  }
}

// ── Vista de éxito tras enviar el correo ──────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 80),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¡Correo enviado!',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall
              .copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada en\n$email\ny sigue las instrucciones.',
          textAlign: TextAlign.center,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Volver al inicio de sesión'),
        ),
      ],
    );
  }
}
