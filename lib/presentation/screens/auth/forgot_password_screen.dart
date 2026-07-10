import 'package:flutter/material.dart';
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

  Future<void> _requestPin() async {
    final ok = await _authService.requestPasswordReset(_emailCtrl.text);
    if (ok) {
      setState(() { _email = _emailCtrl.text; _step = 2; });
    }
  }

  Future<void> _confirmPin() async {
    final ok = await _authService.confirmPasswordReset(
      email: _email, 
      code: _codeCtrl.text,
      password: _passCtrl.text, 
      password2: _pass2Ctrl.text,
    );
    if (ok) {
      setState(() => _step = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_step == 1) ...[
              const Icon(Icons.lock_reset, size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('Ingresa tu email para recibir un PIN de 6 dígitos'),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _requestPin, child: const Text('Enviar PIN'),
              )),
            ],
            if (_step == 2) ...[
              const Icon(Icons.pin, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Ingresa el PIN de 6 dígitos enviado a tu email'),
              const SizedBox(height: 16),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass2Ctrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _confirmPin, child: const Text('Restablecer'),
              )),
            ],
            if (_step == 3) ...[
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Contraseña restablecida exitosamente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
