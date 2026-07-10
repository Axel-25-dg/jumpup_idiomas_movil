import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/dark_theme.dart';
import 'package:jumpup_app/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  // Inicializar notificaciones
  await NotificationService().initialize();

  // Carga variables de entorno (.env bundled como asset)
  await dotenv.load(fileName: '.env');

  // Barra de estado transparente para que el Splash ocupe toda la pantalla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Orientación vertical únicamente (mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: JumpUpApp()));
}

class JumpUpApp extends ConsumerWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'JumpUp',
      debugShowCheckedModeBanner: false,

      // ── Tema Oscuro Premium ─────────────────────────────────────────
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Cambiado a dark para diseño PRO

      // ── go_router ────────────────────────────────────────────────────────
      routerConfig: buildAppRouter(ref),
    );
  }
}
