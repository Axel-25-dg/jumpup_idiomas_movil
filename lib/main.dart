import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asegúrate de crear el archivo .env en la raíz con tu API_BASE_URL
  await dotenv.load(fileName: '.env');
  runApp(
    const ProviderScope(
      child: JumpUpApp(),
    ),
  );
}

class JumpUpApp extends StatelessWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // Tema oscuro con acento dorado
      home: const VerificationScreen(),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'JumpUp UTE',
                      style: tt.displayMedium?.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ecosistema de Idiomas · Estructura del Docente',
                      style: tt.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _SectionCard(
                title: '✅ Arquitectura',
                items: const [
                  'Clean Architecture (data / domain / presentation)',
                  'Riverpod con ProviderScope',
                  'Variables de entorno (.env)',
                  'Material 3 con tema oscuro y acento dorado',
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: '📁 Módulos Auth',
                items: const [
                  'Splash Screen + JWT check',
                  'Login reactivo + Recordar sesión',
                  'Registro + validación de contraseñas',
                  'Recuperar contraseña',
                  'Onboarding selección de idiomas',
                  'Verificación 2FA OTP',
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: '🗂️ Modelos de Dominio',
                items: const [
                  'UserModel (Student / Teacher / Admin)',
                  'LanguageModel',
                  'CourseModel + ModuleModel + LessonModel',
                  'ExerciseModel (Quiz)',
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: tt.titleLarge),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: AppColors.accent, fontSize: 16)),
                    Expanded(
                      child: Text(item, style: tt.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
