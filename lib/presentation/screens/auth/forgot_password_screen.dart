import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/neon_button.dart';
import '../../../services/api_service.dart';
import 'confirm_pin_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _sendEmail() async {
    final email = _emailCtrl.text.trim();
    
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.requestPasswordReset(email);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Código enviado a tu correo!'), backgroundColor: AppTheme.celeste),
      );
      // Navegar a la pantalla de confirmación de PIN
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmPinScreen(email: email),
        ),
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
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
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                ? const CircularProgressIndicator(color: AppTheme.celeste)
                : NeonButton(
                    text: 'Enviar Instrucciones',
                    onPressed: _sendEmail,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
